function test_query()
    baseDir = 'C:\Users\yinglang\Desktop\cv\test\';
    files = ls(baseDir);
    right = [28, 1, 2, 47, 20, 20, 48, 48, 48];
    for i = 3:size(files, 1)
        file = strcat(baseDir, files(i, :));
        query_one(file)
    end
end
