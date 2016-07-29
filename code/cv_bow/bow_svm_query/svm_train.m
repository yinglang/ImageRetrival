function svmModel=svm_train()
    dataset = load('dataMat/dataset_tf_idf.mat');
    dataset = dataset.dataset;
    fprintf(1, 'load dataset from dataMat/dataset_tf_idf.mat\n');
    centers = load('dataMat/centers_kmeans.mat');
    centers = centers.centers;
    fprintf(1, 'load centers from dataMat/centers_kmeans.mat\n');
    
    K = size(centers,1);
%     countPerClass = 20;
%     classCount = 52;
    image_count = size(dataset.d, 2);
    trainData = zeros(image_count, K);
    label = zeros(image_count, 1);
    for i = 1:image_count
        trainData(i, :) = dataset.tf{i}'./ distance(dataset.tf{i});
        label(i) = uint16(str2double(dataset.class{i}));
    end
    svmModel = svm_muti_class(trainData, label);
end

function svmModel=svm_muti_class(trainData, label)
    classes = unique(label);
    SVMModels = cell(length(classes),1);
    rng(1); % For reproducibility

    for j = 1:numel(classes);
        indx = (label==classes(j)); % Create binary classes for each classifier
        SVMModels{j} = fitcsvm(trainData,indx);%...
%         ,'ClassNames',[false true],'Standardize',true,'KernelFunction','rbf','BoxConstraint',1);
    end
    svmModel.SVMModels = SVMModels;
    svmModel.classes = classes;
    save('dataMat/svmModel.mat', 'svmModel');
end

function l = distance(vec)
    l = (sum(vec.*vec)).^(0.5);
end