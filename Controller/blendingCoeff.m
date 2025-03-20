function eta = blendingCoeff(vel,  vel_hover, vel_forward)
    % blendingCoeff Computes eta based on airspeed.
    %
    % Inputs:
    %   vel          - Airspeed
    %   vel_hover    - Airspeed at which the vehicle is considered in full hover
    %   vel_forward  - Airspeed at which the vehicle is considered in full forward flight
    %
    % Output:
    %   eta        - Blending coefficient (1 in hover, 0 in forward flight)
    
    % Ensure transition is smooth using a logistic function
    k = 10 / (vel_forward - vel_hover);  % Controls steepness of transition
    eta = 1 ./ (1 + exp(k * (vel - (vel_hover + vel_forward)/2))); 

    if vel <= vel_hover
        eta = 1;
    elseif vel >= vel_forward
        eta = 0;
    end
end
