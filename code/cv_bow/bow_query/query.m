function index = query(imagepath, dataset, centers,args, para)
    if isempty(dataset)
        dataset = load('dataMat/dataset_tf_idf.mat');
        dataset = dataset.dataset;
        fprintf(1, 'load dataset from dataMat/dataset_tf_idf.mat');
    end
    if isempty(centers)                                         % 如果要从mat文件中读取，传入[],[]  
        centers = load('dataMat/centers_kmeans.mat');
        centers = centers.centers;
        fprintf(1, 'load centers from dataMat/centers_kmeans.mat');
    end

    img = imread(imagepath);
    
    scale = (500 * 800) / (size(img, 1) * size(img, 2));                   % % 根据大概每200-400个像素会有一个sift获得平均1300个点
    if scale < 1
        img = imresize(img, sqrt(scale));
    end
        
    feature = query_get_index_feature(img, centers,dataset);
    save(strcat('dataMat/', 'feature'),'feature');
    
    K = args.K;
    similar = query_in_dataset(feature, dataset, K, para);
    %similar'
    [~, index]=sort(similar);                         %index(i)记录的是排名第i的数的index位置
    %similar(:) = similar(length(similar):-1:1);
    index(:) = index(length(index):-1:1);
    
    classCount = args.classCount;
    numPerClass = args.numPerClass;
