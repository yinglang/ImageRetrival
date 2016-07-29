function index = query( imagepath, dataset, net )
    if isempty(net)
        net = load('cnn_mat/imagenet-vgg-f.mat');
        net = vl_simplenn_tidy(net);
    end
    if isempty(dataset)
        dataset = load('dataMat/dataset.mat', 'dataset');
        dataset = dataset.dataset;
    end
    
    feature = get_vgg_feature(imagepath, net);
    
    image_count = size(dataset, 1);
    similar = zeros(image_count, 1);
    for i = 1:image_count
        similar(i) = cal_similar(feature, dataset{i}.feature);
    end
    [~, index] = sort(similar);
    index = index(end:-1:1);
    
    KNN = 10;
    classCount = 52;
    vote = zeros(classCount, 1);
    for i = 1:KNN
        class = dataset{index(i)}.class;
        vote(class) = vote(class) + 1;
    end
    
    [vote, maxI] = max(vote);
    if vote > 1
        index = maxI;
    else
        index = dataset{index(1)}.class;
    end
end

% function s=cal_similar(f1, f2)
%     s = f1 - f2;
%     s = -sum(s .* s);
% end

function s=cal_similar(f1,f2)                              
    s = (f1'*f2) / (sqrt(f1'*f1) * sqrt(f2'*f2));          % rightRate = 0.6298
%     s = 1 / ((f1 - f2)' * (f1 - f2));                      % rightRate = 0.5962
    
end
