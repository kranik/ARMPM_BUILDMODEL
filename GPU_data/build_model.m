function [m, maxcorr, maxcorrindices, avgcorr] = build_model(X,Y)
#   Build linear regression model of form y = f(x)
#
###########################################################
#   Inputs:
#   X   L by M matrix of activity vectors (regressors).
#       Each row of this matrix is an activity vector.
#   Y   L by 1 vector of dependent variables (regressand).
#       Each row of this is the correspong Power or Energy
#       consumption of the activity vectors.
#
#   Where:
#   L   Number of samples used for regression.
#   M   Number of activity measures in an activity vector.
#       lengthgth of activity vector.
#
###########################################################
#   Outputs:
#   m       M by 1 vector of Model coefficients. LS optimal
#           estimator of the model coefficients. Y ~ X*m,
#           and (Y-X*m)'*(Y-Xm) is minimal.
#   Err     L by 1 vector of % modelling error (X*m-Y)./Y
#   CLow    Lower endpoints of 95% confidence intervals
#   CHigh   Higher endpoints of 95% confidence interals

 #disp("hello5");

    maxcorr=0.0;
    totalcorr=0.0;
    numcorr=0;
    combination_indices = nchoosek(1:size(X,2),2);

	#disp("hello6");

	#disp(size(combination_indices,1));


    for ii = 1:size(combination_indices,1)
	#disp("hello8");

        if (std(X(:,combination_indices(ii,1))) != 0 && std(X(:,combination_indices(ii,2))) != 0)  # chech that columns are not constant
            cc = corr(X(:,combination_indices(ii,1)),X(:,combination_indices(ii,2)));   # calculate correlation coefficient
            totalcorr=totalcorr+abs(cc);
            numcorr++;

	#disp("hello7");
	
            if (abs(cc) > 0.0)
		#disp("hello9");

                 #disp(["Warning: correlation between activity measures " mat2str(combination_indices(ii,:)) " is " num2str(cc)]);
	
		#disp(["Warning: correlation between activity measures ",mat2str(combination_indices(ii,:))," is "]);
		#disp(["Warning: correlation between activity measures "]);
		printf("Warning: correlation between activity measures %s is %s \n", mat2str(combination_indices(ii,:)),num2str(cc));

		#disp("hello10");

                 if ( abs(cc) > maxcorr )
                      maxcorr=abs(cc);
                      maxcorrindices=(combination_indices(ii,:).-1);
                 endif
                 
            endif
	#disp("ok");
        endif
    endfor

#disp("hello9");

    

    avgcorr=totalcorr/numcorr;

    m   = inv(X'*X)*X'*Y;   # calculate model coefficients


    Err = (X*m-Y)./Y;       # valculate % model error

    epsilon     = Y-X*m;
    s_square    = 1/(length(Y) - length(m))*epsilon'*epsilon;
    sig_square  = (length(Y)-length(m))/length(Y)*s_square;
    Qxx         = cov(X,X)+mean(X)'*mean(X);

    d           = diag(inv(Qxx));

    Alpha = 0.05;           # 1-Alpha = Confidence level

    CLow        = m - norminv(1-Alpha/2)*sqrt(1/length(Y).*sig_square.*d);
    CHigh       = m + norminv(1-Alpha/2)*sqrt(1/length(Y).*sig_square.*d);

    #disp("hello10");
