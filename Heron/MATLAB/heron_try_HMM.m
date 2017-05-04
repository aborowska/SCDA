clear all
close all
N_max1 = 79;
N_max3 = 49;

logfact = @(x) sum(log(1:x));

T = 72;
sc = 100;

G1 = zeros((N_max1+1),T);
P2 = zeros((N_max1+1),T);
G3 = zeros((N_max3+1),T);
P4 = zeros((N_max3+1),T);
Q = zeros((N_max3+1),T);
 
time = 1:T;
time = (time-mean(time))/std(time);

% fdays:
fdays = [12, 26, 2, 9, 6, 8, 3, 2, 17, 3, 4, 8, 38, 12, 30, 3, 2, 15, 18, 46, 6,...  
         3, 6, 15, 6, 13, 17, 22, 22, 4, 11, 9, 2, 1, 22, 57, 12, 13, 13, 2, 15,...
         13, 20, 12, 3, 1, 5, 0, 6, 9, 11, 33, 7, 2, 27, 5, 7, 25, 30, 16, 3, 1,...
         1, 12, 12, 9, 6, 3, 18, 10, 0, 1];
f = (fdays-mean(fdays))/std(fdays);

y = round([0,4000, 3500, 3850, 4050, 4000, 4075, 4150, 4150, 4375, 4500, 4800, 4700, 3650, 3550, 3400, 3850, 4300,... 
       4075, 4125, 2700, 2800, 3575, 4100, 4550, 4700, 4575, 4800, 4425, 4150, 4500, 4075, 4550, 4350, 4675,...
       3700, 2250, 2450, 2825, 2925, 3225, 3725, 3925, 4125, 4575, 4625, 4925, 5175, 5100, 5075, 5125, 5375,... 
       5200, 5575, 5675, 5350, 5425, 5700, 5775, 5109, 5166, 5637, 5898, 6143, 5936, 6051, 6310, 6447, 6950,... 
       6570, 6653, 6940]/sc);
       
alpha = zeros(4,1);
beta = zeros(4,1);
alphal = 0;
betal = 0;
alpharho = 0;
tauy = 1;%10;%1000;

% alpha = [-0.55, -0.1, 0.5, 1.1]';
% beta = [0.02, -0.15, -0.15, -0.2]';
% alphal = 1.65;
% betal = -0.2;
% alpharho = 1.1;
% tauy = 1000;

ind = alpha(1) + beta(1)*f;
phi1 = exp(ind)./(1+exp(ind));
ind = alpha(2) + beta(2)*f;
phi2 = exp(ind)./(1+exp(ind));
ind = alpha(3) + beta(3)*f;
phi3 = exp(ind)./(1+exp(ind));
ind = alpha(4) + beta(4)*f;
phi4 = exp(ind)./(1+exp(ind));
ind = alpharho*ones(1,T-1); 
rho = exp(ind);

C = 1000000;
pi = 3.14159265359;

dummy = zeros(1,T);
PHI = zeros(1,T);
loglik = zeros(1,T);
loglam1 = zeros(1,T-1); 


Up2 = 1000;
Up4 = 1000;
X2_prior = ones(1,Up2+1)/(Up2+1); 
X4_prior = ones(1,Up4+1)/(Up4+1); 


X1 = 1400*ones(1,T)/sc;
X1(2:T) = poissrnd([4000/sc,y(2:(T-1))*1.1],1,(T-1));

X2 = 1200*ones(1,T)/sc;
X2(2:T) = binornd(X1(1:(T-1)),0.5,1,(T-1));

X3 = 1000*ones(1,T)/sc;
X3(2:T) = binornd(X2(1:(T-1)),0.6,1,(T-1));

X4 = 900*ones(1,T)/sc;
X4(2:T) = binornd(X3(1:(T-1)),0.7,1,(T-1));


for t = 1:(T-1)
    loglam1(t) = log(X4(t)) + log(rho(t)) + log(phi1(t));
end

% for t = 1:T
%   Use a discrete Uniform prior so the only =fluence on the posterior distr is the Upper limit
%   X2(t) ~ dcat(X2_prior[]) % X2_prior = rep(1/(Up2+1), Up2+1); entered as data
%   X4(t) ~ dcat(X4_prior[]) % X4_prior = rep(1/(Up4+1), Up4+1); entered as data
% end

