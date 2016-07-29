function res = query_all( basedir, dataset, net )
    if isempty(net)
        net = load('../cnn_mat/imagenet-vgg-f.mat');
        net = vl_simplenn_tidy(net);
    end
    if isempty(dataset)
        dataset = load('../dataMat/dataset.mat', 'dataset');
        dataset = dataset.dataset;
    end

    dirs = ls(basedir);
%     delete(gcp('nocreate'));parpool(2);
    k = 1;
    for i = 3:size(dirs, 1)
       classname = dirs(i, :);
       dir = strcat(basedir, dirs(i, :), '/');
       files = ls(dir);
       
       right = zeros(size(files, 1)-2, 1);
       test = zeros(size(files, 1)-2, 1);
%        parfor j = 3: size(files, 1)
       for j = 3: size(files, 1)
           file  = strcat(dir, files(j,:));
           tic
           index = query(file, dataset, net);
           toc
           fprintf(1, 'recognize: %g, right: %s\n', index, classname);
           
           right(j-2) = uint16(str2double(classname));
           test(j-2) = index;
       end
       
       for j = 3:size(files, 1)
           res.right(k) = right(j-2);
           res.query(k) = test(j-2);
           k = k + 1;
       end
    end
end

