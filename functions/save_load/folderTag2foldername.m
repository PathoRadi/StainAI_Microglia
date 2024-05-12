function foldername=folderTag2foldername(folderTag, image_size, case_foldername);
for ii=1:size(folderTag,1)
    tempStr = lower(folderTag{ii,1});
    exshift=strfind(tempStr,'shift');
    if isempty(exshift)==1
        if isempty(case_foldername)~=1
            foldername=[folderTag{ii,1} '_' num2str(image_size(1)) 'x' num2str(image_size(2)) '__' case_foldername];
        else
            foldername=[folderTag{ii,1} '_' num2str(image_size(1)) 'x' num2str(image_size(2))];
        end
    else
        name_temp=[folderTag{ii,1}(1:exshift-1) folderTag{ii,1}(exshift+5:end)];
        if isempty(case_foldername)~=1
            foldername=[name_temp '_' num2str(image_size(1)) 'x' num2str(image_size(2)) 'shift__' case_foldername];
        else
            foldername=[name_temp '_' num2str(image_size(1)) 'x' num2str(image_size(2)) 'shift'];
        end
    end
    if size(folderTag,2)==2
        foldername=[foldername '__' folderTag{ii,2}];
    end
end