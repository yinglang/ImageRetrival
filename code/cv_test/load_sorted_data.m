% 参数:
%   符合 load_sift_kmens返回的dataset数据类型

% 功能:
%   对每张图片的聚类后的index_feature  dataset.d{i}进行升序排列

function dataset=load_sorted_data(dataset)
    if isempty(dataset)
        dataset = load('datamat/dataset_kmeans.mat');
        dataset = dataset.dataset;
        option = 'load dataset from datamat/dataset_kmeans.mat'
    end
    
    image_count = size(dataset.d, 2);
    for i = 1 : image_count
        [dataset.d{i},index] = sort(dataset.d{i});
        dataset.f{i}(:,:) = dataset.f{i}(index,:);
    end
    
    save('datamat/dataset_sorted.mat', 'dataset');
    option = 'load dataset from datamat/dataset_sorted.mat'
end