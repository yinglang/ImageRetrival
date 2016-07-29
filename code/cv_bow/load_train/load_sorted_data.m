% 参数:
%   符合 load_sift_kmens返回的dataset数据类型

% 功能:
%   对每张图片的聚类后的index_feature  dataset.d{i}进行升序排列

function dataset=load_sorted_data(dataset)
    if isempty(dataset)
            dataset = load('dataMat/dataset_sift_signature.mat');
            dataset = dataset.dataset;
            fprintf(1,'load dataset from dataMat/dataset_sift_signature.mat\n');
    end
    
    image_count = size(dataset.d, 2);
    for i = 1 : image_count
        [dataset.d{i},index] = sort(dataset.d{i});
        dataset.f{i}(:,:) = dataset.f{i}(index,:);
        dataset.sig{i}(:, :) = dataset.sig{i}(index,:);
    end
    
    save('datamat/dataset_sorted.mat', 'dataset');
    fprintf(1, 'save dataset from datamat/dataset_sorted.mat\n');
end