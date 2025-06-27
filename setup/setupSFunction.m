function setupSFunction(SimIn,model)
    if SimIn.ScalingFactor > 0
      sfuncName = 'LpC_Scaled_wrapper_sfunc';
    else
      sfuncName = 'LpC_wrapper_sfunc';
    end

    if ~bdIsLoaded(model), open(model); end
    
    % full path to the S-Function block:
    blk = [ model, '/', ...
      'Vehicle Simulation/', ...
      'Vehicle Model/', ...
      'Propulsion and Aerodynamic Forces and Moments/', ...
      'Propulsion and Aerodynamic Forces and Moments/S-Function/', ...
      'Lift+Cruise Forces//Moments' ];
    
    % switch it over
    set_param(blk, 'FunctionName', sfuncName);
end