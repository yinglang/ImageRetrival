% 该脚本应在刚打开matlab时， 运行一次，之后不应再运行
function a_start()
    % load sift libary %
    if strcmp(which('vl_sift'),'')
        run('D:/IDE/matlab/third_part/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/vl_setup');
    end
    
    try
        pool = parpool;
        pool.IdleTimeout = 1;
    catch                                            % 开启失败大多时候是已经开启了
        option = 'parallel open failed, maybe you have open parallel'
    end
%     else if isa(pool,'parallel.Pool')           % 开启过
%             try
%                 if ~pool.Connected                  % 断开连接了, pool.IdelTimeOut可以设多长时间不用就关闭连接，默认30分钟
%                     delete(pool);
%                     pool = parpool;
%                 end
%             catch                                   % 对象已经delete掉了
%                 pool = parpool;
%             end
%         else
%         end
%     end
end