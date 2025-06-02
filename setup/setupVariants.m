disp('Variant setup');

% setup common variant conditions
setupVehicleVariants;
setupAtmosphereVariants;
% There is no Turbulence variant, now SimIn
% varies from 1 to 4 where the value means the turbulence Intensity 
% 1=Off, 2=light, 3=moderate, 4=severe
% setupTurbulenceVariants; 
setupExperimentVariants;

% set model-specific variant conditions
setupControllerVariants;
setupRefInputsVariants;
setupActuatorVariants;
setupPropulsionVariants;
setupForceMomentVariants;
setupEOMVariants;
setupSensorVariants;
