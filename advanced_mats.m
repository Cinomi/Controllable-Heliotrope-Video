% function used to compute distance matrix (advenced section)
% Input ******************************************************
% seq -- image sequence
% flows_a -- optical flow
% Output *****************************************************
% advanced_dist -- distance matrix
function [advanced_dist] = advanced_mats(seq, flows_a)
    
    [height, width, ~, N] = size(seq);
    total = height * width;
    advanced_dist = zeros(N,N);
    
    % construct distance matrix
    for j=1:N
        for i=1:N
            diff_rgb = (seq(:,:,:,i) - seq(:,:,:,j)).^2;
            diff_rgb_sum = sum(diff_rgb(:))/total;
            
            if j~=i
                 if j>i
                    idx_k = (j-1)*(j-2)/2+i;
                    diff_vx = flows_a(:,:,1,idx_k).^2;
                    diff_vy = flows_a(:,:,2,idx_k).^2;
                 else
                    idx_k = (i-1)*(i-2)/2+j;
                    diff_vx = flows_a(:,:,1,idx_k).^2;
                    diff_vy = flows_a(:,:,2,idx_k).^2;
                 end
                 diff_vx_sum = sum(diff_vx(:))/total;
                 diff_vy_sum = sum(diff_vy(:))/total;
            else
                diff_vx_sum = 0;
                diff_vy_sum = 0;
            end
            
            advanced_dist(i,j) = sqrt(diff_rgb_sum+diff_vx_sum+diff_vy_sum);
        end
    end
    advanced_dist = advanced_dist/max(advanced_dist(:));
end