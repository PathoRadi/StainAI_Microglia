function [data1,foldername]=load_unet_v05(data1,flag,filepath01,size_box2,dispfig,foldername)
ts=1;
if isfield(flag,'data_path0temp');data_path0temp=strrep(data1.info.filepath_image,flag.data_path0,flag.data_path0temp);else;data_path0temp=data1.info.filepath_image;end

%%% ii=1 for train_Unet_with_groundtruth, ii>1 for results from yolo boxes
for ii=1:size(data1.info.folderTag_result.UnetOneCell,1)
    % with groundtruth, size(data1.info.folderTag_result.UnetOneCell,1)==2
    if size(data1.info.folderTag_result.UnetOneCell,1)==2
        if ii==1 % get folder name
            foldername.train_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_train.UnetOneCell(ii,:), size_box2, 'train');
            foldername.result_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_result.UnetOneCell(ii,:), size_box2, 'result');
        else
            foldername.train_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_test.yolo2unet(1,:), size_box2, 'test');
            foldername.result_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_result.UnetOneCell(ii,:), size_box2, 'result');
        end
    else
        % assign test => foldername.train_UnetOneCell
        switch flag.save_train_path_case
            case {1,2}
                foldername.train_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_test.yolo2unet(1,:), size_box2, 'test');
            case 3
                foldername.train_UnetOneCell{ii,1}=regexprep(foldername.train_UnetOneCell{ii,1},'Unet','SS3');
        end
        foldername.result_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_result.UnetOneCell(ii,:), size_box2, 'result');
    end
    
    %if exist([data1.info.filepath_image foldername.train_UnetOneCell{ii}],'dir')
        mpara.im_size=size_box2;mpara.imId_case='id0_filename_type2';
        mpara.imId1=data1.info.imId+200;
        mpara.filename_image=data1.info.filename_image;
        mpara.flag_save_train_path_case=flag.save_train_path_case; % get train file info
        mpara.flag_getmaskpath=1;
        file_info=filepathname_of_image_Vmaskrcnn([data_path0temp foldername.train_UnetOneCell{ii}],mpara);
        data1.(foldername.train_UnetOneCell{ii}).file_info=file_info;clear file_info
        data1.(foldername.train_UnetOneCell{ii}).train_imsize=size_box2;mpara.flag_getmaskpath=0;
        file_info_temp=data1.(foldername.train_UnetOneCell{ii}).file_info; % get result file info
        if isfield(file_info_temp,'file_path_mask')==1
            file_info_temp=rmfield(file_info_temp,'file_path_mask');
            file_info_temp=rmfield(file_info_temp,'file_name_mask');
        end
    %end
    
    
    filepath_load_UnetOneCell_result=[data_path0temp  foldername.result_UnetOneCell{ii} filesep];
    %% load train unet from yolo M
    
    %if exist([data1.info.filepath_image  foldername.result_UnetOneCell{ii} filesep],'dir')
        imsize0=size(data1.im0gray);
        filepath_load_UnetOneCell_train=[data1.info.filepath_image 'mat_temp' filesep foldername.train_UnetOneCell{ii}];
        %if exist([filepath_load_UnetOneCell_train '.mat'],'file');
        %   fprintf(['load: ' foldername.train_UnetOneCell{ii} '\n'])
        %     load([filepath_load_UnetOneCell_train '.mat']);
        % else
        if flag.update_yoloscore==1
            cn=findstr( foldername.result_UnetOneCell{ii},'CRBG');
            if isempty(cn)~=1
                fprintf(['load: ' foldername.train_UnetOneCell{ii} '\n'])
                %[unet_result]=load_unet_train_png(data1.(foldername.train_UnetOneCell{ii}),imsize0);
                [unet_result]=load_unet_train_png_v2(data1.(foldername.train_UnetOneCell{ii}));
            else
                %if isfield(data1,[foldername.result_yolo{ts,1} '_M'])==1 && ii==2 % get yolo score
                %[unet_result]=load_unet_train_png(data1.(foldername.train_UnetOneCell{ii}),imsize0,data1.([foldername.result_yolo{ts,1} '_M']));
                try
                    [unet_result]=load_unet_train_png_v2(data1.(foldername.train_UnetOneCell{ii}),data1.([foldername.result_yolo{ts,1} '_M']));
                catch
                    [unet_result]=load_unet_train_png_v2(data1.(foldername.train_UnetOneCell{ii}));
                end
                %else;
                %%% %[unet_result]=load_unet_train_png(data1.(foldername.train_UnetOneCell{ii}),imsize0);
                %[unet_result]=load_unet_train_png_v2(data1.(foldername.train_UnetOneCell{ii}));
                %end
            end
            save([filepath_load_UnetOneCell_train '.mat'],'unet_result','-v7.3');
            %end
        else
            if exist([filepath_load_UnetOneCell_train '.mat'],'file');
                fprintf(['load: ' foldername.train_UnetOneCell{ii} '\n'])
                load([filepath_load_UnetOneCell_train '.mat']);
            else
               % if flag.update_yoloscore==1

                    cn=findstr( foldername.result_UnetOneCell{ii},'CRBG');
                    if isempty(cn)~=1
                        fprintf(['load: ' foldername.train_UnetOneCell{ii} '\n'])
                        %[unet_result]=load_unet_train_png(data1.(foldername.train_UnetOneCell{ii}),imsize0);
                        [unet_result]=load_unet_train_png_v2(data1.(foldername.train_UnetOneCell{ii}));
                    else
                        %if isfield(data1,[foldername.result_yolo{ts,1} '_M'])==1 && ii==2 % get yolo score
                        %[unet_result]=load_unet_train_png(data1.(foldername.train_UnetOneCell{ii}),imsize0,data1.([foldername.result_yolo{ts,1} '_M']));
                        try
                            [unet_result]=load_unet_train_png_v2(data1.(foldername.train_UnetOneCell{ii}),data1.([foldername.result_yolo{ts,1} '_M']));
                        catch
                            [unet_result]=load_unet_train_png_v2(data1.(foldername.train_UnetOneCell{ii}));
                        end
                        %else;
                        %%% %[unet_result]=load_unet_train_png(data1.(foldername.train_UnetOneCell{ii}),imsize0);
                        %[unet_result]=load_unet_train_png_v2(data1.(foldername.train_UnetOneCell{ii}));
                        %end
                    end
                    save([filepath_load_UnetOneCell_train '.mat'],'unet_result','-v7.3');
               % end
            end
        end

        data1.(foldername.train_UnetOneCell{ii}).bbox0=unet_result.bboxU;
        if isfield(unet_result,'bbmaskU')==1
            data1.(foldername.train_UnetOneCell{ii}).bwmask=unet_result.bbmaskU;
            data1.(foldername.train_UnetOneCell{ii}).bbox=mask2bbox(data1.(foldername.train_UnetOneCell{ii}).bwmask);
        else % get box from yolo without ground truth mask
            if isfield(data1,[foldername.result_yolo{ts,1} '_M'])==1
                data1.(foldername.train_UnetOneCell{ii}).bbox=data1.([foldername.result_yolo{ts,1} '_M']).bbox;
            end
        end
        
        if isfield(unet_result,'score');data1.(foldername.train_UnetOneCell{ii}).score=unet_result.score;end;clear unet_result
        
        if flag.save_coco==1
            filename_coco=[data1.info.filename_image(1:end-4) '__' foldername.train_UnetOneCell{ii} '__' data1.info.result_ver '.json'];
            select_data=[foldername.train_UnetOneCell{ii}];
            
            if flag.update_yoloscore==1
                fprintf(['save coco: ' select_data '\n']);
                data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'Y2Unet');
                copt1.get_score=0;copt1.segmentation=1;copt1.case_coco='Y2Unet';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                try
                    data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);
                catch
                    xxx=1
                end
                cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
            else
                if ~exist([data1.info.filepath_coco filesep filename_coco],'file');
                    fprintf(['save coco: ' select_data '\n']);
                    data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                    %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                    %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'Y2Unet');
                    copt1.get_score=0;
                    if isfield(data1.(select_data),'bwmask');copt1.segmentation=1;else;copt1.segmentation=0;end

                    copt1.case_coco='Y2Unet';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                    data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);

                    cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                else
                    try
                        coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                    catch % if error while read by cocoapi
                        data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                        %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                        %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'Y2Unet');
                        copt1.get_score=0;copt1.segmentation=1;copt1.case_coco='Y2Unet';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                        data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);

                        cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                        coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                    end
                    cocostruct=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
                    if flag.category_update>0;cocostruct=coco_category_update_v01(cocostruct,data1);end
                    data1.(select_data).coco=cocostruct;clear coco_temp cocostruct
                end

            end
            
            data1.(select_data).filename_coco=filename_coco;
            
            if flag.coco_add_info==1
                coco_temp_add=data1.(select_data).coco;
                addinfo.brain_area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;addinfo.resolution=data1.info.pixel_size;
                addinfo.dinfo=data1.info;addinfo.select_data=select_data;
                data1.(select_data).coco=coco_modified_v02(coco_temp_add,addinfo,data1.info.filepath_coco,filename_coco);
                clear coco_temp_add addinfo
