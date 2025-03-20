function euler_rates = euler_rates(euler, pqr)
    % Extract Euler angles
    phi = euler(1);
    theta = euler(2);
    psi = euler(3);

    % Extract body angular rates
    p = pqr(1);
    q = pqr(2);
    r = pqr(3);

    % Compute the transformation matrix
    T = [
        1, sin(phi) * tan(theta), cos(phi) * tan(theta);
        0, cos(phi), -sin(phi);
        0, sin(phi) / cos(theta), cos(phi) / cos(theta)
    ];

    % Compute Euler angle rates
    euler_rates = T * [p; q; r];
end
