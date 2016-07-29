function scsm = query_rerank_score(scsm, k, R)
    if isempty(R)
        R = load('dataMat/rerank.mat');
        R = R.rerank_mat;
        %dataset_scsm = load('dataMat/dataset_scsm.mat');
        %dataset_scsm = dataset_scsm.rerank_mat;
    end
    
    image_count = length(scsm);
    
    [~, similiar_index]=sort(scsm,'descend');                   % ½µĞòÅÅÁĞ
    rankQ(similiar_index) = 1:image_count;
    
    for d = 1: image_count
        scsm(d) = 1 / rankQ(d);
        for i = 1:k
            Ni = similiar_index(i);
            wi = 1 / (i + 1);
            scsm(d) = scsm(d) + wi / R(Ni, d) ; % 1 / ((R(Q,Ni) + R(Ni,Q) + 1)R(Ni,D))
        end
    end
end
