# Generic UAM Simulation - NASA TTT-Autonomous Systems(AS): Intelligent Contingency Management (ICM) 
## Point of Contact:
**Michael J. Acheson**  
NASA Langley Research Center (LaRC)  
Dynamics Systems and Control Branch (D-316)  
email: michael.j.acheson@nasa.gov  

## Versions
**Version 1.1, 10.11.2023, MJA:**

- Incorporates expanded polynomial aero-propulsive database, trim tables, and gain scheduled baseline controller.
- Includes trim scripts (see `./vehicles/Lift+Cruise/Trim/trim_helix.x`) and linearization scripts (see `./vehicles/Lift+Cruise/Control/ctrl_scheduler_GUAM.m`).
- Includes piece-wise Bezier RefInput reference trajectory capability, and a simulation output animation script (`./utilities/Animate_SimOut.m`).
- Enables a user-defined output script that allows users to specify output variables (e.g., `./vehicles/Lift+Cruise/setup/User_SimOut/mySimOutFunc_Animate.m`).

## How to Run
### Simulation Example
To run a simulation example case, execute the `RUNME.m` script at the top level!

## About the Simulation

This simulation is a generic UAM simulation. It includes a generic transition aircraft model representative of a NASA Lift+Cruise vehicle configuration.

Some of the key simulation components include:

1. A simulation architecture (e.g., signal buses) that supports the most common rigid body 6-DOF frames of reference (e.g., Earth Centered Inertial, Earth Centered Earth Fixed (ECEF), North-East-Down (NED), Navigation, Velocity, Wind, Stability, and Body)
2. A simulation architecture that contains most aerospace signals/quantities of typical interest
3. A generic architecture that readily supports swapping in and out aircraft models, sensors, actuator models, control algorithms, etc.
4. A wide array of desired trajectory or RefInputs (e.g., ramps, timeseries, piece-wise Bezier curves, and doublets)
5. A nominal gain scheduled (LQRi) baseline, unified controller (same commands across three flight phases). The baseline controller operates in the heading frame (i.e., the NED frame rotated by the heading angle)

Demonstration trajectory flights are found in the `Exec_Scripts` folder. Demo cases include:

1. A simple sinusoidal input case (`./Exec_Scripts/exam_TS_Sinusoidal_traj.m`)
2. A basic lifting hover and transition to forward flight (`./Exec_Scripts/exam_TS_Hover2Cruise_traj.m`)
3. A cruise climbing right hand turn (`./Exec_Scripts/exam_TS_Cruise_Climb_Turn_traj.m`)
4. A takeoff, climbing transition to cruise and descending deceleration to landing using ramps
5. Two examples of piece-wise Bezier curve trajectories:
    - Cruise descent and deceleration
    - Hover climb and acceleration

These demonstration trajectories can be performed by executing `./RUNME.m` at the top level folder. Alternatively, these examples can be accessed by adding the `./Exec_Scripts` folder to the MATLAB path and running the associated execution example script (e.g., "exam_TS_Cruise_Climb_Turn_traj.m" or "exam_TS_Hover2Cruise_traj.m" m-file). Once the "GUAM" Simulink model opens, run the model. Output data is provided by the MATLAB logged signal `logsout{1}`. Many analysis scripts make use of the output data assigned to a `SimOut` structure: `>>SimOut = logsout{1}.Values;`.

Simulation input (fixed) parameters are provided in a large structure `SimIn`, whereas desired tunable simulation parameters are provided using the large structure: `SimPar`. The structure `SimIn`, `SimPar`, and `SimOut` therefore contain the (fixed) simulation inputs, the (variable) simulation inputs, and the simulation outputs respectively. Some basic results plotting can be performed by running the m-file: `./vehicles/Lift+Cruise/Utils/simPlots_GUAM.m`. Simulation results animation (e.g., creation of a .avi file or similar) is available by use of the script: `./utilities/Animate_SimOut.m`.

### Personalization
While demonstration scripts are provided, users can customize various subsystems through the `userStruct` structure and `simSetup.m` script. `userStruct` allows setting different subsystem variants and switches to tailor simulations to specific needs. Key configuration options include actuator type, atmosphere model, trajectory input, and more.

For example, a typical `userStruct` setup might look like this:
```matlab
userStruct.variants:
    refInputType: Timeseries
    vehicleType: LiftPlusCruise
    expType: DEFAULT
    atmosType: US_STD_ATMOS_76
    turbType: None
    ctrlType: BASELINE
    actType: FirstOrder
    propType: None
    fmType: Polynomial
    eomType: Simple
    sensorType: None
```
For detailed instructions on setting each option, reference input types, customizing the aero-propulsive model, and other aspects, please see the [Personalization Guide]().

### Simulation Trimming
The (**offline**) trim routines are found in the `./vehicles/Lift+Cruise/Trim` folder. The top-level trim routine is: `trim_helix.m`. This script was used to trim the overactuated Lift+Cruise vehicle using the polynomial aero-propulsive database. NOTE: the routine could also be used for trimming with the strip theory S-function aero-propulsive model, but the code has not been modified to switch between the models (likely not functional using the S-function model). In the top-level `trim_helix.m` script, the user specifies a range of forward and vertical velocities (could also provide a turn radius). Next, the user provides some quantities needed for the quadratic cost function/optimization (e.g., initial guess, offset, scaling, and free variables). The quadratic cost function used by `fmincon` is: `mycost.m`, and the non-linear constraints function is `nlinCon_helix.m`. The results of the trim table schedule are then saved in a `.mat` file.

### Baseline Controller Gain Scheduling
The gain scheduling m-files are contained in the `./vehicles/Lift+Cruise/control/` folder. The top-level script for gain scheduling the baseline controller (LSQi) is `ctrl_scheduler_GUAM.m`. This script schedules the Longitudinal and Lateral axes separately. A few linearization scripts are available but the main script is `get_lin_dynamics_heading.m`. This script linearizes around a designated flight condition, and other scripts (e.g., `get_lat_dynamics_heading.m` and `ctrl_lat.m`) segregate the linearized dynamics according to desired axes.
