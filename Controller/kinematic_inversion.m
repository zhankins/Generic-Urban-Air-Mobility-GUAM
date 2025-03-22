function rp = kinematic_inversion(xyz_req, yaw, g)
    % Extract x and y accelerations
    ddot_x = xyz_req(1);
    ddot_y = xyz_req(2);

    % z acceleration
    ddot_z = xyz_req(3);

    % Compute theta_req
    theta_req = atan( (ddot_x*cos(yaw) + ddot_y*sin(yaw)) / (ddot_z - g) );

    % Compute phi_req
    phi_req = asin( -(ddot_x*sin(yaw) - ddot_y*cos(yaw)) / ...
                     sqrt(ddot_x^2 + ddot_y^2 + (ddot_z - g)^2) );

    rp = [phi_req; theta_req];
end
