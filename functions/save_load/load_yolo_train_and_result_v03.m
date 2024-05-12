function [data1,foldername]=load_yolo_train_and_result_v03(data1,flag,setp,train_imsize,filepath01,dispfig)

setp.edgelinewidth=flag.edgelinewidth;
setp.edgelinewidth_sh2=flag.edgelinewidth_sh2;
mpara.filename_image=data1.info.filename_image;
if flag.load_yolo==1
    for ts=1
        if size(data1.im0gray,1)<=512 && size(data1.im0gray,2)<=512
            shn=1;
        else
            %shn=1:2;
            shn=1:size(data1.info.folderTag_result.yolo5,1)
        end
                
        for sh=shn
            sh
            if mod(sh,2)==1
                pixel_shift=[0 0];
            else
                pixel_shift=[fix(train_imsize{ts}(1)/2) fix(train_imsize{ts}(2)/2)];
            end
            %if sh==1;pixel_shift=[0 0];else;pixel_shift=[fix(train_imsize{ts}(1)/2) fix(train_imsize{ts}(2)/2)];end

            %% get yolo train/test image info to coco
            imsize0=size(data1.im0gray);size_im4d=[prod(ceil(imsize0./train_imsize{ts})) train_imsize{ts} 3];
            mpara.im_size=train_imsize{ts};mpara.imId_case='id0_filename_type1';
            mpara.imId1=(data1.info.imId+100+(sh+(ts-1)*2)*10);mpara.flag_getmaskpath=1;
            foldername.train_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_train.maskrcnn(sh), train_imsize{ts}, 'train');
