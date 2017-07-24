% Laminar Flow Lookups for Different Cross Sections

% see Incropera Table 8.1, p. 553
b_a  = [1    1.43 2    3    4    8    10000];
Nu   = [2.98 3.08 3.39 3.96 4.44 5.60 7.54];
f_Re = [57   59   62   69   73   82   96];

LamProps.b_a  = b_a;
LamProps.Nu   = Nu;
LamProps.f_Re = f_Re;

save('Laminar_Props','LamProps')