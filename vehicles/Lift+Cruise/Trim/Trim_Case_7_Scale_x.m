%% Trim_Case_7_Scale_x.m
function fname = Trim_Case_7_Scale_x(SimIn)
arguments
    SimIn struct
end

% Extract raw and build scales
buildScale   = SimIn.ScalingFactor;

scriptFullPath = mfilename('fullpath');
[scriptDir,~,~] = fileparts(scriptFullPath);
out_path      = scriptDir;
pct = round(buildScale * 100);
fname = sprintf('Trim_Scale_%02d_XU0_interp.mat', pct);

out_file = fullfile(out_path, fname);

%— if the file already exists, skip the heavy trim work
if isfile(out_file)
  fprintf('Trim file "%s" already exists. Skipping trim generation.\n', fname);
  return;
end

% Build model
LPC = build_Lift_plus_Cruise(buildScale);
LPC.om_p = zeros(1,SimIn.numEngines);

% Set SFunction flag and blending
global POLY
POLY = 0;
blending_method = 2;

% Load simulation units and environment
kts2ft = SimIn.Units.nmile/SimIn.Units.ft/3600;
a = 1125.33;

% Define speed vectors scaled by sqrt(geometric scale)
speedScale = sqrt(buildScale);
UH = [0:5:90,94.8,95,100:5:130]*kts2ft*speedScale;
WH = 0;
R  = inf;

% Define transition thresholds
trans_start = 30*kts2ft*speedScale;
trans_end   = 90*kts2ft*speedScale;

% Optimization settings and physical constants
max_evals      = 5000;   max_iter      = 500;
max_evals2     = 11000;  max_iter2     = 1000;
GRAV = SimIn.Environment.Earth.Gravity.g0(3);
RHO  = SimIn.Environment.Atmos.rho0;
Ns   = 4;
Np   = SimIn.numEngines;
Num_FreeVars  = 18;

% Bounds for strip theory
LB = [ -5*pi/180  -60*pi/180 -2*pi -2*pi -2*pi -30*pi/180 -30*pi/180 -30*pi/180 -30*pi/180 zeros(1,4)    zeros(1,4)     0        ];
UB = [ 15*pi/180   60*pi/180  2*pi  2*pi  2*pi  30*pi/180  30*pi/180  30*pi/180  30*pi/180 repmat(250,1,4)  repmat(250,1,4)   400.00   ];

% Preallocate
XEQ     = nan(numel(UH), Num_FreeVars+3, numel(WH), numel(R));
XEQ_All = XEQ;

% Set quadratic cost component Q
q_theta = 1; % pitch angle
q_phi   = 1 ; % roll angle 
q_p     = 1 ; % roll rate
q_q     = 1 ; % pitch rate
q_r     = 1 ; % yaw rate
q_del_f = 1; % flap deflection
q_del_a = 1 ; % aileron deflection
q_del_e = 1; % elevator deflection
q_del_r = 1 ; % rudder deflection
q_om_l  = 1*[1 1 1 1] ; % leading edge prop speed 
q_om_t  = 1*[1 1 1 1]; % trailing edge prop speed 
q_om_p  = 1; % pusher prop speed