%             if exist([data1.info.filepath_image foldername.train_yolo{ts, sh}],'dir')==0
%                 foldername.train_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_train.maskrcnn(sh), train_imsize{ts}, 'test');
%             end
            if exist([data1.info.filepath_image foldername.train_yolo{ts, sh}],'dir')~=0
                data1.(foldername.train_yolo{ts, sh}).train_imsize=train_imsize{ts};
                mpara.flag_save_train_path_case=flag.save_train_path_case;
                file_info=filepathname_of_image_Vmaskrcnn([data1.info.filepath_image foldername.train_yolo{ts, sh}],mpara);
                data1.(foldername.train_yolo{ts, sh}).file_info=file_info;%clear file_info
                data1.(foldername.train_yolo{ts, sh}).bbox_ims=cell(prod(ceil(imsize0./train_imsize{ts})),1);
                file_name_temp={data1.(foldername.train_yolo{ts, sh}).file_info.file_name}';
                select_data=foldername.train_yolo{ts, sh};fprintf(['load ' select_data '\n']);
                
                %switch flag.operate_mode
                %    case 'processing'

                filename_yoloR0=[data1.info.filepath_image 'mat_temp' filesep foldername.train_yolo{ts, sh} '_bbox.mat'];
                if exist(filename_yoloR0,'file');
                    load(filename_yoloR0);
                    ind=find(cellfun(@isempty,train_yolo.bbox_ims)==0);
                    data1.(foldername.train_yolo{ts, sh}).bbox_ims(ind)=train_yolo.bbox_ims(ind);
                else
                    for ii=1:length(file_name_temp);if mod(ii,200)==1;tic;end;
                        filepath_load_yolo5=[data1.info.filepath_image foldername.train_yolo{ts, sh} filesep file_name_temp{ii}(1:end-4) filesep 'labels' filesep];
                        train_yolo0=load_yolo5_txt_v2(filepath_load_yolo5, imsize0, train_imsize{ts}, size_im4d, pixel_shift, data1.info);
                        ind=find(cellfun(@isempty,train_yolo0.bbox_ims)==0);
                        data1.(foldername.train_yolo{ts, sh}).bbox_ims{ind}=train_yolo0.bbox_ims{ind};
                        tbbox{ind,1}=train_yolo0.bbox;
                        if mod(ii,200)==0;fprintf(['Loading yolo:' num2str(ii) ' (' num2str(toc) 's)\n']);end;
                    end;
                    data1.(foldername.train_yolo{ts, sh}).bbox=cell2mat(tbbox);
                    train_yolo.bbox_ims=data1.(foldername.train_yolo{ts, sh}).bbox_ims;
                    train_yolo.bbox=data1.(foldername.train_yolo{ts, sh}).bbox;
                    save(filename_yoloR0,'train_yolo');
                    
                    clear file_name_temp train_yolo ind filepath_load_yolo5
                end
                
                if flag.save_coco==1 % yolo train to coco
                    filename_coco=[data1.info.filename_image(1:end-4) '__' foldername.train_yolo{ts, sh} '__' data1.info.result_ver '.json'];
                    select_data=foldername.train_yolo{ts, sh};fprintf(['load/save ' select_data '~.Json\n']);
                    if ~exist([data1.info.filepath_coco filesep filename_coco],'file')
                        mask_source='masks_CRBG';cat_name_select='name';annotation_id_select='category_id1';
                        %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,mask_source,cat_name_select,annotation_id_select);
                        %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,mask_source,cat_name_select,annotation_id_select,filename_coco,'SplitIm');
                        copt1.get_score=0;copt1.segmentation=0;copt1.case_coco='SplitIm';copt1.imfile_check=0;
                        data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,mask_source,cat_name_select,annotation_id_select,filename_coco,copt1);
                        cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                    else
                        try
                            coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                        catch
                            mask_source='masks_CRBG';cat_name_select='name';annotation_id_select='category_id1';
                            %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,mask_source,cat_name_select,annotation_id_select);
                            %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,mask_source,cat_name_select,annotation_id_select,filename_coco,'SplitIm');
                            copt1.get_score=0;copt1.segmentation=0;copt1.case_coco='SplitIm';copt1.imfile_check=0;
                            data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,mask_source,cat_name_select,annotation_id_select,filename_coco,copt1);
                            cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                            coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                        end
                        cocostruct=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
                        if flag.category_update>0;cocostruct=coco_category_update_v01(cocostruct,data1,'cat_one');end
                        data1.(select_data).coco=cocostruct;clear coco_temp cocostruct
                    end
                    data1.(select_data).filename_coco=filename_coco;
                    
                    if flag.coco_add_info==1
                        coco_temp_add=data1.(select_data).coco;
                        addinfo.brain_area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;addinfo.resolution=data1.info.pixel_size;
                        addinfo.dinfo=data1.info;addinfo.select_data=select_data;
                        data1.(select_data).coco=coco_modified_v02(coco_temp_add,addinfo,data1.info.filepath_coco,filename_coco);
                        clear coco_temp_add addinfo
                        
                        
                        
                        %                         coco_temp_add=data1.(select_data).coco;
                        %                         coco_temp_add.info.filename_coco=filename_coco;
                        %                         coco_temp_add.info.Brain_Area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;
                        %                         cocostring=gason(coco_temp_add);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                        %                         clear coco_temp_add
                    end
                    
                    
                    
                    %{
                            cocoGt=CocoApi(data1.(foldername.train_yolo{ts, sh}).coco);imgIds = cocoGt.getImgIds;
                            imgId = imgIds(randi(length(imgIds)));img = cocoGt.loadImgs(imgId);I = imread([img.file_path img.file_name]);
                            annIds = cocoGt.getAnnIds('imgIds',imgId,'iscrowd',[]); anns = cocoGt.loadAnns(annIds);
                            imF1 = insertObjectAnnotation(I, 'rectangle', [reshape([anns(:).bbox]',4,length(anns))]', {''},'color',{'yellow'},'LineWidth',3);
                            figure(220001); imagesc(imF1); axis('image'); set(gca,'XTick',[],'YTick',[]);cocoGt.showAnns(anns);
                    %}
                end
                
            end
            %% load yolo result
            foldername.result_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_result.yolo5(sh,:), train_imsize{ts}, 'result');
            filepath_load_yolo5=[data1.info.filepath_image foldername.result_yolo{ts, sh} filesep];
            if exist(filepath_load_yolo5,'dir')~=0;
                % load yolo result
                filename_yoloR0=[data1.info.filepath_image 'mat_temp' filesep foldername.result_yolo{ts, sh} '_txt.mat'];
                if exist(filename_yoloR0,'file');
                    load(filename_yoloR0);
                    data1.(foldername.result_yolo{ts, sh})=yoloR0;
                else
                    yoloR0=load_yolo5_txt_v2(filepath_load_yolo5, imsize0, train_imsize{ts}, size_im4d, pixel_shift,data1.info);
                    data1.(foldername.result_yolo{ts, sh})=yoloR0;
                    save(filename_yoloR0,'yoloR0')
                end
                data1.(foldername.result_yolo{ts, sh}).filepath=filepath_load_yolo5;


                % get image info from yolo train or test
                mpara.flag_save_train_path_case=flag.save_train_path_case;
                file_info=filepathname_of_image_Vmaskrcnn([data1.info.filepath_image foldername.train_yolo{ts, sh}],mpara);

                if isempty(file_info)==1
                    mpara.flag_getmaskpath=0;mpara.flag_save_train_path_case=flag.save_train_path_case;
                    foldername.test_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_test.maskrcnn(sh,:), train_imsize{ts}, 'test');
                    file_info=filepathname_of_image_Vmaskrcnn([data1.info.filepath_image foldername.test_yolo{ts, sh}],mpara);
                end

                data1.(foldername.result_yolo{ts, sh}).file_info=file_info;clear file_info
                data1.(foldername.result_yolo{ts, sh}).train_imsize=train_imsize{ts};mpara.flag_getmaskpath=0;

                if mod(sh,2)==1;data1.(foldername.result_yolo{ts, sh}).edgelinewidth=setp.edgelinewidth; %bug? set = 8 => 16 => result seems like 12;
                    if isempty(data1.(foldername.result_yolo{ts, sh}).bbox)~=1
                        [data1.(foldername.result_yolo{ts, sh}).id_boxcenter,data1.(foldername.result_yolo{ts, sh}).id_boxedge,bw_imsEdge]=indexboxonedge(data1.(foldername.result_yolo{ts, sh}).edgelinewidth,data1.im0gray,train_imsize{ts},data1.(foldername.result_yolo{ts, sh}).bbox,'vertex');
                    else
                        data1.(foldername.result_yolo{ts, sh}).id_boxcenter='';
                        data1.(foldername.result_yolo{ts, sh}).id_boxedge='';
                    end
                end
                if mod(sh,2)==0
                    filename_yolo5sh2_index=[data1.info.filepath_image 'mat_temp' filesep foldername.result_yolo{ts, sh} '.mat'];
                    if exist(filename_yolo5sh2_index,'file');load(filename_yolo5sh2_index);
                    else;
                        edgelinewidth_sh2=setp.edgelinewidth_sh2; %bug? set = 12 => 24 => result seems like 16;
                        [idsh2_boxcenter,idsh2_boxedge]=indexboxonedge(edgelinewidth_sh2,data1.im0gray,train_imsize{ts},data1.(foldername.result_yolo{ts, sh}).bbox,'line');
                        save(filename_yolo5sh2_index,'idsh2_boxcenter','idsh2_boxedge','edgelinewidth_sh2');
                    end;data1.(foldername.result_yolo{ts, sh}).id_boxcenter=idsh2_boxcenter;
                    data1.(foldername.result_yolo{ts, sh}).id_boxedge=idsh2_boxedge;
                    data1.(foldername.result_yolo{ts, sh}).edgelinewidth=edgelinewidth_sh2;
                end
                if isempty(data1.(foldername.result_yolo{ts, sh}).id_boxcenter)==1 && isempty(data1.(foldername.result_yolo{ts, sh}).id_boxedge)==1
                    flag.save_coco=0;
                end
                
                if flag.save_coco==1
                    filename_coco=[data1.info.filename_image(1:end-4) '__' foldername.result_yolo{ts, sh} '__' data1.info.result_ver '.json'];
                    select_data=foldername.result_yolo{ts, sh};fprintf(['load ' select_data '\n']);
                    if ~exist([data1.info.filepath_coco filesep filename_coco],'file');
                        data_format='result_yolo';cat_name_select='name';annotation_id_select='category_id1';
                        %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_format,cat_name_select,annotation_id_select);
                        %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_format,cat_name_select,annotation_id_select,filename_coco,'YoloResult');

                        copt1.get_score=1;copt1.segmentation=0;copt1.case_coco='YoloResult';copt1.imfile_check=0;
                        data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_format,cat_name_select,annotation_id_select,filename_coco,copt1);

                        cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                    else
                        try
                            coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                        catch
                            data_format='result_yolo';cat_name_select='name';annotation_id_select='category_id1';
                            %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_format,cat_name_select,annotation_id_select);
                            %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_format,cat_name_select,annotation_id_select,filename_coco,'YoloResult');
                            copt1.get_score=1;copt1.segmentation=0;copt1.case_coco='YoloResult';copt1.imfile_check=0;
                            data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,data_format,cat_name_select,annotation_id_select,filename_coco,copt1);

                            cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                            coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                            
                        end
                        cocostruct=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
                        if flag.category_update>0;cocostruct=coco_category_update_v01(cocostruct,data1);end
                        data1.(select_data).coco=cocostruct;clear coco_temp cocostruct
                    end
                    
                    data1.(select_data).filename_coco=filename_coco;
                    
                    if flag.coco_add_info==1
                        coco_temp_add=data1.(select_data).coco;
                        addinfo.brain_area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;addinfo.resolution=data1.info.pixel_size;
                        addinfo.dinfo=data1.info;addinfo.select_data=select_data;
                        data1.(select_data).coco=coco_modified_v02(coco_temp_add,addinfo,data1.info.filepath_coco,filename_coco);
                        clear coco_temp_add addinfo
                        
                        
                        %                         coco_temp_add=data1.(select_data).coco;
                        %                         coco_temp_add.info.filename_coco=filename_coco;
                        %                         coco_temp_add.info.Brain_Area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;
                        %                         cocostring=gason(coco_temp_add);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                    end
                    
                    %{
                            cocoDt=CocoApi(data1.(foldername.result_yolo{ts, sh}).coco);imgIds = cocoDt.getImgIds;
                            img = cocoDt.loadImgs(imgId);I = imread([img.file_path img.file_name]);
                            annIds = cocoDt.getAnnIds('imgIds',imgId,'iscrowd',[]); anns = cocoDt.loadAnns(annIds);
                            imF1 = insertObjectAnnotation(I, 'rectangle', [reshape([anns(:).bbox]',4,length(anns))]', {''},'color',{'yellow'},'LineWidth',3);
                            %figure(220002); imagesc(imF1); axis('image'); set(gca,'XTick',[],'YTick',[]);%cocoDt.showAnns(anns);
                    %}
                end
                
            end;
        end;clear bw_imsEdge clear filepath_load_yolo5 idsh2_boxcenter idsh2_boxedge edgelinewidth_sh2
        %% merge yolo result
        filepath_load_yolo5=[data1.info.filepath_image foldername.result_yolo{ts, sh} filesep];
        if exist(filepath_load_yolo5,'dir')~=0;
            if isfield(data1.(foldername.result_yolo{ts,1}),'bbox')==1

                if isempty(data1.(foldername.result_yolo{ts,1}).bbox)~=1
                    if max(shn)==2
                        data1.([foldername.result_yolo{ts,1} '_M']).bbox=[data1.(foldername.result_yolo{ts,1}).bbox(data1.(foldername.result_yolo{ts,1}).id_boxcenter,:);data1.(foldername.result_yolo{ts,2}).bbox(data1.(foldername.result_yolo{ts,2}).id_boxedge,:)];
                        data1.([foldername.result_yolo{ts,1} '_M']).score=[data1.(foldername.result_yolo{ts,1}).score(data1.(foldername.result_yolo{ts,1}).id_boxcenter,:);data1.(foldername.result_yolo{ts,2}).score(data1.(foldername.result_yolo{ts,2}).id_boxedge,:)];
                    else
                        data1.([foldername.result_yolo{ts,1} '_M']).bbox=data1.(foldername.result_yolo{ts,1}).bbox;
                        data1.([foldername.result_yolo{ts,1} '_M']).score=data1.(foldername.result_yolo{ts,1}).score;
                    end
                    if flag.save_coco==1
                        filename_coco=[data1.info.filename_image(1:end-4) '__' foldername.result_yolo{ts,1} '_M__' data1.info.result_ver '.json'];
                        select_data=[foldername.result_yolo{ts,1} '_M'];fprintf(['load ' select_data '\n']);
                        if ~exist([data1.info.filepath_coco filesep filename_coco],'file');
                            data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                            %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                            %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'LargeIm',0);
                            copt1.get_score=1;copt1.segmentation=0;copt1.case_coco='LargeIm';copt1.imfile_check=0;copt1.Low_res=flag.Low_res;
                            mask_source=select_data;
                            data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,mask_source,cat_name_select,annotation_id_select,filename_coco,copt1);
                            cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                        else
                            try
                                coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);
                            catch
                                data_source=select_data;cat_name_select='name';annotation_id_select='category_id1';
                                %data1.(select_data).coco=mask2cocoStructure_04(data1,select_data,data_source,cat_name_select,annotation_id_select);
                                %data1.(select_data).coco=mask2cocoStructure_09(data1,select_data,data_source,cat_name_select,annotation_id_select,filename_coco,'LargeIm',0);
                                copt1.get_score=1;copt1.segmentation=0;copt1.case_coco='LargeIm';copt1.imfile_check=0;
                                data1.(select_data).coco=mask2cocoStructure_11(data1,select_data,mask_source,cat_name_select,annotation_id_select,filename_coco,copt1);

                                cocostring=gason(data1.(select_data).coco);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                                coco_temp=CocoApi([data1.info.filepath_coco filesep filename_coco]);

                            end
                            cocostruct=cocoFilePathChange(coco_temp.data, [filepath01 data1.info.filename_image(1:3) filesep], data1.info.filename_image(1:end-4));
                            if flag.category_update>0;cocostruct=coco_category_update_v01(cocostruct,data1);end
                            data1.(select_data).coco=cocostruct;clear coco_temp cocostruct
                        end
                        data1.(select_data).filename_coco=filename_coco;

                        if flag.coco_add_info==1
                            coco_temp_add=data1.(select_data).coco;
                            addinfo.brain_area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;addinfo.resolution=data1.info.pixel_size;
                            addinfo.dinfo=data1.info;addinfo.select_data=select_data;
                            data1.(select_data).coco=coco_modified_v02(coco_temp_add,addinfo,data1.info.filepath_coco,filename_coco);
                            clear coco_temp_add addinfo

                            %                         coco_temp_add=data1.(select_data).coco;
                            %                         coco_temp_add.info.filename_coco=filename_coco;
                            %                         coco_temp_add.info.Brain_Area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2;
                            %                         cocostring=gason(coco_temp_add);fid = fopen([data1.info.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                            %                         clear coco_temp_add
                        end

                    end
                end


               
            end
        end
        %% display yolo5 result
        if dispfig==1
            %ts=1;edgelinewidth_sh2=8;drc=ceil(imsize0./train_imsize{ts});
            ts=1;edgelinewidth_sh2=20;drc=ceil(imsize0./train_imsize{ts}); % for paper figure
            bw_edge=false(size(data1.im0gray)); bw_edge_4d=imsplit4d(bw_edge,[train_imsize{ts}]);
            bw_edge_4d(:,1:edgelinewidth_sh2,:)=1;   bw_edge_4d(:,train_imsize{ts}(1)-edgelinewidth_sh2+1:train_imsize{ts}(1),:)=1;
            bw_edge_4d(:,:,1:edgelinewidth_sh2)=1;   bw_edge_4d(:,:,train_imsize{ts}(2)-edgelinewidth_sh2+1:train_imsize{ts}(2))=1;
            bw_edge=dmib2(bw_edge_4d,drc(1),drc(2)); bw_edge(1:edgelinewidth_sh2,:)=0;bw_edge(end-edgelinewidth_sh2+1:end,:)=0;bw_edge(:,1:edgelinewidth_sh2)=0;bw_edge(:,end-edgelinewidth_sh2+1:end)=0;
            imF1 = labeloverlay(data1.im0gray,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 0 0],'Transparency',0.5);
            
            imF1 = labeloverlay(data1.im0gray,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 1 0],'Transparency',0.5);
            %imF2 = insertObjectAnnotation(imF1, 'rectangle', data1.(foldername.result_yolo{ts,1}).bbox, {''},'color',{'yellow'},'LineWidth',3);
            figure(21000);imshow(imF1);set(gcf,'Color','w');
            
            %% paper figure1B (iv)(v): 512x512 image 
            ts=1;edgelinewidth_sh2=20;drc=ceil(imsize0./train_imsize{ts}); % for paper figure
            bw_edge=false(size(data1.im0gray)); bw_edge_4d=imsplit4d(bw_edge,[train_imsize{ts}]);
            bw_edge_4d(:,1:edgelinewidth_sh2,:)=1;   bw_edge_4d(:,train_imsize{ts}(1)-edgelinewidth_sh2+1:train_imsize{ts}(1),:)=1;
            bw_edge_4d(:,:,1:edgelinewidth_sh2)=1;   bw_edge_4d(:,:,train_imsize{ts}(2)-edgelinewidth_sh2+1:train_imsize{ts}(2))=1;
            bw_edge=dmib2(bw_edge_4d,drc(1),drc(2)); bw_edge(1:edgelinewidth_sh2,:)=0;bw_edge(end-edgelinewidth_sh2+1:end,:)=0;bw_edge(:,1:edgelinewidth_sh2)=0;bw_edge(:,end-edgelinewidth_sh2+1:end)=0;
            imF1 = labeloverlay(data1.im0gray,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 1 0],'Transparency',0.5);
            imp=data1.im0gray;imp=circshift(imp,pixel_shift(sh),1);imp=circshift(imp,pixel_shift(sh),2);
            imF2 = labeloverlay(imp,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[0 1 0],'Transparency',0.5);
                    
            select_num1=800; %800, 604;
            im_4d1=imsplit4d(imF1,[train_imsize{ts},3]);
            s_im1=squeeze(im_4d1(select_num1,:,:,:));
            s_label=data1.CRBG_wEdge_512x512__result__YOLO_conf_50_100.label{select_num1};
            s_bbox=data1.CRBG_wEdge_512x512__result__YOLO_conf_50_100.bbox_ims{select_num1};
           
