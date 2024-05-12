function file_info=filepathname_of_image_Vmaskrcnn(filepath0,varargin)
if isempty(varargin)~=1
    mpara=varargin{1};
end
%foldername_temp=folderTag2foldername(dinfo{ff,1}.folderTag_train.maskrcnn(sh), train_imsize{ts}, 'train');
%filepath_train_image0=struct2table(dir([dinfo{ff}.filepath_image filesep foldername_temp]));
%foldername_temp=folderTag2foldername(dinfo{ff,1}.folderTag_train.maskrcnn(sh), train_imsize{ts}, 'train');
if exist(filepath0,'dir')
    switch mpara.flag_save_train_path_case
        case 3
            file_path1=[filepath0 filesep 'images'];
            file_name0=dir(file_path1);
            file_name0=file_name0(~ismember({file_name0.name},{'.','..'}));
            file_name={file_name0.name}';
            file_path=repmat({[filepath0 filesep 'images']},length(file_name),1);
           

            
        case {2,1}
            filepath_train_image0=dir(filepath0);

            filepath_train_image0=filepath_train_image0(~ismember({filepath_train_image0.name},{'.','..'}));
            filepath_train_image0=struct2table(filepath_train_image0);
            if size(filepath_train_image0,1)>1
                temp=cellfun(@(x,y) [x filesep y],[filepath_train_image0.folder] ,[filepath_train_image0.name],'un',0);
                file_path = cellfun(@(c)[c filesep 'images' filesep],temp,'uni',false);

                temp=[filepath_train_image0.name];
                file_name_for_ext=dir(file_path{1});
                file_name = cellfun(@(c)[c file_name_for_ext(3).name(end-3:end)],temp,'uni',false);
            else
                file_path={[filepath_train_image0.folder filesep filepath_train_image0.name filesep 'images' filesep]}';
                temp=[filepath_train_image0.name];
                file_name_for_ext=dir(file_path{1});
                file_name={[temp file_name_for_ext(3).name(end-3:end)]};
            end
            if isfield(mpara,'flag_getmaskpath')
                if mpara.flag_getmaskpath==1
                    if size(filepath_train_image0,1)>1
                        temp=cellfun(@(x,y) [x filesep y],[filepath_train_image0.folder] ,[filepath_train_image0.name],'un',0);
                        file_path_mask = cellfun(@(c)[c filesep 'masks' filesep],temp,'uni',false);
                        name_mask=repmat({'_1.png'},length(file_name),1);
                        file_name_mask=cellfun(@(x,y) [x y],[filepath_train_image0.name] ,[name_mask],'un',0);
                    else
                        file_path_mask={[filepath_train_image0.folder filesep filepath_train_image0.name filesep 'masks' filesep]}';
                        temp=[filepath_train_image0.name];
                        %file_name_for_ext=dir(file_path{1});
                        file_name_mask={[temp '_1.png']};
                    end

                    %temp=[filepath_train_image0.name];
                    %
                    %             file_name_mask

                    %             file_name_mask=repmat({''},length(file_path_mask),1);
                    %             for dd=1:length(file_path_mask)
                    %                 dd
                    %                 file_name_for_extmask=dir(file_path_mask{dd});
                    %                 if length(file_name_for_extmask)>=3
                    %                     for mm=3:length(file_name_for_extmask)
                    %                         file_name_mask{dd,mm-2}=file_name_for_extmask(mm).name;
                    %                     end
                    %                 else
                    %                     file_name_mask{dd,1}='';
                    %                 end
                    %             end
                end
            end


    end
   
    
    
    if isempty(varargin)==1
        file_info=table2struct(table(file_path,file_name));
    else
        if isfield(mpara,'im_size')
            height=ones(length(file_name),1)*mpara.im_size(1);
            width=ones(length(file_name),1)*mpara.im_size(2);
        end
        if isfield(mpara,'imId_case')
            switch mpara.imId_case
                case 'id0_filename_type1' %yolo
                    for jj=1:length(file_name)
                        filename_temp=file_name{jj}(length(mpara.filename_image)-3:end);
                        snc=strfind(filename_temp,'_');
                        if length(snc)==1
                            snc=strfind(filename_temp,'_n');
                            if isempty(snc)==1
                                snc=strfind(filename_temp,'_s');
                            end
                            snc(2)=strfind(filename_temp,'.');
                            id(jj,1)=mpara.imId1*10000+uint64(str2num(filename_temp(snc(1)+2:snc(2)-1)));
                        else
                            id(jj,1)=mpara.imId1*10000+uint64(str2num(filename_temp(snc(1)+1:snc(2)-1)));
                        end
                    end
                case 'id0_filename_type2' %unet
                    snc=strfind(file_name,'_');
                    for jj=1:length(file_name)
                        %filename_temp=file_name{jj}(length(mpara.filename_image)-3:end);
                        filename_temp=file_name{jj}(length(mpara.filename_image)-3:end);
                        snc=strfind(filename_temp,'_');
                        
                        %id(jj,1)=mpara.imId1*100000000+uint64(str2num(filename_temp(snc(1)+1:snc(2)-1)));
                        id(jj,1)=mpara.imId1*100000000+uint64(str2num(filename_temp(snc(1)+2:snc(2)-1)));
                    end
                    
            end
        end
        if isfield(mpara,'flag_getmaskpath') 
            try %if mpara.flag_getmaskpath==1
                file_info=table2struct(table(file_path,file_name,height,width,id,file_path_mask,file_name_mask));
            catch
                file_info=table2struct(table(file_path,file_name,height,width,id));
            end
        else
            file_info=table2struct(table(file_path,file_name,height,width,id));
        end
    end
else
    file_info='';
end
%data1{ff}.(foldername_load.yolo5{ts}{sh}).images=table2struct(table(file_path,file_name));