%                 coco_temp_add=data1.(select_data).coco;
%                 coco_temp_add.info.filename_coco=filename_coco;
%                 coco_temp_add.info.Brain_Area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;
%                 cocostring=gason(coco_temp_add);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
%                 clear coco_temp_add
            end
            
        end
    %end
    
    %% load unet result
    %if exist(filepath_load_UnetOneCell_result,'dir')
        fprintf(['load: ' foldername.result_UnetOneCell{ii} '\n'])

        filepath_load_UnetOneCell_result_mat=[data1.info.filepath_image  'mat_temp' filesep foldername.result_UnetOneCell{ii} ];
        if exist([filepath_load_UnetOneCell_result_mat '.mat'],'file')
            load([filepath_load_UnetOneCell_result_mat '.mat']);
            data1.(foldername.result_UnetOneCell{ii}).bbox0=unet_result.bboxU;
            data1.(foldername.result_UnetOneCell{ii}).bwmask=unet_result.bbmaskU;
            data1.(foldername.result_UnetOneCell{ii}).bbox=mask2bbox(data1.(foldername.result_UnetOneCell{ii}).bwmask);
            if isfield(data1.(foldername.train_UnetOneCell{ii}),'score')==1;
                data1.(foldername.result_UnetOneCell{ii}).score=data1.(foldername.train_UnetOneCell{ii}).score;
            end
            clear unet_result
        else

            file_path_mask_temp=repmat({filepath_load_UnetOneCell_result},length(file_info_temp),1);
            file_name_mask_temp0=dir(filepath_load_UnetOneCell_result);
            file_name_mask_temp={file_name_mask_temp0(3:end).name}';
            [file_info_temp.file_path_mask]=file_path_mask_temp{:};
            [file_info_temp.file_name_mask]=file_name_mask_temp{:};
            data1.(foldername.result_UnetOneCell{ii}).file_info=file_info_temp;
            data1.(foldername.result_UnetOneCell{ii}).train_imsize=size_box2;

            filepath_load_UnetOneCell_result_mat=[data1.info.filepath_image  'mat_temp' filesep foldername.result_UnetOneCell{ii}];
            filepath_load_UnetOneCell_result=[data_path0temp  foldername.result_UnetOneCell{ii}];

            if flag.update_yoloscore==1
                train_num=size(data1.(foldername.train_UnetOneCell{ii}).bbox0,1);
                if isfield(data1,[foldername.result_yolo{ts,1} '_M'])==1 && ii==2
                    %               unet_result=load_unet_png_v2(filepath_load_UnetOneCell_result,train_num,data1.([foldername.result_yolo{ts,1} '_M']),imsize0);%%%
                    % load unet results with score from yolo
                    unet_result=load_unet_result_png_v3(filepath_load_UnetOneCell_result,train_num,size_box2,data1.([foldername.result_yolo{ts,1} '_M']));%%%
                else
                    unet_result=load_unet_result_png_v3(filepath_load_UnetOneCell_result,train_num,size_box2);
                    %unet_result=load_unet_png_v2(filepath_load_UnetOneCell_result,train_num);%%%
                end
                save([filepath_load_UnetOneCell_result_mat '.mat'],'unet_result','-v7.3');
                data1.(foldername.result_UnetOneCell{ii}).bbox0=unet_result.bboxU;
                data1.(foldername.result_UnetOneCell{ii}).bwmask=unet_result.bbmaskU;
                data1.(foldername.result_UnetOneCell{ii}).bbox=mask2bbox(data1.(foldername.result_UnetOneCell{ii}).bwmask);
                if isfield(data1.(foldername.train_UnetOneCell{ii}),'score')==1;
                    data1.(foldername.result_UnetOneCell{ii}).score=data1.(foldername.train_UnetOneCell{ii}).score;
                end
                clear unet_result
            else

                if exist([filepath_load_UnetOneCell_result_mat '.mat'],'file');
                    load([filepath_load_UnetOneCell_result_mat '.mat']);
                else;
                    train_num=size(data1.(foldername.train_UnetOneCell{ii}).bbox0,1);
                    if isfield(data1,[foldername.result_yolo{ts,1} '_M'])==1 && ii==2
                        %               unet_result=load_unet_png_v2(filepath_load_UnetOneCell_result,train_num,data1.([foldername.result_yolo{ts,1} '_M']),imsize0);%%%
                        % load unet results with score from yolo
                        unet_result=load_unet_result_png_v3(filepath_load_UnetOneCell_result,train_num,size_box2,data1.([foldername.result_yolo{ts,1} '_M']));%%%
                    else
                        unet_result=load_unet_result_png_v3(filepath_load_UnetOneCell_result,train_num,size_box2);
                        %unet_result=load_unet_png_v2(filepath_load_UnetOneCell_result,train_num);%%%
                    end
                    save([filepath_load_UnetOneCell_result_mat '.mat'],'unet_result','-v7.3');
                end
                data1.(foldername.result_UnetOneCell{ii}).bbox0=unet_result.bboxU;
                data1.(foldername.result_UnetOneCell{ii}).bwmask=unet_result.bbmaskU;
                data1.(foldername.result_UnetOneCell{ii}).bbox=mask2bbox(data1.(foldername.result_UnetOneCell{ii}).bwmask);
                if isfield(data1.(foldername.train_UnetOneCell{ii}),'score')==1;
                    data1.(foldername.result_UnetOneCell{ii}).score=data1.(foldername.train_UnetOneCell{ii}).score;
                end
                clear unet_result
            end
            if flag.save_coco==1;
                filename_coco=[data1.info.filename_image(1:end-4) '__' foldername.result_UnetOneCell{ii} '__' data1.info.result_ver '.json'];
                select_data=[foldername.result_UnetOneCell{ii}];
                if flag.update_yoloscore==1
                    fprintf(['save coco - ' select_data '\n']);
                    data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                    %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                    %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'Y2Unet');
                    copt1.get_score=1;copt1.segmentation=1;copt1.case_coco='Y2Unet';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                    data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);
                    cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);

                else

                    if ~exist([data1.info.filepath_coco filesep filename_coco],'file');
                        fprintf(['save coco - ' select_data '\n']);
                        data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                        %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                        %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'Y2Unet');
                        copt1.get_score=1;copt1.segmentation=1;copt1.case_coco='Y2Unet';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                        data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);
                        cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);

                    else;
                        try
                            coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                        catch
                            data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                            %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                            %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'Y2Unet');
                            copt1.get_score=1;copt1.segmentation=1;copt1.case_coco='Y2Unet';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                            data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);

                            cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                            coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);

                        end
                        cocostruct=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
                        if flag.category_update>0;cocostruct=coco_category_update_v01(cocostruct,data1);end
                        data1.(select_data).coco=cocostruct;clear coco_temp cocostruct
                    end

                end
                data1.(select_data).coco.categories=data1.categories;
                data1.(select_data).filename_coco=filename_coco;

                if flag.coco_add_info==1
                    coco_temp_add=data1.(select_data).coco;
                    addinfo.brain_area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;addinfo.resolution=data1.info.pixel_size;
                    addinfo.dinfo=data1.info;addinfo.select_data=select_data;
                    data1.(select_data).coco=coco_modified_v02(coco_temp_add,addinfo,data1.info.filepath_coco,filename_coco);
                    clear coco_temp_add addinfo

                    %                 coco_temp_add=data1.(select_data).coco;
                    %                 coco_temp_add.info.filename_coco=filename_coco;
                    %                 coco_temp_add.info.Brain_Area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;
                    %                 cocostring=gason(coco_temp_add);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                    %                 clear coco_temp_add
                end

            end
        end
        %% merge unet result
        merge_sort_mathod={'L','S','O'};
        mm_para.overlap_threshold_max=0.7;mm_para.cell_size_max_threshold=12000;
        mm_para.cell_size_chk_threshold=4000;
        mm_para.cell_fragment_size_rm_threshold=[-15, -8];
        mm_para.num_overlap_threshold=15;
        mm_para.num_exist_threshold=4000;
        mm_para.num_bw2d_threshold=500;
        mm_para.cell_size_min_threshold=500;
        mm_para.cell_dist_min_threshold=7;
        for ms=1%:3
            %47239 
            mm_para.sort=merge_sort_mathod{ms}; %'S'; 'O';
            mm_para.save_temp_file=[filepath_load_UnetOneCell_result_mat '__atlas_allcell_v6' mm_para.sort '.mat'];
            save_temp_score=[filepath_load_UnetOneCell_result_mat '__atlas_allcell_v6' mm_para.sort '_scoreY2U__' data1.info.result_ver '.mat'];
            foldername.result_UnetOneCell_M{ii,ms}=[foldername.result_UnetOneCell{ii} '_M' mm_para.sort];
            [data1.(foldername.result_UnetOneCell_M{ii,ms}).atlas_allcell_N,~,~,...
                data1.(foldername.result_UnetOneCell_M{ii,ms}).id_merge,...                                            % yolo5 index order
                data1.(foldername.result_UnetOneCell_M{ii,ms}).area_before_merge, eqid{ii}]=maskinbox2Image_v6(data1.im0gray,data1.(foldername.result_UnetOneCell{ii}).bbox0,data1.(foldername.result_UnetOneCell{ii}).bwmask,mm_para,1);
            % maskinbox2Image_v4,maskinbox2Image_v3 : old version maskinbox2Image_v6
            % atlas_allcell_NU=maskinbox2Image_v2(data1.im0gray,data1.(foldername.result_UnetOneCell{ii}).bbox0,data1.(foldername.result_UnetOneCell{ii}).bwmask,mm_para,1);
            if isfield(data1.([foldername.result_UnetOneCell{ii}]),'score') % get score from yolo
                % data1.(foldername.result_UnetOneCell_M{ii,ms}).score=zeros(length(data1.([foldername.result_UnetOneCell{ii}]).score),1);
                if flag.update_yoloscore==1
                    for ss=1:length(data1.(foldername.result_UnetOneCell_M{ii,ms}).id_merge)
                        if isempty(data1.(foldername.result_UnetOneCell_M{ii,ms}).id_merge{ss})==0
                            area_b=data1.(foldername.result_UnetOneCell_M{ii,ms}).area_before_merge{ss};
                            score_b=data1.([foldername.result_UnetOneCell{ii}]).score(data1.(foldername.result_UnetOneCell_M{ii,ms}).id_merge{ss});
                            if size(score_b,1)==size(area_b,1) && size(score_b,2)==size(area_b,2)
                                data1.(foldername.result_UnetOneCell_M{ii,ms}).score(ss,1)=sum(area_b.*score_b./sum(area_b));
                            else
                                data1.(foldername.result_UnetOneCell_M{ii,ms}).score(ss,1)=sum(area_b.*score_b'./sum(area_b));
                            end
                            %  ddd=cellfun(@length, data1.Yolo512_UnetCRBG_256x256__result__UNET_M.id_merge);
                            %  snum=(find(ddd~=0));
                            %                                   %5936
                            %                                   %  [5921 5940] [5922 5940] 27285  [39330 39335]
                            %  [v,ia]=setdiff(qnum,snum)
                            %  qnum=unique(data1.Yolo512_UnetCRBG_256x256__result__UNET_M.atlas_allcell_N);
                            % % find(data1.Yolo512_UnetCRBG_256x256__result__UNET_M.atlas_allcell_N==5922)
                        end
                    end
                    scoreY2U=data1.(foldername.result_UnetOneCell_M{ii,ms}).score;
                    save(save_temp_score,'scoreY2U');
                else
                    if exist(save_temp_score,'file')==0
                        for ss=1:length(data1.(foldername.result_UnetOneCell_M{ii,ms}).id_merge)
                            if isempty(data1.(foldername.result_UnetOneCell_M{ii,ms}).id_merge{ss})==0
                                area_b=data1.(foldername.result_UnetOneCell_M{ii,ms}).area_before_merge{ss};
                                score_b=data1.([foldername.result_UnetOneCell{ii}]).score(data1.(foldername.result_UnetOneCell_M{ii,ms}).id_merge{ss});
                                if size(score_b,1)==size(area_b,1) && size(score_b,2)==size(area_b,2)
                                    data1.(foldername.result_UnetOneCell_M{ii,ms}).score(ss,1)=sum(area_b.*score_b./sum(area_b));
                                else
                                    data1.(foldername.result_UnetOneCell_M{ii,ms}).score(ss,1)=sum(area_b.*score_b'./sum(area_b));
                                end


                                %  ddd=cellfun(@length, data1.Yolo512_UnetCRBG_256x256__result__UNET_M.id_merge);
                                %  snum=(find(ddd~=0));
                                %                                   %5936
                                %                                   %  [5921 5940] [5922 5940] 27285  [39330 39335]
                                %  [v,ia]=setdiff(qnum,snum)
                                %  qnum=unique(data1.Yolo512_UnetCRBG_256x256__result__UNET_M.atlas_allcell_N);
                                % % find(data1.Yolo512_UnetCRBG_256x256__result__UNET_M.atlas_allcell_N==5922)
                            end
                        end
                        scoreY2U=data1.(foldername.result_UnetOneCell_M{ii,ms}).score;
                        save(save_temp_score,'scoreY2U');
                    else
                        load(save_temp_score);
                        data1.(foldername.result_UnetOneCell_M{ii,ms}).score=scoreY2U;
                    end
                end
            end
            if flag.save_coco==1;
                filename_coco=[data1.info.filename_image(1:end-4) '__' foldername.result_UnetOneCell_M{ii,ms} '__' data1.info.result_ver '.json'];
                select_data=foldername.result_UnetOneCell_M{ii,ms};
                fprintf(['load or save coco:' select_data '\n']);
                if flag.update_yoloscore==1
                    data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                    %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                    % data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'LargeIm',1);
                    copt1.get_score=1;copt1.segmentation=1;copt1.case_coco='LargeIm';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                    data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);


                    cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                else
                    if ~exist([data1.info.filepath_coco filesep filename_coco],'file');
                        data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                        %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                        % data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'LargeIm',1);
                        copt1.get_score=1;copt1.segmentation=1;copt1.case_coco='LargeIm';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                        data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);


                        cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                    else
                        try
                            coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                        catch
                            data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                            %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                            %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'LargeIm',1);
                            copt1.get_score=1;copt1.segmentation=1;copt1.case_coco='LargeIm';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                            data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);


                            cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                            coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                        end
                        cocostruct=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
                        if flag.category_update>0;cocostruct=coco_category_update_v01(cocostruct,data1);end
                        data1.(select_data).coco=cocostruct;clear coco_temp cocostruct
                    end

                end

                
                data1.(select_data).filename_coco=filename_coco;
                
                if flag.coco_add_info==1
                    coco_temp_add=data1.(select_data).coco;
                    addinfo.brain_area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;addinfo.resolution=data1.info.pixel_size;
                    addinfo.dinfo=data1.info;addinfo.select_data=select_data;
                    data1.(select_data).coco=coco_modified_v02(coco_temp_add,addinfo,data1.info.filepath_coco,filename_coco);
                    clear coco_temp_add addinfo

