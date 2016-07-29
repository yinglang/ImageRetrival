function svmfeature = turn_svm_feature( feature, para )
%TURN_SVM_FEATURE Summary of this function goes here
%   Detailed explanation goes here
    if  para.useSVD
        svmfeature = para.dV_sigma' * feature;
    else
        svmfeature = feature;
    end
end

