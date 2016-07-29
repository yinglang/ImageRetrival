function [scsm,T] = load_the_scsm_mat(Q, dataset, no_query_index)
% Q is index_feature of query image
% dataset
% no_query_index it is mean do not need compare dataset[no_query_index] with Q
    if isempty(dataset)
        dataset = load('dataMat/dataset_sorted.mat');
        dataset = dataset.dataset;
        fprintf(1,'load dataset from dataMat/dataset_sorted.mat');
    end

    para.partition_count_r = 8; para.partition_count_s = 8;                          % 这里几个参数都是可调的
    para.nx = 100;                                                             
    para.ny = 100;
    para.rotations = 0 : pi * 2 / para.partition_count_r : pi*2;                     % [0，pi*2]的等差数列，因为首尾重合，所以分count_r份
    para.rotations = para.rotations(1:para.partition_count_r);
    para.scales = exp(-log(2) : 2 * log(2) / (para.partition_count_s-1) : log(2));   % 1/2 到 2的等比数列，因为首尾不重合，所以分count_s-1份
    para.max_location_error = 30;%sqrt(sqrt(Q.s(1)) * sqrt(Q.s(2)));

    Q_RS = query_get_index_feature_by_R_S(Q, para.rotations, para.scales);
    D.idf = dataset.idf;
    image_count = size(dataset.d, 2);
    scsm = zeros(image_count,1);
    T = zeros(image_count,4);
    
    % tic toc 查看程序运行时间
    %tic
    for i = 1 : image_count                                                     % cpu 利用率不高(30%左右，60%左右才算高)，说明matlab 本身cpu协调不好(矩阵运算协调甚至优于并行），可使用并行
        if i == no_query_index
            continue;
        end
        D.d = dataset.d{i};
        D.f = dataset.f{i};
        D.s = dataset.s{i};
        D.tf = dataset.tf{i};
        
        para.grid_size = double(D.s+1)./[para.nx, para.ny];                         % 保证数据向上取舍
        [scsm(i), T(i,:)] = query_SCSM(Q_RS, D, para);
        fprintf(1, '[big] alread get scsm of %g / %g\n',i, image_count);
    end
    %toc
end