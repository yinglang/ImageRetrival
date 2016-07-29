function svmModel=svm_train()
    dataset = load('../dataMat/dataset.mat');
    dataset = dataset.dataset;
    fprintf(1, 'load dataset from dataMat/dataset.mat\n');
    
    dimPerData = length(dataset{1}.svm_feature);
%     countPerClass = 20;
%     classCount = 52;
    image_count = size(dataset, 1);
    trainData = zeros(image_count, dimPerData);
    label = zeros(image_count, 1);
    for i = 1:image_count
        trainData(i, :) = dataset{i}.svm_feature';
        label(i) = dataset{i}.class;
    end
    svmModel = svm_muti_class(trainData, label);
    save('svmModel.mat', 'svmModel');
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
end
