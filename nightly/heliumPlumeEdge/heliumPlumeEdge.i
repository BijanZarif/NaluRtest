Simulations:
  - name: sim1
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_mom
    type: tpetra
    method: gmres
    preconditioner: sgs
    tolerance: 1e-5
    max_iterations: 50
    kspace: 50
    output_level: 0

  - name: solve_cont
    type: epetra
    method: gmres
    preconditioner: ML 
    tolerance: 1e-5
    max_iterations: 75
    kspace: 75
    output_level: 0
    recompute_preconditioner: false
    ML_options_int:
      - name: "coarse: max size"
        value: 1000
      - name: "repartition: enable"
        value: 1
      - name: "repartition: min per proc"
        value: 1000
      - name: "max levels"
        value: 10
      - name: "repartition: Zoltan dimensions"
        value: 3
      - name: "smoother: sweeps"
        value: 2
      - name: "eigen-analysis: iterations"
        value: 15
      - name: "ML output"
        value: 0 
      - name: "output"
        value: 0 
      - name: "repartition: start level"
        value: 2
    ML_options_real:
      - name: "repartition: max min ratio"
        value: 1.327
      - name: "aggregation: damping factor"
        value: 1.33333333
      - name: "aggregation: threshold"
        value: 0.02
    ML_options_string:
      - name: "aggregation: type"
        value: "Uncoupled"
      - name: "repartition: partitioner"
        value: "Zoltan"
      - name: "smoother: type"
        value: "Chebyshev"
      - name: "smoother: pre or post"
        value: "both"
      - name: "eigen-analysis: type"
        value: "power-method"

  - name: solve_other
    type: tpetra
    method: gmres
    preconditioner: sgs
    tolerance: 1e-5
    max_iterations: 50
    kspace: 50
    output_level: 0

realms:

  - name: realm_1
    mesh:  100cm_13K_S_R1.g
    use_edges: yes 

    equation_systems:
      name: theEqSys
      max_iterations: 4    

      solver_system_specification:
        velocity: solve_mom
        turbulent_ke: solve_other
        mixture_fraction: solve_other
        pressure: solve_cont

      systems:
        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-2

        - TurbKineticEnergy:
            name: myTke
            max_iterations: 1
            convergence_tolerance: 1.e-2

        - MixtureFraction:
            name: myZ
            max_iterations: 1
            convergence_tolerance: 1.e-2

    initial_conditions:
      - constant: ic_1
        target_name: block_1
        value:
          pressure: 0
          velocity: [0,0,0]
          turbulent_ke: 0.0
          mixture_fraction: 0.0

    material_properties:
      target_name: block_1

      specifications:

        - name: density
          type: mixture_fraction
          primary_value: 0.163e-3
          secondary_value: 1.18e-3

        - name: viscosity
          type: mixture_fraction
          primary_value: 1.967e-4
          secondary_value: 1.85e-4

    boundary_conditions:

    - inflow_boundary_condition: bc_inflow
      target_name: surface_1
      inflow_user_data:
        velocity: [0.0,34.0,0.0]
        turbulent_ke: 0.17
        mixture_fraction: 1.0

    - wall_boundary_condition: bc_bottom
      target_name: surface_2
      wall_user_data:
        velocity: [0,0,0]
        turbulent_ke: 0.0

    - open_boundary_condition: bc_side
      target_name: surface_3
      open_user_data:
        velocity: [0,0,0]
        pressure: 0.0
        turbulent_ke: 1.0e-16
        mixture_fraction: 0.0

    - open_boundary_condition: bc_top
      target_name: surface_4
      open_user_data:
        velocity: [0,0,0]
        pressure: 0.0
        turbulent_ke: 1.0e-16
        mixture_fraction: 0.0

    solution_options:
      name: myOptions
      turbulence_model: ksgs

      divU_stress_scaling: 1.0

      options:
        - hybrid_factor:
            velocity: 0.0
            turbulent_ke: 1.0
            mixture_fraction: 1.0

        - alpha_upw:
            velocity: 1.0
            turbulent_ke: 1.0
            mixture_fraction: 1.0

        - laminar_schmidt:
            turbulent_ke: 1.0
            mixture_fraction: 0.9

        - turbulent_schmidt:
            turbulent_ke: 1.0
            mixture_fraction: 1.0

        - source_terms:
            momentum: buoyancy
#            continuity: density_time_derivative

        - user_constants:
            gravity: [0.0,-981.0,0.0]
            reference_density: 1.18e-3

    turbulence_averaging:
      time_filter_interval: 10.0
      reynolds_averaged_variables:
       - mixture_fraction
      favre_averaged_variables:
       - mixture_fraction

    output:
      serialized_io_group_size: 2
      output_data_base_name: heliumPlumeEdge.e
      output_frequency: 2
      output_node_set: no
      output_variables:
       - velocity
       - pressure
       - turbulent_ke
       - mixture_fraction
       - density
       - mixture_fraction_fa
       - mixture_fraction_ra

    restart:
      restart_data_base_name: heliumPlumeEdge.rst
      restart_frequency: 2 

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      termination_time: 0.20
      time_step: 1.0e-3
      time_stepping_type: adaptive
      time_step_count: 0
      second_order_accuracy: yes

      realms:
        - realm_1
