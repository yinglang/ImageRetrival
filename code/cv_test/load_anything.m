function [centers, dataset, Q, scsm, rerank_mat] = load_anything()
    % load sift libary %
    if strcmp(which('vl_sift'),'')
        run('D:/IDE/matlab/third_part/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/vl_setup');
    end

    basedir = 'D:/ML/MLInAction/cv/data/';
    %dataset_path = strcat(basedir, 'dataset/');
    queryset_path = strcat(basedir, 'queryset/');
    query_file = 'all_souls_000013.jpg';
    
    centers = load('dataMat/centers_kmeans.mat');
    centers = centers.centers;
    dataset = load('dataMat/dataset_tf_idf.mat');
    dataset = dataset.dataset;
    
    img = imread(strcat(queryset_path, query_file));
    Q = query_get_index_feature(img, centers);
    
    scsm = load('dataMat/scsm.mat');
    scsm = scsm.scsm;
    
    rerank_mat = load('dataMat/rerank.mat');
    rerank_mat = rerank_mat.rerank_mat;
end

%[centers, dataset, Q, scsm, rerank_mat] = load_anything();