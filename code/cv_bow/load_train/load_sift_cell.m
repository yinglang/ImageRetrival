% 参数:
%   dir 放有图片的文件夹路径

% 功能:
%   提取一个文件夹下（不包括子文件）的所有图片的sift，放入返回的dataset里

% 返回值:
% dataset.f{i} = matrix(n, 4)  每一行对应一个特征点，每一行的前两个对应特征点坐标
% dataset.s{i} = matrix(1, 2)  记录第i张图片的size (weight,height)
% dataset.d{i} = matix(n,128)  每一行对应一个特征点的descriptor

% warnning:
%   对于cell而言默认是二维的，cell{i} = cell{1,i}
function dataset=load_sift_cell(basedir)
    dirs = ls(basedir);
    i = 1;
    delete(gcp('nocreate'));parpool(2);
    for dir_i = 3 : size(dirs, 1)
        dir = strcat(basedir, dirs(dir_i, :), '/');
        sub_dataset = load_sift_cell_of_dir(dir, dir_i-2);
        for j = 1: size(sub_dataset.s, 2)
            dataset.s{i} = sub_dataset.s{j};
            dataset.f{i} = sub_dataset.f{j};
            dataset.d{i} = sub_dataset.d{j};
            i = i + 1;
        end
    end
    
        % 大数据应在这里持久化存储
    save('datamat/dataset_sift.mat', 'dataset');
    option = '[BIG]: get sift over. dataset save to datamat/dataset_sift.mat.'
end

function dataset=load_sift_cell_of_dir(dir, dir_i)
    files = ls(dir);
    files_count = size(files, 1);
    ds = cell(1, files_count -2);
    df = cell(1, files_count -2);
    dd = cell(1, files_count -2);
    
    parfor i = 3: files_count       % 前两个是 .和 ..
        filepath = strcat(dir, files(i,:));
        img = imread(filepath);
        
        scale = (500 * 800) / (size(img, 1) * size(img, 2));                   % 根据大概每200-400个像素会有一个sift获得
        if scale < 1
            img = imresize(img, sqrt(scale));
        end

        s =  size(img);
        ds{i-2} = s(1:2);
        [f, d] = get_sift(img);
        df{i-2} = f;                            % 返回值每一列对应一个关键点，与大多数matlab函数习惯相反，这里将它调整为每列对应一个关键点
        dd{i-2} = d;
        fprintf(1, '[load_sift]:  %d / %d / %d\n', i-2, files_count-2 , dir_i);
    end
    dataset.s = ds;
    dataset.f = df;
    dataset.d = dd;
end

% 返回值每一列对应一个关键点，与大多数matlab函数习惯相反
function [f,d] = get_sift(img)
% f is info of each keypoints, center f(1:2, i), scale f(3, i) and orientation f(4, i) %
% d is descriptors for every keypoint %
    img = single(rgb2gray(img));
    [f, d] = vl_sift(img);
    
    % 格式化，matlab图片坐标是(row,col),而f(1:2, i) = (col,row)
    t = f(1,:);
    f(1,:) = f(2,:);
    f(2,:) = t;
    % matlab 矩阵一般每行是一个数据，列数是数据个数，这里取一个转置
    f = f';
    d = d';
end