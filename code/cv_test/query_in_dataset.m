function [best_image_index, T] = query_in_dataset(Q, dataset, rerank_mat)
% Q is index_feature of query image
    if isempty(dataset)
        dataset = load('dataMat/dataset_sorted.mat');
        dataset = dataset.dataset;
        fprintf(1,'load dataset from dataMat/dataset_sorted.mat');
        rerank_mat = load('dataMat/rerank.mat');
        rerank_mat = rerank_mat.rerank_mat;
        fprintf(1,'load rerank_mat from dataMat/rerank.mat');
    end
    
    [scsm, T] = load_the_scsm_mat(Q, dataset, 0);
    save('dataMat/scsm.mat','scsm');
    fprintf(1, '      save scsm to dataMat/ scsm.mat');
        
    % rerank
    tic
    k = 3;
    scsm = query_rerank_score(scsm, k, rerank_mat);
    [~,best_image_index] = max(scsm);
    fprintf(1, '[big] alread query rerank parse');
    toc
    
    T = T(best_image_index,:);
end



