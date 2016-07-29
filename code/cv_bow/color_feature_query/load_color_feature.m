function dataset = load_color_feature( basedir, dataset, para )
    if isempty(dataset)                                         % 如果要从mat文件中读取，传入[],[]
        dataset = load('dataMat/dataset_tf_idf.mat');
        dataset = dataset.dataset;
    end

    dirs = ls(basedir);
    i = 1;

    for dir_i = 3 : size(dirs, 1)
%         classname = dirs(dir_i, :);
        dir = strcat(basedir, dirs(dir_i, :), '/');
        files = ls(dir);
        for j = 1: (size(files, 1)-2)
            file = strcat(dir, files(j+2,:));
%             if dataset.class{i} ~= dirs(dir_i, :)
%                 'error'
%                 break;
%             end
            dataset.color_feature{i} = get_color_feature(file, dataset.f{i}, para);
%             dataset.class{i} = classname;
            i = i + 1;
        end
    end
    
    save('dataMat/dataset_tf_idf', 'dataset');
    fprintf(1, 'save dataset to dataset_tf_idf\n');
end

