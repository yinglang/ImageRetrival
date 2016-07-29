function load_sift_signature()
    dataset = load('datamat/dataset_sift.mat');
    dataset = dataset.dataset;
    sift_descriptors = dataset.d;
    fprintf(1, 'load dataset from datamat/dataset_sift.mat\n');
    
    dataset = load('datamat/dataset_kmeans.mat');
    dataset = dataset.dataset;
    fprintf(1, 'load dataset from datamat/dataset_kmeans.mat\n');
    
    centers = load('dataMat/centers_kmeans.mat');
    centers = centers.centers;
    K = size(centers, 1);
    fprintf(1,'load centers from dataMat/centers_kmeans.mat\n');

    % 通过QR分解获取投影矩阵
    P = rand(128);
    [Q,~]=qr(P);
    P=Q(1:64,:);
    
    Z = cell(1, K);
    for i=1:size(dataset.d, 2)
        len = size(dataset.d{i},1);
        Z{i} = zeros(len, 64);
        labels = dataset.d{i};
        descriptors = sift_descriptors{i};
        for j=1 : len
            Z{labels(j)}(j,:) = P * double(descriptors(j,:))';
        end
    end
    
    T = zeros(K, 64);
    for i = 1:K
        T(i,:) = sum(Z{i}, 1)./ size(Z{i},1);
    end
    
    dataset.P = P;
    dataset.T = T;
    fprintf(1, '[state]: get center T over.\n');
    dataset = get_sift_signature_for_dataset(dataset, sift_descriptors);
    save('dataMat/dataset_sift_signature.mat', 'dataset');
    fprintf(1, 'save dataset with signature to dataset_sift_signature.mat\n');
end

function dataset=get_sift_signature_for_dataset(dataset, sift_descriptors)
    image_count = size(dataset.d, 2);
    dataset.sig = cell(1, image_count);
    for i=1:image_count
       Z_array = dataset.P * double(sift_descriptors{i})';                  % 每列是一条数据
       dataset.sig{i} = mex_get_signature(Z_array, uint32(dataset.d{i}), dataset.T');
    end
end