%                     coco_temp_add=data1.(select_data).coco;
%                     coco_temp_add.info.filename_coco=filename_coco;
%                     coco_temp_add.info.Brain_Area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;
%                     cocostring=gason(coco_temp_add);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
%                     clear coco_temp_add
                end
            
                
%                 if isfield(data1.info,'filename_c50')
%                     if exist([data1.info.filepath_coco filesep data1.info.filename_c50{2}],'file')~=0
%                         coco_temp=CocoApi([data1.info.filepath_coco filesep data1.info.filename_c50{1}]);
%                         coco_temp=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
%                         data1.(select_data).cocoP_C50=coco_temp.data;clear coco_temp
%                     end
%                 end
            end
        end
    %end
end;



%% display Unet_256x256 result
% display 256x256 yolo-unet result with yolo box
%{
            ii=2
            clear ind bbox_yolos scoreYoloM bboxD
            ds0=randperm(length(data1.(foldername.train_UnetOneCell{ii}).file_info),28);
            if isfield(data1.(foldername.result_UnetOneCell{ii}),'score')==1
                ind=find(data1.(foldername.result_UnetOneCell{ii}).score~=0);
                bboxD=data1.CRBG_wEdge_512x512__result__YOLO_conf_50_100_M.bbox;
                scoreYoloM=data1.CRBG_wEdge_512x512__result__YOLO_conf_50_100_M.score;
                bbox_yolos=[size_box2(1)/2-bboxD(:,3)/2 size_box2(2)/2-bboxD(:,4)/2 bboxD(:,3) bboxD(:,4)];
            else
                bboxD=data1.(foldername.result_UnetOneCell{ii}).bbox;
                
            end
            %ds0=randperm(length(ind),28);%bboxYoloSort(1:28,5);% [1:28];
            
            clear imF4 imF3 fnum
            for pp=1:size(bboxD,1);sn1=findstr(data1.(foldername.train_UnetOneCell{ii}).file_info(pp).file_name,'_n');sn2=findstr(data1.(foldername.train_UnetOneCell{ii}).file_info(pp).file_name,'_y');
                fnum(pp)=str2num(data1.(foldername.train_UnetOneCell{ii}).file_info(pp).file_name(sn1(1)+2:sn2(1)-1));end
            for nn=1:15
                nn=1
                clear label_str
                pp=ds0(nn);
                if isfield(data1.(foldername.result_UnetOneCell{ii}),'score')==1
                    bbox_yolosP=bbox_yolos(pp,:);
                    bboxDp=bboxD(pp,:); xc=fix(bboxDp(1)+bboxDp(3)/2); yc=fix(bboxDp(2)+bboxDp(4)/2); ims0=squeeze(data1.im0gray(yc-128:yc+127,xc-128:xc+127));%%figure(1);imshow(ims0);
                end
                bw0=squeeze(data1.(foldername.result_UnetOneCell_M{ii,ms}).atlas_allcell_N(yc-128:yc+127,xc-128:xc+127));%%figure(1);imshow(ims0);
             %  figure(1);subplot(1,3,1);imagesc_bw(squeeze(ims0(:,:,1)),[0 255],'gray',255,{bw0},{'b'},-1,-1);axis off;hold on
            %    subplot(1,3,2);imagesc(bw0);axis off;axis image
                fn=find(fnum==pp);
                imF5(nn,:,:,:)=imread([data1.(foldername.train_UnetOneCell{ii}).file_info(fn).file_path data1.(foldername.train_UnetOneCell{ii}).file_info(fn).file_name]);
                %%figure(2);imshow(squeeze(imF5(nn,:,:,:)))
                ims1=imread([data1.(foldername.train_UnetOneCell{ii}).file_info(fn).file_path data1.(foldername.train_UnetOneCell{ii}).file_info(fn).file_name]);
                if exist([data1.(foldername.train_UnetOneCell{ii}).file_info(fn).file_path_mask data1.(foldername.train_UnetOneCell{ii}).file_info(fn).file_name_mask],'file')
                    if isempty(data1.(foldername.train_UnetOneCell{ii}).file_info(fn).file_name_mask)~=1
                        bws1=imread([data1.(foldername.train_UnetOneCell{ii}).file_info(fn).file_path_mask data1.(foldername.train_UnetOneCell{ii}).file_info(fn).file_name_mask]);
                    else
                        bws1=zeros(size(ims1));
                    end
                else
                    bws1=zero(size(ims1));
                end
                bws1(bws1~=0)=1;
                %%figure(1);subplot(1,3,3);imagesc_bw(squeeze(ims1(:,:,1)),[0 255],'gray',255,{bws1},{'b'},-1,-1);axis off
                
                ims1=imread([data1.(foldername.result_UnetOneCell{ii}).file_info(fn).file_path data1.(foldername.result_UnetOneCell{ii}).file_info(fn).file_name]);
                bws2=imread([data1.(foldername.result_UnetOneCell{ii}).file_info(fn).file_path_mask data1.(foldername.result_UnetOneCell{ii}).file_info(fn).file_name_mask]);
                bws2(bws2~=0)=1;%%figure(3);imagesc_bw(squeeze(ims1(:,:,1)),[0 255],'gray',255,{bws2},{'b'},-1,-1);axis off
                imF30 = labeloverlay(ims1,bws2,'Colormap',[1 0.5 0],'Transparency',0.7);
                if isfield(data1.(foldername.result_UnetOneCell{ii}),'score')==1
                    label_str{1} = ['score: ' num2str(100*scoreYoloM(pp),'%0.1f') '%'];
                    imF30 = insertObjectAnnotation(imF30, 'rectangle', bbox_yolosP, label_str,'color',{'yellow'},'LineWidth',3);
                    [~,imF3(nn,:,:,:)]=imshow_bw(imF30,{bws1},{'b'},1,-1);
                    imF4(nn,:,:,:) = insertObjectAnnotation(ims1, 'rectangle', bbox_yolosP, label_str,'color',{'yellow'},'LineWidth',3);
                else
                    [~,imF3(nn,:,:,:)]=imshow_bw(imF30,{bws1},{'b'},1,-1);
                end
                %[~,imF4(nn,:,:,:)]=imshow_bw(imF40,{bws1},{'b'},1,-1);
                
            end
            %figure(2003);imshow(dmib2rgb(imF3,3,5,5,[255 255 255]));set(gcf,'Color','w')
            %%figure(2004);imshow(dmib2rgb(imF4,3,5,5,[255 255 255]));set(gcf,'Color','w')

            % imwrite(imF1,[data1.info.filepath_image filesep data1.info.filename_image(1:end-4) '_unetF.png']);
%}


