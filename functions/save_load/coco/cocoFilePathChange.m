function cocoStructure=cocoFilePathChange(cocoStructure, newpath, varargin)
%     update coco filepath depend on OS
%{
      input:
          cocoStructure.images
          newpath=''
          varargin{1}=data_folder
      output:
          cocoObj.data  <= from cocoApi, with new file path
                 .inds
%}
if isempty(newpath)~=1
    if length(cocoStructure.images)==1
        cocoimage_temp=struct2table_chh(cocoStructure.images);
    else
        cocoimage_temp=struct2table(cocoStructure.images);
    end
    if ismac
        disp('Platform not supported')
        % Code to run on Mac platform
    elseif isunix
        if isempty(varargin)~=1
            data_folder=varargin{1};
        else
            sepn=strfind(newpath,'/');
            if  strcmp(newpath(end),'/')==1
                data_folder= newpath(sepn(end-1)+1:sepn(end)-1);
            else
                data_folder= newpath(sepn(end)+1:end);
            end
        end
        indt=strfind(cocoimage_temp.file_path{1},data_folder);
        old_path=cocoimage_temp.file_path{1}(1:indt+length(data_folder));
        cocoimage_temp.file_path = strrep(cocoimage_temp.file_path,old_path, [newpath data_folder filesep] );
        cocoimage_temp.file_path = strrep(cocoimage_temp.file_path,'\', '/');
        cocoStructure.images=table2struct(cocoimage_temp)';

    elseif ispc
        if isempty(varargin)~=1
            data_folder=varargin{1};
        else
            sepn=strfind(newpath,'\');
            if  strcmp(newpath(end),'\')==1
                data_folder= newpath(sepn(end-1)+1:sepn(end)-1);
            else
                data_folder= newpath(sepn(end)+1:end);
            end
        end

        indt=strfind(cocoimage_temp.file_path{1},data_folder);
        old_path=cocoimage_temp.file_path{1}(1:indt+length(data_folder));
        cocoimage_temp.file_path = strrep(cocoimage_temp.file_path,old_path, [newpath data_folder filesep] );
        cocoimage_temp.file_path = strrep(cocoimage_temp.file_path,'/', '\');
        cocoStructure.images=table2struct(cocoimage_temp)';
    else
        disp('Platform not supported')
    end
end
%cocoObj=CocoApi(cocoStructure);