% Loop through trim points
numPts = numel(UH)*numel(WH)*numel(R);
for ii = 1:numel(R)
    for kk = 1:numel(WH)
        count = 0;
        for jj = 1:numel(UH)
            count = count + 1;
            fprintf('Trimming point %d/%d  (UH = %.1f ft/s, WH = %.1f, R = %g)\n', ...
                count, numPts, UH(jj), WH(kk), R(ii));
            % Select trim condition based on UH
            if UH(jj) <= trans_start
                % Hover case 7
                X0_hover = [-2*pi/180; 0; 0; 0; 0; -25*pi/180; 0; 0; 0; repmat(90,4,1); repmat(90,4,1); 0];
                FreeVar_hover = boolean([1 1 0 0 0 1 1 1 1 [1 0 1 0] [1 0 1 0] 1]);
                offset_x0_hover = zeros(18,1);
                offset_x0_hover(1) = UH(jj)/trans_start * 6*pi/180;
                offset_x0_hover(6) = (1 - UH(jj)/trans_start) * -25*pi/180;
                offset_x0_hover(10:17) = 90;
                scale_hover = ([180/pi 180/pi 180/pi 180/pi 180/pi 180/pi 180/pi 180/pi 180/pi ones(1,9)]' ./ (UB - LB)');
                gang_hover  = [zeros(9,1); ones(2,1); 2*ones(2,1); 3*ones(2,1); 4*ones(2,1); 0];
                Q_hover = diag([q_theta q_phi q_p q_q q_r q_del_f q_del_a q_del_e q_del_r q_om_l q_om_t q_om_p]);

                FreeVar         = FreeVar_hover;
                offset          = offset_x0_hover;
                x0              = X0_hover(FreeVar);
                X0              = X0_hover;
                scale           = scale_hover;
                gang            = gang_hover;
                Q               = Q_hover;
            elseif UH(jj) <= trans_end
                % Transition case 7
                X0_trans = [6*pi/180; 0; 0; 0; 0; 0; 0; 0; 0; repmat(35,4,1); repmat(35,4,1); 105];
                FreeVar_trans = boolean([1 0 0 0 0 0 1 1 1 [1 0 1 0] [1 0 1 0] 1]);
                offset_x0_trans = zeros(18,1);
                offset_x0_trans(1) = 6*pi/180 + UH(jj)/trans_end * 1.8*pi/180;
                if UH(jj) > (trans_end - 10)
                    offset_x0_trans(10:17) = 60 * (trans_end - UH(jj)) / 10;
                end
                scale_trans = ([180/pi 180/pi 180/pi 180/pi 180/pi 180/pi 180/pi 180/pi 180/pi ones(1,9)]' ./ (UB - LB)');
                gang_trans = [zeros(9,1); ones(2,1); 2*ones(2,1); 3*ones(2,1); 4*ones(2,1); 0];
                Q_trans = diag([q_theta q_phi q_p q_q q_r q_del_f q_del_a q_del_e q_del_r q_om_l q_om_t q_om_p]);

                FreeVar             = FreeVar_trans;
                offset              = offset_x0_trans;
                x0                  = X0_trans(FreeVar);
                X0                  = X0_trans;
                scale               = scale_trans;
                gang                = gang_trans;
                Q                   = Q_trans;
            else
                % Cruise case 7
                X0_cruise = [8*pi/180; 0; 0; 0; 0; 0; 0; 0; 0; zeros(4,1); zeros(4,1); 150];
                FreeVar_cruise = boolean([1 1 0 0 0 0 1 1 1 [0 0 0 0] [0 0 0 0] 1]);
                offset_x0_cruise = zeros(18,1);
                scale_cruise = ([180/pi 180/pi 180/pi 180/pi 180/pi 180/pi 180/pi 180/pi 180/pi ones(1,9)]' ./ (UB - LB)');
                gang_cruise = zeros(18,1);
                Q_cruise = diag([q_theta q_phi q_p q_q q_r q_del_f q_del_a q_del_e q_del_r q_om_l q_om_t q_om_p]);

                FreeVar             = FreeVar_cruise;
                offset              = offset_x0_cruise;
                x0                  = X0_cruise(FreeVar);
                X0                  = X0_cruise;
                scale               = scale_cruise;
                gang                = gang_cruise;
                Q                   = Q_cruise;
            end

            TRIM_POINT = [UH(jj) WH(kk) R(ii)];

            lb = LB(FreeVar);
            ub = UB(FreeVar);

            opts = optimoptions(@fmincon,'algorithm','interior-point','tolcon', 1e-7, ...
                'Display', 'final', 'SpecifyObjectiveGradient', true, 'SpecifyConstraintGradient', false, ...
                'MaxFunctionEvaluations', max_evals,'CheckGradients', false,...
                'FiniteDifferenceType','central', 'MaxIterations', max_iter, 'StepTolerance', 1e-10);
            opts2 = optimoptions(@fmincon,'algorithm','interior-point','tolcon', 1e-7, ...
                'Display', 'final', 'SpecifyObjectiveGradient', true, 'SpecifyConstraintGradient', false, ...
                'MaxFunctionEvaluations', max_evals2,'CheckGradients', false,...
                'FiniteDifferenceType','central', 'MaxIterations', max_iter2, 'StepTolerance', 1e-10);

            % Run primary fmincon
            [x,fval,exitflag,output] = fmincon(@(x) mycost(x, X0, FreeVar, Q, offset, scale, gang), x0, [],[],[],[], lb, ub, ...
                @(x) nlinCon_helix(x, [TRIM_POINT X0(~FreeVar)'], LPC, GRAV, RHO, Ns, Np, FreeVar, gang, kts2ft, a, blending_method), opts);

            % If needed, run alternate solver
            if exitflag <= 0
                if ~isempty(output.bestfeasible)
                    X02 = X0;
                    X02(FreeVar) = output.bestfeasible.x;
                    [x,fval,exitflag,output] = fmincon(@(x) mycost(x, X02, FreeVar, Q, offset, scale, gang), x0, [],[],[],[], lb, ub, ...
                        @(x) nlinCon_helix(x,[TRIM_POINT X0(~FreeVar)'], LPC, GRAV, RHO, Ns, Np, FreeVar, gang, kts2ft, a, blending_method), opts2);
                    if exitflag <= 0
                        if ~isempty(output.bestfeasible.x)
                            % Just output the best feasible
                            exitflag = 99;
                            x = output.bestfeasible.x;
                        end
                    end
                else
                    [x,fval,exitflag,output] = fmincon(@(x) mycost(x, X0, FreeVar, Q, offset, scale, gang), x0, [],[],[],[], lb, ub, ...
                        @(x) nlinCon_helix(x,[TRIM_POINT X0(~FreeVar)'], LPC, GRAV, RHO, Ns, Np, FreeVar, gang, kts2ft, a, blending_method), opts2);
                    if exitflag <= 0
                        if ~isempty(output.bestfeasible)
                            % Just output the best feasible
                            exitflag = 99;
                            x = output.bestfeasible.x;
                        else
                            disp('***** No feasible solution found...'); 
                        end
                    end
                end
            end

            xeq = X0;
            xeq(FreeVar) = x;

            % Now update the final output vector due to gang_vec as appropriate..
            if any(gang)
                % First find the unique (non-zero gang vector entries)
                uniq_gang = unique(gang);
                uniq_gang = uniq_gang(uniq_gang ~= 0); 
                % Now cycle thru them and substitute the values
                for gang_loop = uniq_gang'
                    g_ind = find(gang==gang_loop);
                    for inner = 1:length(g_ind)
                      xeq(g_ind(inner)) = xeq(g_ind(1));
                    end
                end
            end

            if exitflag > 0
                if exitflag ~= 99 && ~isempty(output.bestfeasible) &&  any(output.bestfeasible.x-x)...
                    && ((fval > output.bestfeasible.fval) && output.bestfeasible.constrviolation <1e-6)
                    xeq_alt = X0;
                    xeq_alt(FreeVar) = output.bestfeasible.x;
                    
                    if any(gang)
                        % First find the unique (non-zero gang vector entries)
                        uniq_gang = unique(gang);
                        uniq_gang = uniq_gang(uniq_gang ~= 0); 
                        % Now cycle thru them and substitute the values
                        for gang_loop = uniq_gang'
                            g_ind = find(gang==gang_loop);
                            for inner = 1:length(g_ind)
                                xeq_alt(g_ind(inner)) = xeq(g_ind(1));
                            end
                        end
                    end

                    XEQ(jj,:,kk,ii) = [ TRIM_POINT xeq' ];
                    
                    % Store all results regardless of convergence status
                    XEQ_All(jj,:,kk,ii) = [ TRIM_POINT xeq_alt' ];
                else % no feasible solution was returned
                    XEQ(jj,:,kk,ii) = [ TRIM_POINT xeq' ];
                    XEQ_All(jj,:,kk,ii) = [ TRIM_POINT xeq' ];
                end
            else % no solution and no best feasible
                XEQ_All(jj,:,kk,ii) = [ TRIM_POINT xeq' ];
            end
        end
    end
end

% Build XU0_interp
XEQ_slice = XEQ_All;
numPts   = size(XEQ_slice,1);
XU0_interp = zeros(12 + Ns + Np, numPts);

for i = 1:numPts
  X = XEQ_slice(i,1:8);
  U = XEQ_slice(i,9:end);

  ubar = X(1);
  wbar = X(2);
  th   = X(4);
  phi  = X(5);
  psi  = 0;
  p    = X(6);
  q    = X(7);
  r    = X(8);

  vbar = [ubar; 0; wbar];
  om   = [p; q; r];
  ab   = [-GRAV*sin(th);
           GRAV*cos(th)*sin(phi);
           GRAV*cos(th)*cos(phi)];
  eta  = [phi; th; psi];

  del = U(1:Ns);
  omp = U(Ns+1:Ns+Np);

  XU0_interp(:,i) = [ vbar; om; ab; eta; del(:); omp(:) ];
end

save(out_file, 'XU0_interp', 'R', 'UH', 'WH', '-v7.3');

end
