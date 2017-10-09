function [ k_optim, eta_optim ] = otsu( I )
%   OTSU calculates the optimal histogram threshold following Otsu's paper
%   k_optim is the optimal threshold computed from the image I
%   eta_optim is the separability measure at k_optim in otsu's method
    
    I=double(I); % just to be sure

    nb_px = size(I(:),1);
    histo=hist(I(:),255)/nb_px;
    
    i=(1:255);
    mu_t = sum(i.*histo); 
    MU_T = ones(1,255)*mu_t;
    sigma_T2 = sum((i-MU_T).^2*histo(:)); % total variance (squared)
    
    % we search the maximum value of sigma_B^2 sequentially
    
    k_optim = 0;
    sigma_B2_max = 0; % max value of the inter-class variance (squared)
    for k=1:255
        % we compute the inter-class variance : sigmaB^2 = w0*w1*(mu1-mu0)^2
        % with w0=wk, w1=1-wk, mu0=muk/wk, mu1=(muT-muk)/(1-wk).
        w_k = sum(histo(1:k));
        mu_k = sum(i(1:k).*histo(1:k));
        sigma_B2 = w_k*(1-w_k)*( (mu_t-mu_k)/(1-w_k) - (mu_k/w_k) )^2;
        
        if sigma_B2>sigma_B2_max
            sigma_B2_max=sigma_B2;
            k_optim = k;
        end
    end
    
    eta_optim = sigma_B2 / sigma_T2;
        
    


end

