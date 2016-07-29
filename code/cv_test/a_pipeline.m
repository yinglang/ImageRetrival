function a_pipeline()
    % 加载所需的库和环境
    %a_start();

    basedir = 'C:/Users/yinglang/Desktop/cv/';
    dataset_path = strcat(basedir, 'dataset/');
    queryset_path = strcat(basedir, 'queryset/');
    %query_file = 'all_souls_000013.jpg';
    
%     %dataset = [];centers=[];
%     fprintf(1, '[parse]: get sift from dataset');
%     dataset = load_sift_cell(dataset_path);             % 提取sift
%     %input('press Enter to continue.');
%     fprintf(1, '[parse]: kmeans cluster for BOW of sift');
%     [dataset, centers] = load_sift_kmeans(dataset);     % kmean聚类，并将sift 表示为index特征
%     %input('press Enter to continue.');
%     fprintf(1, '[parse]: post sovle for dataset sift, sort and calculate tf idf terms.');
%     dataset=load_sorted_data(dataset);
%     %input('press Enter to continue.');
%     dataset = load_tf_idf(dataset, centers);             % 计算tf与idf项
    %input('press Enter to continue.');
    dataset = load('dataMat/dataset_tf_idf.mat');
    dataset = dataset.dataset;
    option = 'load dataset from dataMat/dataset_tf_idf.mat'
    rerank_mat=load_the_rerank_mat(dataset);             % 计算rerank_mat
    %input('press Enter to continue.');
    
    fprintf(1, '[parse]: query image in dataset.');
    %query_test(strcat(queryset_path, query_file), centers, dataset, rerank_mat);
    %sovle_queryset(queryset_path, dataset, centers);    % 对待查询的图片进行查询处理
end

% 多行注释ctrl+R 多行取消ctl+T

function Q = query_test(filepath, centers, dataset,rerank_mat)
    img = imread(filepath);
    Q = query_get_index_feature(img, centers);
    image_index = query_in_dataset(Q, dataset,rerank_mat);
end

function sovle_queryset(dir, dataset, centers)
    files = ls(dir);
    for i = 3: size(files,1)
        filepath = strcat(dir, files(i,:));
        img = imread(filepath);
        Q = get_index_feature(img, centers);
        query(Q, dataset);
    end
end  
    