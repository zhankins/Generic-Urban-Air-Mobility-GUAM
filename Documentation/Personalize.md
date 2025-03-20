# How to personalize the GUAM Model
You can create a script with the following structure:
```matlab
%% sim parameters
model = 'GUAM';

%% 'userStruct' definition

%% Trajectory and basic flight manuevers definition

%% Prepare to run simulation
% set initial conditions and add trajectory to SimInput
simSetup;
open(model);
```
## 'userStruct' Customization
The simulation makes use of an input structure: "userStruct" to change the variants of various subsystems that are used, and to specify various "switches". If a user does not provide specific selections for `userStruct.variants` or `userStruct.switches`, default values will be applied.

> [!TIP]
> If a field is not specified, a default enumeration value is assigned.  If a '-1' value is assigned to the field, that will cause the menu selection function to be invoked for that particular 'type' in `setupTypes.m`

### Variants
The following options allow you to customize specific model characteristics:
```matlab
struct with fields:
 
     vehicleType: 1
         expType: DEFAULT
       atmosType: US_STD_ATMOS_76
        turbType: None
        ctrlType: BASELINE
    refInputType: EUTL_TRAJ
         actType: FirstOrder
        propType: None
          fmType: SFunction
         eomType: STARS
      sensorType: None
```
To select a variant, you can write a script or use the MATLAB command line:
```matlab
userStruct.variants.fmType = 1; % 1=SFunction, 2=Polynomial
simSetup
```


#### Actuator Type Variants (actType)
Variants of the Control Surface Dynamics Block in the Surface and Engine Actuator Dynamics
- `None`:1
- `FirstOrder`:2
- `SecondOrder`:3
- `FirstOrderFailSurf`:4

#### Atmosphere type Variants (atmosType)
The only variant is the U.S. Standard Atmosphere, 1976, which is an idealized, steady-state representation of the earth's atmosphere from the surface to 1000 km. [Get more info](https://ntrs.nasa.gov/citations/19770009539).
| Option  | Value |
| :---: | :---: |
| US_STD_ATMOS_76 | 1 |

#### Equations of Motion Variants (eomType)
Controls the Equations of Motion Block in the Vehicle Model:
- `STARS`:1
- `Simple`:2

#### Experiment type Variants (expType)
(Currently not implemented)
- `DEFAULT`:1
- `ATMX_TURB`:2
- `BENCHMARK`:3
- `FULL_SIMOUT`:4

