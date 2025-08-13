# Generic UAM Simulation - NASA TTT-Autonomous Systems(AS): Intelligent Contingency Management (ICM)
A MATLAB/Simulink framework that models a NASA Lift + Cruise VTOL.

## Quick Start
```matlab
% From repository root:
>> main           % launches default config params & opens GUAM model
```
Simulation output is logged to `logsout{1}` and can be mapped to a structure:
```matlab
>> SimOut = logsout{1}.Values;
```

## About the Simulation

This simulation is a generic UAM simulation. It includes a generic transition aircraft model representative of a NASA Lift+Cruise vehicle configuration.

Some of the key simulation components include:

1. A simulation architecture (e.g., signal buses) that supports the most common rigid body 6-DOF frames of reference (e.g., Earth Centered Inertial, Earth Centered Earth Fixed (ECEF), North-East-Down (NED), Navigation, Velocity, Wind, Stability, and Body)
2. A simulation architecture that contains most aerospace signals/quantities of typical interest
3. A generic architecture that readily supports swapping in and out aircraft models, sensors, actuator models, control algorithms, etc.
4. A Incremental Nonlinear Dynamic Inversion (INDI) controller

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
For detailed instructions on setting each option, reference input types, customizing the aero-propulsive model, and other aspects, please see the [Personalization Guide](Documentation/Personalize.md).

### Simulation Trimming
The (**offline**) trim routines are found in the `./vehicles/Lift+Cruise/Trim` folder. The top-level trim routine is: `trim_helix.m`. This script was used to trim the overactuated Lift+Cruise vehicle using the polynomial aero-propulsive database. NOTE: the routine could also be used for trimming with the strip theory S-function aero-propulsive model, but the code has not been modified to switch between the models (likely not functional using the S-function model). In the top-level `trim_helix.m` script, the user specifies a range of forward and vertical velocities (could also provide a turn radius). Next, the user provides some quantities needed for the quadratic cost function/optimization (e.g., initial guess, offset, scaling, and free variables). The quadratic cost function used by `fmincon` is: `mycost.m`, and the non-linear constraints function is `nlinCon_helix.m`. The results of the trim table schedule are then saved in a `.mat` file.

### Controller Architecture
The controller implemented in this simulation is based on the Incremental Nonlinear Dynamic Inversion (INDI) framework as described in [AIAA 2025-3489](https://arc.aiaa.org/doi/10.2514/6.2025-3489). The implementation follows the control architecture originally proposed by **Thomas Lombaerts et al.** in [AIAA 2020-1619](https://arc.aiaa.org/doi/10.2514/6.2020-1619), which was developed for unified, full-envelope flight control of eVTOL vehicles.

### Failure Configuration
Inject surface jams, engine cut-outs, sensor biases and more using the failure API described in [Failures Documentation](Documentation/Failures.md).

## Further Reading

| Area                       | Markdown                                                         |
| -------------------------- | ---------------------------------------------------------------- |
| Personalisation guide      | [Documentation/Personalize.md](Documentation/Personalize.md)     |
| Failure-injection API      | [Documentation/Failures.md](Documentation/Failures.md)           |
| Linearisation process      | [Documentation/Linearization.md](Documentation/Linearization.md) |
| S-Function build           | [Documentation/SFunction.md](Documentation/SFunction.md)         |
| Vehicle scaling            | [Documentation/Scaling.md](Documentation/Scaling.md)             |
| Trim file creation         | [Documentation/Trim.md](Documentation/Trim.md)                   |
| Frames & symbols           | [Documentation/RefFrames.md](Documentation/RefFrames.md)         |

