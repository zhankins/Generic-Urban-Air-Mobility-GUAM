# Linearization of the Control Model

This document explains how the linearization of the simulation model is performed, with a focus on the gain-scheduled unified controller (NASA's Baseline Controller) and the associated interpolation methods. The linearization process transforms the nonlinear dynamics into a linear state-space form that is used to design and schedule controllers for both the longitudinal and lateral axes.

## 1. Overview of the Linear Model

The decoupled system is represented by the standard state-space equations:

```matlab
dx = A*x + B*u
y  = C*x + D*u
```

- **x** is the state vector.
- **u** is the control input vector.
- **A, B, C, D** are the state, input, output, and feedforward matrices, respectively.

In the context of the unified controller, the full state vector is defined as:

```
x = [ px, py, pz, phi, theta, psi, u, v, w, p, q, r ]
```

and the input vector as:

```
u = [ delf, dela, dele, delr, omp1, omp2, ... , omp9 ]
```

The primary function for computing this linearized model is get_lin_dynamics_heading.m. This function computes the state-space matrices: It calculates A, B, C, and D at a specific flight condition.

## 2. Gain Scheduling and Controller Design

The gain scheduling files reside in the `./vehicles/Lift+Cruise/Control/` folder. The main scripts involved include:

- **ctrl_scheduler_GUAM.m:**  
  - Designs and outputs a series of gain-scheduled unified controllers.
  - Uses concatenated trim file data (monotonic arrays of control frame velocities and other parameters) to schedule controllers for both the longitudinal and lateral axes.
  - Based on Dr. Jacob Cook's unified controller approach, which maintains the same control variables across the hover, transition, and cruise flight phases.

- **get_lin_dynamics_heading.m:**  
  - Computes the state-space matrices (A, B, C, D) in the control frame for a designated flight condition.
  - Performs the necessary interpolations from the 3D matrices stored in `SimIn.Control.trim`.

## 3. Extraction of Lateral and Longitudinal Dynamics

Once the full linearized state-space model is computed (using **get_lin_dynamics_heading.m**), the lateral and longitudinal dynamics are extracted using dedicated scripts:

### 3.1. Lateral Dynamics Extraction

- **get_lat_dynamics_heading.m** (and indirectly **ctrl_lat.m**)  
  - **State Selection:**  
    From the full state vector, the lateral dynamics are extracted by selecting specific indices:
    - **Selected States:**  
      - *v* (index 8), *p* (index 10), *r* (index 12), and *phi* (roll angle, index 4).
  - **Input Selection:**  
    - The inputs chosen for lateral control are a subset of the full vector (e.g., corresponding to aileron, rudder, and selected rotor speeds).
  - **Matrix Partitioning:**  
    - The lateral state-space matrix is obtained by extracting the rows and columns corresponding to the lateral state indices, for example:
      ```matlab
      Alat = A(lat_state_indices, lat_state_indices);
      ```

### 3.2. Longitudinal Dynamics Extraction

- **get_long_dynamics_heading.m** (and indirectly **ctrl_lon.m**)  
  - **State Selection:**  
    For the longitudinal dynamics, the selected states are:
    - **Selected States:**  
      - *u* (index 7), *w* (index 9), *q* (pitch rate, index 11), and *theta* (pitch angle, index 5).
  - **Input Selection:**  
    - The inputs chosen for longitudinal control include those corresponding to elevator, flaps, and other relevant effectors.
  - **Matrix Partitioning:**  
    - The longitudinal state-space matrix is obtained by extracting the rows and columns corresponding to the longitudinal state indices:
      ```matlab
      Along = A(long_state_indices, long_state_indices);
      ```

## 4. Alternative Linearization: Body Frame Dynamics

In addition to the heading frame extraction described above, there are scripts named **get_lat_dynamics** and **get_long_dynamics**. These functions:

- Accept the complete aero/propulsive model (either based on strip theory or the polynomial model).
- Take specific trim condition states and actuator settings (XEQ) along with Earth constants.
- Output linearized state-space models for the lateral and longitudinal dynamics expressed in the body frame.

## 5. How is the linearized model used?

For the baseline controller, the state-space matrices are interpolated from precomputed 3D matrices stored in the `SimIn.Control.trim` structure as:

- **Ap_lat_interp, Ap_lon_interp:** Interpolated state matrices for the lateral and longitudinal channels.
- **Bp_lat_interp, Bp_lon_interp:** Interpolated input matrices.
- **Dp_lat_interp, Dp_lon_interp:** Interpolated feedforward matrices.

These 3D matrices are constructed by sampling the system behavior at different control frame body velocities. The interpolation process uses the control frame velocities (usually denoted as **u** and **w**) to select and blend the appropriate matrix data.

