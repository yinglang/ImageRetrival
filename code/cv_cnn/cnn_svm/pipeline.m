basedir = '../../../data/cvcut/';
dataset_path = strcat(basedir, 'dataset/');
queryset_path = strcat(basedir, 'queryset/');
compiler_matcont_path = '..\..\..\third_part_lib\matconvnet-1.0-beta20\matconvnet-1.0-beta20\matlab\vl_compilenn';
setup_matcont_path = '..\..\..\third_part_lib\matconvnet-1.0-beta20\matconvnet-1.0-beta20\matlab\vl_setupnn';

% setup MatConvNet (设置这个库的路径等环境, 所有的matlab库都需要，而且每次打开matlab都需要） 
if strcmp(which('vl_simplenn'),'')
    % install and compile MatConvMat of cpp (need once)
    run(compiler_matcont_path);
    run(setup_matcont_path);
end
fprintf(1, 'load cnn libarray matconvnet over.\n');

if ~exist('../cnn_mat/imagenet-vgg-f.mat','file')
    % download a pre-trained CNN from the web (need once)
    frpintf(1, 'downlaod cnn net from internet in http://www.vlfeat.org/matconvnet/models/imagenet-vgg-f.mat.\n');
    urlwrite(...
        'http://www.vlfeat.org/matconvnet/models/imagenet-vgg-f.mat', ...
        '../cnn_mat/imagenet-vgg-f.mat') ;
end

fprintf(1, 'load cnn over\n');

% net = load('cnn_mat/imagenet-vgg-f.mat');
% net = vl_simplenn_tidy(net);

if ~exist('../dataMat/dataset.mat', 'file');
    dataset=load_vgg_feature(dataset_path, net);
    frpintf(1, 'extract feature using cnn over\n');
end

para.KNN = 8;
para.svmModel=[];
para.useSVD = 0;                              % 不使用SVD他的识别率为 0.7067
para.svd_engine_rate = 0.9;                 % 这个值超过0.75以后一直维持在 0.6298 的识别率
dataset = load_low_dim_feature([], para);
fprintf(1, 'begin train svm\n');tic;svmModel = svm_train();toc;fprintf(1, 'train svm over\n');

res=query_all(queryset_path, [], [], para);
rightRate=sum(res.right == res.query) / length(res.right)

% res = cell(12, 1);
% for i = 1:size(res, 1)
%     para.KNN = i * 5;
%     res{i} =query_all(queryset_path, [], [], para);
%     res{i}.rightRate = sum(res{i}.right == res{i}.query) / length(res{i}.right);
% end
% rightRate = zeros(size(res, 1),1);
% for i = 1:size(res, 1)
%     rightRate(i) = res{i}.rightRate;
% end
% plot(5*(1:size(res, 1)), rightRate);
% save('res.mat','res');

