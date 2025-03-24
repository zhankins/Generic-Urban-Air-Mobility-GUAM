# Reference System Nomenclature

This document explains the nomenclature used for dynamic quantities (position, velocity, angular rate, etc.) in the simulation.

## Naming Convention

Each vector or measurement is labeled as `X_abc` where:
- `X` is the quantity being measured (e.g., `Pos`, `Vel`, `Accel`, `Omeg`)
- `a`: **Point of interest / object**
- `b`: **Reference frame or origin**
- `c`: **Coordinate frame in which the quantity is expressed**


### Letter Definitions

| Symbol | Description                                   |
|--------|-----------------------------------------------|
| a      | `b` - Body origin (e.g., center of mass)      |
|        | `E` - Earth/World frame                       |
|        | `H` - Local NED frame                         |
| b      | `I` - Inertial frame                          |
|        | `E` - Earth/World frame                       |
|        | `H` - Local NED frame                         |
|        | `W` - Wind frame (air-relative)               |
|        | `V` - Older notation for wind frame           |
| c      | `i` - Inertial coordinates                    |
|        | `e` - ECEF coordinates                        |
|        | `h` - NED coordinates                         |
|        | `b` - Body coordinates                        |

## Examples

### Position and Velocity

| Notation     | Description |
|--------------|-------------|
| `Pos_bii`    | Position of point `b` (body COM) relative to inertial frame `i`, expressed in inertial coordinates. |
| `Vel_bIi`    | Velocity of point `b` w.r.t. inertial frame `I`, in inertial coordinates. |
| `Vel_bEi`    | Velocity of point `b` w.r.t. Earth frame `E`, in inertial coordinates. |
| `Vel_bEe`    | Velocity of point `b` w.r.t. Earth frame `E`, in ECEF coordinates. |
| `Vel_bWb`    | Velocity of point `b` w.r.t. Wind frame `W` (air-relative), expressed in body coordinates. |
| `Vel_bVh`    | Air-relative velocity of point `b` in NED frame, expressed in NED coordinates. |

### Acceleration

| Notation        | Description |
|-----------------|-------------|
| `Accel_bIi`     | Acceleration of point `b` w.r.t. inertial frame `I`, in inertial coordinates. |
| `VelDtE_bEi`    | Acceleration of `b` as observed from Earth frame `E`, relative to `E`, in inertial coordinates. |
| `VelDtH_bVh`    | Acceleration of `b` observed from NED frame `H`, relative to Wind frame `V`, in NED coordinates. |

### Angular Rates

| Notation      | Description |
|---------------|-------------|
| `Omeg_EIi`    | Angular rate of Earth frame `E` w.r.t. inertial frame `I`, in inertial coordinates. |
| `Omeg_EIb`    | Angular rate of planet `E` w.r.t. inertial frame `I`, in body coordinates. |
| `Omeg_HEb`    | Angular rate due to Earth's curvature (zero in flat Earth), relative to `E`, in body coordinates. |
| `Omeg_BHb`    | Angular rate of body frame `B` relative to NED frame `H`, in body coordinates. |
| `Omeg_BIb`    | Angular rate of body frame `B` relative to inertial frame `I`, in body coordinates. |
| `Omeg_BEb`    | Angular rate of body frame `B` relative to Earth frame `E`, in body coordinates. |
| `Omeg_BWb`    | Angular rate of body w.r.t. Wind frame, in body coordinates. |


