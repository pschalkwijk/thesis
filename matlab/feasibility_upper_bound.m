function feas = feasibility_upper_bound(tau, l, sigma, N, n, L, Q, region, ops, tol, nu)

Phi = Phi_fun_etc(tau,l,sigma,N,L);  % Note: here again l_star is used instead of l!
clear r
con_break = 0;                        % Loop break condition
r = zeros(N+1,1);
y = floor(tau*l/sigma);
for z=1:N+1                  
    clear U e
    e = sdpvar((n-1),1);  % Generate (n-1) scalars e(psilon)                    
%     Q_seq = region(:,mm);      % Find combination of Q-matrices corresponding to current region
    Q_found = cell((n-1),1);
    % Read Q-matrices belonging to current region
    for i = 1:(n-1)    
        index_Qfound = region(i,1);              
        Q_found{i,1} = Q{index_Qfound,1};     
    end
     % Convert 2x2 Q-matrices to nxn matrices by adding zeros at indices of states that are NOT considered

    Q_LMI = cell((n-1),1);
    for i = 1:(n-1)                         
        Q_2D = Q_found{i,1};
        Q_nD = zeros(n,n);
        Q_nD(i,i) = Q_2D(1,1);
        Q_nD(i,i+1) = Q_2D(1,2);
        Q_nD(i+1,i) = Q_2D(2,1);
        Q_nD(i+1,i+1) = Q_2D(2,2);
        Q_LMI{i,1} = Q_nD;                     
    end                           
    inEq = 0;
    for i = 1:(n-1)                                
        inEq = inEq + e(i)*Q_LMI{i,1};    % Build up LMI from combination of 2D Q-matrices and scalars e(psilon)                          
    end
    Con_e = [e(:)>=tol, (Phi{z,y+1}+nu*eye(n)-inEq)>=10^(-5)];
    diag_sol = solvesdp(Con_e,[],ops);
    %epsilon_upper = [epsilon_upper, double(e)];
    if diag_sol.problem == 0
        r(z,1) = 1;
        %yalmiperror(diag_sol.problem)
        %ff
    else
        break;
    end
end   
feas = (sum(r) ~= N+1);
end