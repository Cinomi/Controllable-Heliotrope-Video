% function used to find shortest path
% Input ******************************************
% start_pix -- start point (row,col) of path
% expect_pix -- expected point of path destination
% paths -- path set
% flows_a -- optical flow
% Output *****************************************
% min_idx -- index of shortest path in path set
% estimate_x -- x coordinate of last point of shortest path
% estimate_y -- y coordinate of last point of shortest path
function [min_idx,estimate_x, estimate_y] = find_min_path(start_pix, expect_pix, paths, flows_a)
    % set of last pixs for each path
    last_pixs = zeros(length(paths),2);
    
    for i = 1:length(paths)
        current_path = paths{i};
        current_pix = start_pix;
        if length(current_path)>1
            for j=1:length(current_path)-1
                current_pos = round(current_pix);
                if current_pos(1)<0
                    current_pos(1)=1;
                elseif current_pos(2)<0
                    current_pos(2)=1;
                end
                if current_path(j)>current_path(j+1)
                    idx_k = (current_path(j)-1)*(current_path(j)-2)/2+current_path(j+1);
                    %current_pos = round(current_pix);                          % position of current pixel in image
                    flow_vx = flows_a(current_pos(1),current_pos(2),1,idx_k);  % flows(x,y,vx,vy,idx_k)
                    flow_vy = flows_a(current_pos(1),current_pos(2),2,idx_k);  % get vx and vy through optical flow
                else
                    idx_k = ((current_path(j+1)-1)*(current_path(j+1)-2))/2+current_path(j);
                    %current_pos = round(current_pix);
                    flow_vx = -flows_a(current_pos(1),current_pos(2),1,idx_k);
                    flow_vy = -flows_a(current_pos(1),current_pos(2),2,idx_k);
                end
                current_pix = current_pix + [flow_vy, flow_vx];
            end
            last_pixs(i,:) = current_pix;    % add last pixel of current path to set
        else
            last_pixs(i,:) = current_pix;
        end    
    end
    dist_toExpect = sqrt(sum((last_pixs-repmat(expect_pix,length(paths),1)).^2,2));    
    [min_dist, min_idx] = min(dist_toExpect);       % get the path whose last pixel is cloest to expect one
    estimate_x = last_pixs(min_idx,2);
    estimate_y = last_pixs(min_idx,1);
end