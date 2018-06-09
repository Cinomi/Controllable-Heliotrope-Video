close
clear
clc

%% choose provided data or own data
if_own = input('Use own data or provided data? (1-own data, other-provided data): ','s');
if if_own=='1'
    own = 1;
else
    own = 0;
end

%% Load image sequence
fprintf('Loading Image Sequence...')
if own==0
    img_seq = load_sequence_color('gjbLookAtTargets','gjbLookAtTarget_',0,71,4,'jpg');
else 
    img_seq = load_sequence_color('own_data','orange_',0,17,4,'jpg');
end

% down scale to 30%
N = size(img_seq,4);
for i=1:N
    seq(:,:,:,i)=imresize(img_seq(:,:,:,i), 0.3);
end

% get size of image sequence
[height_down, width_ori, ~, ~] = size(seq);
fprintf('Done\n');

%% Load flows
% because of space limitation for uploading, flows.mat is removed from the
% uploaded file
fprintf('Loading flows...');
if own==0
    if exist('flows.mat')==0
        flows_a=get_flow(seq);
        save('flows.mat','flows_a');
    else
        flows = load('flows.mat');
        flows_a = flows.flows_a;
    end
else
    if exist('flows_own.mat')==0
        flows_a=get_flow(seq);
        save('flows_own.mat','flows_a');
    else
        flows = load('flows_own.mat');
        flows_a = flows.flows_a;
    end
end

fprintf('Done\n');

%% Get distance matrix
fprintf('Computing distance matrix...');
[dist_mat] = advanced_mats(seq, flows_a);
%[dist_mat] = basic_mats(seq);
thre = mean(dist_mat(:));
fprintf('Done\n');

%% Ask user to select polyline on the image
if_countinue = 1;    % set flag as true
redraw_num = 0;
while(if_countinue)
    redraw_num = redraw_num+1;
    if own==0
        up_limit = 72;
    else
        up_limit = 28;
    end
    
    def_idx = input(['Input number of start image (1-',num2str(up_limit),'): ']);
    input_false = 1;
    while(input_false)
        if def_idx<1 || def_idx >up_limit
            def_idx = input(['Input error, please input again (1-',num2str(up_limit),'): ']);
        else
            input_false = 0;
        end  
    end
    
    % mutiple clicks (at least five clicks)
    fprintf('Select polyline...')
    point_num=0;
    %def_idx = 1;

    imshow(seq(:,:,:,def_idx)),title('Draw path and press enter when finish (at least five points)');
    while(point_num<5)
        [x,y]=getline(gcf);
        hold on, plot(x,y,'ro-');
        point_num=size(x,1);
        hold off, pause(0.5);
        if(point_num<5)
            imshow(seq(:,:,:,def_idx)),title('at least five points');
        end
    end

    fprintf('Done\n');

    %% Find shortest path
    fprintf('Computing path...');
    
    paths = get_path(seq, dist_mat, def_idx, thre);  % get first path
    min_idx2 = 0;
    min_idx3 = 0;
    estimate_pix = zeros(point_num-1,2);
    estimate_pix(1,:)=[x(1),y(1)];
    for count = 1:point_num-1
        start_pix = [y(count),x(count)];         % start pixel of count_th segment of selcted path
        expect_pix = [y(count+1),x(count+1)];    % destination pixel of count_th degment of selcted path

        [min_idx,es_x, es_y] = find_min_path(start_pix, expect_pix, paths, flows_a);   % find shortest path of current segment
        min_path{count} = paths{min_idx};        
        estimate_pix(count+1,:)=[es_x, es_y];
        if count == point_num-1
            [min_idx2, min_idx3] = get_closest_path_2(start_pix, expect_pix, paths, flows_a);
        end
        paths = get_path(seq, dist_mat, min_idx, thre);   % get paths set for next segment
    end
    
    figure,imshow(seq(:,:,:,def_idx));
    hold on, plot(estimate_pix(:,1), estimate_pix(:,2), 'ro-');
    hold off;
    
    fprintf('Done\n');

    %% Intepolate frames
    fprintf('Interpolating frames...');

    node_idx = 1;
    for i=1:length(min_path)
        for j=2:length(min_path{i})
            min_path_no(node_idx)=min_path{i}(j);
            node_idx = node_idx+1;
        end
    end

    last_min_path = min_path{length(min_path)};
    min_path_no = [def_idx min_path_no];
    
    figure;
    for n=1:length(min_path_no)
        imshow(seq(:,:,:,min_path_no(n)));
        %saveas(gcf,['advanced_output/output_',num2str(redraw_num),'_',num2str(n),'.jpg']);
    end

    fprintf('Done\n')
    
% %     %% slow motion 
% % %**************** uncomment this part if use 'slow motion'***************************
%     fprintf('Slow motion interpolation...');
%     
%     f_num = 5;
%     count = 1;
%     for s=1:length(min_path_no)-1
%         start_f = seq(:,:,:,min_path_no(s));
%         end_f = seq(:,:,:,min_path_no(s+1));
%         
%         % get corresponded flow
%         if min_path_no(s)>min_path_no(s+1)
%             idx_k = (min_path_no(s)-1)*(min_path_no(s)-2)/2+min_path_no(s+1);
%         else
%             idx_k = (min_path_no(s+1)-1)*(min_path_no(s+1)-2)/2+min_path_no(s);
%         end
%         flow = flows_a(:,:,:,idx_k);
%         
%         % slow motion for each segment
%         path_imgs = slow_motion(start_f, end_f, flow, f_num);
%         motion_fs(:,:,:,count:count+(f_num-1))=path_imgs;
%         count = count+f_num;
%     end
%     implay(motion_fs);
%     
%     % save as JPG file
% %     figure;
% %     for i=1:f_num*(length(min_path_no)-1)
% %         imshow(motion_fs(:,:,:,i));
% %         saveas(gcf,['test_motion/frame_',num2str(redraw_num),'_',num2str(i),'.jpg']);
% %     end
%     
%     % multi-node interpolation
%     min_path_no_length = length(min_path_no);
%     last_img_idx = min_path_no(min_path_no_length);
%     added_f = multi_node_interpolation(seq,last_img_idx,min_idx2,min_idx3,flows_a);
%     motion_length = size(motion_fs,4);
%     for count = 1:size(added_f,4)
%         motion_fs(:,:,:,motion_length+count) = added_f(:,:,:,count);
%     end
%     implay(motion_fs);
%     
%     fprintf('Done\n');
        
    if_end = input('Redraw?(y-yes,n-no): ','s');
    if(if_end=='n')
        if_countinue=0;    % set flag as false
    end
    close all;
    clear min_path_no;
    clear min_path;
    clear last_min_path;
end



