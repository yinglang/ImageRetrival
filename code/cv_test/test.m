function s=test()
    a = rand(1000,1000);
    s = eye(1000);
    tic
    for i = 1:1000
        s = s * a;
    end
    toc
end