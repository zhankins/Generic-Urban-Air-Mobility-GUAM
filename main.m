clc; close all; clearvars;

addpath('./Exec_Scripts/');
if ~exist("userStruct",'var')
    addpath('./Bez_Functions/');
end

%% network parameters

simAddress = '127.0.0.1';
simPortInput = 5502; % Port used for the simulator to send data
simPortOutput = 5501; % Port used for the simulator to receive data
simIsRemote = ~strcmp(simAddress, '127.0.0.1');

headsetAddress = '127.0.0.1';
headsetPortHUD = 25000;
headsetPortTraj = 25001;

%% sim parameters
model = 'GUAM';

userStruct.variants.fmType = 1; % 1=SFunction, 2=Polynomial
userStruct.variants.actType = 4; % 1=None, 2=FirstOrder, 3=SecondOrder, 4=FirstOrderFailSurf
userStruct.variants.propType = 2; % 1=None, 2=FirstOrder, 3=SecondOrder, 4=FirstOrderFailSurf
userStruct.variants.refInputType = 4; % 1=FOUR_RAMP, 2=ONE_RAMP, 3=Timeseries, 4=Piecewise Bezier, 5=Default(doublets)
userStruct.variants.turbType = 1; % 1=Off, 2=Light, 3=Moderate, 4=Severe

userStruct.switches.AeroPropDeriv = 1; % 1 or 0

%% initial conditions
% target = struct('tas', 0, 'gndtrack', 0,'stopTime', 30);
PW_Bezier_flag = 0; % Flag to denote failure of PW Bezier setup

kts2fts = 1852.0/(0.3048*3600);

% First setup initial conditions:
% pos in ft, vel in ft/sec, and acc in ft/sec^2
wptsX = [0 120*kts2fts 0; 2000 200 0]; % within row = pos vel acc
time_wptsX = [0 10];
wptsY = [0 0 0; 0 0 0]; % within row = pos vel acc
time_wptsY = [0 10];
wptsZ = [-1000 0 0; -580 0 0]; % within row = pos vel acc, NOTE: NED frame -z is up...
time_wptsZ = [0 20];

% Set desired Initial condition vars
target.RefInput.Vel_bIc_des    = [wptsX(1,2);wptsY(1,2);wptsZ(1,2)];
target.RefInput.pos_des        = [wptsX(1,1);wptsY(1,1);wptsZ(1,1)];
target.RefInput.chi_des        = 0;
target.RefInput.chi_dot_des    = 0;
target.RefInput.trajectory.refTime = [0 max([max(time_wptsX), max(time_wptsY), max(time_wptsZ)])];

% Store the PW Bezier trajectory in the target structure (used in RefInputs)
target.RefInput.Bezier.waypoints = {wptsX, wptsY, wptsZ};
target.RefInput.Bezier.time_wpts = {time_wptsX time_wptsY time_wptsZ};

clear wptsX wptsY wptsZ time_wptsX time_wptsY time_wptsZ 
userStruct.trajFile = ''; % Delete user specified PW Bezier file

%% start the simulation

SimIn.stopTime = 1000;
open(model);

% % Execute the model
% sim(model);
% % Create sample output plots
% simPlots_GUAM;
% % Create an animation of the flight
% Animate_SimOut;