%             s_bbox1=s_bbox([1:45 47:end],:);s_label1=s_label([1:45 47:end]);
             boxcolor=repmat([255 255 0],length(s_label),1);
%             s_bbox2=s_bbox(46,:);s_label2=s_label(46);
            
            s_im1f = insertObjectAnnotation(s_im1, 'rectangle', s_bbox, s_label,'color',boxcolor,'LineWidth',5,'TextColor','y','TextBoxOpacity',0,'FontSize',16,'Font','Arial');
           % s_im1f = insertObjectAnnotation(s_im1f, 'rectangle', s_bbox2, s_label2,'color',[255 0 0],'LineWidth',5,'TextColor','r','TextBoxOpacity',0,'FontSize',16,'Font','Arial');

            figure(2121);imshow(s_im1f);set(gcf,'Color','w');axis on;set(gca,'fontsize',20)

            select_num2=854;
            im_4d2=imsplit4d(imF2,[train_imsize{ts},3]);
            s_im2=squeeze(im_4d2(select_num2,:,:,:));
            s_label=data1.CRBG_wEdge_512x512shift__result__YOLO_conf_50_100.label{select_num2};
            s_bbox=data1.CRBG_wEdge_512x512shift__result__YOLO_conf_50_100.bbox_ims{select_num2};
            boxcolor=repmat([0 255 0],length(s_label),1);
            s_im2f = insertObjectAnnotation(s_im2, 'rectangle', s_bbox, s_label,'color',boxcolor,'LineWidth',5,'TextColor','g','TextBoxOpacity',0,'FontSize',16,'Font','Arial');
            figure(2122);imshow(s_im2f);set(gcf,'Color','w');axis on;set(gca,'fontsize',20)
            %% paper figure1B (i)(ii)(iii)
            % (i)
            edgelinewidth_sh2=20;
            bw_edge=false(size(data1.im0gray)); bw_edge_4d=imsplit4d(bw_edge,[train_imsize{ts}]);
            bw_edge_4d(:,1:edgelinewidth_sh2,:)=1;   bw_edge_4d(:,train_imsize{ts}(1)-edgelinewidth_sh2+1:train_imsize{ts}(1),:)=1;
            bw_edge_4d(:,:,1:edgelinewidth_sh2)=1;   bw_edge_4d(:,:,train_imsize{ts}(2)-edgelinewidth_sh2+1:train_imsize{ts}(2))=1;
            bw_edge=dmib2(bw_edge_4d,drc(1),drc(2)); bw_edge(1:edgelinewidth_sh2,:)=0;bw_edge(end-edgelinewidth_sh2+1:end,:)=0;bw_edge(:,1:edgelinewidth_sh2)=0;bw_edge(:,end-edgelinewidth_sh2+1:end)=0;
            imF1 = labeloverlay(data1.im0gray,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 0 0],'Transparency',0.5);
            figure(21111);imshow(imF1);set(gcf,'Color','w');
            % (ii)
            bw_edge_sh=circshift(bw_edge,512/2,1);bw_edge_sh=circshift(bw_edge_sh,512/2,2);
            bw_edge_sh(256-edgelinewidth_sh2+1:256+edgelinewidth_sh2,:)=1;  bw_edge_sh(:,256-edgelinewidth_sh2+1:256+edgelinewidth_sh2)=1;
            imF2 = labeloverlay(data1.im0gray,bw_edge_sh(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[0 1 1],'Transparency',0.5);
            figure(21112);imshow(imF2);set(gcf,'Color','w');
            % (iii)
            bw_edge=false(size(data1.im0gray)); bw_edge_4d=imsplit4d(bw_edge,[train_imsize{ts}]);bw_edge_4d2=bw_edge_4d;
            bw_edge_4d(:,1:edgelinewidth_sh2,:)=1;   bw_edge_4d(:,train_imsize{ts}(1)-edgelinewidth_sh2+1:train_imsize{ts}(1),:)=1;
            bw_edge_4d(:,:,1:edgelinewidth_sh2)=1;   bw_edge_4d(:,:,train_imsize{ts}(2)-edgelinewidth_sh2+1:train_imsize{ts}(2))=1;
            bw_edge_4d(select_num1,1:edgelinewidth_sh2,:)=0;   bw_edge_4d(select_num1,train_imsize{ts}(1)-edgelinewidth_sh2+1:train_imsize{ts}(1),:)=0;
            bw_edge_4d(select_num1,:,1:edgelinewidth_sh2)=0;   bw_edge_4d(select_num1,:,train_imsize{ts}(2)-edgelinewidth_sh2+1:train_imsize{ts}(2))=0;
            bw_edge=dmib2(bw_edge_4d,drc(1),drc(2)); bw_edge(1:edgelinewidth_sh2,:)=0;bw_edge(end-edgelinewidth_sh2+1:end,:)=0;bw_edge(:,1:edgelinewidth_sh2)=0;bw_edge(:,end-edgelinewidth_sh2+1:end)=0;
            bw_edge_4d2(select_num1,1:edgelinewidth_sh2,:)=1;   bw_edge_4d2(select_num1,train_imsize{ts}(1)-edgelinewidth_sh2+1:train_imsize{ts}(1),:)=1;
            bw_edge_4d2(select_num1,:,1:edgelinewidth_sh2)=1;   bw_edge_4d2(select_num1,:,train_imsize{ts}(2)-edgelinewidth_sh2+1:train_imsize{ts}(2))=1;
            bw_edge2=dmib2(bw_edge_4d2,drc(1),drc(2)); bw_edge_4d2(1:edgelinewidth_sh2,:)=0;bw_edge_4d2(end-edgelinewidth_sh2+1:end,:)=0;bw_edge_4d2(:,1:edgelinewidth_sh2)=0;bw_edge_4d2(:,end-edgelinewidth_sh2+1:end)=0;
            imF3 = labeloverlay(data1.im0gray,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 0 0],'Transparency',0.5);
            imF3 = labeloverlay(imF3,bw_edge2(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 1 0],'Transparency',0);
            %figure(21002);imshow(imF3);set(gcf,'Color','w');
            bw_edge_sh=circshift(bw_edge,512/2,1);bw_edge_sh=circshift(bw_edge_sh,-512/2,2);
            %bw_edge_sh(256-edgelinewidth_sh2+1:256+edgelinewidth_sh2,:)=1; bw_edge_sh(:,256-edgelinewidth_sh2+1:256+edgelinewidth_sh2)=1;
            bw_edge_sh2=circshift(bw_edge2,512/2,1);bw_edge_sh2=circshift(bw_edge_sh2,-512/2,2);
            %bw_edge_sh2(256-edgelinewidth_sh2+1:256+edgelinewidth_sh2,:)=1; bw_edge_sh2(:,256-edgelinewidth_sh2+1:256+edgelinewidth_sh2)=1;
            imF3 = labeloverlay(imF3,bw_edge_sh(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[0 1 1],'Transparency',0.5);
            imF3 = labeloverlay(imF3,bw_edge_sh2(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[51 255 51]/255,'Transparency',0);
            %figure(21002);imshow(imF3(5400:5400+1200,4020:4020+1800,:));set(gcf,'Color','w');
            figure(21002);imshow(imF3(6900:6900+1200,21700:21700+1800,:));set(gcf,'Color','w');

            figure(21003);imshow(imF3);set(gcf,'Color','w');
            %% paper figure1B (vi)
            edgelinewidth_sh2=8;
            bw_edge0=false(size(data1.im0gray)); bw_edge_4d0=imsplit4d(bw_edge0,[train_imsize{ts}]);
            bw_edge_4d0(:,1:edgelinewidth_sh2,:)=1;   bw_edge_4d0(:,train_imsize{ts}(1)-edgelinewidth_sh2+1:train_imsize{ts}(1),:)=1;
            bw_edge_4d0(:,:,1:edgelinewidth_sh2)=1;   bw_edge_4d0(:,:,train_imsize{ts}(2)-edgelinewidth_sh2+1:train_imsize{ts}(2))=1;
            bw_edge0=dmib2(bw_edge_4d0,drc(1),drc(2)); bw_edge0(1:edgelinewidth_sh2,:)=0;bw_edge0(end-edgelinewidth_sh2+1:end,:)=0;bw_edge0(:,1:edgelinewidth_sh2)=0;bw_edge0(:,end-edgelinewidth_sh2+1:end)=0;

            imF4 = labeloverlay(data1.im0gray,bw_edge0(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 0 0],'Transparency',0.3);
            imF4 = insertObjectAnnotation(imF4, 'rectangle', data1.(foldername.result_yolo{ts,1}).bbox(data1.(foldername.result_yolo{ts,1}).id_boxcenter,:), {''},'color',{'yellow'},'LineWidth',5);
            imF4 = insertObjectAnnotation(imF4, 'rectangle', data1.(foldername.result_yolo{ts,2}).bbox(data1.(foldername.result_yolo{ts,2}).id_boxedge,:), {''},'color',{'green'},'LineWidth',5);
            %figure(21003);imshow(imF4(5400:5400+1200,4020:4020+1800,:));set(gcf,'Color','w');
            figure(21002);imshow(imF4(6900:6900+1200,21700:21700+1800,:));set(gcf,'Color','w');



            if max(shn)==2
                bw_edge_sh=circshift(bw_edge,512/2,1);bw_edge_sh=circshift(bw_edge_sh,512/2,2);
                bw_edge_sh(256-edgelinewidth_sh2+1:256+edgelinewidth_sh2,:)=1;  bw_edge_sh(:,256-edgelinewidth_sh2+1:256+edgelinewidth_sh2)=1;
                imF1 = labeloverlay(data1.im0gray,bw_edge_sh(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[0 1 1],'Transparency',0.5);
                imF1 = labeloverlay(imF1,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 0 0],'Transparency',0.5);
                imF3 = insertObjectAnnotation(imF1, 'rectangle', data1.(foldername.result_yolo{ts,2}).bbox, {''},'color',{'green'},'LineWidth',3);
                figure(21001);imshow(imF1);set(gcf,'Color','w');
            end
                imF4 = labeloverlay(data1.im0gray,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 0.5 0],'Transparency',0.3);
                imF4 = insertObjectAnnotation(imF4, 'rectangle', data1.(foldername.result_yolo{ts,1}).bbox(data1.(foldername.result_yolo{ts,1}).id_boxcenter,:), {''},'color',{'yellow'},'LineWidth',3);
                imF4 = insertObjectAnnotation(imF4, 'rectangle', data1.(foldername.result_yolo{ts,2}).bbox(data1.(foldername.result_yolo{ts,2}).id_boxedge,:), {''},'color',{'green'},'LineWidth',3);
                figure(21003);imshow(imF4);set(gcf,'Color','w');

                bl=100;bz=[3800, 1800, 2500, 1500];
                figure(21004);imshow(imF4(bz(2):bz(2)+bz(4),bz(1):bz(1)+bz(3),:));set(gcf,'Color','w');
                imF41=imF4;
                
                imF41(bz(2):bz(2)+bz(4), bz(1)-bl:bz(1),1)=0;imF41(bz(2):bz(2)+bz(4), bz(1)-bl:bz(1),2)=255;imF41(bz(2):bz(2)+bz(4), bz(1)-bl:bz(1),3)=255;
                imF41(bz(2):bz(2)+bz(4), bz(1)+bz(3)+bl:bz(1)+bz(3),1)=0;imF41(bz(2):bz(2)+bz(4), bz(1)+bz(3):bz(1)+bz(3)+bl,2)=255;imF41(bz(2):bz(2)+bz(4), bz(1)+bz(3):bz(1)+bz(3)+bl,3)=255;
                imF41(bz(2)-bl:bz(2)+bl, bz(1):bz(1)+bz(3),1)=0;imF41(bz(2):bz(2)+bl, bz(1):bz(1)+bz(3),2)=255;imF41(bz(2):bz(2)+bl, bz(1):bz(1)+bz(3),3)=255;

                imF41(bz(2)+bz(4)-bl:bz(2)+bz(4), bz(1):bz(1)+bz(3),1)=0;imF41(bz(2)+bz(4)-bl:bz(2)+bz(4), bz(1):bz(1)+bz(3),2)=255;imF41(bz(2)+bz(4)-bl:bz(2)+bz(4), bz(1):bz(1)+bz(3),3)=255;

                figure(21005);imshow(imF41);set(gcf,'Color','w');



        end
        %{
                imsp4d=imsplit4d(data1.im0gray,[train_imsize{ts}]);
                eidy=find(cellfun(@isempty,data1.(foldername.result_yolo{ts,1}).bbox_ims)==0);
                
                pp0=eidy(1:4);%[919 973 1027 1081]; %463;
                for nn=1:length(pp0)
                    clear imF1 label_str
                    pp=pp0(nn);
                    ims1=squeeze(imsp4d(pp,:,:));
                    bboxYolo=data1.(foldername.result_yolo{ts,1}).bbox_ims{pp};
                    scoreYolo=data1.(foldername.result_yolo{ts,1}).score_ims{pp};
                    if isfield(data1,foldername.train_yolo{ts,1})
                        bboxYoloGt=data1.(foldername.train_yolo{ts,1}).bbox_ims{pp};
                    end
                    for ii=1:length(scoreYolo);label_str{ii} = ['score: ' num2str(100*scoreYolo(ii),'%0.1f') '%'];end
                    if isfield(data1,foldername.train_yolo{ts,1})
                        imF1 = insertObjectAnnotation(ims1, 'rectangle', bboxYoloGt, {''},'color',{'blue'},'LineWidth',3);
                        imF1 = insertObjectAnnotation(imF1, 'rectangle', bboxYolo, label_str,'color',{'yellow'},'LineWidth',1);
                    else
                        imF1 = insertObjectAnnotation(ims1, 'rectangle', bboxYolo, label_str,'color',{'yellow'},'LineWidth',1);
                    end
                    
                    figure(22100+nn);imshow(imF1);set(gcf,'Color','w');title(num2str(pp))
                end
             
                
                labelsh1=vertcat(data1.(foldername.result_yolo{ts,1}).label{:});
                labelsh2=vertcat(data1.(foldername.result_yolo{ts,2}).label{:});
                sh=2; %Yolo5 shift
                Rshn=[0 fix(train_imsize{ts}(2)/2) fix(train_imsize{ts}(2)/2) 0];Dshn=[0 fix(train_imsize{ts}(1)/2) 0 fix(train_imsize{ts}(1)/2)];
                imp=data1.im0gray; imp=circshift(imp,Dshn(sh),1);imp=circshift(imp,Rshn(sh),2);
                imF1 = labeloverlay(imp,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[0 1 0.5],'Transparency',0.3);
                figure(21002);imshow(imF1);set(gcf,'Color','w');
                
                dis_box_id=1:50;pp=72; %463;
                %imF2 = insertObjectAnnotation(data1.im0gray, 'rectangle', data1.CRBG_wEdge_512x512__train.bbox, {''},'color',{'blue'},'LineWidth',3);
                imF2 = insertObjectAnnotation(data1.im0gray, 'rectangle', data1.(foldername.result_yolo{ts,1}).bbox(data1.(foldername.result_yolo{ts,1}).id_boxcenter,:), {''},'color',{'yellow'},'LineWidth',3);
                imF2 = insertObjectAnnotation(data1.im0gray, 'rectangle', data1.(foldername.result_yolo{ts,1}).bbox(data1.(foldername.result_yolo{ts,1}).id_boxcenter(dis_box_id),:), labelsh1(data1.(foldername.result_yolo{ts,1}).id_boxcenter(dis_box_id)),'color',{'yellow'},'LineWidth',3);
                imF2 = insertObjectAnnotation(imF2, 'rectangle', data1.(foldername.result_yolo{ts,2}).bbox(data1.(foldername.result_yolo{ts,2}).id_boxedge(dis_box_id),:), labelsh2(data1.(foldername.result_yolo{ts,2}).id_boxedge(dis_box_id)),'color',{'green'},'LineWidth',3);
                figure(21003);imshow(imF2);set(gcf,'Color','w');

                % check yolo merge
                imF2_4d=imsplit4d(imF2,[train_imsize{ts},3]);ims2=squeeze(imF2_4d(pp,:,:,:));%figure(21002);imshow(ims2);set(gcf,'Color','w');
                ims1=squeeze(imsp4d(pp,:,:)); clear label_str; bboxYolo=data1.(foldername.result_yolo{ts,1}).bbox_ims{pp};scoreYolo=data1.(foldername.result_yolo{ts,1}).score_ims{pp};bboxYoloGt=data1.(foldername.train_yolo{ts,1}).bbox_ims{pp};
                for ii=1:length(scoreYolo);label_str{ii} = ['score: ' num2str(100*scoreYolo(ii),'%0.1f') '%'];end;imF1 = insertObjectAnnotation(ims1, 'rectangle', bboxYoloGt, {''},'color',{'blue'},'LineWidth',3);imF1 = insertObjectAnnotation(imF1, 'rectangle', bboxYolo, label_str,'color',{'yellow'},'LineWidth',1);
                %figure(21001);imshow(imF1);set(gcf,'Color','w');
                
                imF2 = labeloverlay(data1.im0gray,bw_edge(1:size(data1.im0gray,1),1:size(data1.im0gray,2)),'Colormap',[1 0.25 0],'Transparency',0.3);
                if isfield(data1,'masks_CRBG')==1
                imF2 = insertObjectAnnotation(imF2, 'rectangle', data1.masks_CRBG.bbox, {''},'color',{'blue'},'LineWidth',3);
                end
            
                
                imF2 = insertObjectAnnotation(imF2, 'rectangle',data1.(foldername.result_yolo{ts,1}).bbox,{''},'color',{'yellow'},'LineWidth',3); %% all box
                figure(21004);imshow(imF2);set(gcf,'Color','w');
        %}
        
    end
end
