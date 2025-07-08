# Trim Files Build & Code Summary

This document provides a concise overview of how to build the trim files for the Lift+Cruise model and a summary of the key code functionality.
> [!NOTE]
> We trim because each geometric scale of the vehicle needs a set of trimmed operating points that cover the flight envelope from **hover --> transition --> cruise**.

## About `Trim_Case_7_Scale_x.m`

[Trim_Case_7_Scale_x.m](vehicles/Lift+Cruise/Trim/Trim_Case_7_Scale_x.m) is a script derived from NASA’s original `trim_helix` and `ctrl_scheduler_GUAM` codes.
It shows how to compute trim points for **one vertical speed** (WH) across a **range of forward velocities (UH)** in all three regimes (hover, transition, and cruise). This code removes plotting, printing, and other non-essential lines, making it quick to run whenever you update the VTOL’s scale and need a fresh trim table for the **incremental NDI controller**.

## How to Run the Trim Code

1. **Build the Aircraft Model & Compile the SFunction:**
   - Navigate to `\vehicles\Lift+Cruise`.
      ```matlab
      % in \vehicles\Lift+Cruise
      build_Lift_plus_Cruise(scaleFactor)   % set your scale
      mex_LpC_sfunc(false)                  % compile once
      ```

2. **Generate Trim Files:**
   - Navigate to `\vehicles\Lift+Cruise\Trim`.
   - Open **trim_helix** and set the scaling factor:
     ```matlab
     tiltwing = build_Lift_plus_Cruise(scaleFactor);
     ```
   - Run **trim_helix** for the three conditions (hover, transition, cruise).
   - Three case files will be output after execution.
> [!TIP]
> You can use `GenerateTables` script—just update the scale factor in both `GenerateTables` and `helix_trim_createTables`. The latter has been modified to accept the scaling factor from `GenerateTables`

3. **Controller Trim Table Generation:**
   - Navigate to `\vehicles\Lift+Cruise\Control`.
   - Open **ctrl_scheduler_GUAM** and set the scaling factor:
     ```matlab
     lpc = build_Lift_plus_Cruise(scaleFactor);
     ```
   - Update the trim case file names as needed.
   - Run the script to generate two trim tables—use the polynomial trim table for further processing.

4. **Update the Setup:**
   - In `vehicles/Lift+Cruise/setup/setupControl`, update line 14 to reference the new trim table, or rename this file to `trim_table` and replace the existing one in `/vehicles/Lift+Cruise`.

## Code Functionality Overview

- **Trim Optimization:**
  - The code uses MATLAB’s `fmincon` to solve a constrained optimization problem that minimizes a cost function (`mycost`) subject to nonlinear constraints (`nlinCon_helix`).
  - It computes trim conditions for three flight phases: hover, transition, and cruise.

- **Polynomial Blending Method:**
  - A polynomial blending method is employed to model and smooth the transitions between different flight states.
  - This method ensures a continuous and smooth variation of trim conditions across the flight envelope.

- **Key Parameters & Settings:**
  - **UH:** Range of forward velocities.
  - **WH:** Vertical speeds (e.g., `[-700/60, 0, 700/60]`); note that slight discrepancies may occur between cases.
  - **Transition Speeds:** Defined by `trans_start` and `trans_end` (e.g., transition from 50 to 94.8 knots).
  - **Optimization Settings:** Parameters like maximum function evaluations and iterations are set to ensure robust convergence of the `fmincon` solver.

- **Key MATLAB Functions:**
  - `fmincon` – Performs constrained nonlinear optimization.
  - `mycost` – The cost function to be minimized.
  - `nlinCon_helix` – Defines the nonlinear constraints.
  - `show_trim` – Visualizes the resulting trim conditions.

## Additional Observations

- Some output values (e.g., vertical speeds) might differ slightly between case files. For instance, a value of -11.667 may appear in one case while -7.5 appears in another.  
- Minor differences (around +0.0002) can be attributed to simulation data accuracy and are generally negligible.
