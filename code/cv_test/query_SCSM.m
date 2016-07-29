function [scsm, T] = query_SCSM(Q_RS, D, para)
    if ~is_Q_RS(Q_RS)
        Q_RS = query_get_index_feature_by_R_S(Q_RS,para.rotations, para.scales);
    end
    
    score = cal_score_k(Q_RS, D);
    T = find_best_tranform(Q_RS, D, para,score);
    % T=[8.0000    8.0000   25.6250  208.6200];
    % option = '      find best T over.'
    scsm=cal_SCSM(Q_RS, D, T, para.max_location_error, score);
    %show_map_img(map);

%     location_map = zeros(partition_count_r, partition_count_s, nx, ny);
%     for i = 1 : partition_count_r
%         for j = 1 : partition_count_s
%             location_map(i, j) = cal_location_map(Q, D, rotations(i), scales(j),nx, ny);
%         end
%     end

end

% 判断传进的参数是Q_RS（经过多个rotation和scales处理的，多一个rs_f项），还是Q(只含有s,f,idf,tf)
function result=is_Q_RS(Q_RS)
    result = length(fieldnames(Q_RS)) == 5;
end

% 在一定的T下计算SCSM
function scsm=cal_SCSM(Q_RS, D, T, maxerror, score)
    Q_T = Q_RS.rs_p{T(1), T(2)};
    Q_T(:,1) = Q_T(:, 1) + T(3);
    Q_T(:,2) = Q_T(:, 2) + T(4);
    Q_center = Q_RS.s / 2;
    D_center = T(3:4);
    scsm = 0;
    
    %debug_i = 1;
    Qi_le = 0; Di_le= 0;
    K = size(D.idf,1);                                                      % kmeans分类类数
    for k = 1 : K
        [Qi_e, Di_e] = find_end_index_of_k(Q_RS, D, k, Qi_le, Di_le);
        % Q_location = Q.f(Qi_le+1:Qi_e, 1:2);                             % 找到所有等于k(kmeans分到第k类)的关键点，对他们进行两两比对
        % D_location = D.f(Di_le+1:Di_e, 1:2);
        
        % 这里是对Q_location 和 D_location进行两两匹配，完全可以写成独立的函数
        for i = Qi_le+1:Qi_e
            for j = Di_le+1:Di_e
                error = cal_location_error(Q_T(i,:), Q_center, D.f(j,1:2), D_center);
                if error < maxerror
                    scsm = scsm + score(k);
                end
                
                %debug(debug_i) = error;
                %debug_i = debug_i + 1;
            end
        end 
        Qi_le = Qi_e; Di_le= Di_e;
    end
    
    %debug = sort(debug);
    %[debug(1:10);debug(end-9:end)]
    %sqrt_index = debug(int16(sqrt(end)))               % 简单测试，大概分布在35-60，有一个为128+，平均大概是45
end

function error = cal_location_error(Lf, Q_center, Lg, D_center)
    error = (Lf - Q_center- (Lg - D_center));
    error = sqrt(sum(error.*error));
end

% 选择出最好的transform=(r, s, t)                         % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function maxindex = find_best_tranform(Q_RS, D, para, score)
    len_r = length(para.rotations);
    len_s = length(para.scales);
    %debug_c = zeros(len_r*len_s,2);
    map = zeros(para.nx, para.ny);
    maxscore =  0;maxindex=[1,1,1,1];
    for i = 1: len_r
        for j = 1:len_s
            % [map(:,:),debug_c((i-1)*len_s+j,:)] = cal_location_score_map(Q_RS, i, j, D, para.grid_size, para.nx, para.ny, score);
            map(:,:) = cal_location_score_map(Q_RS, i, j, D, para.grid_size, para.nx, para.ny, score);
            map(:,:) = gaussian_filter_map(map);
            
            % find the maxsocre tranform (r, s, t)
            [temp,rows] = max(map);
            [temp,col] = max(temp);
            if maxscore < temp
                maxindex = [i,j, rows(col), col];
            end
            
            %rotation_scale = [para.rotations(i), para.scales(j)]
            % debug_c((i-1)*len_s+j,:)
        end
    end
    maxindex(3:4) = (maxindex(3:4) - 0.5) .* para.grid_size;
    %sum(debug_c)
