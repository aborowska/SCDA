function [h, accept, A_sum, newloglik] = update_h_HMM_eff(y, h, theta, delta_h,  bins, bin_midpoint, oldloglik)
% integrate out the odd h(t)'s and impute the even ones
% oldloglik contains the values of the integrals wrt the odd h's
    T = length(y);
    odd = mod(T,2);    
    T2 = floor(T/2);
    T = 2*T2; % to make T even

%     bin_size = bin_midpoint(2)-bin_midpoint(1);
    
    mu = theta(1);
    phi = theta(2);
    sigma2 = theta(3);
    nu = theta(4);
    
    accept = 0;
    A_sum = 0;
    
    h0 = mu;  % unconditional mean

    mu_bin = (mu + bin_midpoint);
    exp_mu_bin = exp(mu + bin_midpoint);
    Gauss_const = - 0.5*(log(2*pi) + log(sigma2));
    T_const = gammaln((nu+1)/2) - gammaln(nu/2) -0.5*log((nu-2)*pi);

    newloglik = zeros(1,T2);
  
    for t = 2:2:T % 1:2:T    
        %% RW IMPUTATION
        % Keep a record of the current h value being updated
        h_old = h(t);
        % normal  RW for h
        h(t) = h_old + delta_h*randn;
        % Calculate the log(acceptance probability):
        % Calculate the new likelihood value for the proposed move:
        % Calculate the numerator (num) and denominator (den) in turn:

        %% Numerator
%         num = -0.5*(log(2*pi) + h(t) + (y(t)^2)/exp(h(t)));
        num = T_const -  h(t)/2 - ((nu+1)/2)*log(1+(y(t)^2)/((nu-2)*exp(h(t))));
        % integrate out the previous h 
        loglik_int = Gauss_const - 0.5*((h(t) - mu - phi*bin_midpoint).^2)/sigma2;
%         loglik_int = loglik_int - 0.5*(log(2*pi) + mu_bin + (y(t-1)^2)./exp_mu_bin);   
        loglik_int = loglik_int + T_const -  mu_bin/2 - ((nu+1)/2)*log(1+(y(t-1)^2)./((nu-2)*exp_mu_bin));
    %     loglik_int = loglik_int + log(diff(normcdf((bins-phi*(h_prev-mu))/sigma)));
        if (t==2)
            loglik_int = loglik_int + Gauss_const - 0.5*((bin_midpoint - phi*(h0-mu)).^2)/sigma2;
        else
            loglik_int = loglik_int + Gauss_const - 0.5*((bin_midpoint - phi*(h(t-2)-mu)).^2)/sigma2;
        end  
%         num = num + log(sum(exp(loglik_int)));
%         NNN =  log(sum(exp(loglik_int)));
        NNN = log(sum(exp(loglik_int)));
        num = num + NNN;
        
        % integrate out the next h 
        if (t<T)   % t+2 <= T
            loglik_int = Gauss_const - 0.5*((h(t+2) - mu - phi*bin_midpoint).^2)/sigma2;
%             loglik_int = loglik_int - 0.5*(log(2*pi) + mu_bin + (y(t+1)^2)./exp_mu_bin);    
            loglik_int = loglik_int  + T_const -  mu_bin/2 - ((nu+1)/2)*log(1+(y(t+1)^2)./((nu-2)*exp_mu_bin));    
    %     loglik_int = loglik_int + log(diff(normcdf((bins-phi*(h_prev-mu))/sigma)));
            loglik_int = loglik_int +  Gauss_const - 0.5*((bin_midpoint - phi*(h(t)-mu)).^2)/sigma2;
%             newloglik(1,t/2+1) = log(sum(exp(loglik_int)));
%             num = num + newloglik(1,(t/2)+1);
            num = num + log(sum(exp(loglik_int)));            
        end    
        
        %% Denominator
%         den = -0.5*(log(2*pi) + h_old + (y(t)^2)/exp(h_old));
        den = T_const -  h_old/2 - ((nu+1)/2)*log(1+(y(t)^2)/((nu-2)*exp(h_old)));

        % integrate out the previous h 
        loglik_int = Gauss_const - 0.5*((h_old - mu - phi*bin_midpoint).^2)/sigma2;
%         loglik_int = loglik_int - 0.5*(log(2*pi) + mu_bin + (y(t-1)^2)./exp_mu_bin);   
        loglik_int = loglik_int + T_const -  mu_bin/2 - ((nu+1)/2)*log(1+(y(t-1)^2)./((nu-2)*exp_mu_bin));

    %     loglik_int = loglik_int + log(diff(normcdf((bins-phi*(h_prev-mu))/sigma)));
        if (t==2)
            loglik_int = loglik_int + Gauss_const - 0.5*((bin_midpoint - phi*(h0-mu)).^2)/sigma2;
        else
            loglik_int = loglik_int + Gauss_const - 0.5*((bin_midpoint - phi*(h(t-2)-mu)).^2)/sigma2;
        end    
%         den = den + log(sum(exp(loglik_int)));
%         DDD = log(sum(exp(loglik_int)));
        DDD = log(sum(exp(loglik_int)));
        den = den + DDD;        
        
        % integrate out the next h 
        if (t<T)   % t+2 <= T
%             loglik_int = - 0.5*(log(2*pi) + log(sigma2) + ((h(t+2) - mu - phi*bin_midpoint).^2)/sigma2);
%             loglik_int = loglik_int - 0.5*(log(2*pi) + mu_bin + (y(t+1)^2)./exp_mu_bin);    
%     %     loglik_int = loglik_int + log(diff(normcdf((bins-phi*(h_prev-mu))/sigma)));
%             loglik_int = loglik_int - 0.5*(log(2*pi) + log(sigma2) + ((bin_midpoint - phi*(h_old-mu)).^2)/sigma2);
%             den = den + log(sum(exp(loglik_int)));                  
             den = den + oldloglik(t/2+1);
        end    
 
        %% Acceptance Rate
        % Proposal terms cancel since proposal distribution is symmetric.
        % All other prior terms cancel in the acceptance probability. 
        % Acceptance probability of MH step:
        A = min(1,exp(num-den));
 
        A_sum = A_sum + A;
        % To do the accept/reject step of the algorithm:        
        % Accept the move with probability A:
        if (rand <= A)  % Accept the proposed move:
            % Update the log(likelihood) value:
            accept = accept+1;
            newloglik(1,t/2) = NNN;
        else  % Reject proposed move:
            % h(t) stays at current value:
            h(t) = h_old;
            % loglik stays at current value:
            newloglik(1,t/2) = DDD;
        end              
    end
end
