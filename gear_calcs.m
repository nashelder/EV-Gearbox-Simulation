%% Gear Design Tool - EV Transmission - ME 329 Lab
% Nash Elder
% June 5, 2020
% ME 329 Lab
clc;
clear;
close all;

%% Gear Geometry and Knowns

dp = 4.25; % Pinion Diameter [in]
dg = 6; % Gear Diameter [in]
P = 6; % Diametral Pitch [teeth/in]
f = 2; % Face Width [in]

np = P*dp; % Number of teeth on pinion
ng = P*dg; % Number of teeth on gear

phiN = 20; % Normal Contact Angle [degrees]
psi = 30; % Helix Angle [degrees]
phiT = atand(tand(phiN)/tand(psi)); % Tangent Contact Angle [degrees]

specMod = 0.292; % Specific Modulus of Steel
Esteel = 30*10^6; % Elastic Modulus Steel [Mpsi]

%% Pulling data from AC50 96v.XLSX (Motor Data)

% Using the Excel doc, a maximum power transferred to the gear was calculated 
% to occur initially, with maximum torque.

H = 1.17; % Motor Power [hp]
rpm = 48; % Motor Speed at Max Torque
v = pi() * dp * rpm / 12; % Pitchline Velocity [fpm]

%% Transferred Loads

wt = 33000*H / v; % Tangential Load [lbf]
wr = wt*tand(phiT); % Radial Load [lbf]
wa = wt*tand(psi); % 
w = sqrt(wt^2 + wr^2 + wa^2); % Total Load [lbf]

%% St and Sc

% Assuming grade 1 Steel from Fig 14.2, 200 Brinell hardness

hb = 200; % [Brinell hardness]
st = 77.3 * hb + 12800; % [psi]
sc = 322* hb + 29100; % [psi]
%% K Constants and Other Factors

ko = 1; % Overload Factor

%Dynamic Factor Calc.
Qv = 6; % Quality Factor
Bv = 0.25*(12-Qv)^(2/3);
Av = 50 + 56*(1-Bv);
kv = ((Av + sqrt(rpm))/Av)^Bv; % Dynamic Factor
ks = 1; % Size Factor

%Load Dist. Factor Calc.
cmc = 1; % Uncrowned Teeth
cpf = f/(10*dp) - 0.0375 - 0.0125*f;
cpm = 1;
Ac = 0.127;
Bc = 0.0158;
Cc = -0.930*10^(-4);
cma = Ac + Bc*f + Cc*f^2;
ce = 1;
km = 1 + cmc*(cpf*cpm + cma*ce); % Load Distribution Factor

kb = 1; % Rim Thickness Factor
cf = 1; % Surface Factor
kr = 0.85; % Reliability Factor for 90%
kt = 1; % Temperature Factor T < 250 deg. F
cp = sqrt(1/(pi()*((1-specMod^2)/Esteel + (1- specMod^2)/Esteel)));
ch = 1;
% Stress Cycle Factors where N = 10^7 Cycles
yN = 1;
zN = 1;

%% Geometry Factors

jPrimeP = 0.49; % Geometry Factor J' for Helical Pinion
jPrimeG = 0.50; % Geometry Factor J' for Helical Gear

mg = ng / np;
mn = 1;

I = (cosd(phiT)*sind(phiT) / (2*mn)) * (mg/(mg+1));

%% AGMA Stress Eqns. for Bending and Pitting (Actual)

sigmaP = wt * ko * kv * ks * (P / f) * (km * kb / jPrimeP);

sigmaG = wt * ko * kv * ks * (P / f) * (km * kb / jPrimeG);

sigmaCP = cp * sqrt(wt * ko * kv * ks * (km / (dp * f)) * (cf / I));

sigmaCG = cp * sqrt(wt * ko * kv * ks * (km / (dg * f)) * (cf / I));

%% Safety Factors

SFbendP = (st/sigmaP) * yN / (kt * kr);

SFbendG = (st/sigmaG) * yN / (kt * kr);

SFcP = (sc / sigmaCP) * (zN * ch / (kt * kr));
SFcG = (sc / sigmaCG) * (zN * ch / (kt * kr));

%% Results

%% PINION

fprintf('%f = Bending Stress', sigmaP); 
fprintf('%f = Contact Stress', sigmaCP);
fprintf('%f = SF Bending', SFbendP);
fprintf('%f = SF Contact', SFcP);

%% GEAR

fprintf('%f = Bending Stress', sigmaG); 
fprintf('%f = Contact Stress', sigmaCG);
fprintf('%f = SF Bending', SFbendG);
fprintf('%f = SF Contact', SFcG);
