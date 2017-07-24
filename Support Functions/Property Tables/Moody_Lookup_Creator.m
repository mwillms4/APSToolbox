% Generate a Moody Diagram Lookup Table using the "Hydro Scheme Designer" Functions

%% Create the table

Re_vec = 1000:500:500000;
eD_vec = .000001:.001:.05;

f = zeros(length(Re_vec),length(eD_vec));

for i=1:length(Re_vec)
    for j=1:length(eD_vec)
        f(i,j) = moody(eD_vec(j),Re_vec(i));
    end
end

%% Evaluate

Re = 2000;
eD = .02;
test  = qminterp2(eD_vec, Re_vec, f, eD, Re);
test2 = moody(eD,Re);

surf(f)

%% Save
Moody.f      = f;
Moody.Re_vec = Re_vec;
Moody.eD_vec = eD_vec;

save('Moody','Moody')