end

function show_map_img(map)
    map(1:10, 1:10)
    map1 = map;
    map = map(map>0);   % 找出所有非零的 map>0返回的索引是相当于把map按列优先展开成的一维数组的下标,二位的map如果给一个一维的index,他会按照相同的规则查找
    max_v = max(map);
    min_v = min(map);
    size(map)
    min_v
    max_v
    map1 = map1./max_v;
    figure
    imshow(map1);
end

% 计算经过旋转R和伸缩S变换的location_map                         % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function map=gaussian_filter_map(map)
    %# Create the gaussian filter with hsize = [5 5] and sigma = 2
    G = fspecial('gaussian',[5 5],2);
    %# Filter it
    map = imfilter(map,G,'same');
end

% 在指定的rotation和scale下，查询图片，获得map
function [map,debug_c]=cal_location_score_map(Q_RS, rotate_i, scale_j, D, grid_size, nx, ny, score)
    c1 = 0; c2 = 0;
    map = zeros(nx, ny);
    K = size(D.idf,1);                                                      % kmeans分类类数
    Qi_le = 0; Di_le= 0;
    for k = 1 : K
        [Qi_e, Di_e] = find_end_index_of_k(Q_RS, D,k, Qi_le, Di_le);
        % Q_location = Q.f(Qi_le+1:Qi_e, 1:2);                             % 找到所有等于k(kmeans分到第k类)的关键点，对他们进行两两比对
        % D_location = D.f(Di_le+1:Di_e, 1:2);
        
        % 这里是对Q_location 和 D_location进行两两匹配，完全可以写成独立的函数
        for i = Qi_le+1:Qi_e
            for j = Di_le+1:Di_e
                fi = Q_RS.rs_p{rotate_i, scale_j}(i, :);
                location = cal_location(fi, D.f(j, 1:2), Q_RS.s);          % (fi ,gj), 在D中寻找Q; 也可以根据实际情况在Q中查找D
                grid_index = cal_grid_of_location(location, grid_size);
                if grid_index(1) > 0 && grid_index(2) > 0  && grid_index(1) <101 && grid_index(2) <101                 % (fi,gi)匹配使得D中能有足够的空间匹配才行，否则舍弃（这里可以修改）
                    map(grid_index(1),grid_index(2)) = map(grid_index(1), grid_index(2)) + score(Q_RS.d(i));
                    c1 = c1 + 1;
                end
                c2 = c2 + 1;
            end
        end
        
        Qi_le = Qi_e;
        Di_le = Di_e;
    end   
   
    debug_c = [c1, c2]; %c 用来辅助查看程序是否正常运行
end

% 找到最后一个等于k的点的下标，用于找到所有等于k的关键点
function [Qi_e, Di_e]=find_end_index_of_k(Q, D,k, Qi_le, Di_le)                          % Qi_e end(beggest) index i of Q(i)=k, Qi_le end(beggest) index i of Q(i) < k 
    Qs = size(Q.d, 1);
    Ds = size(D.d, 1);
    for i = Qi_le+1: Qs                                                   % find first i of Q(i) > k
        if Q.d(i) > k
            break;
        end
    end
    Qi_e = i - 1;
    
    for i = Di_le+1: Ds
        if D.d(i) > k
            break;
        end
    end
    Di_e = i -1;
end

% 下面三个函数是用来计算给定(fi,gj)时的grid_index和socre的        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function grid_index=cal_grid_of_location(location, grid_size)
    grid_index = int32(location./grid_size) + 1;
end

% location 取值(0,0)-->(size(D)-1)
function center_location = cal_location(Lf, Lg, s)                                   
%   Lf 是 query图中匹配关键点的坐标，已经经过了rotation和scale变换
%   Lg 是 dataset 中待匹配图D的对应关键点的坐标
%   location 是D图中对应到query图片中原点的坐标(这里为了方便，没有使用中心点的坐标，使用的是左上角点-（1,1）)
%   Lf - center = Lg - location;
    center_location = Lg - Lf + s./2;
end

function score = cal_score_k(Q, D)
    idf = D.idf;
    score = (idf./ Q.tf).* (idf./D.tf);
end