#### Aero/Propulsion Force/Moment model Variants (fmType)
Controls the Propulsion and Aerodynamic Forces and Moments Block.
| Option  | Value | Description | Default |
| :-------------: | :-------------: | :------------- | :-------------: |
| SFunction  | 1  | A strip-theory model allowing user-built configurations. [Get more info](https://doi.org/10.2514/6.2021-1720) | |
| Polynomial | 2  | A CFD-derived model with limited range, faster execution. [Get more info](https://doi.org/10.2514/6.2021-3170) | ✔️|

#### Propulsion type Variants (propType)
Variants of the Propulsion Dynamics Block in the Surface and Engine Actuator Dynamics
- `None`:1
- `FirstOrder`:2
- `SecondOrder`:3
- `FirstOrderFailProp`:4
#### Sensor type Variants (sensorType)
Variants of the Sensors Block in the Vehicle Model
- `None`:1
- `ZOH`:2

#### Turbulence type Variants (turbType)
Levels of turbulence intensity. If value different from None the Ubody, Vbody, Wbody turbulence will be increased based on the selected intensity.
| Option  | Value | Default |
| :-------------: | :-------------: | :-------------: |
| None | 1 | ✔️ |
| Light | 2 |  |
| Moderate | 3 |  |
| Severe | 4 |  |

#### Vehicle type Variants (vehicleType)
Variants of the GenCtrl Inputs Block
| Option  | Value | Description | Default | Implemented |
| :-------------: | :-------------: | :------------- | :-------------: | :-------------: |
| LiftPlusCruise | 1 | Lift+Cruise VTOL aircraft conceptual configurations. [Get more info](https://arc.aiaa.org/doi/10.2514/6.2018-3847) | ✔️ | Yes |
| Quad6 | 2 | Six-passenger quadrotor |  | No |
| GenTiltRotor | 3 | Generic Tilt Rotor |  | No |
| GenTiltWing | 4 | Generic Tilt Wing |  | No |
| GL10 | 5 | Greased Lightning (GL-10) is an aircraft configuration that combines the characteristics of a cruise efficient airplane with the ability to perform vertical takeoff and landing (VTOL). [Get more info](https://ntrs.nasa.gov/citations/20170007194) |  | No |
| LA8 | 6 | The Langley Aerodrome No. 8 (LA-8) is a distributed electric propulsion, vertical takeoff and landing (VTOL) aircraft. [Get more info](https://ntrs.nasa.gov/citations/20205011023) |  | No |
| OTHER | 7 |  |  |  |

#### Controller type Variants (ctrlType)
Variants of the Controller Block in the Vehicle Generalized Control
| Option  | Value | Description | Default | Implemented |
| :-------------: | :-------------: | :------------- | :-------------: | :-------------: |
| TRIM | 1 |  |  | No |
| BASELINE | 2 |  | ✔️ | Yes |
| BASELINE_L1 | 3 | L1 Adaptive Control. [Get more info](https://ntrs.nasa.gov/citations/20220017506) |  | No |
| BASELINE_AGI | 4 | Control allocation uses an expanded Affine Generalized Inverse (AGI) algorithm. [Get more info](https://ntrs.nasa.gov/citations/20205010869) |  | No |

#### Reference input type Variants (refInputType)
Variants of the Reference Inputs Block in the GenCtrl Inputs
| Option  | Value | Description | Default |
| :-------------: | :-------------: | :------------- | :-------------: |
| FOUR_RAMP   | 1 | Simulink ramp blocks are used to build a simple trajectory. The user makes use of an input structure "target" to provide some basic trim configuration information and then provides timing and magnitude for the ramps blocks using the SimPar structure |  |
| ONE_RAMP    | 2 |  |  |
| TIMESERIES  | 3 | Allows users to define the trajectory using a series of time-stamped points. |  |
| BEZIER      | 4 | Piece-wise Bezier curve desired trajectory. Can be a user provided PW Bezier trajectory file or a "target" structure input the contains the PW Bezier information |  |
| DEFAULT(doublets) | 5 |  | ✔️ |


### Switches
Switches modify specific simulation behaviors. If no selections are provided, the default choices are applied. To set a switch option, use a script or the MATLAB command line:
```matlab
userStruct.switches.FeedbackCurrent = 1; % 1 or 0
simSetup
```
If a user doesn't provide userStruct.variant selections, then the default choices are set. 
| Switch  | Default Value | Description |
| :---: | :---: | :--- |
| WindShearOn | 0 | Enables wind shear effects |
| SensorNoiseOn | 0 | Switch on sensor noise when sensor type variant set to ZOH (2) |
| TrimModeOn | 0 | Switch on/off InputModification for Trimming in Surface and Engine Actuator Dynamics|
| LinearizeModeOn | 0 | Enables system linearization mode |
| RefTrajOn | 0 | Switch on forces switches FeedbackCurrent and PositionError |
| FeedbackCurrent | 1 | Turns on/off table lookup (controller gains etc.) for current velocities |
| PositionError | 0 | Turns on/off position/heading error feedback in generalized controller |
| TurbulenceOn | 0 | std Ubody, Vbody, Wbody turbulence |
| RotationalGustsOn | 0 | Pbody, Qbody, Rbody rotational turbulence |
| WindsOn | 0 | Steady Winds, Wind shear, etc.. |
| AeroPropDeriv | 0 | |
| TrajAbeamPos | 0 | |

## 'SFunction' Customization
The customization of the aircraft is managed in the `build_Lift_plus_Cruise.m` file in the `/vehicles/Lift+Cruise/AeroProp/SFunction/` directory. This file specifies the tiltwing aircraft configuration.
> [!NOTE]
> The `setup.m` file at the '/home/adcl/Documents/MATLAB/Generic-Urban-Air-Mobility-GUAM-main/vehicles/Lift+Cruise/' directory is overriding the num of engines and surfaces established in the `build_Lift_plus_Cruise.m` file.

## Trajectory and basic flight manuevers Customization
Users have a few options to provide desired trajectories and basic flight maneuvers to execute. The `userStruct.variant.refInputType` option selects (look in the Lift+Cruise Reference Inputs variant subsystem block at the simulation top level) between: 
- `FOUR_RAMP`
- `ONE_RAMP`
- `TIMESERIES`
- `BEZIER`
- `DEFAULT` (doublets) 
The `TIMESERIES` is demonstrated in the `Exec_Scripts` folder for the m-files that contain "TS" in the name and they end with the suffix "_traj.m".

### FOUR_RAMP Example
The `Exec_Scripts` contains a sample script for the `FOUR_RAMP` option, where Simulink ramp blocks create a simple trajectory. This setup uses an input structure `target` to specify trim configuration, with timing and magnitude provided through the `SimPar` structure. Target fields available for user specification include: 
- `alt`
- `tas`
- `gndtrack`
- `RefInput`
- `Rate`
- `stopTime`

A sample script (`exam_RAMP.m`) demonstrates the use of both the user-provided target structure, methods to programmatically specify Ramp settings (using `SimPar`), and the RAMP refInput variant subsystem.

### Piece-wise Bezier Curve Example
The example `./Exec_Scripts/exam_Bezier.m` shows how to generate and execute a Piece-wise Bezier curve trajectory. This example offers two options:

1. A user provided PW Bezier trajectory file (e.g., `./Exec_Scripts/exam_PW_Bezier_Traj.mat`) that must contain the structure:
```matlab
pwcurve.waypoints = {wptsX, wptsY, wptsZ};
pwcurve.time_wpts = {time_wptsX, time_wptsY, time_wptsZ};
```
2. Or a "target" structure input that contains the PW Bezier information,
```matlab
target.RefInput.Bezier.waypoints = {wptsX, wptsY, wptsZ};
target.RefInput.Bezier.time_wpts = {time_wptsX, time_wptsY, time_wptsZ};
```
along with the associated IC information (see `./Exec_Scripts/exam_Bezier.m` for details). Additionally, a PW Bezier curve plotting script is available `./Bez_Functions/Plot_PW_Bezier.m` for users to see the 3D trajectory, positions, velocities, and accelerations (for each axis) of the desired PW Bezier trajectory.

## Failures Customization
Failure customization is managed in `/vehicles/Lift+Cruise/setup/setupParameters.m`.

## Example
Below is an example setup for a first-principles-based strip-theory model **"SFunction"** using **"Piecewise Bezier"** desired trajectory:
```matlab
userStruct.variants.fmType = 1; % 1=SFunction, 2=Polynomial
userStruct.variants.refInputType = 4; % 1=FOUR_RAMP, 2=ONE_RAMP, 3=Timeseries, 4=Piecewise Bezier, 5=Default(doublets)

% Setup the desired trajectory ...

simSetup;
```
