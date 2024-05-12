function [cocostruct,data1]=mask2cocoStructure_11(data1,select_data,mask_source,cat_name_select,annotation_id_select,filename_coco,varargin);
% select_data='CRBG_wEdge_512x512__result__YOLO_conf_50_100';
% data_format='small_image_yolo_result';  mask2cocoStructure_01
% cat_name_select='name1';
% cat_id_select='id1';
%filename_image=filename_temp;
% if isempty(varargin)~=1
%     cocostruct=varargin{1};
% else
%     cocostruct='';
% end  mask2cocoStructure_01
% modified id_masknii

cocostruct='';
if isfield(data1, select_data)==0
    if contains(select_data,'train')
        mask_source='masks_CRBG';
    else
        fprintf('mask not exist');
        select_data='';
    end
end


if isempty(varargin)==1
    opt1.case_coco=select_data;
else
    opt1=varargin{1};
    if isfield(opt1,'segmentation')==0
        opt1.segmentation=1;
    end
    if isfield(opt1,'case_coco')==0
        opt1.case_coco=select_data;
    end
    if isfield(opt1,'imfile_check')==0
        opt1.imfile_check=0;
    end
end


if isempty(select_data)~=1

    if isfield(data1.(select_data),'coco_ida')==1
        coco_ida=data1.(select_data).coco_ida;
    end

    %% coco.info
    cocostruct.info.description=select_data;
    cocostruct.info.url='';
    cocostruct.info.version='3.0';
    cocostruct.info.year='2021';
    cocostruct.info.contributor='HU';
    cocostruct.info.date_created='2021/02/19';

    cocostruct.info.filename_coco=filename_coco;
    if isfield(data1,'imbackground')==1
        cocostruct.info.Brain_Area=sum(data1.imbackground(:))*(data1.info.pixel_size).^2; %*0.424
    end
    cocotemp.info.imreso_orig=data1.info.pixel_size; %

    %% coco.licenses
    url={'http1';'http2';'http3'};
    id=[1;2;3];
    name={'Chaohsiung';'Alan';'Willim'};
    cocostruct.licenses=table2struct(table(url,id,name))';
    clear url id name
    %% coco.categories
    temp={data1.categories.(cat_name_select)}';
    cocostruct.categories=data1.categories;
    [cocostruct.categories.name]=temp{:};
    if contains(select_data,'ImJroi')
        if contains(select_data,'_M')
            opt1.case_coco='ChImJroi_DChecked_512x512__train_M';
        else
            opt1.case_coco='ChImJroi_DChecked_512x512__train';
        end
    end
    switch opt1.case_coco
        case {'Y2Unet','CRBG_UnetOneCell_256x256__train','CRBG_UnetOneCell_256x256__result__UNET',...
                'Yolo512_UnetCRBG_256x256__test','Yolo512_Unet_256x256__test',...
                'Yolo512_UnetCRBG_256x256__result__UNET','Yolo512_Unet_256x256__result__UNET'}
            % coco.image
            file_path={data1.(select_data).file_info.file_path}';
            file_name={data1.(select_data).file_info.file_name}';
            license=ones(length(file_name),1);
            coco_url= cell(length(file_name), 1);coco_url(:) ={''};
            height=[data1.(select_data).file_info.height]';
            width=[data1.(select_data).file_info.width]';
            data_captured= cell(length(file_name), 1);data_captured(:) ={''};
            flickr_url= cell(length(file_name), 1);flickr_url(:) ={''};
            id=[data1.(select_data).file_info.id]';
            cocostruct.images=table2struct(table(license,file_path,file_name,coco_url,height,width,data_captured,flickr_url,id))';
            clear id
            % coco.annotation
            num_box=size(data1.(select_data).bbox,1);

            if isfield(data1.(select_data),'bwmask')==1
                segmentation=cell(size(data1.(select_data).bbox,1),1);
                bwmask=uint8(data1.(select_data).bwmask);
                for qq=1:num_box;bwmask0=squeeze(bwmask(qq,:,:));segmentation{qq,1}=rle_chh(bwmask0);end

            end


            image_id0=fix([data1.(select_data).file_info.id]'/10000/1000);
            switch select_data
                case 'CRBG_UnetOneCell_256x256__train';id0=image_id0+1;
                case 'CRBG_UnetOneCell_256x256__result__UNET';id0=image_id0+5;
                case {'Yolo512_UnetCRBG_256x256__test','Yolo512_Unet_256x256__test'};id0=image_id0+11;
                case {'Yolo512_UnetCRBG_256x256__result__UNET','Yolo512_Unet_256x256__result__UNET'};id0=image_id0+15;
                otherwise
                    id0=image_id0+1;
            end
            %segmentation1{qq,1}=MaskApi.encode(bwmask0);

            image_id=uint64(image_id0*10000*1000+uint64([1:num_box]'));
            id=uint64(id0*10000*1000+uint64([1:num_box]'));



            id_masknii=[1:num_box]';
            %             for qq=1:num_box
            %                 image_id(qq,1)=image_id0(1)*100000000+qq;
            %                 id(qq,1)=id0(qq)*100000000+qq;
            %
            %             end


            category_id1=uint64(ones(size(data1.(select_data).bbox,1),1))*cocostruct.categories(1).id;
            category_id2=uint64(zeros(size(data1.(select_data).bbox,1),1));
            iscrowd=uint8(zeros(size(data1.(select_data).bbox,1),1));
            bbox=data1.(select_data).bbox;
            if isfield(data1.(select_data),'bwmask')==1
                area=sum(sum(data1.(select_data).bwmask,2),3);
            else
                area=bbox(:,3).*bbox(:,4);
            end


            %%% ind for remove zero box
            sumbc=sum(data1.(select_data).bbox,2);
            ind_n0=find(sumbc~=0);
            if isfield(data1,'atlas_brain')==1; %check box position in the atlas
                xc=fix((data1.(select_data).bbox0(ind_n0,1)+data1.(select_data).bbox0(ind_n0,3)/2)/abs(opt1.Low_res));
                yc=fix((data1.(select_data).bbox0(ind_n0,2)+data1.(select_data).bbox0(ind_n0,4)/2)/abs(opt1.Low_res));

                %                 xc=fix((data1.(select_data).bbox0(ind_n0,1)+data1.(select_data).bbox0(ind_n0,3)/2));
                %                 yc=fix((data1.(select_data).bbox0(ind_n0,2)+data1.(select_data).bbox0(ind_n0,4)/2));
                try
                    ind = sub2ind(size(data1.atlas_brain),yc,xc);%y,x
                catch
                    yc
                end

                num_at=data1.atlas_brain(ind);
                id_at=unique(num_at);
                ccc=data1.atlas_table.id;
                for aa=1:length(id_at)
                    index_at(aa) = find(ccc == id_at(aa));
                    idna=find(num_at==id_at(aa));
                    in=find(strcmpi({cocostruct.categories.name},data1.atlas_table.atlas_name{index_at(aa)})==1);
                    if strcmpi(data1.atlas_table.atlas_name{index_at(aa)},'brain')==1
                        if isempty(in)==1
                            in=find(strcmpi({cocostruct.categories.name},'microglia')==1);
                        end
                    end
                    category_id2(ind_n0(idna),:)=cocostruct.categories(in).id;
                end
                category_id2=category_id2(ind_n0);
            end


            bbox=bbox(ind_n0,:);
            area=area(ind_n0,:);
            iscrowd=iscrowd(ind_n0);
            category_id1=category_id1(ind_n0);
            image_id=image_id(ind_n0,:);
            id=id(ind_n0,:);
            id_masknii=id_masknii(ind_n0,:);
            if isfield(data1.(select_data),'bwmask')==1
                segmentation=segmentation(ind_n0);
            end

            eval(['category_id=' annotation_id_select ';'])


            try image_id=uint64(image_id);catch;end
            try bbox=double(bbox);catch;end
            try area=double(area);catch;end
            try iscrowd=double(iscrowd);catch;end
            try category_id=uint64(category_id);catch;end
            try id=uint64(id);catch;end
            try category_id1=uint64(category_id1);catch;end
            try category_id2=uint64(category_id2);catch;end
            try category_id3=uint64(category_id3);catch;end
            try category_id4=uint64(category_id4);catch;end
            try N_bbox=double(N_bbox);catch;end

            if isfield(data1.(select_data),'score')==1
                score=data1.(select_data).score(ind_n0);if size(score,1)~=size(image_id,1);score=score';end
                if isfield(data1.(select_data),'bwmask')==1
                    cocostruct.annotations=table2struct(table(score,image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id2))';
                else
                    cocostruct.annotations=table2struct(table(score,image_id,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id2))';

                end
            else
                if isfield(data1.(select_data),'bwmask')==1
                    cocostruct.annotations=table2struct(table(image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id2))';
                else
                    cocostruct.annotations=table2struct(table(image_id,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id2))';
                end
            end


        case {'SplitIm','Children_GoldStandard_512x512__train','ChImJroi_DChecked_512x512__train',...
                'CRBG_wEdge_512x512__train','CRBG_wEdge_512x512shift__train','CRBG_wEdge_1024x1024__train','CRBG_wEdge_1024x1024shift__train',...
                'CRBG_noEdge_512x512__train','CRBG_noEdge_512x512shift__train','CRBG_noEdge_1024x1024__train','CRBG_noEdge_1024x1024shift__train',...
                'URBG_wEdge_512x512__test','URBG_wEdge_512x512shift__test'}
            if isfield(data1.(select_data),'file_info')==1

                train_imsize0=data1.(select_data).train_imsize;
                % coco.image
                file_path={data1.(select_data).file_info.file_path}';
                file_name={data1.(select_data).file_info.file_name}';
                license=ones(length(file_name),1);
                coco_url= cell(length(file_name), 1);coco_url(:) ={''};
                height=[data1.(select_data).file_info.height]';
                width=[data1.(select_data).file_info.width]';
                data_captured= cell(length(file_name), 1);data_captured(:) ={''};
                flickr_url= cell(length(file_name), 1);flickr_url(:) ={''};
                id=[data1.(select_data).file_info.id]';
                cocostruct.images=table2struct(table(license,file_path,file_name,coco_url,height,width,data_captured,flickr_url,id))';
                clear id
                % coco.annotation
                train_imsize0=data1.(select_data).train_imsize;
                if isempty(strfind(lower(select_data),'shift'))~=1
                    pixel_shift=[fix(train_imsize0(2)/2) fix(train_imsize0(2)/2)];sh=2;else;pixel_shift=[0 0];sh=1;end
                %if train_imsize0(1)==512;ts=1;end;if train_imsize0(1)==1024;ts=2;end
                iMid0=[data1.(select_data).file_info.id]';

                iMid0k=fix(iMid0/10000)*10000;
                %imp=data1.im0gray; %imp=circshift(imp,pixel_shift(1),1);imp=circshift(imp,pixel_shift(2),2);%imt_4d=imsplit4d(imp,train_imsize0);
                % get mask from CRBG
                atlas_allcell_p=circshift(data1.(mask_source).atlas_allcell_N,pixel_shift(1),1);atlas_allcell_p=circshift(atlas_allcell_p,pixel_shift(2),2);
                bw_gt_4d=imsplit4d(atlas_allcell_p,train_imsize0);
                num_exitbw=sum(sum(bw_gt_4d,2),3);
                index_exitbw=find(num_exitbw~=0);



                if isempty(strfind(select_data,'noEdge'))~=1
                    bw_gt_4d0=bw_gt_4d;clear bw_gt_4d
                    bw_gt_4d=bw_gt_4d0*0;
                    for ee=index_exitbw'
                        bwt0=squeeze(bw_gt_4d0(ee,:,:));bwt1=bwt0;
                        bwt0(2:end-1,2:end-1)=0;
                        idedge=unique(bwt0);idedge=idedge(idedge~=0);
                        for kk=1:length(idedge)
                            bwt1(bwt1==idedge(kk))=0;
                        end
                        bw_gt_4d(ee,:,:)=bwt1;
                    end
                end

                num_exitbw=sum(sum(bw_gt_4d,2),3);
                index_exitbw=find(num_exitbw~=0);

                if opt1.imfile_check==1
                    idfile=iMid0-fix(iMid0/10000)*10000;
                    index_exitbw=double(intersect(index_exitbw,idfile));
                end

                bbox0i_ims=cell(size(bw_gt_4d,1),1);
                %iMid0r=iMid0-fix(iMid0/10000)*10000;
                image_id0=cell(size(bw_gt_4d,1),1);
                id0=cell(size(bw_gt_4d,1),1);
                id0ch=cell(size(bw_gt_4d,1),1);
                seg0=cell(size(bw_gt_4d,1),1);
                area0=cell(size(bw_gt_4d,1),1);
                category_id20=cell(size(bw_gt_4d,1),1);
                if opt1.get_score==1
                    try
                        id_masknii=[data1.(mask_source).cocoP.annotations.id_masknii];
                    catch
                        id_masknii=[data1.(mask_source).coco.annotations.id_masknii];
                    end
                end

                for bco=1:length(index_exitbw)
                    if mod(bco,200)==1;tic;end
                    bwt0=squeeze(bw_gt_4d(index_exitbw(bco),:,:));
                    stats=regionprops(bwt0,'BoundingBox','Area');
                    bbox_temp={stats(:).BoundingBox}';Area_temp=[stats(:).Area]';
                    bbox2=cell2mat(bbox_temp(Area_temp~=0));bbox2=ceil(bbox2);
                    area0{index_exitbw(bco)}=Area_temp(Area_temp~=0);
                    bbox0i_ims{index_exitbw(bco)}=bbox2;
                    bnum=unique(bwt0);bnum=bnum(bnum~=0);
                    num_box=length(bnum);
                    if isfield(data1,'fix_imId')==1
                        image_id0{index_exitbw(bco)}=data1.(select_data).file_info.id*ones(num_box,1);
                    else
                        image_id0{index_exitbw(bco)}=(double(iMid0k(1))+index_exitbw(bco))*ones(num_box,1);
                    end
                    if isfield(data1,'atlas_brain')==1; %check box position in the atlas
                        if bco==1;
                            if isempty(strfind(lower(select_data),'shift'))~=1;sh=2;
                                Rshn=[0 fix(train_imsize0(2)/2) fix(train_imsize0(2)/2) 0]; Dshn=[0 fix(train_imsize0(1)/2) 0 fix(train_imsize0(1)/2)];
                                atlas_brain_sh=circshift(data1.atlas_brain,Dshn(sh),1);atlas_brain_sh=circshift(atlas_brain_sh,Rshn(sh),2);
                            else
                                atlas_brain_sh=data1.atlas_brain;sh=1;
                            end
                            atb_4d=imsplit4d(atlas_brain_sh,train_imsize0);
                        end
                        at_s=squeeze(atb_4d(index_exitbw(bco),:,:));

                        bbox_temp=bbox2;
                        bbox_center=fix([bbox_temp(:,1)+bbox_temp(:,3)/2 bbox_temp(:,2)+bbox_temp(:,4)/2]);%x,y
                        ind = sub2ind(size(at_s),bbox_center(:,2),bbox_center(:,1));%y,x
                        num_at=at_s(ind);
                        id_at=unique(num_at);
                        ccc=data1.atlas_table.id;
                        category_id2i=zeros(length(ind),1);
                        category_id2ii_name=repmat({''},[length(ind),1]);
                        for aa=1:length(id_at)
                            %index_at(aa) = find([ccc{:}] == id_at(aa));
                            index_at(aa) = find(ccc == id_at(aa));
                            idna=find(num_at==id_at(aa));
                            in=find(strcmpi({cocostruct.categories.name},data1.atlas_table.atlas_name{index_at(aa)})==1);
                            if strcmpi(data1.atlas_table.atlas_name{index_at(aa)},'brain')==1
                                if isempty(in)==1
                                    % fprintf('no atlas \n');
                                    in=find(strcmpi({cocostruct.categories.name},'microglia')==1);
                                end
                            end
                            category_id2i(idna,:)=cocostruct.categories(in).id;
                            category_id2ii_name(idna,:)=repmat(data1.atlas_table.atlas_name(index_at(aa)),[length(idna),1]);
                        end
                        category_id20{index_exitbw(bco),1}=category_id2i;
                        category_id20_name{index_exitbw(bco),1}=category_id2ii_name;
                    end

                    category_id3i=zeros(length(bnum),1);
                    category_id4i=zeros(length(bnum),1);
                    category_id3i_name=repmat({''},[length(bnum),1]);
                    category_id4i_name=repmat({''},[length(bnum),1]);
                    category_idCi_name=repmat({''},[length(bnum),1]);

                    for qq=1:length(bnum)

                        if opt1.get_score==1
                            itemp=find(id_masknii==bnum(qq));
                            try
                                score0{index_exitbw(bco),1}{qq,1}=data1.(mask_source).cocoP.annotations(itemp).score;
                            catch
                                try
                                    score0{index_exitbw(bco),1}{qq,1}=data1.(mask_source).coco.annotations(itemp).score;
                                catch
                                end
                            end
                        end

                        % bwtt2=zeros(size(data1.(mask_source).atlas_allcell_N));
                        % bwtt2(data1.(mask_source).atlas_allcell_N==data1.(mask_source).cocoP.annotations(itemp).id_masknii)=1;
                        % data1.(mask_source).cocoP.annotations(itemp).id_masknii;
                        % figure(2);imagesc(bwtt2);axis image


                        bwt1=bwt0;bwt1(bwt0~=bnum(qq))=0;bwt1(bwt0==bnum(qq))=1;
                        seg0{index_exitbw(bco),1}{qq,1}=rle_chh(bwt1);

                        % figure(1);imagesc(bwt1);axis image

                        id0ch{index_exitbw(bco),1}(qq,1)=double(bnum(qq))+(index_exitbw(bco))/100000;  % index in + image #
                        if isfield(data1.(select_data),'label')==1
                            idnumtemp=cell2mat(data1.(select_data).label{index_exitbw(bco)}(:,2));
                            n_temp=find(idnumtemp==bnum(qq));
                            %name_temp=[cocostruct.categories(1).supercategory '__' data1.(select_data).label{index_exitbw(bco)}{n_temp,3}];
                            name_temp=[data1.(select_data).label{index_exitbw(bco)}{n_temp,3}];
                            %%%%name_temp=['brain__' data1.(select_data).label{index_exitbw(bco)}{n_temp,3}];
                            [~,ia]=intersect({cocostruct.categories(:).name},{name_temp});


                            category_id3i(qq,1)=cocostruct.categories(ia).id;
                            category_id3i_name{qq,1}=name_temp;

                            if isfield(data1,'atlas_brain')==1;

                                category_idCi_name{qq,:}=data1.(select_data).label{index_exitbw(bco),1}{n_temp,1}(1:end-4);
                                name_temp4=[category_id20_name{index_exitbw(bco),1}{qq,1} '__' data1.(select_data).label{index_exitbw(bco),1}{n_temp,3}];
                                in=find(strcmpi({cocostruct.categories.name},name_temp4)==1);
                                category_id4i(qq,:)=cocostruct.categories(in).id;
                                category_id4i_name{qq,:}=name_temp4;

                            end
                        end


                    end
                    if isfield(data1.(select_data),'label')==1
                        category_id30{index_exitbw(bco),1}=category_id3i;
                        category_id30_name{index_exitbw(bco),1}=category_id3i_name;
                        category_id40{index_exitbw(bco),1}=category_id4i;
                        category_id40_name{index_exitbw(bco),1}=category_id4i_name;
                        category_idC0_name{index_exitbw(bco),1}=category_idCi_name;
                    end

                    switch opt1.case_coco
                        case {'Children_GoldStandard_512x512__train','ChImJroi_DChecked_512x512__train','ArStImJroi_20210812_512x512__train_M'}
                            id0{index_exitbw(bco),1}=image_id0{index_exitbw(bco)}*1000+[1:num_box]'+(coco_ida-1)*100000000;
                        otherwise
                            id0{index_exitbw(bco),1}=image_id0{index_exitbw(bco)}*1000+[1:num_box]';
                    end
                    if mod(bco,200)==0;bco
                        toc
                    end
                end
                id=cell2mat(id0);
                image_id=cell2mat(image_id0);
                bbox=cell2mat(bbox0i_ims);
                area=cell2mat(area0(index_exitbw));
                iscrowd=zeros(length(id),1);
                category_id1=uint64(ones(length(id),1))*cocostruct.categories(1).id;
                category_id1_name=repmat({cocostruct.categories(1).supercategory},[length(id),1]);

                id_masknii=cell2mat(id0ch);
                idxe=find(cellfun(@isempty,id0)==0);
                segmentation=vertcat(seg0{idxe});

                if opt1.get_score==1
                    score=vertcat(score0{idxe});
                end
                category_id2=cell2mat(category_id20);
                category_id2_name=vertcat(category_id20_name{idxe});

                if isfield(data1.(select_data),'label')==1
                    category_id3=cell2mat(category_id30);
                    category_id3_name=vertcat(category_id30_name{idxe});
                    category_id4=cell2mat(category_id40);
                    category_id4_name=vertcat(category_id40_name{idxe});
                    ROI_name=vertcat(category_idC0_name{idxe});

                end


                eval(['category_id=' annotation_id_select ';'])

                try image_id=uint64(image_id);catch;end
                try bbox=double(bbox);catch;end
                try area=double(area);catch;end
                try iscrowd=double(iscrowd);catch;end
                try category_id=uint64(category_id);catch;end
                try id=uint64(id);catch;end
                try category_id1=uint64(category_id1);catch;end
                try category_id2=uint64(category_id2);catch;end
                try category_id3=uint64(category_id3);catch;end
                try category_id4=uint64(category_id4);catch;end
                try N_bbox=double(N_bbox);catch;end

                if opt1.get_score==1
                    score=vertcat(score0{idxe});
                    if isfield(data1.(select_data),'label')==1
                        cocostruct.annotations=table2struct(table(score,image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii, ROI_name,category_id1,category_id1_name,category_id2,category_id2_name,category_id3,category_id3_name,category_id4,category_id4_name))';
                    else
                        cocostruct.annotations=table2struct(table(score,image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id1_name,category_id2,category_id2_name))';
                    end
                else

                    if isfield(data1.(select_data),'score_ims')==1
                        score=data1.(select_data).score_ims;
                        if isfield(data1.(select_data),'label')==1
                            cocostruct.annotations=table2struct(table(score,image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii, ROI_name,category_id1,category_id1_name,category_id2,category_id2_name,category_id3,category_id3_name,category_id4,category_id4_name))';
                        else
                            cocostruct.annotations=table2struct(table(score,image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id1_name,category_id2,category_id2_name))';
                        end
                    else
                        if isfield(data1.(select_data),'label')==1
                            cocostruct.annotations=table2struct(table(image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii, ROI_name, category_id1,category_id1_name,category_id2,category_id2_name,category_id3,category_id3_name,category_id4,category_id4_name))';

                        else
                            cocostruct.annotations=table2struct(table(image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id1_name,category_id2,category_id2_name))';
                        end
                    end
                end
            else
                fprintf(['no train image exist'])
            end

            %check id and bbox and segmentation
            %                 idck=cocostruct.annotations(dd).id_masknii*100000-fix(cocostruct.annotations(dd).id_masknii)*100000
            %                 attemp=squeeze(bw_gt_4d(idck,:,:))
            %                 figure(1);imagesc(attemp(cocostruct.annotations(dd).bbox(2):cocostruct.annotations(dd).bbox(2)+cocostruct.annotations(dd).bbox(4),...
            %                                   cocostruct.annotations(dd).bbox(1):cocostruct.annotations(dd).bbox(1)+cocostruct.annotations(dd).bbox(3)));
            %            M=double(MaskApi.decode(cocostruct.annotations(dd).segmentation));
            %            figure(2);imagesc(M);axis image

        case {'YoloResult','CRBG_wEdge_512x512__result__YOLO_conf_50_100','CRBG_wEdge_512x512shift__result__YOLO_conf_50_100',...
                'CRBG_wEdge_1024x1024__result__YOLO_conf_50_100','CRBG_wEdge_1024x1024shift__result__YOLO_conf_50_100',...
                'noGt_im_512x512__result__YOLO_conf_50_100','noGt_im_512x512shift__result__YOLO_conf_50_100',...
                'noGt_im_1024x1024__result__YOLO_conf_50_100','noGt_im_1024x1024shift__result__YOLO_conf_50_100'}
            train_imsize0=data1.(select_data).train_imsize;
            % coco.image
            file_path={data1.(select_data).file_info.file_path}';
            file_name={data1.(select_data).file_info.file_name}';
            license=ones(length(file_name),1);
            coco_url= cell(length(file_name), 1);coco_url(:) ={''};
            height=[data1.(select_data).file_info.height]';
            width=[data1.(select_data).file_info.width]';
            data_captured= cell(length(file_name), 1);data_captured(:) ={''};
            flickr_url= cell(length(file_name), 1);flickr_url(:) ={''};
            id=[data1.(select_data).file_info.id]';
            cocostruct.images=table2struct(table(license,file_path,file_name,coco_url,height,width,data_captured,flickr_url,id))';
            clear id

            iMid0=[data1.(select_data).file_info.id]';
            tt=1;clear image_id bbox
            category_id1=uint64(ones(size(data1.(select_data).bbox,1),1))*cocostruct.categories(1).id;
            category_id2=uint64(zeros(size(data1.(select_data).bbox,1),1));
            iscrowd=zeros(size(data1.(select_data).bbox,1),1);
            area=zeros(size(data1.(select_data).bbox,1),1);

            yolo_class=repmat({''},size(data1.(select_data).bbox,1),1);  % zeros(size(data1.(select_data).bbox,1),1);

            id=zeros(size(data1.(select_data).bbox,1),1);
            id_masknii=zeros(size(data1.(select_data).bbox,1),1);
            ak=0;
            for ii=1:length(file_name)
                clear bbox_center
                sn=findstr(file_name{ii},'_');
                if length(sn)==1
                    sn=findstr(file_name{ii},'_n');
                    if isempty(sn)==1
                        sn=findstr(file_name{ii},'_s');
                    end
                    sn(1)=sn(1)+1;
                    sn(2)=findstr(file_name{ii},'.');
                end

                % %
                % kk=0;kk2=0;
                % for pp=1:length(data1.(select_data).bbox_ims)
                % kk=kk+size(data1.(select_data).bbox_ims{pp},1);
                % if isempty(data1.(select_data).bbox_ims{pp})~=1
                % kk2=kk2+1;
                % end
                % end


                imId0=str2num(file_name{ii}(sn(1)+1:sn(2)-1));
                if isempty(data1.(select_data).bbox_ims{imId0})~=1
                    num_box=size(data1.(select_data).bbox_ims{imId0},1);
                    image_id(tt:tt+num_box-1,1)=iMid0(ii);%;
                    bbox(tt:tt+num_box-1,:)=data1.(select_data).bbox_ims{imId0};
                    area(tt:tt+num_box-1,:)=[data1.(select_data).bbox_ims{imId0}(:,3).*data1.(select_data).bbox_ims{imId0}(:,4)];
                    if isfield(data1.(select_data),'score_ims')==1
                        score(tt:tt+num_box-1,:)=data1.(select_data).score_ims{imId0};
                    end
                    if isfield(data1.(select_data),'yolo_class0')==1
                        yolo_class(tt:tt+num_box-1,:)=data1.(select_data).yolo_class0{imId0};
                    end
                    %                     bbox_temp=data1.(select_data).bbox_ims{imId0};
                    %                     seg0=[bbox_temp(:,1) bbox_temp(:,2),...
                    %                     bbox_temp(:,1)+bbox_temp(:,3) bbox_temp(:,2),...
                    %                     bbox_temp(:,1)+bbox_temp(:,3) bbox_temp(:,2)+bbox_temp(:,4),...
                    %                     bbox_temp(:,1) bbox_temp(:,2)+bbox_temp(:,4)];
                    %                     seg2= mat2cell(seg0,ones(num_box,1),8);
                    %                     segmentation(tt:tt+num_box-1,:)={seg2};

                    if isfield(data1,'atlas_brain')==1; %check box position in the atlas
                        if ak==0;
                            if isempty(strfind(lower(select_data),'shift'))~=1;sh=2;
                                Rshn=[0 fix(train_imsize0(2)/2) fix(train_imsize0(2)/2) 0]; Dshn=[0 fix(train_imsize0(1)/2) 0 fix(train_imsize0(1)/2)];
                                atlas_brain_sh=circshift(data1.atlas_brain,Dshn(sh),1);atlas_brain_sh=circshift(atlas_brain_sh,Rshn(sh),2);
                            else
                                atlas_brain_sh=data1.atlas_brain;sh=1;
                            end
                            atb_4d=imsplit4d(atlas_brain_sh,train_imsize0);ak=1;
                        end
                        at_s=squeeze(atb_4d(imId0,:,:));
                        bbox_temp=data1.(select_data).bbox_ims{imId0};

                        bbox_center=fix([bbox_temp(:,1)+bbox_temp(:,3)/2 bbox_temp(:,2)+bbox_temp(:,4)/2]);%x,y
                        ind = sub2ind(size(at_s),bbox_center(:,2),bbox_center(:,1));%y,x
                        num_at=at_s(ind);
                        id_at=unique(num_at);
                        ccc=data1.atlas_table.id;
                        category_id2i=zeros(length(ind),1);

                        for aa=1:length(id_at)
                            index_at(aa) = find(ccc == id_at(aa));
                            idna=find(num_at==id_at(aa));
                            in=find(strcmpi({cocostruct.categories.name},data1.atlas_table.atlas_name{index_at(aa)})==1);
                            if isempty(in)==1
                                % fprintf('no atlas \n');
                                in=find(strcmpi({cocostruct.categories.name},'microglia')==1);
                            end
                        end
                        category_id2(tt:tt+num_box-1,:)=category_id2i;
                    end
                    id(tt:tt+num_box-1,1)=(image_id(tt:tt+num_box-1,1)+uint64(ones(num_box,1))*50000)*1000+uint64([1:num_box])';
                    id_masknii(tt:tt+num_box-1,1)=(image_id(tt:tt+num_box-1,1)-fix(image_id(tt:tt+num_box-1,1)/10000)*10000)*1000000+uint64([1:num_box])';
                    tt=length(image_id)+1;
                end
            end

            eval(['category_id=' annotation_id_select ';'])


            try image_id=uint64(image_id);catch;end
            try bbox=double(bbox);catch;end
            try area=double(area);catch;end
            try iscrowd=double(iscrowd);catch;end
            try category_id=uint64(category_id);catch;end
            try id=uint64(id);catch;end
            try category_id1=uint64(category_id1);catch;end
            try category_id2=uint64(category_id2);catch;end
            try category_id3=uint64(category_id3);catch;end
            try category_id4=uint64(category_id4);catch;end
            try N_bbox=double(N_bbox);catch;end

            if isfield(data1.(select_data),'score_ims')==1
                if isfield(data1.(select_data),'yolo_class')==1
                    cocostruct.annotations=table2struct(table(yolo_class, score,image_id,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id2))';
                else
                    cocostruct.annotations=table2struct(table(score,image_id,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id2))';
                end

            else
                cocostruct.annotations=table2struct(table(image_id,bbox,area,iscrowd,category_id,id,id_masknii, category_id1,category_id2))';
            end


        case {'LargeIm','masks_CRBG','CRBG_wEdge_512x512__result__YOLO_conf_50_100_M','CRBG_wEdge_1024x1024__result__YOLO_conf_50_100_M',...
                'CRBG_UnetOneCell_256x256__result__UNET_M','Yolo512_Unet_256x256__result__UNET_M','Children_GoldStandard_512x512__train_M','ChImJroi_DChecked_512x512__train_M',...
                'CRBG_UnetOneCell_256x256__result__UNET_ML','Yolo512_Unet_256x256__result__UNET_ML','CRBG_UnetOneCell_256x256__result__UNET_MS','Yolo512_Unet_256x256__result__UNET_MS'...
                'CRBG_UnetOneCell_256x256__result__UNET_MO','Yolo512_Unet_256x256__result__UNET_MO',...
                'noGt_im_512x512__result__YOLO_conf_50_100_M'};
            %% coco.image
            file_path={data1.info.filepath_image};
            file_name={[data1.info.filename_image(1:end-4) '_gray.png']};
            %file_name1={[data1.info.filename_image(1:end-4) '.png']};
            license=ones(length(file_name),1);
            coco_url= cell(length(file_name), 1);coco_url(:) ={''};
            height=size(data1.im0,1);
            width=size(data1.im0,2);
            data_captured= cell(length(file_name), 1);data_captured(:) ={''};
            flickr_url= cell(length(file_name), 1);flickr_url(:) ={''};
            id=data1.info.imId;
            cocostruct.images=table2struct(table(license,file_path,file_name,coco_url,height,width,data_captured,flickr_url,id))';
            clear id

            %% coco.annotations
            if isfield(data1.(select_data),'atlas_allcell_N')
                stats=regionprops(data1.(select_data).atlas_allcell_N,'BoundingBox','Area');
                bbox=ceil(cell2mat({stats(:).BoundingBox}'));
                if isfield(data1.(select_data),'bbox')~=1
                    data1.(select_data).bbox=bbox;
                end
                area=cell2mat({stats(:).Area}');
            else
                bbox=data1.(select_data).bbox;
                area=bbox(:,3).*bbox(:,4);
            end
            image_id=repmat(data1.info.imId,size(bbox,1),1);
            id=zeros(length(image_id),1);
            iscrowd=zeros(size(bbox,1),1);
            %xxx=unique(data1.(select_data).atlas_allcell_N);xxx=xxx(xxx~=0)
            if isfield(data1.(select_data),'score')==1
                score=data1.(select_data).score;
            else
                score=ones(length(area),1);
            end
            switch opt1.case_coco
                case 'masks_CRBG';id0=(image_id)*10000000;opt1.segmentation=1;  %+[1:length(image_id)]';
                case {'CRBG_wEdge_512x512__result__YOLO_conf_50_100_M','noGt_im_512x512__result__YOLO_conf_50_100_M'};id0=(image_id+119)*100*100000+[1:length(image_id)]';opt1.segmentation=0;
                case 'CRBG_wEdge_1024x1024__result__YOLO_conf_50_100_M';id0=(image_id+139)*100*100000+[1:length(image_id)]';opt1.segmentation=0;
                case {'CRBG_UnetOneCell_256x256__result__UNET_M','CRBG_UnetOneCell_256x256__result__UNET_ML','CRBG_UnetOneCell_256x256__result__UNET_MS','CRBG_UnetOneCell_256x256__result__UNET_MO'};id0=(image_id+209)*100*100000;opt1.segmentation=1;
                case {'Yolo512_Unet_256x256__result__UNET_M','Yolo512_Unet_256x256__result__UNET_ML','Yolo512_Unet_256x256__result__UNET_MS','Yolo512_Unet_256x256__result__UNET_MO'};id0=(image_id+219)*100*100000;opt1.segmentation=1;
                case {'Children_GoldStandard_512x512__train_M','ChImJroi_DChecked_512x512__train_M'};id0=(image_id+109+coco_ida*10)*100*100000;
                    opt1.segmentation=1;
                    bw_gt_4d=imsplit4d(data1.(select_data).atlas_allcell_N,[512 512]);
                    num_exitbw=sum(sum(bw_gt_4d,2),3);index_exitbw=find(num_exitbw~=0);
                    for dd=1:length(index_exitbw)
                        nnum{dd,1}=unique(bw_gt_4d(index_exitbw(dd),:,:));nnum{dd,1}=double(nnum{dd,1}(nnum{dd,1}~=0));
                        nnum{dd,2}=min(nnum{dd});
                        nnum{dd,3}=max(nnum{dd});
                        nnum{dd,4}=index_exitbw(dd);
                    end
                    nnumsort=sortrows(nnum,2);
                otherwise
                    id0=(image_id)*10000000;
                    if opt1.segmentation==2
                        id0=(image_id+159)*100*100000;
                        bw_gt_4d=imsplit4d(data1.(select_data).atlas_allcell_N,[512 512]);
                        num_exitbw=sum(sum(bw_gt_4d,2),3);index_exitbw=find(num_exitbw~=0);
                        for dd=1:length(index_exitbw)
                            nnum{dd,1}=unique(bw_gt_4d(index_exitbw(dd),:,:));nnum{dd,1}=double(nnum{dd,1}(nnum{dd,1}~=0));
                            nnum{dd,2}=min(nnum{dd});
                            nnum{dd,3}=max(nnum{dd});
                            nnum{dd,4}=index_exitbw(dd);
                        end
                        nnumsort=sortrows(nnum,2);
                        %                       for ss=1:size(nnumsort,1)
                        %                           id_masknii0(nnumsort{ss,2}:nnumsort{ss,3},1)=nnumsort{ss,4}/100000;
                        %                       end
                    end
            end

            if opt1.segmentation>=1
                segmentation=cell(size(bbox,1),1);
                qnum=unique(data1.(select_data).atlas_allcell_N);qnum=qnum(qnum~=0);
                bsize0=size(data1.(select_data).atlas_allcell_N);
                switch opt1.case_coco
                    case {'Children_GoldStandard_512x512__train_M','ChImJroi_DChecked_512x512__train_M','ArStImJroi_20210812_512x512__train_M'}
                        tt1=1;clear id_masknii
                        for ss=1:size(nnumsort,1)
                            for dd=1:length(nnumsort{ss,1})
                                id_masknii(tt1,1)=double(nnumsort{ss,1}(dd))+double(nnumsort{ss,4})/100000;
                                %id_masknii(tt1,1)=double(nnumsort{ss,1}(dd))+double(nnumsort{ss,4})*1000000;
                                tt1=tt1+1;
                            end
                        end
                    otherwise
                        if opt1.segmentation==2
                            tt1=1;clear id_masknii
                            for ss=1:size(nnumsort,1)
                                for dd=1:length(nnumsort{ss,1})
                                    id_masknii(tt1,1)=double(nnumsort{ss,1}(dd))+double(nnumsort{ss,4})*1000000;
                                    %id_masknii(tt1,1)=double(nnumsort{ss,1}(dd))+double(nnumsort{ss,4})/100000;
                                    tt1=tt1+1;
                                end
                            end

                        else
                            id_masknii=double(qnum);
                        end
                end



                for qq=1:length(qnum)

                    bwmask0=data1.(select_data).atlas_allcell_N(bbox(qnum(qq),2)-1:bbox(qnum(qq),2)+bbox(qnum(qq),4),bbox(qnum(qq),1)-1:bbox(qnum(qq),1)+bbox(qnum(qq),3));
                    bwmask0(bwmask0~=qnum(qq))=0; sizb0=size(bwmask0);
                    % get +1pixel small mask image from bbox to avoid "1" on the edge
                    bwmask0(bwmask0==qnum(qq))=1;
                    seg0=rle_chh(bwmask0); %figure(1);subplot(1,2,1);imagesc(bwmask0);axis image
                    % increase 1 pixel on  each side to get the index of changing encoding number of RLE
                    bwmask1=zeros(size(bwmask0)+2);
                    bwmask1(2:size(bwmask0,1)+1,2:size(bwmask0,2)+1)=bwmask0;
                    seg1=rle_chh(bwmask1);%figure(1);subplot(1,2,2);imagesc(bwmask1);axis image
                    bboxt=[bbox(qnum(qq),1)-1,bbox(qnum(qq),2)-1, bbox(qnum(qq),3)+2, bbox(qnum(qq),4)+2];% get new box corrdinate for bwmask0
                    segchange=find(seg0.counts~=seg1.counts); %find the difference between two small mask
                    segf.counts=seg0.counts;
                    segf.counts(segchange)= seg0.counts(segchange)+bboxt(2)-1+(bsize0(1)-bboxt(2)-bboxt(4)+1); % calculate the new RLE encoding depend on image size
                    segf.counts(segchange(1))= (bboxt(1))*bsize0(1)+seg0.counts(segchange(1))+bboxt(2)-1-bboxt(4); % change of 1st RLE number
                    segf.counts(end)=seg0.counts(end)+(bsize0(1)-bboxt(2)-bboxt(4)+1)+(1+bsize0(2)-(bboxt(1)+ bboxt(3)-1))*bsize0(1)-bboxt(4); % change of last RLE number
                    segdiff=(seg1.counts-seg0.counts)-2; % find the zero line in column matrix in RLE encoding
                    idz0=find(segdiff>0);
                    if length(idz0)>=3;nL=segdiff(idz0)./2;idz=idz0(2:end-1);segf.counts(idz)=seg0.counts(idz)+(nL(2:end-1)+1)*(bsize0(1)-sizb0(1));end
                    segmentation{qnum(qq)}=segf;segmentation{qnum(qq)}.size=bsize0;

                    %[~,ia]=setdiff(segmentation{qnum(qq)}.counts,seg_ch{qnum(qq)}.counts)
                    %if isempty(setdiff(segmentation{qnum(qq)}.counts,seg_ch{qnum(qq)}.counts))~=1;wrong(qq)=1;end
                end %200 for 0.253313 seconds.
                % for checking RLE encoding from small image
                %seg_ch=cell(length(qnum),1);
                %for qq=1:200;if mod(qq,20)==1;tic;end
                %bwmask0=uint8(false(size(data1.(select_data).atlas_allcell_N)));bwmask0(data1.(select_data).atlas_allcell_N==qnum(qq))=1;seg_ch{qnum(qq)}=rle_chh(bwmask0);
                %if mod(qq,20)==0;qq;toc
                %end;end% 243.255072 seconds.
                %wrong=zeros(length(qnum),1);
                %           for % compare with coco api
                %           qq=1:200;bwmask0=uint8(false(size(data1.(select_data).atlas_allcell_N)));bwmask0(data1.(select_data).atlas_allcell_N==qnum(qq))=1;
                %                seg_ch=MaskApi.encode(bwmask0);end % 92.495255 seconds.
                %                 bbox=bbox(qnum,:);
                %                 segmentation=segmentation(qnum);
                %                 image_id=image_id(qnum);
                %                 area=area(qnum);
                %                 iscrowd=iscrowd(qnum);
                % id=id0(qnum)+double(qnum);
            else
                id_masknii=[1:length(image_id)]';
                qnum=[1:size(bbox,1)]';
            end


            category_id1=uint64(ones(size(bbox,1),1))*cocostruct.categories(1).id;
            category_id1_name=repmat({cocostruct.categories(1).supercategory},[size(bbox,1),1]);
            category_id2=uint64(zeros(size(bbox,1),1));
            category_id2_name=repmat({''},[size(bbox,1),1]);



            if isfield(data1,'atlas_brain')==1;
                bbox_center=fix([bbox(:,1)+bbox(:,3)/2 bbox(:,2)+bbox(:,4)/2]./abs(opt1.Low_res));%x,y
                %bbox_center=fix([bbox(:,1)+bbox(:,3)/2 bbox(:,2)+bbox(:,4)/2]);%x,y
                ind = sub2ind(size(data1.atlas_brain),bbox_center(:,2),bbox_center(:,1));%y,x
                num_at=data1.atlas_brain(ind);
                id_at=unique(num_at);
                index_at=zeros(length(id_at),1);
                ccc=data1.atlas_table.id(:);
                for aa=1:length(id_at)
                    %index_at(aa) = find([ccc{:}] == id_at(aa));
                    index_at(aa) = find(ccc == id_at(aa));

                    %in=find(strcmpi({cocostruct.categories.name},data1.atlas_table{index_at(aa),1})==1);
                    in=find(strcmpi({cocostruct.categories.name},data1.atlas_table.atlas_name{index_at(aa)})==1);
                    %data1.atlas_table.atlas_name{index_at(aa),1}
                    if strcmpi(data1.atlas_table.atlas_name{index_at(aa),1},'brain')==1
                        if isempty(in)==1
                            in=find(strcmpi({cocostruct.categories.name},'microglia')==1);
                        end
                    end
                    %category_id2c(idna,:)=cocostruct.categories(in).id;
                    if isempty(in)~=1
                        category_id2(num_at==id_at(aa),:)=cocostruct.categories(in).id;
                        idd=find(num_at==id_at(aa));
                        category_id2_name(idd,:)=repmat(data1.atlas_table.atlas_name(index_at(aa)),[length(idd),1]);


                        %category_id2_name(num_at==id_at(aa),:)=repmat(data1.atlas_table(index_at(aa),1),[length(in),1]);
                    end
                end
            end

            if isfield(data1.(select_data),'label')==1
                idnumtemp=cell2mat(data1.(select_data).label(:,2));
                category_id3=zeros(size(bbox,1),1);
                category_id3_name=repmat({''},[size(bbox,1),1]);
                category_id4=zeros(size(bbox,1),1);
                category_id4_name=repmat({''},[size(bbox,1),1]);
                category_idC_name=repmat({''},[size(bbox,1),1]);

                for ll=1:size(bbox,1)

                    n_temp=find(idnumtemp==ll);
                    name_temp=[cocostruct.categories(1).supercategory '__' data1.(select_data).label{n_temp,3}];
                    [~,ia]=intersect({cocostruct.categories(:).name},{name_temp});
                    if isempty(ia)==1
                        %%%%%                        name_temp=['brain__' data1.(select_data).label{n_temp,3}];
                        name_temp=[data1.(select_data).label{n_temp,3}];
                        [~,ia]=intersect({cocostruct.categories(:).name},{name_temp});
                    end

                    category_id3_name{ll}=name_temp;
                    category_id3(ll)=cocostruct.categories(ia).id;

                    if isfield(data1,'atlas_brain')==1;
                        %idna=find(num_at==id_at(aa));
                        name_temp4=[category_id2_name{ll} '__' data1.(select_data).label{n_temp,3}];
                        in=find(strcmpi({cocostruct.categories.name},name_temp4)==1);
                        %category_id2c(idna,:)=cocostruct.categories(in).id;
                        category_id4(ll,:)=cocostruct.categories(in).id;
                        category_id4_name{ll,:}=name_temp4;
                        category_idC_name{ll,:}=data1.(select_data).label{n_temp,1}(1:end-4);
                    end
                end
            end
            if isfield(data1.(select_data),'yolo_class')==1
                yolo_class=data1.(select_data).yolo_class;
            end

            eval(['category_id=' annotation_id_select ';'])
            % remove empty
            bbox=bbox(qnum,:);
            image_id=image_id(qnum);
            area=area(qnum);
            iscrowd=iscrowd(qnum);
            id=id0(qnum)+uint64(qnum);

            category_id=category_id(qnum);
            category_id1=category_id1(qnum);category_id1_name=category_id1_name(qnum);
            category_id2=category_id2(qnum);category_id2_name=category_id2_name(qnum);
            if isfield(data1.(select_data),'label')==1
                category_id3=category_id3(qnum);category_id3_name=category_id3_name(qnum);
                category_id4=category_id4(qnum);category_id4_name=category_id4_name(qnum);
                ROI_name=category_idC_name(qnum);
            end

            try image_id=uint64(image_id);catch;end
            try bbox=double(bbox);catch;end
            try area=double(area);catch;end
            try iscrowd=double(iscrowd);catch;end
            try category_id=uint64(category_id);catch;end
            try id=uint64(id);catch;end
            try category_id1=uint64(category_id1);catch;end
            try category_id2=uint64(category_id2);catch;end
            try category_id3=uint64(category_id3);catch;end
            try category_id4=uint64(category_id4);catch;end
            try N_bbox=double(N_bbox);catch;end

            if opt1.segmentation>=1
                segmentation=segmentation(qnum);

                if isfield(data1.(select_data),'score')==1
                    score=score(qnum);
                    if isfield(data1.(select_data),'label')==1
                        if isfield(data1.(select_data),'yolo_class')==1
                            anntable=table(yolo_class,score,image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii,ROI_name,category_id1,category_id1_name,category_id2,category_id2_name,category_id3,category_id3_name,category_id4,category_id4_name);
                        else
                            anntable=table(score,image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii,ROI_name,category_id1,category_id1_name,category_id2,category_id2_name,category_id3,category_id3_name,category_id4,category_id4_name);
                        end
                    else
                        if isfield(data1.(select_data),'yolo_class')==1
                            anntable=table(yolo_class,score,image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii,category_id1,category_id1_name,category_id2,category_id2_name);
                        else
                            anntable=table(score,image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii,category_id1,category_id1_name,category_id2,category_id2_name);
                        end
                    end




                    %anntable=sortrows(anntable,{'bbox'},{'ascend'});
                    cocostruct.annotations=table2struct(anntable)';
                else
                    if isfield(data1.(select_data),'label')==1
                        anntable=table(image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii,ROI_name,category_id1,category_id1_name,category_id2,category_id2_name,category_id3,category_id3_name,category_id4,category_id4_name);
                    else
                        anntable=table(image_id,segmentation,bbox,area,iscrowd,category_id,id,id_masknii,category_id1,category_id1_name,category_id2,category_id2_name);
                    end
                    %anntable=sortrows(anntable,{'bbox'},{'ascend'});
                    cocostruct.annotations=table2struct(anntable)';
                end
            else
                if isfield(data1.(select_data),'score')==1
                    if isfield(data1.(select_data),'label')==1
                        if isfield(data1.(select_data),'yolo_class')==1
                            anntable=table(yolo_class,score,image_id,bbox,area,iscrowd,category_id,id,id_masknii,category_idC_name,category_id1,category_id1_name,category_id2,category_id2_name,category_id3,category_id3_name,category_id4,category_id4_name);

                        else
                            anntable=table(score,image_id,bbox,area,iscrowd,category_id,id,id_masknii,category_idC_name,category_id1,category_id1_name,category_id2,category_id2_name,category_id3,category_id3_name,category_id4,category_id4_name);
                        end
                    else
                        if isfield(data1.(select_data),'yolo_class')==1
                            anntable=table(yolo_class,score,image_id,bbox,area,iscrowd,category_id,id,id_masknii,category_id1,category_id1_name,category_id2,category_id2_name);

                        else
                            anntable=table(score,image_id,bbox,area,iscrowd,category_id,id,id_masknii,category_id1,category_id1_name,category_id2,category_id2_name);
                        end
                    end
                    %anntable=sortrows(anntable,{'bbox'},{'ascend'});

                    cocostruct.annotations=table2struct(anntable)';

                else
                    if isfield(data1.(select_data),'label')==1
                        anntable=table(image_id,bbox,area,iscrowd,category_id,id,id_masknii,category_idC_name,category_id1,category_id1_name,category_id2,category_id2_name,category_id3,category_id3_name,category_id4,category_id4_name);
                    else
                        anntable=table(image_id,bbox,area,iscrowd,category_id,id,id_masknii,category_id1,category_id1_name,category_id2,category_id2_name);
                    end
                    %anntable=sortrows(anntable,{'bbox'},{'ascend'});
                    cocostruct.annotations=table2struct(anntable)';
                end
            end

            %            dd=72; %check id and bbox and segmentation
            %             idck=cocostruct.annotations(dd).id_masknii*100000-fix(cocostruct.annotations(dd).id_masknii)*100000
            %             figure(1);imagesc(data1.(select_data).atlas_allcell_N(cocostruct.annotations(dd).bbox(2):cocostruct.annotations(dd).bbox(2)+cocostruct.annotations(dd).bbox(4),...
            %                 cocostruct.annotations(dd).bbox(1):cocostruct.annotations(dd).bbox(1)+cocostruct.annotations(dd).bbox(3)));axis image
            %             M=double(MaskApi.decode(cocostruct.annotations(dd).segmentation));
            %             figure(2);imagesc(M);axis image


        otherwise
            fprintf(['no data \n'])
            wrong
            return
    end
end





