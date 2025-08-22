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

### Alternate steps for MacOS Apple Silicon

### S-Function Error
When running `RUNME.m`, I am receiving the following error.
```matlab
Error using RUNME (line 26)
Error in S-function 'GUAM/Vehicle Simulation/Vehicle Model/Propulsion and
Aerodynamic Forces and Moments/Propulsion and Aerodynamic Forces and
Moments/S-Function/Lift+Cruise Forces//Moments': S-Function 'LpC_wrapper_sfunc'
does not exist
```
I am trying the following steps to correct:
```matlab
mex_LpC_sfunc(false);
```
It appears that since I am using an Apple Silicon Macbook, my extension for mex based S-functions is `.mexmaca64`.

It also appears that, contrary to the instructions [listed](./Documentation/Sfunction.md), you need to perform all 3 steps in order to prepare the s-functions. I am going to try the instructions as written and see if they work, however in [`codegen_LpC_lib.m`](./vehicles/Lift+Cruise/Aeroprop/SFunction/codegen_sfunc/codegen_LpC_lib.m) on lines 56-62, it looks like they hardcode the mexext based on the OS type. This is an odd behavior, since Matlab has a built in function called mexext which automatically detects the OS type and returns the correct extension.

I will try the instructions as written, and then revert if necessary and try again, commenting out those lines, since I don't think they are necessary, and interfere with normal operation of the system.

I ran step 1 successfully, then had the following error:
```matlab
Error using mex
/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc/LpC_wrapper_sfunc.c
not detected; check that you are in the correct current folder, and check the
spelling of
'/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc/LpC_wrapper_sfunc.c'.
```
I'm wondering if I'm meant to run this from the parent folder of GUAM, but that seems odd... I'm also noticing in the [matlab documentation](https://www.mathworks.com/help/matlab/matlab_external/building-on-unix-operating-systems.html#f28833) that for macOS and Linux you need to set the library path based on the OS you're running. I'm going to try setting that and see if it fixes the problem.

I am running macOS with Apple silicon, so for me that would be
    `DYLD_LIBRARY_PATH=matlabroot/bin/maca64:matlabroot/sys/os/maca64`
Which we can achieve by executing the following in the Matlab Command Window
```matlab
>> DYLD_LIBRARY_PATH = [matlabroot, '/bin/maca64:', matlabroot, '/sys/os/maca64']
```

Now we're going to try the prior script again...

that didn't work... so this time we're going to delete the variable we just set (in case it doesn't matter) and go to the parent directory so the relative paths still work, and try again.

codegen isn't in the path... it needs to be added manually...

so after adding the codegen folder manually, we manually added the above instructions to be the following:
`
>> mex -I'/usr/local/MATLAB/R2024a/extern/include' ...
-I'codegen/lib/LpC_wrapper' ...
-L'codegen/lib/LpC_wrapper' ...
-l:LpC_wrapper.a ...
'vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc/LpC_wrapper_sfunc.c' ...
-output LpC_wrapper_sfunc_new``matlab
```

 and then got the following error
```matlab
Error using mex
ld: library ':LpC_wrapper.a' not found
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

I'm going to work on something else for a bit and come back to this.
## 3. Alternative Compilation Method

Alternatively, you can run the following command to perform all of the above steps in one go:

```matlab
mex_LpC_sfunc(false);
```

The `mex_LpC_sfunc` script is located in:
```
vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc
```
