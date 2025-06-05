
# VTOL Simulation Failure Configurations and Parameter Documentation

This document describes the failure types used in the VTOL simulation and explains how the failure parameters are applied to compute the actual actuator (control surface and propeller) positions and rates. The failure signals are computed every iteration in the simulation based on the user-configured parameters in `SimPar.Value.Fail`.

## Overview

In the simulation, failures are implemented by modifying the actuator signals using several parameters. These parameters affect how the controller commands are scaled, biased, or saturated, and they allow simulation of realistic actuator failures (e.g., a stalled actuator or degraded response). The parameters are defined and configured in the `SimPar.Value.Fail` structure and are used every timestep to compute the following signals:

| **Parameter**                       | **Description**                                                                                                                                                                                                                                                                                                 |
|-------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **F_Fail_Initiate**                 | A vector computed by multiplying the failure type (set with `FailInit`) by an indicator based on the time window defined by `InitTime` and `StopTime`. It activates the failure when the simulation time falls within the specified period.                                                         |
| **F_Hold_Last**                     | A flag that determines whether the actuator should hold its previous position (`1`) or update to a new value computed at the current timestamp (`0`). This parameter is used to "freeze" the actuator state in a Hold-Last failure scenario.                                                          |
| **F_Pre_Scale**                     | A scaling factor that multiplies the controller command **before** the actuator dynamics are evaluated. It simulates reduced (or increased) command effectiveness entering the actuator system during a Pre-scale failure.                                                                              |
| **F_Post_Scale**                    | A scaling factor applied **after** the actuator dynamics have been computed, modifying the final actuator output to simulate post-dynamic degradation (as seen in Post-scale failures).                                                                                                                   |
| **F_Pos_Bias**                      | An additive offset applied to the computed actuator position to simulate systematic bias or error in the actuator response due to the failure.                                                                                                                                                                |
| **F_Pos_Scale**                     | A scaling factor applied to the actuator position after adding the bias, altering the final position magnitude to reflect the impact of the failure.                                                                                                                                                          |
| **F_Up_Plim** and **F_Lwr_Plim**      | **F_Up_Plim:** Upper saturation limit of the actuator position. <br> **F_Lwr_Plim:** Lower saturation limit of the actuator position. Together, they ensure the actuator’s output remains within physically allowable bounds even under failure conditions.                                          |
| **F_Rate_Bias**                     | An offset applied to the time derivative (rate) of the actuator position, representing errors in the actuator response speed due to the failure.                                                                                                                                                             |
| **F_Rate_Scale**                    | A scaling factor applied to the actuator rate after adding the bias, adjusting the effective rate to simulate degradation due to failure.                                                                                                                                                                    |
| **F_Up_Rlim** and **F_Lwr_Rlim**      | **F_Up_Rlim:** Upper saturation limit of the actuator rate. <br> **F_Lwr_Rlim:** Lower saturation limit of the actuator rate. These parameters cap the rate at which the actuator can change, ensuring realistic dynamics even when a failure is present.                                         |

## Actuator Allocation and Failure Type Mapping

The simulation uses a specific mapping for assigning failures to both aerodynamic surfaces and propellers. The following diagrams and descriptions show the allocation and available failure types:

### Aerodynamic Surfaces

**Surface Allocation Diagram:**

```
                         / \
                         | |  
                ,-------------------,
                '-1---------------2-'
                         | |  
                         | |
                      ,---|---,
                      '3--|--4'
                         5 
```

**Failure Types for Surfaces:**  
1. Hold Last  
2. Pre-Scale  
3. Post-Scale  
4. Position Limits  
5. Rate Limits  
6. Generic  
7. Runaway (currently inactive)  
8. Control Reversal  

### Propellers

**Propeller Allocation Diagram:**

```
                         / \
                 (1) (2) | | (3) (4)
                ,-------------------,
                '-------------------'
                 (5) (6) | | (7) (8)
                         | |
                      ,-------,
                      '-------'
                         (9)
```

