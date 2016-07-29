% 凡写程序，必要从重点开始写，以点带面的突破，
% 同时想办法确认自己想法的正确性，因此开始不在于系统的完善，而在于先看看效果
% 只有能够预知的确认结果，才好系统的完善
%

% 提取sift
% 对sift进行 kmeans聚类
% 计算匹配点 idf 和 tf，获取相似度

function res=bow_pipeline()
    addpath('./load_train');
    addpath('./tool');
    addpath('./bow_query');
    addpath('./bow_svm_query');
    addpath('./color_feature_query');

    basedir = '../../data/cvcut/';
    dataset_path = strcat(basedir, 'dataset/');
    queryset_path = strcat(basedir, 'queryset/');
    
        % load sift libary %
    if strcmp(which('vl_sift'),'')
        run('../../third_part_lib/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/vl_setup');
    end
    
    if ~exist('datamat/dataset_sift.mat', 'file')
        load_sift_cell(dataset_path);
    end
    if ~exist('dataMat/dataset_kmeans.mat', 'file') || ~ exist('dataMat/centers_kmeans.mat', 'file')
        load_sift_kmeans([]);
    end
    if ~exist('dataMat/dataset_sift_signature.mat', 'file')
        load_sift_signature();
    end
    load_sorted_data([]);
    load_tf_idf([],[]);  
    load_uint_name(dataset_path, []);
    
%     i = 1;
%     for KNN_K = 5 : 5 : 60
%         
%         i = i + 1;
%     end

%     args.K = 100;
%     args.classCount = 52;
%     args.numPerClass = 20;
%     args.KNN_K = 5;
%     query(strcat(queryset_path ,'乒乓球盒子\IMG_2000.JPG'), [], [], args)
    
    mex('./tool/mex_cal_similar.cpp');
    para.dataset_path = dataset_path;
    para.recalculate_color_feature = 0;
    
    tic
    res =query_set(queryset_path, 5, para);                                        % 结果对KNN_K不敏感
    toc
    
%     tic
%     KNN = 1:5:50;
%     rightRate=zeros(length(KNN), 1);
%     for i = 1:length(KNN)
%         tic
%         res =query_set(queryset_path, KNN(i), para);                                        % 结果对KNN_K不敏感
%         toc
%         rightRate(i) = res.rightRate;
%         res.rightRate
%     end
%     res.rightRate = rightRate;
%     res.KNN = KNN;
%     toc
%     save('dataMat/res', 'res');
end

function res=query_set(querySet, KNN_K, para)
    dataset = load('dataMat/dataset_tf_idf.mat');
    dataset = dataset.dataset;
    fprintf(1, 'load dataset from dataMat/dataset_tf_idf.mat\n');
    centers = load('dataMat/centers_kmeans.mat');
    centers = centers.centers;
    fprintf(1, 'load centers from dataMat/centers_kmeans.mat\n');
    
    args.K = size(centers, 1);
    args.classCount = 52;
    args.numPerClass = 20;
    args.KNN_K = KNN_K;
    
    para.useSVM = 0;                                                            % 是否使用svm  rightRate=0.7308
    
    para.useColorFeature=0;                                                     % 是否只使用color feature
    para.color_bin_size = 8;
    para.block_size = 5;
    
    para.use_sift_signature = 0;                                                % 如果不使用svm，是否使用64bit sift signatrue,如果不使用，
                                                                                % 将直接使用余弦夹角计算相似度（rightRate=0.5433
    para.hamming_threshold = 30;                                                % 如果使用sift signature, 设定hamming距离阈值
    
    
    %delete(gcp('nocreate'));parpool(2);
    if para.useSVM
        svmModel = svm_train();                                                 % SVM
    end
    
    if para.useColorFeature && para.recalculate_color_feature
        tic;dataset=load_color_feature(para.dataset_path, dataset, para);toc;
    end
    
    dirs = ls(querySet);
    k = 1;
    for i = 3 : size(dirs, 1)
        dir = strcat(querySet,dirs(i, :), '/');
        files = ls(dir);
        for j = 3 : size(files, 1)
            right(j-2) = uint16(str2double(dirs(i,:)));
            file = strcat(dir, files(j, :));
         
            if para.useSVM
                    test(j-2) = svm_query(file, dataset, centers, svmModel);        % SVM
            else if para.useColorFeature
                    test(j-2) = color_feature_query(file, dataset, centers, args, para);
                else
                    test(j-2) = query(file, dataset, centers, args, para);
                end
            end
            fprintf(1, 'right: %g, recognzie: %g\n', right(j-2), test(j-2));
        end  
        res.right(k:k+size(files, 1)-2-1) = right(:);
        res.test(k:k+size(files, 1)-2-1) = uint16(test(:));
        k = k + size(files, 1)-2;
    end
    
    res.rightRate = sum(res.right == res.test) / length(res.right);
end
