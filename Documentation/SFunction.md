# Compiling the SFunction Model

This document provides instructions on how to compile the SFunction model used in the Lift+Cruise configuration of the NASA GUAM project.

## 1. Generate the Static Library

Before compiling the mex file, run the following command in the MATLAB command window to generate the static library:

```matlab
codegen_LpC_lib(true, false);
```

The `codegen_LpC_lib` function is located in:
```
vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc
```

## 2. Compile the Mex File

Once the static library has been generated, compile the mex file using the following command:

```bash
mex -I'/usr/local/MATLAB/R2024a/extern/include' ...
    -I'/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper' ...
    -L'/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper' ...
    -l:LpC_wrapper.a ...
    '/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc/LpC_wrapper_sfunc.c' ...
    -output LpC_wrapper_sfunc_new
```

This command sets up the necessary include paths and links to the static library.

## 3. Alternative Compilation Method

Alternatively, you can run the following command to perform all of the above steps in one go:

```matlab
mex_LpC_sfunc(false);
```

The `mex_LpC_sfunc` script is located in:
```
vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc
```
