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
My initial thought when opening the repo was to run RUNME.m (seems like the obvious choice). If you do so, you get the following output and error:
```matlab
>> RUNME
Specify the desired example case to run:
	(1) Sinusoidal Timeseries
	(2) Hover to Transition Timeseries
	(3) Cruise Climbing Turn Timeseries
	(4) Ramp demo
	(5) Piecewise Bezier Trajectory
User Input: 1
Default path setup
userStruct exists
userStruct.variants exists
userStruct.switches does not exist

---------------------------------------
Switch setup:
Lift+Cruise polynomial aerodynamic model: v2.1-MOF
Variant setup
Bus setup
Error using RUNME (line 26)
Variant control 'simIsRemote == 1' used by block 'GUAM/Vehicle Simulation/ADCL
Vehicle Control/Variant Subsystem' must return a logical value.
Caused by:
    Error using RUNME (line 26)
    Unrecognized function or variable 'simIsRemote'.
        Error using RUNME (line 26)
        Variable 'simIsRemote' does not exist.
        Suggested Actions:
            • Load a file into base workspace. - Fix
            • Create a new variable. - Fix
```
in addition to the above output, the `GUAM.slx` file is opened to the S-Function sub-block, and everything is greyed out.

When going to a terminal window and running `git status`, we see that we have the following new files:
```
Exec_Scripts/exam_PW_Bezier_traj.mat
GUAM.slx.r2024a
vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.mexmaca64
vehicles/Lift+Cruise/obj/mac
```
We also see that `GUAM.slx` was modified, even though we didn't make any changes to the files ourselves.

After reviewing the instructions, it appears that it is intended to run `main.m` first. So, we will reset our folders and start from scratch.

After resetting git and closing out matlab to clear all effects of the prior run, we then run `main.m` and get the following effects:
`GUAM.slx` is opened to the top-level layer.
We read the following output:
```matlab
Default path setup
userStruct exists
userStruct.variants exists
userStruct.switches exists

---------------------------------------
Switch setup:
Standard Mode
Variant setup
Bus setup
```
Running `git status` in a terminal window shows that `GUAM.slx` has been modified, but no other changes have been made.

We proceed to run RUNME.m, and observe the following effects:
We receive the following prompt (and choose option 1):
```matlab
>> RUNME
Specify the desired example case to run:
	(1) Sinusoidal Timeseries
	(2) Hover to Transition Timeseries
	(3) Cruise Climbing Turn Timeseries
	(4) Ramp demo
	(5) Piecewise Bezier Trajectory
User Input: 1
```
We then observe:
The `GUAM.slx` file is opened, a loading bar appears in the bottom left (perhaps it is trying to execute the simulation?), and we notice it has opened to the `S_Function` Sub-block again. Going back to the main MATLAB window we get the following output:
```matlab
Default path setup
userStruct exists
userStruct.variants exists
userStruct.switches exists

---------------------------------------
Switch setup:
Standard Mode
Variant setup
Bus setup
Warning: Signals entering Bus Creator 'GUAM/Vehicle Simulation/ADCL Vehicle
Control/Mapping To Output/Bus Creator2' have duplicated names at input ports:
m0_in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)
All signals in the resulting bus are being made unique by appending "(signal
#)". Please update the labels of the signals such that they are all unique. 
> In RUNME (line 26) 
Warning: Signals entering Bus Creator 'GUAM/Vehicle Simulation/ADCL Vehicle
Control/Mapping To Output/Bus Creator2' have duplicated names at input ports:
m0_in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)
All signals in the resulting bus are being made unique by appending "(signal
#)". Please update the labels of the signals such that they are all unique. 
> In RUNME (line 26) 
Error using RUNME (line 26)
Error in S-function 'GUAM/Vehicle Simulation/Vehicle Model/Propulsion and
Aerodynamic Forces and Moments/Propulsion and Aerodynamic Forces and
Moments/S-Function/Lift+Cruise Forces//Moments': S-Function 'LpC_wrapper_sfunc'
does not exist
```
We check `git status` again and no files have been changed.

