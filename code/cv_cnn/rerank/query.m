function index = query( imagepath, dataset, net, rerank_mat, para )
    if isempty(net)
        net = load('../cnn_mat/imagenet-vgg-f.mat');
        net = vl_simplenn_tidy(net);
    end
    if isempty(dataset)
        dataset = load('../dataMat/dataset.mat', 'dataset');
        dataset = dataset.dataset;
    end
    
    feature = get_vgg_feature(imagepath, net);
    
    image_count = size(dataset, 1);
    
    % 对数据库中的图片按相似度进行排序
    similar = zeros(image_count, 1);
    for i = 1:image_count
        similar(i) = cal_similar(feature, dataset{i}.feature);
    end
    [~, index] = sort(similar);
    index = index(end:-1:1);
    
    KNN = para.KNN;
    [similar, index]=rerank(similar, index, rerank_mat, KNN);
    
    classCount = 52;
    vote = zeros(classCount, 1);
    for i = 1:KNN
        class = dataset{index(i)}.class;
        vote(class) = vote(class) +  similar(index(i));
    end

    [vote, maxI] = max(vote);
    if vote > similar(index(1))
        index = maxI;
    else
        index = dataset{index(1)}.class;
    end
end

% function s=cal_similar(f1, f2)
%     s = f1 - f2;
%     s = -sum(s .* s);
% end

function [similar,index]=rerank(similar, index, rerank_mat, KNN)
    % 进行rerank 二次查询
    image_count = size(index, 1);
    similar_Ni_Q = similar(index(1:KNN));
    similar(index) = 1 ./ (1 : image_count);
    for i = 1:KNN
        Ni_index = rerank_mat.index(index(i), :);
        Ni_similar = rerank_mat.similar(index(i),:);
        rank_Q_D = get_rank_Q_D(image_count, Ni_index);
        rank_Ni_Q = get_rank_Ni_Q(similar_Ni_Q(i),Ni_similar(Ni_index));
        similar = similar + (1 / (i+1 + rank_Ni_Q)) ./ rank_Q_D ;
    end
    
    % 进行rerank 排序
    [~, index] = sort(similar);
    index = index(end:-1:1);
end

function rank=get_rank_Q_D(image_count, index)
    score = 1 : image_count;
    rank = zeros(image_count, 1);
    rank(index) = score;
end

function rank=get_rank_Ni_Q(similar_ni_Q, sorted_similar_Ni_D)
    rank = length(sorted_similar_Ni_D) + 1;
    for i=1:length(sorted_similar_Ni_D)
        if similar_ni_Q > sorted_similar_Ni_D(i)
            rank = i;
            break;
        end
    end
end

function s=cal_similar(f1,f2)                              
    s = (f1'*f2) / (sqrt(f1'*f1) * sqrt(f2'*f2));          % rightRate = 0.6298
%     s = 1 / ((f1 - f2)' * (f1 - f2));                      % rightRate = 0.5962
end
