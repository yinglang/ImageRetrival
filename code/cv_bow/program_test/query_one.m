function index=query_one(imagepath)
    args.K = 200;
    args.classCount = 52;
    args.numPerClass = 20;
    args.KNN_K = 8;
    
    index=query(imagepath, [], [], args);
    
%     svmModel = load('dataMat/svmModel.mat');
%     svmModel = svmModel.svmModel;
%     index=svm_query(imagepath, [], [], svmModel);
end