This is when we first notice the instructions for S-Functions, as detailed here in the documentation.
Since step 3 indicates we can do the whole s-function compilation by running `mex_LpC_sfunc(false);`, we do so and observe the following:
```matlab
>> mex_LpC_sfunc(false);
Generating LpC_wrapper static library...
Code generation successful: View report

Verbose mode is on.
No MEX options file identified; looking for an implicit selection.
... Looking for compiler 'Xcode with Clang' ...
... Looking for environment variable 'DEVELOPER_DIR' ...No.
... Executing command 'which xcrun' ...Yes ('/usr/bin/xcrun').
... Looking for folder '/usr/bin' ...Yes.
... Executing command 'xcode-select -print-path' ...Yes ('/Applications/Xcode.app/Contents/Developer').
... Looking for folder '/Applications/Xcode.app/Contents/Developer' ...Yes.
... Executing command 'defaults read com.apple.dt.Xcode IDEXcodeVersionForAgreedToGMLicense' ...No.
... Executing command 'defaults read /Library/Preferences/com.apple.dt.Xcode IDEXcodeVersionForAgreedToGMLicense' ...Yes ('16.4').
... Executing command '
agreed=16.4 
 if echo $agreed | grep -E '[\.\"]' >/dev/null; then 
 lhs=`expr "$agreed" : '\([0-9]*\)[\.].*'` 
  rhs=`expr "$agreed" : '[0-9]*[\.]\(.*\)$'` 
 if echo $rhs | grep -E '[\."]' >/dev/null; then 
 rhs=`expr "$rhs" : '\([0-9]*\)[\.].*'` 
 fi 
 if [ $lhs -gt 4 ] || ( [ $lhs -eq 4 ] && [ $rhs -ge 3 ] ); then 
 echo $agreed 
 else 
 exit 1
 fi 
 fi' ...Yes ('16.4').
... Executing command 'xcrun -sdk macosx --show-sdk-path' ...Yes ('/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk').
... Executing command 'xcrun -sdk macosx --show-sdk-version | awk 'BEGIN {FS="."} ; {print $1"."$2}'' ...Yes ('15.5').
... Executing command 'clang --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]'|head -1' ...Yes ('17.0.0').
Found installed compiler 'Xcode with Clang'.
Options file details
-------------------------------------------------------------------
	Compiler location: /Applications/Xcode.app/Contents/Developer
	Options file: /Applications/MATLAB_R2024b.app/bin/maca64/mexopts/clang_maca64.xml
	CMDLINE200 : /usr/bin/xcrun -sdk macosx15.5 clang -Wl,-twolevel_namespace  -arch arm64 -mmacosx-version-min=12.0 -Wl,-syslibroot,/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/mexFunction.map" /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/LpC_Scaled_wrapper_sfunc.o /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/c_mexapi_version.o  -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/c_exportsmexfileversion.map"  /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper/LpC_wrapper.a  -L/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper   -L"/Applications/MATLAB_R2024b.app/bin/maca64" -weak-lmx -weak-lmex -weak-lmat -lc++ -o /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.mexmaca64
	CC : /usr/bin/xcrun -sdk macosx15.5 clang
	CXX : /usr/bin/xcrun -sdk macosx15.5 clang++
	DEFINES : -DMATLAB_DEFAULT_RELEASE=R2017b  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE
	MATLABMEX : -DMATLAB_MEX_FILE
	MACOSX_DEPLOYMENT_TARGET : 12.0
	CFLAGS : -fno-common -arch arm64 -mmacosx-version-min=12.0 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -fwrapv -ffp-contract=off 
	INCLUDE : -I"/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper"  -I"/Applications/MATLAB_R2024b.app/extern/include" -I"/Applications/MATLAB_R2024b.app/simulink/include"
	COPTIMFLAGS : -O2 -DNDEBUG
	CDEBUGFLAGS : -g
	LD : /usr/bin/xcrun -sdk macosx15.5 clang
	LDXX : /usr/bin/xcrun -sdk macosx15.5 clang++
	LDFLAGS : -Wl,-twolevel_namespace  -arch arm64 -mmacosx-version-min=12.0 -Wl,-syslibroot,/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/mexFunction.map"
	LDBUNDLE : -bundle 
	FUNCTIONMAP : "/Applications/MATLAB_R2024b.app/extern/lib/maca64/mexFunction.map"
	VERSIONMAP : "/Applications/MATLAB_R2024b.app/extern/lib/maca64/c_exportsmexfileversion.map"
	LINKEXPORT : -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/mexFunction.map"
	LINKEXPORTVER : -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/c_exportsmexfileversion.map"
	LINKLIBS : /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper/LpC_wrapper.a  -L/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper   -L"/Applications/MATLAB_R2024b.app/bin/maca64" -weak-lmx -weak-lmex -weak-lmat -lc++
	LDOPTIMFLAGS : -O
	LDDEBUGFLAGS : -g
	OBJEXT : .o
	LDEXT : .mexmaca64
	SETENV : CC="/usr/bin/xcrun -sdk macosx15.5 clang"
                CXX="/usr/bin/xcrun -sdk macosx15.5 clang++"
                CFLAGS="-fno-common -arch arm64 -mmacosx-version-min=12.0 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -fwrapv -ffp-contract=off  -DMATLAB_DEFAULT_RELEASE=R2017b  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE"
                CXXFLAGS="-fno-common -arch arm64 -mmacosx-version-min=12.0 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -fwrapv -ffp-contract=off  -fobjc-arc -std=c++14 -stdlib=libc++ -DMATLAB_DEFAULT_RELEASE=R2017b  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE"
                COPTIMFLAGS="-O2 -DNDEBUG"
                CXXOPTIMFLAGS="-O2 -DNDEBUG"
                CDEBUGFLAGS="-g"
                CXXDEBUGFLAGS="-g"
                LD="/usr/bin/xcrun -sdk macosx15.5 clang"
                LDXX="/usr/bin/xcrun -sdk macosx15.5 clang++"
                LDFLAGS="-Wl,-twolevel_namespace  -arch arm64 -mmacosx-version-min=12.0 -Wl,-syslibroot,/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/mexFunction.map" /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper/LpC_wrapper.a  -L/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper   -L"/Applications/MATLAB_R2024b.app/bin/maca64" -weak-lmx -weak-lmex -weak-lmat -lc++ -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/mexFunction.map""
                LDDEBUGFLAGS="-g"
	DEVELOPER_DIR_CHECK : 
	XCRUN_DIR : /usr/bin
	XCODE_DIR : /Applications/Xcode.app/Contents/Developer
	XCODE_AGREED_VERSION : 16.4
	ISYSROOT : /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk
	SDKVER : 15.5
	CLANG_VERSION : 17.0.0
	MATLABROOT : /Applications/MATLAB_R2024b.app
	ARCH : maca64
	SRC : "/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/./vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc/LpC_Scaled_wrapper_sfunc.c";"/Applications/MATLAB_R2024b.app/extern/version/c_mexapi_version.c"
	OBJ : /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/LpC_Scaled_wrapper_sfunc.o;/var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/c_mexapi_version.o
	OBJS : /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/LpC_Scaled_wrapper_sfunc.o /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/c_mexapi_version.o 
	SRCROOT : /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/./vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc/LpC_Scaled_wrapper_sfunc
	DEF : /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/LpC_Scaled_wrapper_sfunc.def
	EXP : "/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.exp"
	LIB : "/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.lib"
	EXE : /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.mexmaca64
	ILK : "/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.ilk"
	TEMPNAME : /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc
	EXEDIR : /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/
	EXENAME : LpC_Scaled_wrapper_sfunc
	MANIFEST : "/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.mexmaca64.manifest"
	COMPFLAGS :  /MT
	OPTIM : -O2 -DNDEBUG
	LINKOPTIM : -O
	CMDLINE100_0 : /usr/bin/xcrun -sdk macosx15.5 clang -c -DMATLAB_DEFAULT_RELEASE=R2017b  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper"  -I"/Applications/MATLAB_R2024b.app/extern/include" -I"/Applications/MATLAB_R2024b.app/simulink/include" -fno-common -arch arm64 -mmacosx-version-min=12.0 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -fwrapv -ffp-contract=off  -O2 -DNDEBUG "/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/./vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc/LpC_Scaled_wrapper_sfunc.c" -o /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/LpC_Scaled_wrapper_sfunc.o
	CMDLINE100_1 : /usr/bin/xcrun -sdk macosx15.5 clang -c -DMATLAB_DEFAULT_RELEASE=R2017b  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper"  -I"/Applications/MATLAB_R2024b.app/extern/include" -I"/Applications/MATLAB_R2024b.app/simulink/include" -fno-common -arch arm64 -mmacosx-version-min=12.0 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -fwrapv -ffp-contract=off  -O2 -DNDEBUG "/Applications/MATLAB_R2024b.app/extern/version/c_mexapi_version.c" -o /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/c_mexapi_version.o
-------------------------------------------------------------------
Building with 'Xcode with Clang'.
/usr/bin/xcrun -sdk macosx15.5 clang -c -DMATLAB_DEFAULT_RELEASE=R2017b  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper"  -I"/Applications/MATLAB_R2024b.app/extern/include" -I"/Applications/MATLAB_R2024b.app/simulink/include" -fno-common -arch arm64 -mmacosx-version-min=12.0 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -fwrapv -ffp-contract=off  -O2 -DNDEBUG "/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/./vehicles/Lift+Cruise/AeroProp/SFunction/codegen_sfunc/LpC_Scaled_wrapper_sfunc.c" -o /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/LpC_Scaled_wrapper_sfunc.o
/usr/bin/xcrun -sdk macosx15.5 clang -c -DMATLAB_DEFAULT_RELEASE=R2017b  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper"  -I"/Applications/MATLAB_R2024b.app/extern/include" -I"/Applications/MATLAB_R2024b.app/simulink/include" -fno-common -arch arm64 -mmacosx-version-min=12.0 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -fwrapv -ffp-contract=off  -O2 -DNDEBUG "/Applications/MATLAB_R2024b.app/extern/version/c_mexapi_version.c" -o /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/c_mexapi_version.o
{ 
  "bundle.symbolic_name" : "73257220-c174-4e93-9d31-c1f95cebf530", 
  "mw" : 
  { 
      "mex" : 
      {
          "apiVersion" : 0,
          "release" : "R2024b",
          "threadpoolSafe" : 0
      }
  } 
}


/Applications/MATLAB_R2024b.app/bin/maca64/usResourceCompiler3 --manifest-add /private/var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780//mw_mex_tempmex_manifest.json --bundle-name mexVersioning --out-file /private/var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780//mw_mex_tempmex_bundle.zip

/usr/bin/xcrun -sdk macosx15.5 clang -Wl,-twolevel_namespace  -arch arm64 -mmacosx-version-min=12.0 -Wl,-syslibroot,/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/mexFunction.map" /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/LpC_Scaled_wrapper_sfunc.o /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/c_mexapi_version.o  -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/c_exportsmexfileversion.map"  /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper/LpC_wrapper.a  -L/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper   -L"/Applications/MATLAB_R2024b.app/bin/maca64" -weak-lmx -weak-lmex -weak-lmat -lc++ -o /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.mexmaca64 -Wl,-sectcreate,__TEXT,us_resources,/private/var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780//mw_mex_tempmex_bundle.zip 
Recompile embedded version with '-DMX_COMPAT_32'
/usr/bin/xcrun -sdk macosx15.5 clang -c -DMATLAB_DEFAULT_RELEASE=R2017b  -DUSE_MEX_CMD   -DMATLAB_MEX_FILE -I"/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper"  -I"/Applications/MATLAB_R2024b.app/extern/include" -I"/Applications/MATLAB_R2024b.app/simulink/include" -fno-common -arch arm64 -mmacosx-version-min=12.0 -fexceptions -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -fwrapv -ffp-contract=off  -O2 -DNDEBUG "/Applications/MATLAB_R2024b.app/extern/version/c_mexapi_version.c" -o /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/c_mexapi_version.o -DMX_COMPAT_32
{ 
  "bundle.symbolic_name" : "da1e4eb7-a537-43f3-897e-013be77f5533", 
  "mw" : 
  { 
      "mex" : 
      {
          "apiVersion" : 700,
          "release" : "R2024b",
          "threadpoolSafe" : 0
      }
  } 
}


/Applications/MATLAB_R2024b.app/bin/maca64/usResourceCompiler3 --manifest-add /private/var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780//mw_mex_tempmex_manifest.json --bundle-name mexVersioning --out-file /private/var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780//mw_mex_tempmex_bundle.zip

/usr/bin/xcrun -sdk macosx15.5 clang -Wl,-twolevel_namespace  -arch arm64 -mmacosx-version-min=12.0 -Wl,-syslibroot,/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.5.sdk -bundle  -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/mexFunction.map" /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/LpC_Scaled_wrapper_sfunc.o /var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780/c_mexapi_version.o  -O -Wl,-exported_symbols_list,"/Applications/MATLAB_R2024b.app/extern/lib/maca64/c_exportsmexfileversion.map"  /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper/LpC_wrapper.a  -L/Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/codegen/lib/LpC_wrapper   -L"/Applications/MATLAB_R2024b.app/bin/maca64" -weak-lmx -weak-lmex -weak-lmat -lc++ -o /Users/zrwuhank/Documents/School/USC/Ioannou/NASA/Generic-Urban-Air-Mobility-GUAM/vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.mexmaca64 -Wl,-sectcreate,__TEXT,us_resources,/private/var/folders/dp/4vhtyck55nx914fyg9c7r4s00000gn/T/mex_1157989817998_7780//mw_mex_tempmex_bundle.zip 
MEX completed successfully.
```
In addition to the above output, we note the following by running `git status`:
We now have newly generated files for 
```
vehicles/Lift+Cruise/obj/LpC_Scaled_wrapper_sfunc.mexmaca64
vehicles/Lift+Cruise/obj/mac
```

Given that it says MEX completed successfully, we're going to try running `RUNME.m` again:


When running `RUNME.m`, I am receiving the following error.
```matlab
Error using RUNME (line 26)
Error in S-function 'GUAM/Vehicle Simulation/Vehicle Model/Propulsion and
Aerodynamic Forces and Moments/Propulsion and Aerodynamic Forces and
Moments/S-Function/Lift+Cruise Forces//Moments': S-Function 'LpC_wrapper_sfunc'
does not exist
```
It appears that since I am using an Apple Silicon Macbook, my extension for mex based S-functions is `.mexmaca64`. I am wondering if the S-Function block is looking for a specific type of extension, and that's the problem... I will have to investigate further...

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
