close all;

% Extract the data
surfCmd = logsout{1}.Values.Control.Cmd.CtrlSurfaceCmd;
surfAct = logsout{1}.Values.Vehicle.SurfAct.Position;
engAct  = logsout{1}.Values.Vehicle.PropAct.EngSpeed;
engCmd = logsout{1}.Values.Control.Cmd.EngineCmd;

% Convert deflections
degCmd       = surfCmd;
degAct       = surfAct;
degCmd.Data  = surfCmd.Data * 180/pi;
degAct.Data  = surfAct.Data * 180/pi;

% Convert propeller speeds to rpm
rpmAct          = engAct;
rpmCmd          = engCmd;
rpmAct.Data     = rpmAct.Data * 60/(2*pi);
rpmCmd.Data     = rpmCmd.Data * 60/(2*pi);

% Convert limits
hiDeg = SimIn.Act.PosLim_hi * 180/pi;
loDeg = SimIn.Act.PosLim_lo * 180/pi;

hiRPM = SimIn.Eng.PosLim_hi * 60/(2*pi);
loRPM = SimIn.Eng.PosLim_lo * 60/(2*pi);

% Control surface figure
figure('Name','Control Surfaces','NumberTitle','off'); clf;

% Flaperons (L & R)
subplot(3,1,1);
plot(degCmd.Time, degCmd.Data(:,1), '--', ...
     degCmd.Time, degCmd.Data(:,2), '--', ...
     degAct.Time, degAct.Data(:,1), ...
     degAct.Time, degAct.Data(:,2));
title('Flaperons');  ylabel('Deflection (deg)'); grid on;
legend({'Cmd L','Cmd R','Act L','Act R'}, 'Location','best');
ylim([min(loDeg(1:2))  max(hiDeg(1:2))]);

% Elevators (L & R)
subplot(3,1,2);
plot(degCmd.Time, degCmd.Data(:,3), '--', ...
     degCmd.Time, degCmd.Data(:,4), '--', ...
     degAct.Time, degAct.Data(:,3), ...
     degAct.Time, degAct.Data(:,4));
title('Elevators');  ylabel('Deflection (deg)'); grid on;
legend({'Cmd L','Cmd R','Act L','Act R'}, 'Location','best');
ylim([min(loDeg(3:4))  max(hiDeg(3:4))]);

% Rudder
subplot(3,1,3);
plot(degCmd.Time, degCmd.Data(:,5), '--', ...
     degAct.Time, degAct.Data(:,5));
title('Rudder');  ylabel('Deflection (deg)'); xlabel('Time [s]'); grid on;
legend({'Cmd','Act'}, 'Location','best');
ylim([loDeg(5)  hiDeg(5)]);

% Engine figure
figure('Name','Propeller & Pusher RPM','NumberTitle','off'); clf;

% 8 vertical propellers
subplot(2,1,1);  hold on;
plot(rpmAct.Time, rpmAct.Data(:,1:8));
% plot(rpmCmd.Time, rpmCmd.Data(:,1:8), '--');
title('Vertical Propellers (1-8)');  ylabel('Speed (RPM)'); grid on;
legend( ...
    [arrayfun(@(k)sprintf('Act P%d',k),1:8,'UniformOutput',false)], ...
     ...arrayfun(@(k)sprintf('Cmd P%d',k),1:8,'UniformOutput',false)], ...
    'Location','eastoutside');
ylim([min(loRPM(1:8)) max(hiRPM(1:8))]);

% pusher propeller
subplot(2,1,2);  hold on;
plot(rpmCmd.Time, rpmCmd.Data(:,9), '--');
plot(rpmAct.Time, rpmAct.Data(:,9));
title('Pusher Propeller'); ylabel('Speed (RPM)'); xlabel('Time [s]'); grid on;
legend({'Cmd','Act'},'Location','best');
ylim([loRPM(9) hiRPM(9)]);
