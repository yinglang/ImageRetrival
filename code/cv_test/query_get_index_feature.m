% 多行注释ctrl+R 多行取消ctl+T

% 计算单张图片的 index feature%
function feature = query_get_index_feature(img, centers)
    if isempty(centers)
        centers = load('dataMat/centers_kmeans.mat');
        centers = centers.centers;
        option = 'load centers from dataMat/centers_kmeans.mat'    
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
        [value, index] = min(sum(((repmat(descriptor, K, 1) - centers).^2), 2));    %sum(a,2)表示对a进行逐行求和，默认是逐列求和
        feature.d(i) = index;
    end
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
end
