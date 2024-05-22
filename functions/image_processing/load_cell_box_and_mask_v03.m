function data1=load_cell_box_and_mask_v03(data1,flag,dispfig,varargin)
% (Dp2) data1=load_cell_box_and_mask_v03(data1,flag,dispfig,varargin)
%     get cell bounding box and segment mask
%{
    Input:
        data1.info.filepath_image = 'H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\';
        data1.info.folder_mat = 'matlab_rule_base_mask';
        data1.info.filename_image = 'CR1 slide 10.tif'
        flag.load_clean_rule_base_groundtruth = 1 % load or get rule_base_groundtruth
        flag.get_rule_base~=1; copy old 'cellatlas_f01.mat' from filepath_old0 if exist 
            ex: 'H:\Expdata\HU_William\IHC\data1\CR1 slide 10\matlab_rule_base_mask\cellatlas_f01.mat'
        flag.sort_cell==1; load 'cellatlas_f01.mat' from [data1.info.filepath_image data1.info.folder_mat]
            ex: 'F:\Expdata\HU_William\IHC\data2\CR1\CR1 slide 10\matlab_rule_base_mask\cellatlas_f01.mat'
        flag.sort_cell==2; % load 'cellatlas_f02.mat' from [data1.info.filepath_image data1.info.folder_mat]
        flag.load_URBG=1;  % load unclean rule base mask into data1.masks_URBG
        varargin{1} = filepath_old0 % not used
        varargin{2} = mpara_getbox  % from (P1) parameters_Get_cell_box_optical_v14.m
        varargin{3} = mpara_getmask % from (P2) parameters_Get_cell_mask_optical_v14.m
        varargin{4} = size_box2 % bounding box size: [256, 256]
    Output:
        data1.masks_CRBG.atlas_allcellsort  % cell masks in atlas form
        data1.masks_CRBG.bb                 % old index for create cell masks
        data1.masks_CRBG.bbmask2            % masks for individual cells
        data1.masks_CRBG.bbox2              % bounding box on original image corrdinates
        data1.masks_CRBG.linearIndsort      % sort index to old index before merged masks    
        data1.masks_URBG                    % unclearn rule base masks
    Save files
        flag.data_clean=1; % manual clean rule base mask 1st time, save to bwboxAll_M01.mat
                       =2; % manual clean rule base mask 2nd time, save to bwboxAll_M02.mat
                           in [data1.info.filepath_image data1.info.folder_mat] ex: 'H:\Expdata\HU_William\IHC\data1\CR1 slide 10\matlab_rule_base_mask
       'H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\matlab_rule_base_mask\cellatlas_f01.mat'
    Functions: (Dp2-1),(Dp2-1-1),(Dp2-1-2),(Dp2-1-2-1),(Dp2-1-2-1-1),
               (Dp2-1-2-1-2),(Dp2-1-3),(Dp2-1-4),(Dp2-1-4-1),(Dp2-1-5),(Dp2-2)
%}


if isempty(varargin)~=1
    if length(varargin)==1
        filepath_old0=varargin{1};
    else
        filepath_old0=varargin{1};
        mpara_getbox=varargin{2};
        mpara_getmask=varargin{3};
        size_box2=varargin{4};
    end
end



