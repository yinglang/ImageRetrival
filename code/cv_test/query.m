function [image_index, T] = query()
    [centers, dataset, ~, ~, rerank_mat] = load_anything();
    tic
    img = get_img();
    [image_index, T] = query_main(img,centers, dataset, rerank_mat);
    toc
end

function img=get_img()
    basedir = 'img/';
    queryset_path = strcat(basedir, 'queryset/all_souls_000013.jpg');
    img = imread(queryset_path);
    figure;
    imshow(img);
end

function [image_index, T] = query_main(img,centers, dataset, rerank_mat)
    basedir = 'img/';
    dataset_path = strcat(basedir, 'dataset/');
    files = ls(dataset_path);
    files = files(3:end,:);
    
    Q = query_get_index_feature(img, centers);
    [image_index, T] = query_in_dataset(Q, dataset, rerank_mat)
    
    img = imread(strcat(dataset_path, files(image_index,:)));
    figure;
    imshow(img);
end