%% display whole brain unet result
%%{

if dispfig==2
    cmap2=rand(max(data1.(foldername.result_UnetOneCell_M{ii,ms}).atlas_allcell_N(:)),3);
    %cmap=lines(max(data1.Yolo512_UnetCRBG_256x256__result__UNET.atlas_allcell_N(:)));
    if isfield(data1,'masks_CRBG')==1
        cmap1=rand(max(data1.masks_CRBG.atlas_allcell_N(:)),3);
        atlas_allcell_NL=getAtlasEdge(data1.masks_CRBG.atlas_allcell_N,1);
        imF1 = labeloverlay(data1.im0gray,data1.(foldername.result_UnetOneCell_M{ii,ms}).atlas_allcell_N,'Colormap',cmap2,'Transparency',0.65);
        imF1 = labeloverlay(imF1,atlas_allcell_NL,'Colormap',cmap1,'Transparency',0);
        figure(29000);imshow(imF1);set(gcf,'color','w');
    else
        atlas_allcell_NL=getAtlasEdge(data1.(foldername.result_UnetOneCell_M{ii,ms}).atlas_allcell_N,1);
        imF1 = labeloverlay(data1.im0gray,atlas_allcell_NL,'Colormap',cmap2,'Transparency',0);
    end
    figure(29001);imshow(imF1);set(gcf,'color','w');
    
    %if ~exist([data1.info.filepath_image filesep 'results' filesep 'masks'  data1.info.filename_image(1:end-4) '_unetF.png'],'file')
    %    imwrite(imF1,[data1.info.filepath_image filesep 'results' filesep 'masks'  data1.info.filename_image(1:end-4) '_unetF.png']);
    %end

    if ~exist([data1.info.filepath_image filesep 'results' filesep 'masks'  data1.info.filename_image(1:end-4) '_unetF_zp.jpg'],'file')
        imwrite(imF1,[data1.info.filepath_image filesep 'results' filesep 'masks'  data1.info.filename_image(1:end-4) '_unetF_zp.jpg']);
       
        imF2=imF1(ceil(flag.size_zpe(1)/2)+1:ceil(flag.size_zpe(1)/2)+size(imF1,1)-flag.size_zpe(1),ceil(flag.size_zpe(2)/2)+1:ceil(flag.size_zpe(2)/2)+size(imF1,2)-flag.size_zpe(2),:);

        %imF2=imF1(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+data1.info.imOrig_size(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+data1.info.imOrig_size(2),:);
        imwrite(imF2,[data1.info.filepath_image filesep 'results' filesep 'masks'  data1.info.filename_image(1:end-4) '_unetF.jpg']);
    end
    % for check yolo score
%         bboxYolo=data1.([foldername.result_yolo{ts,1} '_M']).bbox;
%         bboxYolo(:,5)=1:size(bboxYolo,1);
%         bboxYoloSort=sortrows(bboxYolo,1);
%         labels=mat2cell(data1.([foldername.result_yolo{ts,1} '_M']).score(bboxYoloSort(1:300,5)),ones(300,1),1);
%         labelsC=cellfun(@num2str,labels,'UniformOutput',false);
%         imF1 = labeloverlay(data1.im0gray,data1.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N,'Colormap',cmap2,'Transparency',0.65);
%         imF1 = labeloverlay(imF1,atlas_allcell_NL,'Colormap',cmap1,'Transparency',0);
%         
%         imF2 = insertObjectAnnotation(imF1, 'rectangle', bboxYoloSort(1:300,1:4), labelsC,'color',{'yellow'},'LineWidth',1);
%         figure(29001);imshow(imF2);set(gcf,'color','w');
   % 

%% display 512x512 yolo-Unet result
%{
%% paper figure 1C (v)
cmap2=rand(max(data1.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N(:)),3);
cmap2(14196,:)=[1 0 0];
atlas_allcell_NL=getAtlasEdge(data1.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N,1);
imF0 = labeloverlay(data1.im0gray,atlas_allcell_NL,'Colormap',cmap2,'Transparency',0);
train_imsize=[512 512];
edgelinewidth_sh2=20;drc=ceil(imsize0./train_imsize);
select_num1=800;
bw_edge=false(size(data1.im0gray)); bw_edge_4d=imsplit4d(bw_edge,[train_imsize]);bw_edge_4d2=bw_edge_4d;
bw_edge_4d(:,1:edgelinewidth_sh2,:)=1;   bw_edge_4d(:,train_imsize(1)-edgelinewidth_sh2+1:train_imsize(1),:)=1;
bw_edge_4d(:,:,1:edgelinewidth_sh2)=1;   bw_edge_4d(:,:,train_imsize(2)-edgelinewidth_sh2+1:train_imsize(2))=1;
bw_edge_4d(select_num1,1:edgelinewidth_sh2,:)=0;   bw_edge_4d(select_num1,train_imsize(1)-edgelinewidth_sh2+1:train_imsize(1),:)=0;
bw_edge_4d(select_num1,:,1:edgelinewidth_sh2)=0;   bw_edge_4d(select_num1,:,train_imsize(2)-edgelinewidth_sh2+1:train_imsize(2))=0;
bw_edge=dmib2(bw_edge_4d,drc(1),drc(2)); bw_edge(1:edgelinewidth_sh2,:)=0;bw_edge(end-edgelinewidth_sh2+1:end,:)=0;bw_edge(:,1:edgelinewidth_sh2)=0;bw_edge(:,end-edgelinewidth_sh2+1:end)=0;
bw_edge_4d2(select_num1,1:edgelinewidth_sh2,:)=1;   bw_edge_4d2(select_num1,train_imsize(1)-edgelinewidth_sh2+1:train_imsize(1),:)=1;
bw_edge_4d2(select_num1,:,1:edgelinewidth_sh2)=1;   bw_edge_4d2(select_num1,:,train_imsize(2)-edgelinewidth_sh2+1:train_imsize(2))=1;
bw_edge2=dmib2(bw_edge_4d2,drc(1),drc(2)); bw_edge_4d2(1:edgelinewidth_sh2,:)=0;bw_edge_4d2(end-edgelinewidth_sh2+1:end,:)=0;bw_edge_4d2(:,1:edgelinewidth_sh2)=0;bw_edge_4d2(:,end-edgelinewidth_sh2+1:end)=0;
imF3 = labeloverlay(imF0,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 0 0],'Transparency',0.5);
imF3 = labeloverlay(imF3,bw_edge2(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[255 233 27]/255,'Transparency',0.3);
figure(28000);imshow(imF3(6900:6900+1200,21700:21700+2000,:));set(gcf,'color','w');

% Fig1C(iv)
imF04d=imsplit4d(imF0,[train_imsize,3]);
imF0s=squeeze(imF04d(select_num1,:,:,:));
sh=1;ds=select_num1;
bbox_yoloim=data1.([foldername.result_yolo{sh}]).bbox_ims{ds};
labels=mat2cell(round(100*data1.([foldername.result_yolo{sh}]).score_ims{ds})/100,ones(length(data1.([foldername.result_yolo{sh}]).score_ims{ds}),1),1);
labelsC=cellfun(@num2str,labels,'UniformOutput',false);
labelsE=repmat({''},length(labelsC),1);
imF0s2 = insertObjectAnnotation(imF0s, 'rectangle', bbox_yoloim, labelsE,'color',{'w'},'LineWidth',5,'TextColor','w','TextBoxOpacity',0,'FontSize',16);
figure(29001);imshow(imF0s2);set(gcf,'color','w');axis on;set(gca,'fontsize',20)   

% Fig 1C(iv)
imp=data1.im0gray;imsp4d=imsplit4d(imp,[train_imsize]);
imd1=squeeze(imsp4d(select_num1,:,:));
bbox_yoloim2=bbox_yoloim([1:45 47:end],:);labelsC2=labelsC([1:45 47:end]);
imF0s3 = insertObjectAnnotation(imd1, 'rectangle', bbox_yoloim2, labelsC2,'color',{'y'},'LineWidth',5,'TextColor','y','TextBoxOpacity',0,'FontSize',16);
bbox_yoloim1=bbox_yoloim(46,:);labelsC1=labelsC(46);
imF0s3 = insertObjectAnnotation(imF0s3, 'rectangle', bbox_yoloim1, labelsC1,'color',{'r'},'LineWidth',5,'TextColor','r','TextBoxOpacity',0,'FontSize',16);
figure(29002);imshow(imF0s3);set(gcf,'color','w');axis on;set(gca,'fontsize',20)   

% Fig 1C (vii)
imd1u = insertObjectAnnotation(imd1, 'rectangle', bbox_yoloim1, {''},'color',{'r'},'LineWidth',5,'TextColor','r','TextBoxOpacity',0,'FontSize',16);
imU1=imd1u(fix(bbox_yoloim1(2)+bbox_yoloim1(4)/2)-127:fix(bbox_yoloim1(2)+bbox_yoloim1(4)/2)+128,...
     fix(bbox_yoloim1(1)+bbox_yoloim1(3)/2)-127:fix(bbox_yoloim1(1)+bbox_yoloim1(3)/2)+128,:);
figure(29003);imshow(imU1);set(gcf,'color','w');axis on;set(gca,'fontsize',14)   

% Fig1C (iii)
atp4d=imsplit4d(data1.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N,[train_imsize]);
atd1=squeeze(atp4d(select_num1,:,:));

atd1(atd1~=14196)=0;atd1(atd1==14196)=255;
bw=atd1(fix(bbox_yoloim1(2)+bbox_yoloim1(4)/2)-127:fix(bbox_yoloim1(2)+bbox_yoloim1(4)/2)+128,...
     fix(bbox_yoloim1(1)+bbox_yoloim1(3)/2)-127:fix(bbox_yoloim1(1)+bbox_yoloim1(3)/2)+128,:);
figure(29004);imshow(uint8(bw));axis image;set(gcf,'color','w');axis on;set(gca,'fontsize',14)   


train_imsize=data1.([foldername.result_yolo{ts,1}]).train_imsize;
path_temp='I:\HU\DLdata_v2_ppt\Shoykhet\project1\IHC\CR1\CR1 slide 10\results\image_512x512\';
for sh=1:2
    if sh==1
        ds0=[1254 1255 1256 1308 1309 1310 1362 1363 1364];
    else
        ds0=[1255 1256 1257 1309 1310 1311 1363 1364 1365];
    end

    if sh==1;pixel_shift=[0 0];else;pixel_shift=[fix(train_imsize(1)/2) fix(train_imsize(2)/2)];end
    imp=data1.im0gray; imp=circshift(imp,pixel_shift(sh),1);imp=circshift(imp,pixel_shift(sh),2);
    atp=data1.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N;atp=circshift(atp,pixel_shift(sh),1);atp=circshift(atp,pixel_shift(sh),2);
    imsp4d=imsplit4d(imp,[train_imsize]);
    unetsp4d=imsplit4d(atp,[train_imsize]);
    if sh==1
        cmap1=rand(max(atp(:)),3);
    end

    for dn=1:length(ds0)
        dn=1
        ds=ds0(dn);
        imd1=squeeze(imsp4d(ds,:,:));
        atud1=squeeze(unetsp4d(ds,:,:));atud1L=getAtlasEdge(atud1,1);
        
        imF1 = labeloverlay(imd1,atud1L,'Colormap',cmap1,'Transparency',0);

        bbox_yoloim=data1.([foldername.result_yolo{sh}]).bbox_ims{ds};
        labels=mat2cell(round(100*data1.([foldername.result_yolo{sh}]).score_ims{ds})/100,ones(length(data1.([foldername.result_yolo{sh}]).score_ims{ds}),1),1);
        labelsC=cellfun(@num2str,labels,'UniformOutput',false);
        labelsE=repmat({''},length(labelsC),1);
        imF2 = insertObjectAnnotation(imF1, 'rectangle', bbox_yoloim, labelsE,'color',{'w'},'LineWidth',2,'TextColor','w','TextBoxOpacity',0,'FontSize',16);
        if sh==1
            name_temp=[data1.info.filename_image(1:end-4) '_512x512_n' num2str(ds) '_UnetYolo.png'];
        else
            name_temp=[data1.info.filename_image(1:end-4) '_512x512shift_n' num2str(ds) '_UnetYolo.png'];
        end
        %imwrite(imF2,[path_temp name_temp]);

        figure(211);imshow(imF2)
        imF3 = insertObjectAnnotation(imd1, 'rectangle', bbox_yoloim, labelsC,'color',{'g'},'LineWidth',2,'TextColor','g','TextBoxOpacity',0,'FontSize',16);

        if sh==1
            name_temp2=[data1.info.filename_image(1:end-4) '_512x512_n' num2str(ds) '_Yolo.png'];
        else
            name_temp2=[data1.info.filename_image(1:end-4) '_512x512shift_n' num2str(ds) '_Yolo.png'];
        end
        %imwrite(imF3,[path_temp name_temp2]);
        figure(212);imshow(imF3)
    end
end

%}






end


