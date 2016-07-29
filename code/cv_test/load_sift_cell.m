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

function dataset=load_sift_cell(dir)
    files = ls(dir);
    for i = 3: size(files,1)       % 前两个是 .和 ..
        filepath = strcat(dir, files(i,:));
        img = imread(filepath);
        s =  size(img);
        dataset.s{i-2} = s(1:2);
        [f, d] = get_sift(img);
        dataset.f{i-2} = f;                            % 返回值每一列对应一个关键点，与大多数matlab函数习惯相反，这里将它调整为每列对应一个关键点
        dataset.d{i-2} = d;
        option = strcat('  get_sift of ',int2str(i-2) ,' / ', int2str(size(files,1)-2))
    end
    % 大数据应在这里持久化存储
    save('datamat/dataset_sift.mat', 'dataset');
    option = '[BIG]: get sift over. dataset save to datamat/dataset_sift.mat.'
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