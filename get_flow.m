% function used to get flows for given image sequence
% Input **************************************************
% seq -- image sequence
% Output *************************************************
% flows_a -- output flows
function [flows_a] = get_flow(seq)

    [height,width,~,N] = size(seq);
    flows_a = zeros(height, width, 2, N*(N-1)/2);
    
    % set parameters
    alpha = 0.012;     % the regularization weight
    ratio = 0.75;      % the downsample ratio
    minWidth = 20;     % the width of the coarest level
    nOuterFPIterations = 7;     % the number of outer fixed point iterations
    nInnerFPIterations = 1;     % the number of inner fixed point iterations
    nSORIterations = 30;        % the number of SOR iteration
    
    para = [alpha, ratio, minWidth, nOuterFPIterations, nInnerFPIterations, nSORIterations];
   
    idx_k = 1;        
    for i=2:N
       for j=1:i-1
           im1 = seq(:,:,:,i);
           im2 = seq(:,:,:,j);
           [vx, vy, ~] = Coarse2FineTwoFrames(im1, im2, para);
           flows_a(:,:,1,idx_k) = vx;
           flows_a(:,:,2,idx_k) = vy;
           idx_k = idx_k + 1;
        end
    end       
end