# Controller and Linearization
## Baseline Controller
The baseline controller is designed to manage control inputs and state feedback for stable flight operations. The key matrices used for this purpose are:
- **Ki, Kx, Kv, F, C**: Matrices used for control and state feedback, calculated using interpolation or extrapolation based on control frame velocities `u` and `w`.
	- **Kv** for longitudinal control is **K_theta**
	- **Kv** for lateral control is **K_phi**
- **Trim States (X0)**: Interpolated state variables that represent the aircraft’s stable configuration at a given flight condition.
	- **3 velocities (u, v, w)**: Control reference frame velocities.
	- **3 rotation rates (p, q, r)**: Body frame rotation rates.
	- **3 accelerations (ax, ay, az)**: Accelerations in the body frame.
	- **3 Euler angles (phi, theta, psi)**: Aircraft orientation.
- **Trim Inputs (U0)**: Interpolated control inputs that keep the vehicle in a steady state.
	- **Control surfaces**: Flap, aileron, elevator, and rudder.
	- **Rotors**: 8 rotor speeds.
	- **Propulsor**: Additional propulsion unit.

### Interpolation for X0 and U0
The controller performs interpolation on the trim states (X0) and trim inputs (U0) as well as all the matrices used in the control for varying `u` and `w` velocities. This process involves 2 main blocks: prelookup blocks and the matrix interpolation block.

#### Prelookup Blocks
The prelookup blocks are used to determine where the input values (u and w velocities) fall within a specified set of breakpoints. These breakpoints are defined as vectors of values that segment the input range into intervals. Each prelookup block produces two outputs:
- **k**: Index that identifies which interval the input value falls into within the breakpoints.
- **f**: Fraction that represents how far along the interval the input value is (normalized between 0 and 1).
Let's walk through an example using the `w` prelookup block with the breakpoints `[-7.5, 0, 11.667]` given an input `w=5`:
- Interval `[0, 11.667]` contains `w=5`
- **Output** `k2 = 1`: This indicates that the interval `[0, 11.667]` is the second interval in the set of breakpoints
- **Output** `f2 = 0.4286`: The fraction is calculated as `5-0/11.667 = 0.428` (w - lower bound of interval/length of interval)

```matlab
function [k, f] = prelookup(value, breakpoints)
    % Ensure breakpoints are sorted
    breakpoints = sort(breakpoints);
    
    % Find the interval index k where value falls
    k = find(value >= breakpoints, 1, 'last'); % Last breakpoint ≤ value
    
    % If value is outside the breakpoints range, clamp it
    if k >= length(breakpoints) % If value is beyond the last interval
        k = length(breakpoints) - 1;
        f = 1;
    elseif k == 0 % If value is below the first breakpoint
        k = 1;
        f = 0;
    else
        % Compute fraction f within the interval
        lower_bound = breakpoints(k);
        upper_bound = breakpoints(k+1);
        f = (value - lower_bound) / (upper_bound - lower_bound);
    end
end
```

#### Matrix Interpolation Block
Takes indices `(k1, k2)` and fractions `(f1, f2)` from the prelookup blocks to interpolate a 3D matrix (25x28x3) resulting in a 25x1 vector.
The 3D table data (25x28x3) can be thought of as a collection of 25 matrices, each of size 28x3. Then the output is a 25x1 vector, where each element is the result of interpolating a corresponding 28x3 matrix. An example of how this is done is the following code for `u = 90` and `w = 5`:
```matlab
k1 = 10;
f1 = 0.66470842332614;
k2 = 1;
f2 = 0.42857142857143;
XU0 = zeros(25,1);
for i=1:25
    % Obtain the 28x3 matrix
    m = SimIn.Control.trim.XU0_interp(i,:,:);

    % Ensure k1 and k2 do not exceed bounds
    max_k1 = 27; % Since we need k1+1 and k1+2, max allowed k1 is 27
    max_k2 = 2;  % Since we need k2+1 and k2+2, max allowed k2 is 2
    k1 = min(k1, max_k1);
    k2 = min(k2, max_k2);

    % Identify the four neighboring points safely
    v11 = m(1, k1+1, k2+1);
    v21 = m(1, min(k1+2, 28), k2+1); % Prevent k1+2 from exceeding 28
    v12 = m(1, k1+1, min(k2+2, 3));  % Prevent k2+2 from exceeding 3
    v22 = m(1, min(k1+2, 28), min(k2+2, 3)); % Ensure both indices are within limits

    % Interpolate along the u dimension
    v1 = v11 + f1 * (v21 - v11);
    v2 = v12 + f1 * (v22 - v12);

    % Interpolate along the w dimension
    XU0(i) = v1 + f2 * (v2 - v1);
end
```

## Linearization
The gain scheduling m-files are contained in the `./vehicles/Lift+Cruise/control/` folder. The top-level script for gain scheduling the baseline controller (LSQi) is `ctrl_scheduler_GUAM.m`. This script schedules the Longitudinal and Lateral axes separately. A few linearization scripts are available but the main script is `get_lin_dynamics_heading.m`. This script linearizes around a designated flight condition, and other scripts (e.g., `get_lat_dynamics_heading.m` and `ctrl_lat.m`) segregate the linearized dynamics according to desired axes.

## External References
For further reading on the EOMs, envelope, baseline controller design, and analysis, check out the following resources:
- **EOMs and Envelope**: 		[AIAA Article](https://arc.aiaa.org/doi/epdf/10.2514/6.2021-3170)
- **Baseline controller design**: 	[NASA Report](https://ntrs.nasa.gov/api/citations/20210000418/downloads/VFS-2021-A%20Robust%20Uniform%20Approach%20for%20VTOL%20Aircraft%20-%20JWC-6.pdf)
- **EOMs and Controller analysis**: 	[NASA Report](https://ntrs.nasa.gov/api/citations/20205010869/downloads/AIAA_SCITECH_Unif_Cont_Strives_V2.pdf)
