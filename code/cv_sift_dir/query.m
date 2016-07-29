function index = query(filepath, dataset)
%QUERY Summary of this function goes here
%   Detailed explanation goes here
    if isempty(dataset)
        dataset = load('dataMat/dataset.mat', 'dataset');
        dataset = dataset.dataset;
    end

    classes = 52;
    %classPerCount = 20;
    feature = get_sift(filepath);
    save('dataMat/feature','feature');
    vote = zeros(classes, 1);
    for i = 1:size(dataset, 1)
        [matches, scores] = vl_ubcmatch(feature.d, dataset{i}.d) ;
        vote(dataset{i}.class) = vote(dataset{i}.class) + size(matches, 2);
    end
    
    [~, maxI] = max(vote);
    index = maxI;
end



