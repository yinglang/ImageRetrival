function Q=query_get_index_feature_by_R_S(Q, rotations, scales)
    len_r = length(rotations);
    len_s = length(scales);
    R = zeros(len_r, 2,2);
    for i = 1 : len_r
        R(i,:,:) = get_rotate_matrix(rotations(i));
    end
    
    Q.rs_p = {};
    for j = 1 : len_s
        Q.rs_p{1, j} = Q.f(:, 1:2).*scales(j);                  % 伸缩变换，将所有的location等比放缩
        for i = 1 : len_r
            Q.rs_p{i,j} = R(i) * Q.rs_p{1,j};                      % 旋转变换，将所有的rotation旋转一定角度
        end
    end
end

% 根据弧度制的角度theta确定一个旋转矩阵，R * p 得到坐标p逆时针旋转theta角度的新坐标
function R=get_rotate_matrix(theta)
    R = [cos(theta), -sin(theta);
         sin(theta), cos(theta)];
end