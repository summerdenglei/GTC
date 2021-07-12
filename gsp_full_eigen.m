function [U,E] = gsp_full_eigen(L)
%GSP_FULL_EIGEN Compute and order the eigen decomposition of L

    % Compute and all eigenvalues and eigenvectors 
%     try
%         [eigenvectors,eigenvalues]=eig(full(L+L')/2);
%     catch
        [eigenvectors,eigenvalues,~]=svd(full(L+L')/2);
%     end
    
    % Sort eigenvectors and eigenvalues
    [E,inds] = sort(diag(eigenvalues),'ascend');
    eigenvectors=eigenvectors(:,inds);
    
    % Set first component of each eigenvector to be nonnegative
    signs=sign(eigenvectors(1,:));
    signs(signs==0)=1;
    U = eigenvectors*diag(signs);
end