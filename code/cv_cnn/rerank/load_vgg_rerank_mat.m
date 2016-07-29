function similar=load_vgg_rerank_mat( dataset )
%LOAD_VGG_RERANK_MAT Summary of this function goes here
%   Detailed explanation goes here
    if isempty(dataset)
        dataset = load('../dataMat/dataset.mat', 'dataset');
        dataset = dataset.dataset;
    end

    image_count = size(dataset, 1);
    similar = zeros(image_count);
    for i = 1:image_count
        for j = 1: image_count
            similar(i,j) = cal_similar(dataset{i}.feature, dataset{j}.feature);
        end
    end
    
    index = zeros(image_count);
    for i = 1:image_count
        [~, temp_index]=sort(similar(i,:));
        index(i, :) = temp_index(end: -1: 1);
    end
    
    rerank_mat.similar = similar;
    rerank_mat.index = index;
    save('rerank_mat.mat', 'rerank_mat');
end

function s=cal_similar(f1,f2)                              
    s = (f1'*f2) / (sqrt(f1'*f1) * sqrt(f2'*f2));          
%     s = 1 / ((f1 - f2)' * (f1 - f2));                     
end

