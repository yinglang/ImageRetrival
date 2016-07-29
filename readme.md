目录 | 说明
--- | ---
code|使用的算法的实现代码
data| 裁剪后的图片数据
third_part_lib| 依赖的第三方库
third_part_lib\vl_feature| 用于提取sift
third_part_lib\matconvtnet| 一个CNN的matlab库，用于加载解析cnn model

code 中的算法 与 程序入口的对应关系

		方法                | 对应的代码位置
--------------------|--------------------------------------------------------------------------
sift bow + 余弦 			| code/cv_bow/bow_pipeline.m
sift bow + svm				| code/cv_bow/bow_svm_pipeline.m
color feature + 余弦		| code/cv_bow/color_feature_pipeline.m
cnn feature + 余弦			| code/cv_cnn/cnn_query/pipeline.m
cnn feature + svm			| code/cv_cnn/cnn_svm/pipeline.m
cnn feature + 余弦 + rerank | code/cv_cnn/rerank/pipeline.m
cnn feature + svd + svm		| code/cv_cnn/cnn_svm/pipeline.m (修改35行为 para.useSVD = 1; )
纯 sift 匹配				| code/cv_sift_dir/pipeline.m
scsm | 效果不理想，没有把代码加进来

该代码使用的数据云盘链接：[http://pan.baidu.com/s/1cgdpjo](http://pan.baidu.com/s/1cgdpjo)<br/>
该代码对该数据集提取的特征: [http://pan.baidu.com/s/1nvlg50t](http://pan.baidu.com/s/1nvlg50t)
该特征不是运行代码所必需的，但是如果使用提取好的特征可以省去其中的提取特征和聚类的时间（大概3小时）