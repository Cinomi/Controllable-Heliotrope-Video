% function used to get path set 
% Input ****************************************
% seq -- image sequence
% dist_mat -- distance matrix of image sequence
% def_idx -- index of start image
% thre -- threshold
% Output ***************************************
% path -- path set
function [path] = get_path(seq, dist_mat, def_idx, thre)
    N = size(seq,4);
    dist_mat_tem = dist_mat;
    dist_mat_tem(dist_mat>thre)=0;   % if exceed threshold, set weight as 0
    
    % construct min span tree of distance matrix
    % MSTree = minspantree(graph(dist_mat));     % MSTree is in graph format
    dist_mat_sparse = sparse(dist_mat);
    MSTree = graphminspantree(dist_mat_sparse);
    [start_idx, end_idx] = find(MSTree~=0);   % get index of edges
    
    % sparse matrix for MSTree
    dist_mat_mst = zeros(N, N);   
    
    for i=1:N-1
        dist_mat_mst(start_idx(i),end_idx(i))=dist_mat(start_idx(i), end_idx(i));
    end
    
    % make symmetric matrix
    for i=1:N
        for j=1:N
            if(dist_mat_mst(i,j)~=0)
                dist_mat_tem(i,j)=dist_mat_mst(i,j);
                dist_mat_tem(j,i)=dist_mat_mst(i,j);
            end
        end
    end
    
    dist_mat_new = dist_mat_tem;
    dist_mat_new = sparse(dist_mat_new);
%   graph_new = biograph(dist_mat_new);
%   view(graph_new);

    % solve shortest path problem for MSTree, def_idx is source point
    % paths from defined start point to other all points
    [~,path,~] = graphshortestpath(dist_mat_new, def_idx);
end