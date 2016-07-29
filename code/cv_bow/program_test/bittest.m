% image_count = size(dataset.d, 2);
% for i=1:image_count
%     res = sum(dataset_cpp.sig{i} ~= dataset_matlab.sig{i});
%     if res ~= 0
%         i
%     end
% end


bit = bitxor(2^32, 2^32-1);
dis = 0;
for i = 1 : 64
    dis = dis + bitand(bit, 1);
    bit = bitshift(bit, -1);
end