filepath_mat=[data1.info.filepath_image data1.info.folder_mat];
if flag.load_clean_rule_base_groundtruth==1 || flag.get_rule_base~=0% or get from rule base mask from get_rule_base_groundtruth_v02.m
    %if ff>2;flag.sort_cell=0;end
    mpara_manual.save_cell_atlas=[filepath_mat filesep 'cellatlas_f01.mat']; % sorted clean rule base mask
    
    if flag.get_rule_base~=1 % get old data from filepath_old0 if exist
        if ~exist(mpara_manual.save_cell_atlas,'file');
            file_old=[filepath_old0 data1.info.filename_image(1:end-4) filesep data1.info.folder_mat filesep 'cellatlas_f01.mat'];
            if exist(file_old,'file');copyfile(file_old,mpara_manual.save_cell_atlas);end;end
    end
    
    if flag.sort_cell==1;
        mpara_manual.save_cell_atlas=[filepath_mat filesep 'cellatlas_f01.mat'];
    elseif flag.sort_cell==2;
        mpara_manual.save_cell_atlas=[filepath_mat filesep 'cellatlas_f02.mat'];
    end
          
    if flag.get_rule_base~=1
        if exist(mpara_manual.save_cell_atlas,'file')~=0; % clean sort groundtruth: "cellatlas_f01"
            data1.masks_CRBG=load(mpara_manual.save_cell_atlas);
            if dispfig==1
               cmap=parula(max(data1.masks_CRBG.atlas_allcellsort(:)));
               imF1 = labeloverlay(data1.im0gray,data1.masks_CRBG.atlas_allcellsort,'Colormap',cmap,'Transparency',0.7);
               figure(10701);imshow(imF1);set(gcf,'color','w');axis image
            end
            %                     imwrite(data1.im0,[data1.info.filepath_output filesep data1.info.imat_name '.png']);
            %                     imwrite(imF1,[data1.info.filepath_output filesep data1.info.imat_name '_Im_masks.png']);
            %                     imwrite(data1.masks_CRBG.atlas_allcellsort,[data1.info.filepath_output filesep data1.info.imat_name '_masks.png']);
        else
            mpara_manual.save_temp_file=[filepath_mat filesep 'bwboxAll_M01.mat']; % clean-01
            if ~exist(mpara_manual.save_temp_file,'file');file_old=[filepath_old0 data1.info.filename_image(1:end-4) filesep data1.info.folder_mat filesep 'bwboxAll_M01.mat'];
                if exist(file_old,'file');copyfile(file_old,mpara_manual.save_temp_file);end;end
            if exist(mpara_manual.save_temp_file,'file')~=0
                masks_usCRBG=load(mpara_manual.save_temp_file); % load unsort clean rule base mask
                % %figure(1);imagesc(masks_usCRBG.atlas_allcellM);
                % sort unsort clean rule base mask and save into 'cellatlas_f01.mat'
                data1.masks_CRBG=sortatlas2box_v2(masks_usCRBG.atlas_allcellM,size_box2,mpara_manual);
            else % get unclean rule base groundtruth from rule or loading from 'bwboxAll.mat'
                file_old=[filepath_old0 data1.info.filename_image(1:end-4) filesep data1.info.folder_mat];
                filename_bwboxAll='bwboxAll.mat';
                if ~exist([filepath_mat filesep filename_bwboxAll],'file')
                    data1=get_rule_base_groundtruth_v02(data1,data1.info,mpara_getbox,mpara_getmask,file_old,size_box2,flag);
                else
                    data1.masks=load([filepath_mat filesep filename_bwboxAll]);flag_exist_old_data=1;
                end
                data1.masks_CRBG=data1.masks; % asign unclean mask to clean mask for next step
                %data1=rmfield(data1,'masks');
            end
            if isfield(data1.masks_CRBG,'atlas_allcellsort')==1
                cmap=parula(max(data1.masks_CRBG.atlas_allcellsort(:)));imsize=size(data1.masks_CRBG.atlas_allcellsort); dd=12542;
                [bboxS,corrd_on_image,corrd_on_smallbox]=shiftbox2imsize(data1.masks_CRBG.bbox2,imsize);
                bwtemp0(corrd_on_smallbox(dd,1):corrd_on_smallbox(dd,2),corrd_on_smallbox(dd,3):corrd_on_smallbox(dd,4))=data1.masks_CRBG.atlas_allcellsort(corrd_on_image(dd,1):corrd_on_image(dd,2),corrd_on_image(dd,3):corrd_on_image(dd,4));
                bwtemp=uint16(false(size(bwtemp0)));bwtemp(bwtemp0==dd)=1;bwtemp(bwtemp0~=dd)=0;bwtemp2=squeeze(data1.masks_CRBG.bbmask2(dd,:,:));
                ims1(corrd_on_smallbox(dd,1):corrd_on_smallbox(dd,2),corrd_on_smallbox(dd,3):corrd_on_smallbox(dd,4))=data1.im0gray(corrd_on_image(dd,1):corrd_on_image(dd,2),corrd_on_image(dd,3):corrd_on_image(dd,4));
                if dispfig==1
                    %figure(10711);imagesc_bw(ims1,[0 255],'gray',255,{bwtemp,bwtemp2},{'b','g','r'},[2 -2],-1);
                    size(data1.im0gray),   size(data1.masks_CRBG.atlas_allcellsort)
                    imF1 = labeloverlay(data1.im0gray,data1.masks_CRBG.atlas_allcellsort,'Colormap',cmap,'Transparency',0.7);
                    figure(10701);imshow(imF1);set(gcf,'color','w');axis image;title('unclean rule base mask')
                end
            end
        end
    else
        if flag.load_clean_rule_base_groundtruth==1
            if isfield(data1,'masks_CRBG')~=1
                if exist(mpara_manual.save_cell_atlas,'file')~=0;
                    data1.masks_CRBG=load(mpara_manual.save_cell_atlas);
                else 
                    fprintf('no clean data (cellatlas_f02.mat)\n')
                end
            end

        else
            if exist([filepath_mat filesep 'bwboxAll.mat'],'file')
                masks=load([filepath_mat filesep 'bwboxAll.mat']);
                data1.masks=masks;
            else
                data1=get_rule_base_groundtruth_v02(data1,data1.info,mpara_getbox,mpara_getmask,filepath_old0,size_box2,flag);
            end
        end
    end
    
    
    
    if flag.data_clean==1; % clean mask from rule base
        mpara_manual.save_temp_file=[filepath_mat filesep 'bwboxAll_M01.mat'];
        %%%o if ~exist(mpara_manual.save_temp_file,'file');file_old=[filepath_old0 data1.info.filename_image(1:end-4) filesep data1.info.folder_mat filesep 'bwboxAll_M01.mat'];if exist(file_old,'file');copyfile(file_old,mpara_manual.save_temp_file);end;end
        %data1.masks=data1.masks_CRBG;
        masks_usCRBG=manual_correction_v01(data1.im0gray,data1.masks.atlas_allcellsort,data1.masks.bbox2,mpara_manual,1);
        masks_usCRBG=load(mpara_manual.save_temp_file);
        cmap=parula(max(masks_usCRBG.atlas_allcellM(:)));imF1 = labeloverlay(data1.im0gray,masks_usCRBG.atlas_allcellM,'Colormap',cmap,'Transparency',0.7);
        %figure(10603);imagesc(imF1);set(gcf,'color','w');axis image;axis off
    elseif flag.data_clean==2;
        %%%  clean 2-1 
        if isfield(data1,'masks_CRBG')==1
            data1.masks_CRBG0=data1.masks_CRBG;data1=rmfield(data1,'masks_CRBG');
        else;data1.masks_CRBG0=data1.masks;data1=rmfield(data1,'masks');
        end
        
        
        measurements = regionprops(data1.masks_CRBG0.atlas_allcellsort, 'Area','BoundingBox');
        areat=[measurements.Area]'; id1=find(areat<200 & areat>0);
        bboxt=ceil(cell2mat({measurements.BoundingBox}'));id2=find(bboxt(:,3)>150);id3=find(bboxt(:,4)>150);
        mpara_manual.flag_assign_num=0; mpara_manual.bn0=[10000];% assigned bwbox number for clean
        
        close all %33121 33964 36496 45854
        mpara_manual.save_temp_file=[filepath_mat filesep 'bwboxAll_M02.mat'];
        masks_usCRBG=manual_correction_v01(data1.im0gray,data1.masks_CRBG0.atlas_allcellsort,data1.masks_CRBG0.bbox2,mpara_manual,1);
        
        measurements = regionprops(masks_usCRBG.atlas_allcellM, 'Area','BoundingBox');areat=[measurements.Area]'; id1=find(areat<150 & areat>0);
        bboxt=ceil(cell2mat({measurements.BoundingBox}'));
        bboxt2(:,1)=bboxt(:,1)+fix(bboxt(:,3)/2)-128; bboxt2(:,2)=bboxt(:,2)+fix(bboxt(:,4)/2)-128;bboxt2(:,3)=256;bboxt2(:,4)=256;
        %%%  clean 2-2
        
%         mpara_manual.save_temp_file=[filepath_mat filesep 'bwboxAll_M02b.mat'];
% 
%         masks_usCRBG02b=manual_correction_v01(data1.im0gray,masks_usCRBG.atlas_allcellM,masks_usCRBG.bbox1add,mpara_manual,1);
%         %masks_usCRBG02b=load(mpara_manual.save_temp_file);
%         data1=rmfield(data1,'masks_CRBG0');
        


        if dispfig==1
            measurements = regionprops(masks_usCRBG.atlas_allcellM, 'Area','BoundingBox');areat=[measurements.Area]'; id1=find(areat<50 & areat>0);
            cmap=parula(max(masks_usCRBG.atlas_allcellM(:)));imF1 = labeloverlay(data1.im0gray,masks_usCRBG.atlas_allcellM,'Colormap',cmap,'Transparency',0.7);
            figure(10603);imagesc(imF1);set(gcf,'color','w');axis image;axis off
        end

    

    end
    if flag.data_clean~=0 % sort mask and save "cellatlas_f02.mat" or "cellatlas_f01.mat"
        if flag.sort_cell==1;mpara_manual.save_cell_atlas=[filepath_mat filesep 'cellatlas_f01.mat'];
        elseif flag.sort_cell==2;mpara_manual.save_cell_atlas=[filepath_mat filesep 'cellatlas_f02.mat'];end

        if isfield(data1,'masks_CRBG')~=1
            if exist(mpara_manual.save_cell_atlas,'file')~=0;data1.masks_CRBG=load(mpara_manual.save_cell_atlas);
            else
                data1.masks_CRBG=sortatlas2box_v2(masks_usCRBG.atlas_allcellM,size_box2,mpara_manual);
            end
        end
        %else;
    end
    
    %figure(10601);imagesc(data1.masks_CRBG.atlas_allcellsort)
    if dispfig==1
        cmap=parula(max(data1.masks_CRBG.atlas_allcellsort(:)));
        imF1 = labeloverlay(data1.im0gray,data1.masks_CRBG.atlas_allcellsort,'Colormap',cmap,'Transparency',0.7);
        figure(10602);imagesc(imF1);set(gcf,'color','w');axis image
    end
    %length(unique(data1.masks_CRBG.atlas_allcellsort))
end
if isfield(flag,'load_URBG')==1
    if flag.load_URBG==1
          file_old=[filepath_old0 data1.info.filename_image(1:end-4) filesep data1.info.folder_mat];
          data0=get_rule_base_groundtruth_v02(data1,data1.info,mpara_getbox,mpara_getmask,file_old,size_box2,flag);
          data1.masks_URBG=data0.masks;
    end
end