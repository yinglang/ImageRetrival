function plot_sift_match(img1, img2, f1, f2, matches, max_point_count)  % pos = (col, row) = (x, y)
%PLOT_SIFT_MATCH Summary of this function goes here
%   Detailed explanation goes here
     matches_pos1 = f1(1:2, matches(1, :))';
     matches_pos2 = f2(1:2, matches(2,:))';

     plot_by_posXY(img1, img2, matches_pos1, matches_pos2, max_point_count);

end

function plot_by_posXY(img1, img2, matches_pos1, matches_pos2, max_point_count)
     img = zeros(max(size(img1,1), size(img2, 1)), size(img1,2) + size(img2,2), max(size(img1, 3), size(img2,3)));
     img(1:size(img1,1), 1:size(img1,2),1:size(img1, 3)) = img1;
     img(1:size(img2,1), size(img1,2) + 1 : size(img1,2)+size(img2,2),1:size(img2, 3)) = img2;
     imshow(uint8(img));
     
     matches_pos2(:, 1) = matches_pos2(:, 1) + size(img1, 2);               
     for i = 1:size(matches_pos1, 1)
         hold on
         plot([matches_pos1(i, 1), matches_pos2(i, 1)], [matches_pos1(i, 2), matches_pos2(i, 2)], 'g');
         if i >= max_point_count
             break
         end
     end
end

     

