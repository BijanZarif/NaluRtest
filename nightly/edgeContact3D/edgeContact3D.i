Simulations:
  - name: sim1
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: sgs 
    tolerance: 1e-5
    max_iterations: 50
    kspace: 50
    output_level: 0

  - name: solve_cont
    type: tpetra
    method: gmres 
    preconditioner: muelu 
    tolerance: 1e-5
    max_iterations: 50
    kspace: 50
    output_level: 0
    muelu_xml_file_name: muelu_sliding.xml

realms:

  - name: realm_1
    mesh: rot_cyl_14.exo
    use_edges: yes
    provide_entity_count: yes 
    check_for_missing_bcs: no

    time_step_control:
     target_courant: 5.0
     time_step_change_factor: 1.2
   
    equation_systems:
      name: theEqSys
      max_iterations: 2 
  
      solver_system_specification:
        pressure: solve_cont
        velocity: solve_scalar
   
      systems:
        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-5

    initial_conditions:
      - constant: ic_1
        target_name: [block_1, block_2, block_3, block_4, block_5, block_6, block_7, block_8, block_9, block_10, block_11, block_12, block_13, block_14, block_15, block_16, block_17, block_18, block_19]
        value:
          pressure: 0.0
          velocity: [100.0,0.0,0.0]

    material_properties:
      target_name: [block_1, block_2, block_3, block_4, block_5, block_6, block_7, block_8, block_9, block_10, block_11, block_12, block_13, block_14, block_15, block_16, block_17, block_18, block_19]
      specifications:
        - name: density
          type: constant
          value: 1.0e-3

        - name: viscosity
          type: constant
          value: 1.8e-4

    solution_options:
      name: myOptions
      turbulence_model: laminar

      mesh_motion:
        - name: mmOne
          target_name: [block_1, block_2, block_3, block_4, block_5, block_6, block_7, block_8]
          omega: 5.0

        - name: mmTwo
          target_name: [block_9, block_10, block_11, block_12, block_13, block_14, block_15, block_16, block_17, block_18, block_19]
          omega: 0.0

      options:
        - hybrid_factor:
            velocity: 0.5

        - alpha_upw:
            velocity: 1.0

        - limiter:
            pressure: no
            velocity: yes 

        - projected_nodal_gradient:
            pressure: element
            velocity: element 
 
        - noc_correction:
            pressure: yes 

    boundary_conditions:

    - inflow_boundary_condition: bc_1
      target_name: A_Inflow
      inflow_user_data:
        velocity: [100.0,0.0,0.0]

    - open_boundary_condition: bc_2
      target_name: B_Outflow
      open_user_data:
        pressure: 0.0
        velocity: [0.0,0.0,0.0]

    - wall_boundary_condition: bc_3
      target_name: C_Cylinder
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_parameters:
         velocity: [5.0]

    - symmetry_boundary_condition: bc_4
      target_name: D_TopBott
      symmetry_user_data:

    - symmetry_boundary_condition: bc_5
      target_name: E_Sides
      symmetry_user_data:

    - contact_boundary_condition: bc_Outer
      target_name: G_outer
      contact_user_data:
        max_search_radius: 12.0
        min_search_radius: 1.0
        search_block: [block_2, block_3, block_4, block_5, block_8]
        extrusion_distance: 0.20
        expand_box_percentage: 5.0 
        clip_isoparametric_coordinates: no 

    - contact_boundary_condition: bc_Inner
      target_name: F_inner
      contact_user_data:
        max_search_radius: 10.0
        min_search_radius: 1.0
        search_block: [block_9, block_10, block_11, block_12, block_13, block_14, block_15, block_16, block_17]
        extrusion_distance: 0.20
        expand_box_percentage: 5.0 
        clip_isoparametric_coordinates: no 
    output:
      output_data_base_name: output.e
      output_frequency: 2 
      output_node_set: no 
      output_variables:
       - dual_nodal_volume
       - velocity
       - pressure
       - mesh_displacement
       - dpdx

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      termination_time: 20.0e-3 
      time_step: 2.0e-3
      time_stepping_type: fixed
      time_step_count: 0
      second_order_accuracy: no

      realms:
        - realm_1
