function a = test_sig(sift, label, P, T)
    Z = double(sift) * P';
    bit = Z > T(label, :);
    
    a = uint64(0);
    for i = 64:-1:1
        a = bitshift(a, 1) + uint64(bit(i));
    end
end

