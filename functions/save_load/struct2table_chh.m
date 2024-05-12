function table_opt=struct2table_chh(struct_in)
sfieldname=fieldnames(struct_in);
table_opt='';
for nn=1:length(sfieldname)
    
    if ischar(struct_in.(sfieldname{nn}))==1
        eval([ sfieldname{nn} '{1}= struct_in.(sfieldname{ ' num2str(nn) '});']);
    else
        eval([ sfieldname{nn} '= struct_in.(sfieldname{ ' num2str(nn) '});']);
    end
end
temp=cellfun(@(c) [c ', '],sfieldname,'un',0);
tempstring=[temp{:}];
eval(['table_opt=table(' tempstring(1:end-2) ');']);
%table_opt=table(license,file_path,file_name,file_name1,coco_url,height,width,data_captured,flickr_url,id);
%clear license file_path file_name file_name1 coco_url height width data_captured flickr_url id
