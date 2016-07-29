function vgg_feature=get_vgg_feature(imagapath, net)
    % load and processs an image
    im = imread(imagapath);
    im = single(im);
    im = imresize(im, net.meta.normalization.imageSize(1:2));
    im = bsxfun(@minus, im, net.meta.normalization.averageImage);

    % run the CNN
    res = vl_simplenn(net, im);

    % show the classification result
    scores= squeeze(gather(res(end).x));
    vgg_feature= scores;
end
