% 警告：
%   kmeans 聚类总是不收敛，总有几个点过不了交叉验证，不知道有没有影响

% 参数:
%   dataset 需要符合load_sift_cell函数返回的dataset的格式

% 功能:
%   使用kmeans对dataset中的所有sift的descriptor进行聚类，获取聚类中心，
%   并且使用聚类的index代替descriptor来描述特征点，实质上完成了一个降维的操作

% 返回：
%   dataset.f{i} = matrix(n, 4)  每一行对应一个特征点，每一行的前两个对应特征点坐标。 没变
%   dataset.s{i} = matrix(1, 2)  记录第i张图片的size (weight,height)。  没变
%   dataset.d{i} = matrix(n, 1). n是第i张图片里特征点的数量。
%   centers  sift聚类中心

function [dataset,centers] = load_sift_kmeans(dataset)
    % 相应的大数据应在这里从磁盘读取
    if isempty(dataset)                                         % 如果使用加载的数据，dataset设置为[]
        dataset = load('datamat/dataset_sift.mat');
        dataset = dataset.dataset;
        option = 'load dataset from datamat/dataset_sift.mat'
		
% 		centers = load('dataMat/centers_kmeans.mat');
% 		centers = centers.centers;
% 		option = 'load centers from dataMat/centers_kmeans.mat'
    end
    K = 200;
    
    image_count = size(dataset.d, 2);                           % 图片数量。对于cell而言默认是二维的，cell{i} = cell{1,i}
    
    % 下面代码是将所有descriptors，合到一个数组里，同时释放原有空间
    sift_length = size(dataset.d{1}, 2);                        % sift descriptor长度，默认是128
    all_sift_count = 0;                                         % sift descriptor的总数量
    for i = 1 : image_count
        all_sift_count = all_sift_count + size(dataset.d{i}, 1);
    end
    
    all_sift_descriptors = zeros(all_sift_count, sift_length);  % 申请空间
    b = 1;
    for i = 1 : image_count
        len = size(dataset.d{i}, 1);
        all_sift_descriptors(b:b + len-1, :) = double(dataset.d{i});
        b = b + len;
        dataset.d{i} = [];                                      % 释放空间，d在后面用来存储 index feature
    end
    
    size(all_sift_descriptors)
    option = '  begin kmeans '
    
    % 并行是每种初始点之间并行，一次初始点是不会并行的，即只有Replicates > 1时才有意义
    % open_parallel();
    stream = RandStream('mlfg6331_64');                         % Random number stream,伪随机数要有一个流吧，matlab的两个流
                                                                % 只有这个支持substreams(对应下面的UseSubStreams),mt19937ar 生成函数不支持子流。
    opts=statset('Display', 'iter','MaxIter', 100, 'UseParallel',1, 'UseSubStreams', 1, 'Streams', stream); % UseSubStreams应该是每个并行的进程使用不同的流吧
    opts=statset('Display', 'iter','MaxIter', 100);
    [labels, centers] = kmeans(all_sift_descriptors, K, 'Options', opts, 'Replicates',1, 'start', 'plus'); 
	%[labels, centers] = kmeans(all_sift_descriptors, K, 'Options', opts, 'Replicates',1, 'start', centers); 
    % [idx, c, sumd, D] = kmenas(X, K, 'Replicates',5 ,'Options', opts)
    % X: 每行是一个数据点，聚类数据集 (n * p)；K 聚类个数；'Replicates',5使用5组初始点（结果选距离和最小的）
    % idx 每个数据点被分到那一类了    (n * 1)
    % c 是聚类中心，每一行是一个中心  (k * p)
    % sumd 每个类内的距离和          (k * 1)
    % D 每个点到每个类的距离         (n * k)
    % Display iter每次迭代显示出的分别是 迭代次数， 阶段(参考matlab2016文档）， 交叉验证错误的点的个数， sum距离和
    % start plus 表示使用k-means++的方法确定初始中心点
    option = '[BIG]: kmeans over.'
    
    % hist(labels, K);
    % size(labels)
    b = 1;
    for i = 1:image_count
        len =  size(dataset.f{i}, 1);
        dataset.d{i} = labels(b: b + len-1);
        b = b + len;
    end
    
    save('dataMat/dataset_kmeans.mat','dataset');
    option = 'save dataset to dataMat/dataset_kmeans.mat.'
    save('dataMat/centers_kmeans.mat', 'centers');
    option = 'save centers to dataMat/centers_kmeans.mat.'
end