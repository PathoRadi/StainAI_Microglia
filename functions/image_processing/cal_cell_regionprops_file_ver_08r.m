function data1=cal_cell_regionprops_file_ver_08r(data1,select_data,flag,varargin)
% cell_regionprops_09r, 
%    find bug in cell_regionprops_09r, the core map should be created before calculate core distance
% cell_regionprops_09rC: correct version without oarfor for plot figure
% cell_regionprops_09r_parfor: use parfor to increase processing speed

if isempty(varargin)~=1
    filepath01=varargin{1};
end
filepath_mat_temp=[data1.info.filepath_image 'mat_temp' filesep];
mpara.folder_fig_temp=[filepath_mat_temp select_data '__fig'];
mpara.save_figure=0;
%5
filenamefull_cell_prop=[filepath_mat_temp select_data '__' flag.regp_ver '.mat'];
filename_cocoN=[data1.info.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_verN '.json'];
if isfield(data1,select_data)==1;clear tableN tableNr atlas_allcellcore_N
try
    score=[data1.(select_data).coco.annotations.score]';
catch
    score=ones(size(data1.(select_data).coco.annotations,2),1);
end
    if isempty(flag.regp_verN)==1 %isfield(flag,'regp_verN')==1
        filenamefull_cell_prop=[filepath_mat_temp select_data '__' flag.regp_ver '.mat'];
        filename_coco=[data1.info.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver '.json'];
        if ~exist([data1.info.filepath_coco filesep filename_coco],'file');
            %if ~exist(filenamefull_cell_prop,'file');
            close all;flag.rcal_all=1;
            filenamefull_cell_temp=[filepath_mat_temp select_data '__' flag.regp_ver '_temp.mat'];
            [tableN,tableNr,atlas_allcellcore_N]=cell_regionprops_09r_parfor(data1,select_data,flag,filenamefull_cell_temp,mpara);
            %%%[tableN,tableNr]=cell_regionprops_01(data1,select_data,filenamefull_cell_temp);
            %             [tableNc,tableNrc,bnSc]=cell_regionprops_08rcheck(data1,select_data,filenamefull_cell_temp,mpara);
            %             Tname=fieldnames(tableNc);
            %             for tn=[3 4 19:55];tn
            %                 if sum(tableNc.(Tname{tn})(bnSc(3),:)-tableN.(Tname{tn})(bnSc(3),:))>1*10-7
            %                     wrong
            %                 end
            %             end;tableNc.(Tname{49})(bnSc(3),:)
            save(filenamefull_cell_prop,'tableN','tableNr','atlas_allcellcore_N','-v7.3');
            data1.(select_data).atlas_allcellcore_N=atlas_allcellcore_N;
            %else;
            %load(filenamefull_cell_prop);
            %end
            data1.(select_data).cocoP=data1.(select_data).coco;data1.(select_data).cocoP.annotations=table2struct(tableN);
            data1.(select_data)=rmfield(data1.(select_data),'coco');
            cocostring=gason(data1.(select_data).cocoP);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
        else
            try
                coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                data1.(select_data).filename_coco=filename_coco;

                if isfield(coco_temp.data.annotations,'distC_mean3');coco_temp.data.annotations=rmfield(coco_temp.data.annotations,'distC_mean3');end
                if isfield(coco_temp.data.annotations,'distC_mean');coco_temp.data.annotations=rmfield(coco_temp.data.annotations,'distC_mean');end
                if isfield(coco_temp.data.annotations,'distC_std');coco_temp.data.annotations=rmfield(coco_temp.data.annotations,'distC_std');end
                if isfield(coco_temp.data.annotations,'cellC_adjN');coco_temp.data.annotations=rmfield(coco_temp.data.annotations,'cellC_adjN');end
                if isfield(coco_temp.data.annotations,'distE_mean3');coco_temp.data.annotations=rmfield(coco_temp.data.annotations,'distE_mean3');end
                if isfield(coco_temp.data.annotations,'distE_mean');coco_temp.data.annotations=rmfield(coco_temp.data.annotations,'distE_mean');end
                if isfield(coco_temp.data.annotations,'distE_std');coco_temp.data.annotations=rmfield(coco_temp.data.annotations,'distE_std');end
            catch
                %if ~exist(filenamefull_cell_prop,'file');
                close all
                filenamefull_cell_temp=[filepath_mat_temp select_data '__' flag.regp_ver '_temp.mat'];
                [tableN,tableNr,atlas_allcellcore_N]=cell_regionprops_09r_parfor(data1,select_data,flag,filenamefull_cell_temp,mpara);
                %[tableN,tableNr]=cell_regionprops_01(data1,select_data,filenamefull_cell_temp);
                save(filenamefull_cell_prop,'tableN','tableNr','atlas_allcellcore_N','-v7.3');
                data1.(select_data).atlas_allcellcore_N=atlas_allcellcore_N;
                %else;load(filenamefull_cell_prop);end
                data1.(select_data).cocoP=data1.(select_data).coco;data1.(select_data).cocoP.annotations=table2struct(tableN);
                data1.(select_data)=rmfield(data1.(select_data),'coco');
                cocostring=gason(data1.(select_data).cocoP);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
            end
            %filename_cocob=[data1.info.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver 'b.json'];
            %coco_tempb=CocoApi([data1.info.filepath_coco filesep filename_cocob]);
            coco_temp=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));

            cocoStructure=cocoFilePathChange(coco_temp, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
            if flag.category_update>0;cocoStructure=coco_category_update_v01(cocoStructure,data1);end
            data1.(select_data).cocoP=cocoStructure;

        end
    else
        if flag.cal_cell_prop_rn==1
            filename_cocoN=[data1.info.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_verN '.json'];
            filenamefull_cell_propN=[filepath_mat_temp select_data '__' flag.regp_verN '.mat'];
            if exist([data1.info.filepath_coco filesep filename_cocoN],'file') && flag.rcal_all==0; % load data if exist
                coco_temp=CocoApi([data1.info.filepath_coco filesep filename_cocoN]);
                cocoStructure=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
                if flag.category_update>0;cocoStructure=coco_category_update_v01(cocoStructure,data1);end
                data1.(select_data).cocoP=cocoStructure;
                try
                    load(filenamefull_cell_propN);
                catch % load old version of flag.regp_ver
                    filenamefull_cell_propOld=[filepath_mat_temp select_data '__ ' flag.regp_ver '.mat'];
                    load(filenamefull_cell_propOld);
                    %save(filenamefull_cell_propN,'tableN','tableNr','atlas_allcellcore_N','iex');
                end
                %filename_cocob=[data1.info.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver 'b.json'];
                %coco_tempb=CocoApi([data1.info.filepath_coco filesep filename_cocob]);
                %data1.(select_data).cocoPb=coco_tempb.data;
            else
                filenamefull_cell_propN=[filepath_mat_temp select_data '__' flag.regp_verN '.mat'];
                if flag.cal_cell_prop_rn==1;
                    filename_coco=[data1.info.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver '.json'];
                    filenamefull_cell_temp=[filepath_mat_temp select_data '__' flag.regp_ver '_temp.mat'];
                    filenamefull_cell_temp_old=[filepath_mat_temp select_data '__' flag.regp_ver '_tempO_' date '.mat'];
                    % if exist(filenamefull_cell_temp,'file'); % backup old file
                    %copyfile(filenamefull_cell_temp,filenamefull_cell_temp_old);
                    %                     end
                    filenamefull_cell_N=[filepath_mat_temp select_data '__' flag.regp_verN '.mat'];
                    %flag.rn_prop={'distCE'}; % add the new calculated prop

                    rn_prop={'distCE','CHC','core_Cdist'};

                    [tableN,tableNr,atlas_allcellcore_N,iex]=cell_regionprops_09r_parfor(data1,select_data,flag,filenamefull_cell_N,mpara,rn_prop);
                    %filenamefull_cell_prop_old=[filepath_mat_temp select_data '__' flag.regp_ver 'O.mat'];
                    %copyfile(filenamefull_cell_prop,filenamefull_cell_prop_old);
                    save(filenamefull_cell_propN,'tableN','tableNr','atlas_allcellcore_N','iex','-v7.3');
                    if isfield(data1.(select_data),'coco')==1
                        data1.(select_data).cocoP=data1.(select_data).coco;
                    else
                        if isfield(data1.(select_data),'cocoP')==1
                            data1.(select_data).cocoP=data1.(select_data).cocoP;
                        end
                    end
                    data1.(select_data).cocoP.annotations=table2struct(tableN);
                    data1.(select_data).filename_coco=filename_cocoN;
                    cocostring=gason(data1.(select_data).cocoP);
                    fid = fopen([data1.info.filepath_coco filesep filename_cocoN], 'w');
                    if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                end
            end

        else % load flag.regp_verN if exist, if not exist load flag.regp_ver, if not exist calculate 
            filename_cocoN=[data1.info.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_verN '.json'];
            filenamefull_cell_propN=[filepath_mat_temp select_data '__' flag.regp_verN '.mat'];
            
            try
                coco_temp=CocoApi([data1.info.filepath_coco filesep filename_cocoN]);
                if isfield(coco_temp.data.annotations,'id1');coco_temp.data.annotations=rmfield(coco_temp.data.annotations,'id1');
                    cocoStructure=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
                    cocostring=gason(cocoStructure);fid = fopen([data1.info.filepath_coco filesep filename_cocoN], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                end
                try
                    load(filenamefull_cell_propN);
                catch
                    filenamefull_cell_propOld=[filepath_mat_temp select_data '__ ' flag.regp_verN '.mat'];
                    copyfile(filenamefull_cell_propOld,filenamefull_cell_propN);
                    load(filenamefull_cell_propN);
                    %save(filenamefull_cell_propN,'tableN','tableNr','atlas_allcellcore_N','iex');
                end
                data1.(select_data).filename_coco=filename_cocoN;
            catch
                filenamefull_cell_prop=[filepath_mat_temp select_data '__' flag.regp_ver '.mat'];
                filename_coco=[data1.info.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver '.json'];

                try
                    coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                    data1.(select_data).filename_coco=filename_coco;
                    filenamefull_cell_prop=[filepath_mat_temp select_data '__' flag.regp_ver '.mat'];
                    try
                        load(filenamefull_cell_prop);
                    catch % move from old folder
                        filenamefull_cell_prop2=[filepath_mat_temp select_data '__ ' flag.regp_ver '.mat'];
                        copyfile(filenamefull_cell_prop2,filenamefull_cell_prop);
                        load(filenamefull_cell_prop);
                        %save(filenamefull_cell_prop,'tableN','tableNr','atlas_allcellcore_N','iex');
                    end
                catch
                    close all;flag.rcal_all=0;
                    filenamefull_cell_temp=[filepath_mat_temp select_data '__' flag.regp_ver '_temp.mat'];
                    %[tableN,tableNr,atlas_allcellcore_N]=cell_regionprops_09r(data1,select_data,flag,filenamefull_cell_temp,mpara);

                    %[tableN,tableNr,atlas_allcellcore_N]=cell_regionprops_09rC(data1,select_data,flag,filenamefull_cell_temp,mpara);

                    [tableN,tableNr,atlas_allcellcore_N]=cell_regionprops_09r_parfor(data1,select_data,flag,filenamefull_cell_temp,mpara);


                    %%%[tableN,tableNr]=cell_regionprops_01(data1,select_data,filenamefull_cell_temp);
                    %             [tableNc,tableNrc,bnSc]=cell_regionprops_08rcheck(data1,select_data,filenamefull_cell_temp,mpara);
                    %             Tname=fieldnames(tableNc);
                    %             for tn=[3 4 19:55];tn
                    %                 if sum(tableNc.(Tname{tn})(bnSc(3),:)-tableN.(Tname{tn})(bnSc(3),:))>1*10-7
                    %                     wrong
                    %                 end
                    %             end;tableNc.(Tname{49})(bnSc(3),:)
                    save(filenamefull_cell_prop,'tableN','tableNr','atlas_allcellcore_N','-v7.3');
                    data1.(select_data).atlas_allcellcore_N=atlas_allcellcore_N;
                    %else;
                    %load(filenamefull_cell_prop);
                    %end
                    data1.(select_data).cocoP=data1.(select_data).coco;data1.(select_data).cocoP.annotations=table2struct(tableN);
                    data1.(select_data)=rmfield(data1.(select_data),'coco');
                    cocostring=gason(data1.(select_data).cocoP);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                    coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                    data1.(select_data).filename_coco=filename_coco;
                end
            end

            if flag.update_yoloscore==1
                cocopT=struct2table(coco_temp.data.annotations);
                if istablefield(cocopT,'score')~=1
                    cocopT= addvars(cocopT,score,'Before','image_id');
                end
                if isfield(data1.(select_data),'coco')
                    data1.(select_data).cocoP=data1.(select_data).coco;
                end
                data1.(select_data).cocoP.annotations=table2struct(cocopT);
                data1.(select_data)=rmfield(data1.(select_data),'coco');
                cocostring=gason(data1.(select_data).cocoP);fid = fopen([data1.info.filepath_coco filesep filename_cocoN], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                coco_temp=CocoApi([data1.info.filepath_coco filesep filename_cocoN]);
                data1.(select_data).filename_coco=filename_cocoN;
            end

            cocoStructure=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
            if flag.category_update>0;cocoStructure=coco_category_update_v01(cocoStructure,data1);end
            data1.(select_data).cocoP=cocoStructure;
            
        end
    end
    if isfield(data1.(select_data),'coco')==1
        data1.(select_data)=rmfield(data1.(select_data),'coco');
    end

    data1.(select_data).atlas_allcellcore_N=atlas_allcellcore_N;
    if flag.coco_add_info==1
        coco_temp_add=data1.(select_data).cocoP;
        if exist([data1.info.filepath_coco filesep filename_cocoN],'file')
            %coco_temp_add=data1.(select_data).coco;
            addinfo.brain_area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;addinfo.resolution=data1.info.pixel_size;
            addinfo.dinfo=data1.info;addinfo.select_data=select_data;
            data1.(select_data).cocoP=coco_modified_v02(coco_temp_add,addinfo,data1.info.filepath_coco,filename_cocoN);
            clear coco_temp_add addinfo
            %
            %             coco_temp_add.info.filename_coco=filename_cocoN;
            %             coco_temp_add.info.Brain_Area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;
            %             cocostring=gason(coco_temp_add);fid = fopen([data1.info.filepath_coco filesep filename_cocoN], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
            %             clear coco_temp_add
        else
            %coco_temp_add=data1.(select_data).coco;
            addinfo.brain_area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;addinfo.resolution=data1.info.pixel_size;
            addinfo.dinfo=data1.info;addinfo.select_data=select_data;
            data1.(select_data).cocoP=coco_modified_v02(coco_temp_add,addinfo,data1.info.filepath_coco,filename_coco);
            clear coco_temp_add addinfo

            %             coco_temp_add.info.filename_coco=filename_coco;
            %             coco_temp_add.info.Brain_Area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;
            %             cocostring=gason(coco_temp_add);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
            %             clear coco_temp_add
        end
    end
end

