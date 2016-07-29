function index = svm_query(imagepath, net, svmModel, para)
     if isempty(net)
        net = load('../cnn_mat/imagenet-vgg-f.mat');
        net = vl_simplenn_tidy(net);
     end
    
    feature = get_vgg_feature(imagepath, net);
    feature = turn_svm_feature(feature, para);
    
    index=svm_muti_predict(svmModel, feature');
end

function class=svm_muti_predict(svmModel, X)
    scores = zeros(size(X, 1), length(svmModel.classes));
    for j = 1:numel(svmModel.classes);
        [~, score] = predict(svmModel.SVMModels{j}, X);
        scores(:,j) = score(:,2); % Second column contains positive-class scores
    end
    [~, maxIndex] = max(scores, [], 2);
    class = svmModel.classes(maxIndex);
end
