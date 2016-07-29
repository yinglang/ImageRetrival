right = [28, 1, 2, 47, 20, 20, 48, 48, 48];
dataset = load('dataMat/dataset.mat', 'dataset');
dataset = dataset.dataset;
net = load('cnn_mat/imagenet-vgg-f.mat');
net = vl_simplenn_tidy(net);

res = zeros(9,1);
tic
for i = 1:9
    file = strcat('C:\Users\yinglang\Desktop\cv\test\', int2str(i), '.jpg');
    tic
    res(i) = query(file, dataset, net);
    toc
    fprintf(1, 'recognize: %g, right: %g\n', res(i), right(i));
end

% 500 * 400
% Elapsed time is 42.034638 seconds.
% recognize: 49, right: 28
% Elapsed time is 40.153341 seconds.
% recognize: 1, right: 1
% Elapsed time is 38.345912 seconds.
% recognize: 49, right: 2
% Elapsed time is 45.323161 seconds.
% recognize: 47, right: 47
% Elapsed time is 42.270503 seconds.
% recognize: 20, right: 20
% Elapsed time is 41.089034 seconds.
% recognize: 35, right: 20
% Elapsed time is 36.482465 seconds.
% recognize: 48, right: 48
% Elapsed time is 35.374508 seconds.
% recognize: 48, right: 48
% Elapsed time is 40.546321 seconds.
% recognize: 48, right: 48
