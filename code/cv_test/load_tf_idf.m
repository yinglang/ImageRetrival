% 参数:
%   dataset 符合 load_sift_kmeans/load_sorted_data 返回的dataset的格式
%   centers 符合 load_sift_kmeans 返回的聚类中心的格式

% 功能:
%   计算每个词(kmeans聚类的每个类)的idf 和tf项
%   idf : 反映一个词在语料库中出现次数和重要性成反比。这里使用在语料库(所有图片)中出现频率和的倒数。
%       因为这个数可能会很小，所以涉及他的计算，应当使用log
%   tf  : 反映一个词在待查询图片中出现此数和重要性成正比。 这里使用的是在一张图中出现的频率。

% 返回：
%   dataset.f{i} = matrix(n, 4)  每一行对应一个特征点，每一行的前两个对应特征点坐标。 没变
%   dataset.s{i} = matrix(1, 2)  记录第i张图片的size (weight,height)。          没变
%   dataset.d{i} = matrix(n, 1). n 是第i张图片里特征点的数量。        没变
%   dataset.tf{i} = matrix(K,1)  K 是聚类个数。       
%   dataset,idf = matrix(K,1)

function dataset=load_tf_idf(dataset, centers)
    if isempty(dataset)                                         % 如果要从mat文件中读取，传入[],[]
        dataset = load('dataMat/dataset_sorted.mat');
        dataset = dataset.dataset;
        option = 'load dataset from dataMat/dataset_sorted.mat'
        centers = load('dataMat/centers_kmeans.mat');
        centers = centers.centers;
        option = 'load centers from dataMat/centers_kmeans.mat'
    end
    
    K = size(centers, 1);
    image_count = size(dataset.d, 2);
    dataset.idf = zeros(K, 1);
    for i = 1 : image_count
        index_feature = dataset.d{i};
        tf = zeros(K, 1);
        for j = 1 : size(index_feature,1)
            tf(index_feature(j)) = tf(index_feature(j)) + 1;
        end
        dataset.idf = dataset.idf + (tf > 0);
        dataset.tf{i} = tf;
    end
    dataset.idf = idf_function(image_count, dataset.idf);
    
    save('dataMat/dataset_tf_idf.mat','dataset');
    option = 'save dataset with idf and tf item to dataMat/dataset_tf_idf.mat'
end

function idf=idf_function(image_count, idf)
    idf = image_count./idf;
end
