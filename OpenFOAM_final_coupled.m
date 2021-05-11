clc;
clear all;
%% Coupled MATLAB OpenFOAM model

%Step 1: Pick a velocity of U
U=0.0853; %in m/s

%Step 2: Select the best concentration profile
%Profile concentration selected is 30% H2 and 70% He 

%Step 3: Obtain the temperature and concentration profiles from OpenFOAM

%Step 4: Obatin dT/dr from OpemFOAM
dT_dr= 595.3; %in K (483.367223)(527.75) (575.39691)

%Step 5: Determine the value of thermal conductivity k near the droplet surface using profile from OpenFOAM and birthforths model
Cp_online= 0.918; %in KJ/kg*K
Cp_birdforth= 0.00025706952; %in KJ/kg*K. Actual value is 0.00006139999999999999 cal/gm*K

%Step 6: Calculate Cp*dt_dr 
Kappa_online= Cp_online*dT_dr;
Kappa_birdforth= Cp_birdforth*dT_dr;

%Step 7: Compute the desired parameters
h_fg= 271.013;%in KJ/kg (213)
rs= 0.015;%in m
m_dot= Kappa_online*dT_dr*4*pi*rs^2/h_fg;
m_dot_birdforth= Kappa_birdforth*dT_dr*4*pi*rs^2/h_fg;

%Step 8: Compute U
rho_l=3.941; %in kg/m3
rho_l_new= 1.283; 
U_new= m_dot_birdforth/((4*pi).*(rs.^2)*rho_l);

%Step 9: Determine kg
kg= m_dot_birdforth*h_fg/(4*pi*dT_dr*rs^2);

%Step 10: Determine the transfer number
c_pg= 1.850; %in kJ/kg*K
Bq=1+ exp(m_dot_birdforth*c_pg/(4*pi*kg*rs));

%Step 11: Determine the evaporation constant
rho_l= 1000; % Density of water in kg/m3
K= 8*kg*log(Bq+1)/(rho_l*c_pg);

%Step 12: Compute the D2 Law and plot it
t= 0:0.01:1.23;
D_squared_t= 4*rs^2- K*t;
td= 4*rs^2/K;% droplet lifetime (s)
plot(t,D_squared_t)
xlim([0 1.25])
ylim([0 9*10^-4])
ylabel("D2 (m2)")
xlabel("Time (s)")
title("D2-Law")

%% OpenFOAM Calculations

%Step 1: Compute the desired parameters
h_fg= 271.013;%in KJ/kg (213)
rs= 0.015;%in m
dT_dr= 595.3;
Q_dot_OpenFoam= 1.6*10^6; %in kJ/kg*s
m_dot_OpenFOAM= Q_dot_OpenFoam/h_fg;

%Step 2: Determine kg
kg= m_dot_OpenFOAM*h_fg/(4*pi*dT_dr*rs^2);

%Step 10: Determine the transfer number
c_pg= 1.850; %in kJ/kg*K
Bq_OpenFOAM=1+ exp(m_dot_OpenFOAM*c_pg/(4*pi*kg*rs));

%Step 11: Determine the evaporation constant
rho_l= 1000; % Density of water in kg/m3
K_OpenFOAM= 8*kg*log(Bq_OpenFOAM+1)/(rho_l*c_pg);

%Step 12: Compute the D2 Law and plot it
t= 0:0.01:3;
D_squared_t= 4*rs^2- K_OpenFOAM*t;
td= 4*rs^2/K_OpenFOAM;% droplet lifetime (s)
plot(t,D_squared_t)
