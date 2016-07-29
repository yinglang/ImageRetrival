function feature=get_sift(imagepath)
    img = imread(imagepath);
    scale = 500 * 400 / (size(img,1) * size(img,2));
    %if scale < 1
    img = imresize(img, sqrt(scale));
    %end
    img = single(rgb2gray(img));
    [f,d] = vl_sift(img);
    feature.f = f;
    feature.d = d;
    s = size(img);
    feature.s = s(1:2);
end