%% EV Transmission Engineering Tool
% Nash Elder
% ME 329, Dr. Mello

%% Mass Terms

g = 32.2; % [ft/s^2] Acceleration due to gravity

mCar = 1250/g; % [slug] Previous total mass with ICE
mChassis = 650/g; % [slug] Chassis mass (given)
mBattery = 275/g; % [slug] Battery mass
% Quantity of 5 Tesla Model S cells (55 lb per cell) 
mDriver = 130*2/g; % [slug] Driver mass (estimate)
mBike = 50/g; % [slug] Bike + bike rack mass (estimate)
mTire = 40/g; % [slug] Tire mass (estimate)

%% Inertia Terms

rTire = 21.75/2; % [in] Tire rolling diameter
dGear = 1.4; % [in]
dPinion = 1; % [in]

im = 1.5/12; % [lb ft s^2] Motor inertia (given)
id = 1.6/12; % [lb ft s^2] Driveshaft inertia (given)
% it = mTire*rTire^2; 
it = 5/12; % [lb ft s^2] Tire inertia

%% Gear Ratios

ratioA = 3.45; % Axle gear ratio(given)
ratioT = dGear/dPinion; % Transmission gear ratio

%% Mass Effective

mTotal = mChassis +mBattery + mDriver + mBike;
mEff = mTotal + (1/(rTire/12)^2)*(it+(id*ratioA^2)+(im*(ratioA*ratioT)^2)); % [slug] Effective mass
disp('mEff (slug) = ')
disp(mEff);
% See hand calculations for derivation of mEff
w = mEff*g; % [lbm] Effective weight

%% Motor Data

tm = [127.59
127.59
127.59
127.59
127.59
126.70
126.70
126.70
125.82
124.93
123.31
121.54
120.66
119.77
119.77
119.77
118.89
118.89
118.89
118.00
118.00
118.00
118.00
118.00
118.00
118.00
118.00
118.00
118.00
118.00
118.00
118.00
117.12
117.12
117.12
117.12
117.12
117.12
117.12
116.23
116.23
116.23
116.23
114.31
111.95
109.30
103.99
101.33
98.09
95.29
91.75
89.24
86.58
81.86
79.65
76.11
73.46
70.80
68.15
66.52
61.21
59.44
57.67
56.05
54.28
52.51
50.74
47.20
46.32
44.69
42.92
41.15
40.42
39.38
37.61
35.84
34.96
33.34
32.45
31.57
30.68
29.80
28.03
27.14
26.26
25.37
24.19
22.57
21.98
21.09
21.09
20.21
19.32
18.44];
wm = [48
51
52
55
58
55
48
108
202
280
362
521
604
684
769
846
927
1005
1170
1251
1330
1413
1493
1575
1651
1812
1895
1976
2056
2136
2216
2296
2469
2561
2654
2746
2840
2928
3019
3197
3280
3348
3419
3496
3573
3645
3794
3856
3937
4002
4078
4153
4224
4372
4449
4524
4602
4670
4757
4825
4984
5062
5149
5216
5311
5382
5456
5626
5699
5793
5868
5952
6012
6095
6187
6343
6411
6509
6568
6672
6740
6830
6981
7073
7132
7237
7405
7573
7621
7729
7788
7879
7935
8000];

v = ((wm/60)*2*pi()*rTire/12)/(ratioT*ratioA); % [ft/s] Car's linear velocity

%% Aerodynamic Drag Force›

rho = 0.0765/g; % [slug/ft^3] Density of air
cd = 0.66; % Drag coefficient (given)
aFront = 19.50; % [ft^2] Frontal car area (given)

rAero = 0.5*rho*(v.*(5280/3600)).^2*aFront*cd; % [lbf] Drag force

%% Rolling Resistance

fo = 0.02; % [] (parameter given)
fs = 0.0025; % [] (parameter given)

fr = fo + 3.24*fs*((v.*(5280/3600))/100).^2.5; % [lbf] (from Gillespie)
rRollingr = fr*mEff*g; % [lbf] Reaction, rolling rear
rRollingf = rRollingr; % [lbf] Reaction, rolling front 
% Note: Flat ground makes front and rear equal

%% Tractive Force Limit of Wheels and Motor

mu = 0.8; % [] Tire grip traction limit
cg = 20/12; % [in] Center of gravity (given)
l = 94/12; % [in] Wheel base (given)

wR = 4/l*(l/2*w + cg*rAero+cg*mEff*aFront); % [lbf] Dynamic weight

ftl = (mu/l*(l/2*w+cg*rAero))/(1-mu*cg/l); % [lbf] Tractive Force Limit
ftm = ratioT*ratioA*tm/(rTire/12); % [lbf] Motor Limit
fTract = min(ftl,ftm); % [lbf]

torque = tm*ratioA*ratioT/(rTire/12);
torqueMax = max(torque);
disp('Tmax (lbf ft) = ');
disp(torqueMax);
Fnet
fNet = abs(fTract - rAero - rRollingr - rRollingf);
fNetmax = max(fNet);

disp('Max Force (lbf) = ')
disp(fNetmax);

%% TTS 0-60

i = 1;
dT = 0;
for i = 1:48
    
    fStep = ((mEff/fNet(i)) + (mEff/fNet(i+1)))/2;

    dV = v(i+1) - v(i);
    
    dT = dT + fStep*dV;
    
end
disp('0-60 t = ');
disp(dT);

%% TTS 65-75

i = 1;
dT2 = 0;
for i = 52:60
    
    fStep = ((mEff/fNet(i)) + (mEff/fNet(i+1)))/2;

    dV2 = v(i+1) - v(i);
    
    dT2 = dT2 + fStep*dV;
    
end
disp('65-75 t = ');
disp(dT2);

