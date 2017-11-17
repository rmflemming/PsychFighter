clear all;

% hyper params
tf = 5;
t = linspace(0,tf,100);
mu_a = 2.5;
sig_a = .2;
nsamples = 1000;
c = 0.02;
c_0 = 0.15;

% Generate seed values
attk_i = normrnd(mu_a,sig_a,nsamples,1);
strat = (betarnd(0.5,0.5,nsamples,1) - 0.5);
t = linspace(0,tf,nsamples);
cost = c*t + c_0;

for i= 1:nsamples
    if attk_i(i) <= 0
        attk_i(i) = 0 + rand()*mu_a;
    elseif attk_i(i) >= tf - 0.01
        attk_i(i) = tf - rand()
    end
end

% save
attk_file = fopen('init_attack.txt','w');
fprintf(attk_file,'%f\n', attk_i);
fclose(attk_file);

strat_file = fopen('strat.txt','w');
fprintf(strat_file, '%f\n', strat);
fclose(strat_file);

cost_file = fopen('init_cost.txt','w');
fprintf(cost_file, '%f\n', cost);
fclose(cost_file);