%     rsimilar = zeros(classCount, 1);
%     
%     for i = 1:classCount
%         for j = 1: numPerClass
%            rsimilar(i) = rsimilar(i) + similar(numPerClass*(i-1)+j);% / index(numPerClass*(i-1)+j); 
%         end
%     end
    
    KNN_K = args.KNN_K;
    vote = zeros(classCount, 1);
    %similar(index)'
    %(floor((index(1:100)-1)'./20) + 1)
    for i = 1: KNN_K
        class = uint16(str2double(dataset.class{index(i)}));
        vote(class) = vote(class) + 1;%similar(index(i));
    end
    
    [vote, maxI] = max(vote);
    if vote > 1
        index = maxI;
    else
        index = uint16(str2double(dataset.class{index(1)}));
    end
end

function similar=query_in_dataset(feature, dataset, K, para)
    similar = zeros(size(dataset.d, 2), 1);
    for i = 1:size(dataset.d, 2)
        similar(i) = cal_similar(feature, dataset.d{i}, dataset.sig{i}, dataset.idf, dataset.tf{i}, K, para);
    end
%     save('dataMat/similar.mat','similar');
end

function similar = cal_similar(Q, Dd, Dsig, Didf, Dtf, K, para)
%     Dtf = Dtf ./ (sum(Dtf));
%     Q.tf = Q.tf ./ (sum(Q.tf));
%     similar = 0;
%     for i = 1 : K
%         similar = similar +  Didf(i) * Q.tf(i) * Dtf(i);
%     end
    %similar = similar / distance(Q.tf) / distance(Dtf);
   
    if para.use_sift_signature
        similar = mex_cal_similar(uint8(Q.d), Q.sig, uint8(Dd), Dsig, Didf, para.hamming_threshold, 4);
        similar = similar / (distance(Q.tf) * distance(Dtf));
    else
        similar = sum(Q.tf .* Dtf .*Didf ) / (distance(Q.tf) * distance(Dtf));
    end
    
%     similar = zeros(K, 1);
%     db_threshold = 5;
%     
%     last_end_i = 0;
%     last_end_j = 0;
% %     dis = zeros(1, 1496);
%     l = 1;
%     for k = 1:K
%         [end_i, end_j] = find_end(last_end_i, last_end_j, k, Q.d, Dd);
%         for i = last_end_i+1: end_i
%             for j = last_end_j+1: end_j
%                 db = hamming(Q.sig(i), Dsig(j));
% %                 dis(l) = db; l = l + 1;
%                 if db < db_threshold
%                     similar(k) = similar(k) + exp(-db*db);
%                 end
%             end
%         end   
%         last_end_i = end_i;
%         last_end_j = end_j;
%     end
% %     save('dataMat/dis_db', 'dis');
%     similar = (similar'*Didf) / (distance(Q.tf) * distance(Dtf));

%     similar = sum(Q.tf .* Dtf .*Didf ) / (distance(Q.tf) * distance(Dtf));
%     similar = sum(Q.tf .* Dtf .*Didf ) / (sum(Q.tf) * sum(Dtf));

    %similar = sum((Q.tf - Dtf).^2) / (distance(Q.tf) * distance(Dtf));
end 

function dis = hamming(uint64_a, uint64_b)
    bit = bitxor(uint64_a, uint64_b);
    dis = 0;
    for i = 1 : 64
        dis = dis + bitand(bit, 1);
        bit = bitshift(bit, -1);
    end
    dis = double(dis);
end

function [end_i, end_j] = find_end(last_end_i, last_end_j, k, Qd, Dd)
    end_i = last_end_i;
    for end_i = last_end_i+1: size(Qd, 1)
        if Qd(end_i) > k
            break
        end
    end
    end_i = end_i-1;
    
    end_j = last_end_j;
    for end_j = last_end_j +1: size(Dd, 1)
        if Dd(end_j) > k
            break
        end
    end
    end_j = end_j -1;
end
    
function l = distance(vec)
    l = (sum(vec.*vec)).^(0.5);
end
% 多行注释ctrl+R 多行取消ctl+T

% 计算单张图片的 index feature%
function feature = query_get_index_feature(img, centers, dataset)
    if isempty(centers)
        centers = load('dataMat/centers_kmeans.mat');
        centers = centers.centers;
        fprintf(1,'load centers from dataMat/centers_kmeans.mat');
    end
    s = size(img);
    feature.s = s(1:2);
    [f, d] = get_sift(img);
    feature.f = f;
    feature.d = zeros(size(d,1), 1);
    K = size(centers, 1);
    
    % 如果内存紧张，使用这个方法
%     for i = 1 : size(d,1)
%         descriptor = double(d(i, :));
%         min_index = -1;
%         min_dis2 = inf;
%         for j = 1 : K
%             dis2 = sum((descriptor - centers(k, :)).^2);
%             if dis2 < min_dis2
%                 min_dis2 = dis2;
%                 min_index = j;
%             end
%         end
%         feature.d(i) = min_index;
%     end
    
    % 如果内存OK， 没有利用并行，使用这个方法
    for i = 1 : size(d, 1)
        descriptor = double(d(i, :));
        [~, index] = min(sum(((repmat(descriptor, K, 1) - centers).^2), 2));    %sum(a,2)表示对a进行逐行求和，默认是逐列求和
        feature.d(i) = index;
    end
    feature=get_sift_signature(feature, dataset.P, dataset.T, d);
    feature = sort_by_index(feature);                       % 将index_feature 各个关键点排个序
    
    % 统计tf
    feature.tf = zeros(K, 1);
    for i = 1 : size(feature.d,1)
        feature.tf(feature.d(i)) = feature.tf(feature.d(i)) + 1;
    end
end

% 返回值每一列对应一个关键点，与大多数matlab函数习惯相反
function [f,d] = get_sift(img)
% f is info of each keypoints, center f(1:2, i), scale f(3, i) and orientation f(4, i) %
% d is descriptors for every keypoint %
    img = single(rgb2gray(img));
    [f, d] = vl_sift(img);
    
    % 格式化，matlab图片坐标是(row,col),而f(1:2, i) = (col,row)
    t = f(1,:);
    f(1,:) = f(2,:);
    f(2,:) = t;
        % matlab 矩阵一般每行是一个数据，列数是数据个数，这里取一个转置
    f = f';
    d = d';
end

function index_feature = sort_by_index(index_feature)
    [index_feature.d, i] = sort(index_feature.d);
    index_feature.f(:, :) = index_feature.f(i, :);
    index_feature.sig(:) = index_feature.sig(i);
end

function index_feature=get_sift_signature(index_feature, P, T, sift)
    Z_array = P * double(sift)';                  % 每列是一条数据
    index_feature.sig = mex_get_signature(Z_array, uint32(index_feature.d), T');
end
