function [ k_optim, eta_optim,sigmalist ] = otsu( I )
%   OTSU calculates the optimal histogram threshold following Otsu's paper
%   [ k_optim, eta_optim ] = otsu( I )
%   I is the original grey level image with values between 0 and 1.
%   k_optim is the optimal threshold computed from the image I
%   eta_optim is the separability measure at k_optim in otsu's method
    
    I=double(I); % just to be sure

    nb_px = size(I(:),1);
    histo=hist(I(:),255)/nb_px;
    
    % mu_t is the mean value of the entire histogram
    i=(1:255);
    mu_t = sum(i.*histo); 
    MU_T = ones(1,255)*mu_t;

    % total variance (squared)
    sigma_T2 = sum((i-MU_T).^2*histo(:)); 
    
    % sigma_B2 is the inter-class variance : sigmaB^2 = w0*w1*(mu1-mu0)^2 with w0 and 
    % w1 the probability of occurence of the class 1 and 2, mu1 and mu2 are the mean 
    % values of the two clusters

    % we search the maximum value of sigma_B^2 sequentially : maximizing sigma_B^2 is 
    % equivalent to maximizing the separability measure eta, since 
    % eta=(sigmaB)^2/(sigmaT)^2 and sigmaT does not depend on k.
    k_optim = 0;
    sigma_B2_max = 0; 
    sigmalist=[];
    for k=1:255
        % we compute the inter-class variance : 
        % with w0=wk, w1=1-wk, mu0=muk/wk, mu1=(muT-muk)/(1-wk).
        w_k = sum(histo(1:k));
        mu_k = sum(i(1:k).*histo(1:k));
        sigma_B2 = w_k*(1-w_k)*( (mu_t-mu_k)/(1-w_k) - (mu_k/w_k) )^2;
        sigmalist=[sigmalist,sigma_B2];
        if sigma_B2>sigma_B2_max
            sigma_B2_max=sigma_B2;
            k_optim = k/255; % les images sont entre 0 et 1
        end
    end
    
    % we calculate eta
    % it can be useful for the evaluation of the quality of the segmentation (if eta is
    % small, it is likely that thresholding methods won't give good results)
    eta_optim = sigma_B2_max / sigma_T2;       
end

