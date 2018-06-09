% function uesd for multi-node interpolation
% Input ******************************************************
% seq -- image sequence
% last_img_idx -- index of end image of closest path
% min_idx2 -- index of second closest path
% min_idx3 -- index of third closest path
% flows_a -- flows matrix
% Output *****************************************************
% added_path -- computed additional interpolation frames
function [added_path] = multi_node_interpolation(seq, last_img_idx, min_idx2, min_idx3, flows_a)
    last_img = seq(:,:,:,last_img_idx);
    last_img = double(last_img);
    [height,width,dim] = size(last_img);
    
    % select vx and vy
    if last_img_idx>min_idx2
        idx_k2 = (last_img_idx-1)*(last_img_idx-2)/2+min_idx2;
        flow_vx2 = flows_a(:,:,1,idx_k2);
        flow_vy2 = flows_a(:,:,2,idx_k2);
    else
        idx_k2 = (min_idx2-1)*(min_idx2-2)/2+last_img_idx;
        flow_vx2 = -flows_a(:,:,1,idx_k2);
        flow_vy2 = -flows_a(:,:,2,idx_k2);
    end
    
    if last_img_idx>min_idx3
        idx_k3 = (last_img_idx-1)*(last_img_idx-2)/2+min_idx3;
        flow_vx3 = flows_a(:,:,1,idx_k3);
        flow_vy3 = flows_a(:,:,2,idx_k3);
    else
        idx_k3 = (min_idx3-1)*(min_idx3-2)/2+last_img_idx;
        flow_vx3 = -flows_a(:,:,1,idx_k3);
        flow_vy3 = -flows_a(:,:,2,idx_k3);
    end
    
    % flows from last_img to expected point
    used_vx = double(flow_vx2 + flow_vx3);
    used_vy = double(flow_vy2 + flow_vy3);
    
    % define added path
    f_num = round(max(max(used_vx(:)),max(used_vy(:))));
    if f_num>10
        f_num=10;
    end 
    added_path=zeros(height,width,dim,f_num+1);
    added_path(:,:,:,1) = last_img;
    
    [cord_x, cord_y] = meshgrid(1:width,1:height);
    seg_vx = used_vx/f_num;
    seg_vy = used_vy/f_num;
    added_f = zeros(height,width,dim);
    
    for count=2:f_num+1
        cord_x_forward = cord_x + (count-1)*seg_vx;
        cord_y_forward = cord_y + (count-1)*seg_vy;
        
        for d=1:dim
            added_f(:,:,d)=griddata(cord_x_forward,cord_y_forward,last_img(:,:,d),cord_x,cord_y);
        end
        
        nan_idx = find(isnan(added_f));
        added_f(nan_idx)=last_img(nan_idx);
        
        added_path(:,:,:,count)=added_f;
    end
end