basedir = '../../data/cvcut/';
dataset_path = strcat(basedir, 'dataset/');
queryset_path = strcat(basedir, 'queryset/');

    % load sift libary %
if strcmp(which('vl_sift'),'')
    run('../../third_part_lib/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/vl_setup');
end

if ~exist('dataMat/dataset.mat', 'file')
    load_dataset_sift(dataset_path);
end
dataset = load('dataMat/dataset.mat', 'dataset');
dataset = dataset.dataset;
res = query_all(queryset_path, dataset);
fprintf(1, 'right rate : %g\n', sum(res.right == res.query) / length(res.right));

% right rate : 0.673077