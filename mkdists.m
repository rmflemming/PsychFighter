clear all;

% hyper params
tf = 5; % length of trial (s)
t = linspace(0,tf,100); % discrete time points in trial
mu_a = 2.5; % mean of attack dist
sig_a = .2; % std of attack dist

mu_t = 0; sig_t = 1; % trialwise variance params
lambda = 7; % poisson parameter

nsamples = 1000; % length of samples of the dists
c = 0.02; % slope of rt cost  
c_0 = 0.15; % intercept of rt cost

% Generate seed values
attk_i = normrnd(mu_a,sig_a,nsamples,1);
strat = (betarnd(0.5,0.5,nsamples,1) - 0.5);
t = linspace(0,tf,nsamples);
cost = c*t + c_0;

strat2 = poissrnd(lambda,nsamples,1); % these two lines are for second way
trial_var = normrnd(mu_t,sig_t,nsamples,1); % of ai changes in strategy

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

strat2_file = fopen('strat2.txt','w');
fprintf(strat2_file, '%f\n', strat2);
fclose(strat2_file);

tvar_file = fopen('trialvar.txt','w');
fprintf(tvar_file, '%f\n', trial_var);
fclose(tvar_file);