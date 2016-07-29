function open_parallel()
    try
            pool = parpool;
            pool.IdleTimeout = 1;
        catch                                            % 开启失败大多时候是已经开启了
            fprintf(1, '[state]: parallel open failed, maybe you have open parallel\n');
    end
end

