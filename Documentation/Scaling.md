# VTOL Scaling

These additions allow the VTOL model to be scaled including, gemoetry velocities, and flight path, while preserving similar dynamics.

## Froude Scaling and Similitude
This scaling is done on the foundation of Similitude and Froude scaling. If length is scaled by a factor of two, then area is scaled by a factor of 2^2 and volume 2^3. This is applied to all geometric concepts including moments of inertia, mass, etc. For velocity time and velocity are scaled by the square root of your factor so if your scaling factor is 4, the velocity is scaled by a factor of two. Let the linear scale factor be $\lambda$ (e.g. $\lambda = 0.5$ for a half-scale model):

| Quantity          | Scaling Law                 | Example ($\lambda = 0.5$)                                                         |
| ----------------- | --------------------------- | --------------------------------------------------------------------------------- |
| Length            | $L \propto \lambda$         | $1\,\text{m} \;\rightarrow\; 0.5\,\text{m}$                                       |
| Area              | $A \propto \lambda^{2}$     | $1\,\text{m}^{2} \;\rightarrow\; 0.25\,\text{m}^{2}$                              |
| Volume / Mass     | $V,\,m \propto \lambda^{3}$ | $1\,\text{m}^{3} \;\rightarrow\; 0.125\,\text{m}^{3}$                             |
| Moment of inertia | $I \propto \lambda^{5}$     | $1\,\text{kg}\cdot\text{m}^{2} \;\rightarrow\; 0.031\,\text{kg}\cdot\text{m}^{2}$ |
| Velocity          | $V \propto \sqrt{\lambda}$  | $10\,\text{m\,s}^{-1} \;\rightarrow\; 7.07\,\text{m\,s}^{-1}$                     |
| Time              | $t \propto \sqrt{\lambda}$  | $1\,\text{s} \;\rightarrow\; 0.707\,\text{s}$                                     |

## Implementation in Code

Add the following line to `main.m`:

```matlab
userStruct.variants.scaling = 0.5;   % lambda = 0.5 --> half-scale model
```

The `userStruct.variants.scaling = 0.5;` line defines a global variable that is used in the LPC wrapper to scale geometry as well as scale the propeller coefficients. Geometry files, mass properties, and propeller coefficients are all multiplied by the appropriate powers of $\lambda$ automatically.

> [!NOTE]
> Set $\lambda = 1$ to disable scaling.

After changing $\lambda$ and running `simSetup`, you must rebuild the MEX file so that the compiled VTOL dynamics match the new scale:
```matlab
mex_LpC_sfunc(false);
```
Running the command above once per scaling change is sufficient; no rebuild is needed if $\lambda$ is unchanged.

## Refrences
Wolowicz, C.; Bowman, J.; Gilbert, W. (NASA TP-1534, 1979). [https://ntrs.nasa.gov/api/citations/19790022005/downloads/19790022005.pdf](https://ntrs.nasa.gov/api/citations/19790022005/downloads/19790022005.pdf)
