function dataset=load_dataset_sift(basedir)
    classes = 52;
    countPerClass = 20;
    
   dirs = ls(basedir);
   delete(gcp('nocreate'));parpool(2);
   dataset = cell(classes * countPerClass, 1);
   k = 1;
   for i = 3:size(dirs, 1)
       classname = dirs(i,:);
       dir = strcat(basedir, dirs(i, :), '/');
       files = ls(dir);
       
       features = cell(1, size(files, 1)-2);
       
       files_count = size(files, 1)-2;
       parfor j = 3: size(files, 1)
           file = strcat(dir, files(j, :));
           features{j-2} = get_sift(file);
           fprintf(1, '%s %g / %g, %g / %g over\n', classname, j-2, files_count, i-2, size(dirs, 1)-2);
       end

       for j = 3: size(files, 1)
           dataset{k}.d = features{j-2}.d;
           dataset{k}.f = features{j-2}.f;
           dataset{k}.s = features{j-2}.s;
           dataset{k}.class = uint16(str2double(classname)); %files(j,:)
           k = k + 1;
       end
   end
   
   save('dataMat/dataset.mat', 'dataset');
end