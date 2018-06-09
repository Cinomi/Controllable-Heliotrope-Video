% function used to compute distance matrix (basic section)
% Input ***************************************************
% seq -- image sequence
% Output **************************************************
% dist_mat -- distance matrix
function [dist_mat]=basic_mats(seq)

    [height, width, ~, N] = size(seq);
    total = height*width;
    dist_mat = zeros(N, N);
    
    % construct distance matrix
    for j=1:N
        for i=1:N
            dist = abs(seq(:,:,:,i) - seq(:,:,:,j));
            dist_mat(i,j) = sum(dist(:))/total;
        end
    end
    dist_mat = dist_mat/(max(dist_mat(:)));

%     for j=1:N
%         for i=1:N
%             diff_r = (seq(:,:,1,i)-seq(:,:,1,i)).^2;
%             diff_g = (seq(:,:,2,i)-seq(:,:,2,j)).^2;
%             diff_b = (seq(:,:,3,i)-seq(:,:,3,j)).^2;
%             
%             diff_r_sum = sum(diff_r(:))/total;
%             diff_g_sum = sum(diff_g(:))/total;
%             diff_b_sum = sum(diff_b(:))/total;
%             
%             dist_mat(i,j) = sqrt(diff_r_sum+diff_g_sum+diff_b_sum);
%         end
%     end
%     dist_mat = dist_mat/max(dist_mat(:));
end