% prior for first transition/augmented observations/observation probabilities
for ii = 0:N_max1
    G1(ii+1,1) = 1/N_max1; % diffuse =itialisation
    P2(ii+1,1) = X2_prior(1);
end

for ii = 0:N_max3
    G3(ii+1,1) = 1/N_max3; % diffuse =itialisation
    P4(ii+1,1) = X4_prior(1);
    Q(ii+1,1) = exp(-tauy*((y(1) - (X2(1) + ii + X4(1))).^2)/2)*sqrt(tauy)/sqrt(2*pi);
end    


for t = 2:T
    for ii = 0:(N_max1-1)  % X1 (depends only on [imputed] X4)
        G1(ii+1,t)= exp(-exp(loglam1(t-1)) + ii*loglam1(t-1) - logfact(ii));
    end 
    G1((N_max1+1),t) = max(0,1- sum(G1((1:N_max1),t)));

    for ii = 0:(N_max3) % X3 (depends only on [imputed] X2) & y
        if ((X2(t-1) - ii)>0)
            G3(ii+1,t) = exp(ii*log(phi3(t-1)) + (X2(t-1) - ii)*log(1-phi3(t-1)) + logfact(X2(t-1)) - logfact(abs(X2(t-1)-ii)) - logfact(ii));
        else
            G3(ii+1,t) = 0;
        end
        Q(ii+1,t) = exp(-tauy*((y(t) - (X2(t) + ii + X4(t))).^2)/2)*sqrt(tauy)/sqrt(2*pi);
    end 
   
    for ii = 0:N_max1 % X2 (depends only on [=tegrated] X1)
        if ((ii - X2(t)) > 0)
            P2(ii+1,t) = exp(X2(t)*log(phi2(t-1)) + (ii - X2(t))*log(1-phi2(t-1)) + logfact(ii) - logfact(abs(ii - X2(t))) - logfact(X2(t)));
        else
            P2(ii+1,t) = 0;
        end
    end
    
    for ii = 0:(N_max3)  % X4 (depends on [=tegrated] X3)
        if ((ii + X4(t-1) - X4(t)) > 0)
            P4(ii+1,t) = exp(X4(t)*log(phi4(t-1)) + (ii + X4(t-1) - X4(t))*log(1-phi4(t-1)) + logfact(ii + X4(t-1)) - logfact(abs(ii + X4(t-1) - X4(t))) - logfact(X4(t)));
        else
            P4(ii+1,t)= 0;
        end       
    end
end

figure(200)
set(gcf, 'Units', 'normalized', 'Position', [0.1 0 0.9 1]);
subplot(2,3,1)
hold all
for t = 1:T
    plot(G1(:,t))
end
title('G1')

subplot(2,3,2)
hold all
for t = 1:T
    plot(G3(:,t))
end
title('G3')

subplot(2,3,4)
hold all
for t = 1:T
    plot(P2(:,t))
end
title('P2')

subplot(2,3,5)
hold all
for t = 1:T
    plot(P4(:,t))
end
title('P4')

subplot(2,3,6)
hold all
for t = 1:T
    plot(Q(:,t))
end
title('Q')

% [maxP2 , inP2] = max(P2);
% figure(11)
% plot(inP2)
% plot(X1,'r')
% plot(X2,'g')
% 
% figure(12)
% plot(phi2)

sumsum = zeros(1,T);
for t = 1:T
    sumsum(t) = exp(log(sum(G1(:,t) .* P2(:,t))) + log(sum(G3(:,t) .* P4(:,t) .* Q(:,t))));
    loglik(t) = log(sumsum(t));
    PHI(t) = -loglik(t) + C;
    dummy(t) = poisspdf(0,PHI(t));
end

LL = sum(loglik) 
% tauy = 10 --> LL = -Inf

% figure(2)
% plot(sumsum)
% 
% 
% theta_init = [alpha', beta', alpharho, tauy];
% loglik_heron_HMM_statespace = @(xx) -Heron_HMM_loglik_statespace(xx, N_max1, N_max3, y, f, X2, X4, X2_prior, X4_prior)/T;
% options = optimoptions('fminunc');%,'MaxFunEvals',2000,'MaxIter',1500);
% [theta_mle_ss, ~, ~, ~, ~, ~] = fminunc(loglik_heron_HMM_statespace, theta_init,options);
% 
