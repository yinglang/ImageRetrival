 basedir = 'C:/Users/yinglang/Desktop/cvcut/dataset/';
 imgpath1 = '1/1.jpg';
 imgpath2 = '1/10.jpg';
 [f1, d1] = get_sift_size(strcat(basedir, imgpath1));
 [f2, d2] = get_sift_size(strcat(basedir, imgpath2));
 [matches, scores] = vl_ubcmatch(d1, d2) ;
 
 img = imread(strcat(basedir, imgpath1));
 scale = 500 * 800 / (size(img,1) * size(img,2));
 if scale < 1
    img = imresize(img, sqrt(scale));
 end
 img1 = img;
 img = imread(strcat(basedir, imgpath2));
 scale = 500 * 800 / (size(img,1) * size(img,2));
 if scale < 1
    img = imresize(img, sqrt(scale));
 end
 img2 = img;
 img = [];
%  img = zeros(max(size(img1,1), size(img2, 1)), size(img1,2) + size(img2,2), max(size(img1, 3), size(img2,3)));
%  img(1:size(img1,1), 1:size(img1,2),1:size(img1, 3)) = img1;
%  img(1:size(img2,1), size(img1,2) + 1 : size(img1,2)+size(img2,2),1:size(img2, 3)) = img2;
%  imshow(uint8(img));
%  hold on
 
%  plot_sift_match(img1, img2, f1, f2, matches, 64);

figure; 
 ss = 64;
 subplot(1,2,1);
 img = imread(strcat(basedir, imgpath1));
 scale = 500 * 800 / (size(img,1) * size(img,2));
 if scale < 1
    img = imresize(img, sqrt(scale));
 end
 imshow(img);
 hold on
 plot(f1(1,matches(1,1:ss)), f1(2, matches(1,1:ss)),'.g'); 
%  plot(f1(1,:), f1(2, :),'.g'); 
 
 subplot(1,2,2);
 img = imread(strcat(basedir, imgpath2));
 scale = 500 * 800 / (size(img,1) * size(img,2));
 if scale < 1
    img = imresize(img, sqrt(scale));
 end
 imshow(img);
 hold on
 plot(f2(1,matches(2,1:ss)), f2(2, matches(2,1:ss)),'.r'); 
%  plot(f2(1, :), f2(2, :),'.g'); 
 hold on;
 img=[];

 
 