**Failure Types for Propellers:**  
1. Hold Last  
2. Pre-Scale  
3. Post-Scale  
4. Position Limits  
5. Rate Limits  
6. Generic  
7. Runaway (currently inactive)  
8. Control Reversal

## Example Configurations

> [!TIP]
> For additional details on the mapping and the set-up, please refer to the comments in the `Challenge_Problems/Generate_Failures.m` script.

### Aerodynamic Surface Failure Example

Below is an example configuration for an aerodynamic surface experiencing a *Pre-Scale* failure.

```matlab
% Aerodynamic Surface Failure (Pre-Scale)
SimPar.Value.Fail.Surfaces.FailInit   = [2; 0; 0; 0; 0];       % '2' indicates a Pre-scale failure on surface 1.
SimPar.Value.Fail.Surfaces.InitTime   = [15; 0; 0; 0; 0];      % Failure begins at t = 15 seconds.
SimPar.Value.Fail.Surfaces.StopTime   = [inf; 0; 0; 0; 0];     % Failure remains active indefinitely.
SimPar.Value.Fail.Surfaces.PreScale   = [0.7; 0; 0; 0; 0];       % Scale controller command to 70% for surface 1.
```

### Propeller Failure Example

The following example sets up a *Post-Scale* failure for a propeller.

```matlab
% Propeller Failure (Post-Scale)
SimPar.Value.Fail.Props.FailInit   = [0; 3; 0; 0; 0; 0; 0; 0; 0];  % '3' for a Post-scale failure on propeller 2.
SimPar.Value.Fail.Props.InitTime   = [0; 20; 0; 0; 0; 0; 0; 0; 0];  % Failure begins at t = 20 seconds.
SimPar.Value.Fail.Props.StopTime   = [0; inf; 0; 0; 0; 0; 0; 0; 0]; % Failure remains active indefinitely.
SimPar.Value.Fail.Props.PostScale  = [0; 0.8; 0; 0; 0; 0; 0; 0; 0];   % Scale actuator output to 80% for propeller 2.
```

## Using Randomized Failure Parameters

The file `Challenge_Problems/Generate_Failures.m` contains examples of how to generate random failure parameters. This script creates a MAT-file (e.g., `Data_Set_4.mat`) that includes arrays defining failure types, activation times, scaling factors, and other parameters.
  
To integrate the examples provided in **Challenge_Problems**, you can use an approach similar to what is shown in the **Challenge_Problems/RUNME.m** file. Here is an example snippet:

```matlab
% Load the failure scenario data set
fail_obj = matfile('./Challenge_Problems/Data_Set_4.mat');
fail_run_num = 3;  % Choose the desired failure scenario index

% Configure failure parameters for the simulation
SimPar.Value.Fail.Surfaces.FailInit  = fail_obj.Surf_FailInit_Array(:, fail_run_num);
SimPar.Value.Fail.Surfaces.InitTime  = fail_obj.Surf_InitTime_Array(:, fail_run_num);
SimPar.Value.Fail.Surfaces.StopTime  = fail_obj.Surf_StopTime_Array(:, fail_run_num);
SimPar.Value.Fail.Surfaces.PreScale  = fail_obj.Surf_PreScale_Array(:, fail_run_num);
SimPar.Value.Fail.Surfaces.PostScale = fail_obj.Surf_PostScale_Array(:, fail_run_num);

SimPar.Value.Fail.Props.FailInit     = fail_obj.Prop_FailInit_Array(:, fail_run_num);
SimPar.Value.Fail.Props.InitTime     = fail_obj.Prop_InitTime_Array(:, fail_run_num);
SimPar.Value.Fail.Props.StopTime     = fail_obj.Prop_StopTime_Array(:, fail_run_num);
SimPar.Value.Fail.Props.PreScale     = fail_obj.Prop_PreScale_Array(:, fail_run_num);
SimPar.Value.Fail.Props.PostScale    = fail_obj.Prop_PostScale_Array(:, fail_run_num);
```

