function data1=load_Atlas_v04(data1,DataSetInfo,flag,size_zpe,dispfig)
% set atlas version in "envsetting_v20231214_Shoykhet.m"
% set atlas_table in "data_set_info_v02.m"
% set atlas file number in get_atlas_from_nii.m
% set RGB color in "load_Atlas_v05.m"
% set auto correct parameters in brainatlas_nii2mat.m for different atlas version

if isfield(data1,'zeropadding_sizeext')==1
    size_zpe=data1.zeropadding_sizeext;
end
switch flag.atlas_ver
    case {'v2','v3'}
        atlasname0{1,1}={'background','Cortex','External_Capsule','Interpeduncular_Nucleus','Substantia_Nigra','CA2',...
            'Pituitary_Gland','Thalamus','Contricofugal_Pathways','Midbrain','DG','CA1','CA3'};
        atlasname0{2,1}={'background','Cortex','External_Capsule','Pons','Midbrain','Hippocampus_Subiculum','Inferior_Colliculus'};
        atlasname0{3,1}={'background','Cortex','External_Capsule','Hippocampus','Striatum','Global_Pallidus','Basal_Forebrain',...
            'Thalamus','Contricofugal_Pathways','Anterior_Commisure','CC','Optic_tract'};
        atlasname0{end+1,1}='brain';
        atlas_table=[unique(horzcat(atlasname0{:}),'stable')]';
        atlas_table(1:size(atlas_table,1),2)=mat2cell([0:1:size(atlas_table,1)-1]',ones(size(atlas_table,1),1),1);
        atlas_table{end,2}=255;
    case {'v12'}
        atlas_name=DataSetInfo.atlas_rename.atlas_name;
        atlas_name_N=DataSetInfo.atlas_rename.atlas_name_N;
        id=DataSetInfo.atlas_rename.id;
        atlas_table=table(atlas_name,atlas_name_N,id);
    otherwise
        atlas_name=DataSetInfo.atlas_rename.atlas_name;
        id=DataSetInfo.atlas_rename.id;
        atlas_table=table(atlas_name,id);
end
flag1.get_atlas_from_background=0;


switch flag.load_brainAtlas
    case 1 % load exist atlas .mat or .nii, not use
        file_brainatlas=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver '.mat'];
        if exist(file_brainatlas,'file')
            data1.info.load_atlas_nii=0;
            load(file_brainatlas);
            if istable(atlas_table)~=1
                try
                    data1.atlas_table=cell2table(atlas_table,'VariableNames',{'atlas_name' 'id'});
                catch
                    data1.atlas_table=cell2table(atlas_table(:,1:3),'VariableNames',{'atlas_name' 'id','atlas_namefull'});
                end
            else
                data1.atlas_table=atlas_table;
            end
            data1.atlas_brain=atlas_brain;
        else
            try
                file_brainatlas_nii=[data1.info.filepath_image 'brain_atlas' filesep data1.info.atlas_filename];
                if exist(file_brainatlas_nii,'file')
                    data1.info.load_atlas_nii=1;
                    atlas_brain=get_atlas_from_nii(data1,atlas_table,file_brainatlas_nii,flag);
                else
                    data1.info.load_atlas_nii=0;
                    flag1.get_atlas_from_background=1;
                    %atlas_brain=get_atlas_from_background(data1,atlas_table);
                end
                data1.atlas_brain=atlas_brain;
                data1.atlas_table=atlas_table;
            catch
                atlas_nii_file=dir([data1.info.filepath_image 'brain_atlas']);
                exnii=find(contains({atlas_nii_file.name},'.nii')==1);
                if isempty(exnii)==1
                    flag1.get_atlas_from_background=1;
                else
                    xxx
                end
            end
            
        end
        
    case 2 % load exist atlas .mat and update with new .nii
        file_brainatlas=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver '.mat'];

        %file_brainatlasX=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver 'X.mat'];

        if exist(file_brainatlas,'file')
            data1.info.load_atlas_nii=0;
            load(file_brainatlas);
            if istable(atlas_table)~=1
                try
                    data1.atlas_table=cell2table(atlas_table,'VariableNames',{'atlas_name' 'id'});
                catch
                    data1.atlas_table=cell2table(atlas_table(:,1:3),'VariableNames',{'atlas_name' 'id','atlas_namefull'});
                end
            else
                data1.atlas_table=atlas_table;
            end
            data1.atlas_brain=atlas_brain;

 %           figure(2);imagesc(atlas_brain);axis image
%%
% mpara_atlas.atlas_ver='v10';
%          an=0;mpara_atlas.atlasname{an+1}='background';
%         an=200;mpara_atlas.atlasname{an+1}='RT';
%         an=201;mpara_atlas.atlasname{an+1}='VPL_VPM';
%         mpara_atlas.atlas_ver='v10';
%         mpara_atlas.fullfilename_atlas=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_RT_VPM_VPL_SunV2.nii'];
%         mpara_atlas.fullname_image=[data1.info.filepath_image data1.info.filename_image];
%         mpara_atlas.flag_atlas_clean=1;
%         [atlas_brain0, atlas_table0]=brainatlas_nii2mat(mpara_atlas);
% figure(1);imagesc(atlas_brain0)
% atlas_brain(atlas_brain==23)=254;
% atlas_brain(atlas_brain0==200)=23;
% atlas_brain(atlas_brain0==201)=25;
%                 save(file_brainatlas,'atlas_brain','atlas_table');
%%


        else
            switch flag.atlas_ver
                case 'v5' % add RT
                    data1.info.atlas_filename=[data1.info.filename_image(1:end-4) '_brain_atlas_RTv5.nii'];
                case 'v6' % add Cortex layers in slide 7, slide 8
                    data1.info.atlas_filename=[data1.info.filename_image(1:end-4) '_brain_atlas_CTXLv1.nii'];
                case 'v7' % old HPC (not correct)
                    data1.info.atlas_filename=[data1.info.filename_image(1:end-4) '_brain_atlas_HPCv1.nii'];
                case 'v8' % update HPC from Sunny
                    data1.info.atlas_filename=[data1.info.filename_image(1:end-4) '_brain_atlas_HPCv2.nii'];
                case 'v9' % update cortex layers from Sunny
                    data1.info.atlas_filename=[data1.info.filename_image(1:end-4) '_brain_atlas_CTXLv2.nii'];
                case 'v10'
                    data1.info.atlas_filename=[data1.info.filename_image(1:end-4) '_RT_VPM_VPL_SunV2.nii'];
                case 'v11'
                    data1.info.atlas_filename=[data1.info.filename_image(1:end-4) '_Quant_SSC_MASK_Sun_Revision.nii'];
                case 'v12'
                    data1.info.atlas_filename=[data1.info.filename_image(1:end-4) '_CoarseAtlas_MASK_Sun.nii'];
                    
            end

            file_brainatlas_nii=[data1.info.filepath_image 'brain_atlas' filesep data1.info.atlas_filename];
            if exist(file_brainatlas_nii,'file')
                
                data1.info.load_atlas_nii=1;
                flag1.get_atlas_from_background=0;
                atlasN=get_atlas_from_nii(data1,atlas_table,file_brainatlas_nii,flag);
                figure(1);imagesc(atlasN);axis image
                anumN=unique(atlasN);anumN=anumN(anumN~=0);
                file_brainatlas_old=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver_old '.mat'];
                if exist(file_brainatlas_old,'file') && flag.update_atlas==1 % need check
                    at_old=load(file_brainatlas_old);
                    atlas_brain_old=at_old.atlas_brain;
                    anumN_old=unique(atlas_brain_old);anumN_old=anumN_old(anumN_old~=0);
                    atlas_brain=uint8(zeros(size(atlas_brain_old)));
                    for aaOld=1:length(anumN_old)
                        idp_old=find(at_old.atlas_table.id==anumN_old(aaOld));
                        name_old=at_old.atlas_table.atlas_name(idp_old);
                        idp_new=find(strcmpi(atlas_table.atlas_name,name_old)==1);
                        
                        %%%flag.old_atlas_remove={'Ctx1','Ctx23','Ctx4','Ctx5','Ctx6'};

                        if isempty(flag.old_atlas_remove)~=1
                            idpkp=find(strcmpi(flag.old_atlas_remove,name_old)==1);
                            if isempty(idpkp)==1
                                atlas_brain(atlas_brain_old==anumN_old(aaOld))=atlas_table.id(idp_new);
                            else
                                atlas_brain(atlas_brain_old==anumN_old(aaOld))=atlas_table.id(end-1);
                            end
                        end
                        
                    end
                    atlas_brain(atlasN~=0)=atlasN(atlasN~=0);


                    %figure(11);imagesc(atlasN)
                else
                    atlas_brain=atlasN;
                    %flag1.get_atlas_from_background=1;
                    %atlas_brain=get_atlas_from_background(data1,atlas_table);
                    %atlas_brain(atlas_brain==255)=254;
                    %atlas_brain(atlasN~=0)=atlasN(atlasN~=0);
                end
                %             xxx=atlas_brain*0;xxx(atlas_brain==1)=1;
                %             figure(1);imagesc(xxx)
                clear at_old
            else
                data1.info.load_atlas_nii=0;
                file_brainatlas_old=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver_old '.mat'];
                if exist(file_brainatlas_old,'file')% && flag.update_atlas==1 
%                     at_old=load(file_brainatlas_old);
% 
%                     anum_old=unique(at_old.atlas_brain);anum_old=anum_old(anum_old~=0);
%                     atlas_brain=uint8(zeros(size(at_old.atlas_brain)));
% 
%                     for ao=1:length(anum_old)
%                         idp=find(at_old.atlas_table.id==anum_old(ao));
%                         atname_old=at_old.atlas_table.atlas_name{idp};
%                         idp_new=find(strcmpi(DataSetInfo.atlas_rename.atlas_name,atname_old)==1);
%                         atlas_brain(at_old.atlas_brain==anum_old(ao))=atlas_table.id(idp_new);
%                     end
                    
                    at_old=load(file_brainatlas_old);
                    atlas_brain_old=at_old.atlas_brain;
                    anumN_old=unique(atlas_brain_old);anumN_old=anumN_old(anumN_old~=0);
                    atlas_brain=uint16(zeros(size(atlas_brain_old)));

                    for aaOld=1:length(anumN_old)
                        idp_old=find(at_old.atlas_table.id==anumN_old(aaOld));
                        name_old=at_old.atlas_table.atlas_name(idp_old);
                        idp_new=find(strcmpi(atlas_table.atlas_name,name_old)==1);
                        %%%flag.old_atlas_remove={'Ctx1','Ctx23','Ctx4','Ctx5','Ctx6'};

                        if isempty(flag.old_atlas_remove)~=1
                            idpkp=find(strcmpi(flag.old_atlas_remove,name_old)==1);
                            if isempty(idpkp)==1
                                atlas_brain(atlas_brain_old==anumN_old(aaOld))=atlas_table.id(idp_new);
                            else
                                atlas_brain(atlas_brain_old==anumN_old(aaOld))=atlas_table.id(end-1);
                            end
                        end

                    end

                    %atlas_brain(atlasN~=0)=atlasN(atlasN~=0);
                    %figure(11);imagesc(atlasN)
                    %atlas_brain=at_old.atlas_brain;clear at_old
                else
                    data1.info.load_atlas_nii=0;
                    flag1.get_atlas_from_background=1;
                    %figure(1);imagesc(atlas_brain)
                    %data1.atlas_brain=atlas_brain;
                end
            end


            file_brainatlas=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver '.mat'];
            if flag1.get_atlas_from_background~=1
                data1.atlas_brain=atlas_brain;
                atlas_table0=atlas_table;clear atlas_table
                atlas_name=atlas_table0.atlas_name_N;
                id=atlas_table0.id;
                atlas_table=table(atlas_name,id);
                data1.atlas_table=atlas_table;
                save(file_brainatlas,'atlas_brain','atlas_table');
            end

        end
    otherwise
        flag1.get_atlas_from_background=1;
        

end

if flag1.get_atlas_from_background==1
   % if flag.Low_res~=-1
%         filepath_mat=[data1.info.filepath_image data1.info.folder_mat];
%         if isempty(strfind(data1.info.filepath_image,'Shoykhet'))==0
%             switch data1.info.filename_image
%                 case 'N34 slide 11.tif'
%                     filename_background_mat=[data1.info.filename_image(1:end-4) '_background_m.mat'];
%                 otherwise
%                     filename_background_mat=[data1.info.filename_image(1:end-4) '_background.mat'];
%             end
%         else
%             filename_background_mat=[data1.info.filename_image(1:end-4) '_background_m.mat'];
%         end
%         load([filepath_mat filesep filename_background_mat]);
%         atlas_brain=uint8(imbackground);
  %  else
  
      if flag.imzp==1 || flag.Low_res~=-1
          atlas_brain=uint8(data1.imbackground(ceil(size_zpe(1)/2)+1:end-ceil(size_zpe(1)/2),ceil(size_zpe(2)/2)+1:end-ceil(size_zpe(1)/2)));
      else
          atlas_brain=uint8(data1.imbackground);
      end


  %  end


    ida=find(strcmp(atlas_table.atlas_name(:,1),'brain')==1);
    atlas_brain(atlas_brain==1)=atlas_table.id(ida);

    %atlas_brain=get_atlas_from_background(data1,atlas_table); % old version
    data1.info.load_atlas_nii=0;
    %filepath_mat=[data1.info.filepath_image data1.info.folder_mat];
    %filename_background_mat=[data1.info.filename_image(1:end-4) '_background.mat'];
    %load([filepath_mat filesep filename_background_mat]);
    %data1.imbackground=imbackground;clear imbackground
    % end
    %atlas_brain=uint8(imbackground);
    %figure(1);imagesc(atlas_brain)
    %atlas_table=[unique(horzcat(atlasname0{:}),'stable')]';
    %atlas_table(1:size(atlas_table,1),2)=mat2cell([0:1:size(atlas_table,1)-1]',ones(size(atlas_table,1),1),1);
    %atlas_table{end,2}=255;
    ida=find(strcmp(atlas_table.atlas_name,'brain')==1);
    switch  flag.atlas_ver
        case 'v12'
            atlas_brain(atlas_brain==1)=atlas_table{ida,3};

        otherwise
            atlas_brain(atlas_brain==1)=atlas_table{ida,2};
    end
    data1.atlas_brain=atlas_brain;
    data1.atlas_table=atlas_table;
    file_brainatlas=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver '.jpg'];
    dispfig=0;
    if exist(file_brainatlas,'file')
        delete(file_brainatlas)
    end
else
    if flag.update_atlas~=0
        dispfig=1;
    end

end


%%% load detected atlas region
if flag.Load_decArea==1
    if flag.th_FM==500
        file_brainatlas_dec=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' data1.info.atlas_dec_ver '.mat'];
    else
        file_brainatlas_dec=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' data1.info.atlas_dec_ver '_fm' num2str(flag.th_FM) '.mat'];
    end
    if exist(file_brainatlas_dec,'file');
        adect=load(file_brainatlas_dec);
        try
            data1.atlas_brain_dec=adect.bwD0u;  %include badFM, exclude thickness error, figure(1);imagesc(adect.bwD0u);axis image
            data1.atlas_brain_badFM=adect.bwDFM0u; %figure(2);imagesc(adect.bwDFM0u);axis image, bwDFM depend on FM setting default (FM<500)
        catch
            data1.atlas_brain_dec=adect.atlas_brain;
        end
    else;
        file_brainatlas_dec=[data1.info.filepath_image 'brain_atlas' filesep data1.info.filename_image(1:end-4) '_brain_atlas_' data1.info.atlas_dec_ver '_bk.mat'];
        if exist(file_brainatlas_dec,'file');
            adect=load(file_brainatlas_dec);
            try
                data1.atlas_brain_dec=adect.bwD0u;
                data1.atlas_brain_badFM=adect.bwDFM0u;
            catch
                ata1.atlas_brain_dec=adect.atlas_brain;
            end
        end;
    end
end
%% update atlas name and number - move to afte change the resolution and zeropadding
%{ 
%if flag1.get_atlas_from_background~=1
    if flag.update_atlas==1 || flag.update_atlasname==1
        if isfield(data1.info,'atlas_rename')==1; %need initial atlasname to create new atlas number
            atlas_table0=data1.atlas_table;
            atlas_brain=data1.atlas_brain;
            nameN=intersect(data1.atlas_table.atlas_name,data1.info.atlas_rename.atlas_name,'stable');%from  DataSetInfo in data_set_info_v02.m
            if isempty(setdiff(data1.info.atlas_rename.atlas_name_N,data1.atlas_table.atlas_name))==1
                flag1.nameN=0;
            else
                flag1.nameN=1;
            end
            clear atlas_table
            if flag1.nameN==1
                for aa=1:size(data1.info.atlas_rename.atlas_name_N,1)
                    name_temp=data1.info.atlas_rename.atlas_name_N{aa};
                    ia=find(strcmpi(atlas_table0.atlas_name,name_temp)==1);
                    atlas_nameT{aa,1}=data1.info.atlas_rename.atlas_name_N{aa,1};
                    atlas_nameT{aa,2}=data1.info.atlas_rename.id(aa,1);
                    atlas_nameT{aa,3}=data1.info.atlas_rename.atlas_namefull{aa,1};
                    if isempty(ia)~=1
                        atlas_brain(data1.atlas_brain==data1.atlas_table.id(ia))=data1.info.atlas_rename.id(aa,1);
                    end
                end
                data1.atlas_brain=atlas_brain;
                data1.atlas_table=cell2table(atlas_nameT,'VariableNames',{'atlas_name','id','atlas_namefull'});
                if flag1.get_atlas_from_background==1
                    dispfig=0;
                else
                    dispfig=1;
                end
            end
        end
    else
        if isempty(setdiff(data1.atlas_table.atlas_name,data1.info.atlas_rename.atlas_name_N))==1
            flag1.nameN=0;
        else
            flag1.nameN=1;
        end
    end
%end
% rename atlas
% if isfield(data1.info,'atlas_rename')==1
%     for aa=1:size(data1.info.atlas_rename,1)
%         ia=find(strcmpi(data1.atlas_table.atlas_name,data1.info.atlas_rename.atlas_name(aa))==1);
%         if isempty(ia)==1
%             ia=find(strcmpi(data1.atlas_table.atlas_name,data1.info.atlas_rename.atlas_name_N(aa))==1);
%         end
%         if isempty(ia)~=1
%             data1.atlas_table.atlas_name(ia)=data1.info.atlas_rename.atlas_name_N(aa);
%             data1.atlas_table.atlas_namefull(ia)=data1.info.atlas_rename.atlas_namefull(aa);
%         end
%     end
% end
%   CR1 slide 7_brain_atlas_RTv5
% get atlas area and coco_id
id_at=unique(data1.atlas_brain);
%data1.atlas_table(:,3:6)=repmat({0},size(data1.atlas_table,1),4);
%atlas_tableN = cell2table(data1.atlas_table,'VariableNames',{'Atlas_name' 'id'})

%'RGB' 'RGBnum' 'coco_id' 'area'
%figure(1);imagesc(data1.atlas_brain);axis image
data1.atlas_table.area=repmat({-1},size(data1.atlas_table,1),1);
data1.atlas_table.coco_id=repmat({-1},size(data1.atlas_table,1),1);
ccc=data1.atlas_table.id;
for aa=1:length(id_at)
    bw0=false(size(data1.atlas_brain));
    bw0(data1.atlas_brain==id_at(aa))=true;
    index_at = find([ccc] == id_at(aa));
    if isempty(index_at)~=1
        data1.atlas_table.area{index_at}=sum(bw0(:))*(data1.info.pixel_size).^2;
        in=find(strcmpi({data1.categories.name},data1.atlas_table.atlas_name{index_at,1})==1);
        try
        data1.atlas_table.coco_id{index_at}=data1.categories(in).id;
        catch
        aa
        end
    end
end
%}


%end
if flag.Low_res~=-1
    %if flag.imzp==1 for low resolution always do zero padding and change size of the atlas
        im_size=size(data1.im0);
        if isfield(data1,'atlas_brain')==1
            at0zp=uint8(zeros(size(data1.atlas_brain,1)+size_zpe(1),size(data1.atlas_brain,2)+size_zpe(2),size(data1.atlas_brain,3)));
            at0zp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.atlas_brain,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.atlas_brain,2),:)=data1.atlas_brain;
            data1.atlas_brain=imresize(at0zp,[im_size(1) im_size(2)],'Method','nearest');clear at0zp
        end
        
        if isfield(data1,'atlas_brain_dec')==1
            at0zp=uint8(zeros(size(data1.atlas_brain_dec,1)+size_zpe(1),size(data1.atlas_brain_dec,2)+size_zpe(2),size(data1.atlas_brain_dec,3)));
            at0zp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.atlas_brain_dec,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.atlas_brain_dec,2),:)=data1.atlas_brain_dec;
            data1.atlas_brain_dec=imresize(at0zp,[im_size(1) im_size(2)],'Method','nearest');clear at0zp
        end
        if isfield(data1,'atlas_brain_badFM')==1
            at0zp=uint8(zeros(size(data1.atlas_brain_badFM,1)+size_zpe(1),size(data1.atlas_brain_badFM,2)+size_zpe(2),size(data1.atlas_brain_badFM,3)));
            at0zp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.atlas_brain_badFM,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.atlas_brain_badFM,2),:)=data1.atlas_brain_badFM;
            data1.atlas_brain_badFM=imresize(at0zp,[im_size(1) im_size(2)],'Method','nearest');clear at0zp
        end

        if isfield(data1,'imbackground') % no zero filling at imbackground
            if size(data1.imbackground,1)~=size(data1.im0gray,1) || size(data1.imbackground,2)~=size(data1.im0gray,2) 
                imbackgroundzp=uint8(false(size(data1.imbackground,1)+size_zpe(1),size(data1.imbackground,2)+size_zpe(2),size(data1.imbackground,3)));
                imbackgroundzp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.imbackground,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.imbackground,2),:)=data1.imbackground;
                %data1.info.im0_size=size(imbackgroundzp); % get zerofilling imagesize
                data1.imbackground=imresize(imbackgroundzp,[im_size(1) im_size(2)],'Method','nearest');
                clear imbackgroundzp
            end
        end
   
%         if isfield(data1,'atlas_brain_dec')==1
%         end
%         if isfield(data1,'atlas_brain_badFM')==1
%         end
else
    if flag.imzp==1
        at0zp=uint8(zeros(size(data1.atlas_brain,1)+size_zpe(1),size(data1.atlas_brain,2)+size_zpe(2),size(data1.atlas_brain,3)));
        at0zp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.atlas_brain,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.atlas_brain,2),:)=data1.atlas_brain;
        data1.atlas_brain=at0zp;clear at0zp
        data1.info.im0_size=size(data1.atlas_brain);
        if isfield(data1,'atlas_brain_dec')==1
            at0zp=uint8(zeros(size(data1.atlas_brain_dec,1)+size_zpe(1),size(data1.atlas_brain_dec,2)+size_zpe(2),size(data1.atlas_brain_dec,3)));
            at0zp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.atlas_brain_dec,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.atlas_brain_dec,2),:)=data1.atlas_brain_dec;
            data1.atlas_brain_dec=at0zp;clear at0zp
        end
        if isfield(data1,'atlas_brain_badFM')==1
            at0zp=uint8(zeros(size(data1.atlas_brain_badFM,1)+size_zpe(1),size(data1.atlas_brain_badFM,2)+size_zpe(2),size(data1.atlas_brain_badFM,3)));
            at0zp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.atlas_brain_badFM,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.atlas_brain_badFM,2),:)=data1.atlas_brain_badFM;
            data1.atlas_brain_badFM=at0zp;clear at0zp
        end
    end
end



%% update atlas name and number
%if flag1.get_atlas_from_background~=1
    if flag.update_atlas>=1 || flag.update_atlasname>=1
        if isfield(data1.info,'atlas_rename')==1; %need initial atlasname to create new atlas number
            atlas_table0=data1.atlas_table;
            atlas_brain=data1.atlas_brain;
            nameN=intersect(data1.atlas_table.atlas_name,data1.info.atlas_rename.atlas_name,'stable');%from  DataSetInfo in data_set_info_v02.m
            if isempty(setdiff(data1.info.atlas_rename.atlas_name_N,data1.atlas_table.atlas_name))==1
                flag1.nameN=0;
            else
                flag1.nameN=1;
            end
            clear atlas_table
            if flag1.nameN==1
                for aa=1:size(data1.info.atlas_rename.atlas_name_N,1)
                    name_temp=data1.info.atlas_rename.atlas_name_N{aa};
                    ia=find(strcmpi(atlas_table0.atlas_name,name_temp)==1);
                    atlas_nameT{aa,1}=data1.info.atlas_rename.atlas_name_N{aa,1};
                    atlas_nameT{aa,2}=data1.info.atlas_rename.id(aa,1);
                    atlas_nameT{aa,3}=data1.info.atlas_rename.atlas_namefull{aa,1};
                    if isempty(ia)~=1
                        atlas_brain(data1.atlas_brain==data1.atlas_table.id(ia))=data1.info.atlas_rename.id(aa,1);
                    end
                end
                data1.atlas_brain=atlas_brain;
                data1.atlas_table=cell2table(atlas_nameT,'VariableNames',{'atlas_name','id','atlas_namefull'});
                if flag1.get_atlas_from_background==1
                    dispfig=0;
                else
                    dispfig=1;
                end
            end
        end
    else
        if isempty(setdiff(data1.atlas_table.atlas_name,data1.info.atlas_rename.atlas_name_N))==1
            flag1.nameN=0;
        else
            flag1.nameN=1;
        end
    end
%end


id_at=unique(data1.atlas_brain);
%data1.atlas_table(:,3:6)=repmat({0},size(data1.atlas_table,1),4);
%atlas_tableN = cell2table(data1.atlas_table,'VariableNames',{'Atlas_name' 'id'})

%'RGB' 'RGBnum' 'coco_id' 'area'
%figure(1);imagesc(data1.atlas_brain);axis image
data1.atlas_table.area=repmat({-1},size(data1.atlas_table,1),1);
data1.atlas_table.coco_id=repmat({-1},size(data1.atlas_table,1),1);
ccc=data1.atlas_table.id;
for aa=1:length(id_at)
    bw0=false(size(data1.atlas_brain));
    bw0(data1.atlas_brain==id_at(aa))=true;
    index_at = find([ccc] == id_at(aa));
    if isempty(index_at)~=1
        data1.atlas_table.area{index_at}=sum(bw0(:))*(data1.info.pixel_size).^2;
        in=find(strcmpi({data1.categories.name},data1.atlas_table.atlas_name{index_at,1})==1);
        try
        data1.atlas_table.coco_id{index_at}=data1.categories(in).id;
        catch
        %aa
        end
    end
end


switch flag.atlas_ver
    case {'v1','v2','v3'}
        cmap=[0     0     0; % 0  background
            0   255     0; % 1  cor
            0     0   255; % 2  EC
            153    76     0; % 3  IN
            128   255     0; % 4  SN
            255   128     0; % 5  CA2
            0   128   255;   % 6  PG
            255     0   127; % 7  THAL
            255   255     0; % 8  CP
            0     0   153;   % 9  MB
            0   153     0;   % 10 DG
            153   153     0; % 11 CA1
            0   255   128;   % 12 CA3
            0   153    76;   % 13 Pons
            0   255   255;   % 14 HPC_S
            153     0    76; % 15 IC
            76   153     0; % 16 HPC
            153     0     0; % 17 STRI
            76     0   153;  % 18 GP
            0    76   153;   % 19 BF
            128     0   255; % 20 AC
            255     0     0; % 21 CC
            0   153   153;   % 22 OT
            255    0   255;];% 23 brain

    case 'v4'
        cmap=[0     0     0; % 0  background
            0   255     0; % 1  cor
            0     0   255; % 2  EC
            153    76     0; % 3  IN
            128   255     0; % 4  SN
            255   128     0; % 5  CA2
            0   128   255;   % 6  PG
            255     0   127; % 7  THAL
            255   255     0; % 8  CP
            0     0   153;   % 9  MB
            0   153     0;   % 10 DG
            153   153     0; % 11 CA1
            0   255   128;   % 12 CA3
            0   153    76;   % 13 Pons
            %0   255   255;   % 14 HPC_S
            %153     0    76; % 15 IC
            76   153     0;  % 14 HPC
            153     0     0; % 15 STRI
            76     0   153;  % 16 GP
            0    76   153;   % 17 BF
            128     0   255; % 18 AC
            255     0     0; % 19 CC
            0   153     153;   % 20 OT
            255   255   102;   % 21 Chp
            255    0   255;];% 22 brain -> 255
    case 'v5'
        cmap=[0     0     0; % 0  background
            0   255     0; % 1  cor
            0     0   255; % 2  EC
            153    76     0; % 3  IN
            128   255     0; % 4  SN
            255   128     0; % 5  CA2
            0   128   255;   % 6  PG
            255     0   127; % 7  THAL
            255   255     0; % 8  CP
            0     0   153;   % 9  MB
            0   153     0;   % 10 DG
            153   153     0; % 11 CA1
            0   255   128;   % 12 CA3
            0   153    76;   % 13 Pons
            %0   255   255;   % 14 HPC_S
            %153     0    76; % 15 IC
            76   153     0;  % 14 HPC
            153     0     0; % 15 STRI
            76     0   153;  % 16 GP
            0    76   153;   % 17 BF
            128     0   255; % 18 AC
            255     0     0; % 19 CC
            0   153     153;   % 20 OT
            255   255   102;   % 21 Chp
            0   108    64;  %  22 RT
            205    0   205; % 254 undefined
            255    0   255;];% 22 brain -> 255
    case 'v6'
        cmap=[0     0     0; % 0  background
            0   255     0; % 1  cor
            0     0   255; % 2  EC
            153    76     0; % 3  IN
            128   255     0; % 4  SN
            255   128     0; % 5  CA2
            0   128   255;   % 6  PG
            255     0   127; % 7  THAL
            255   255     0; % 8  CP
            0     0   153;   % 9  MB
            0   153     0;   % 10 DG
            153   153     0; % 11 CA1
            0   255   128;   % 12 CA3
            0   153    76;   % 13 Pons
            %0   255   255;   % 14 HPC_S
            %153     0    76; % 15 IC
            76   153     0;  % 14 HPC
            153     0     0; % 15 STRI
            76     0   153;  % 16 GP
            0    76   153;   % 17 BF
            128     0   255; % 18 AC
            255     0     0; % 19 CC
            0   153     153;   % 20 OT
            255   255   102;   % 21 Chp
            148   0  211;  %  22 RT
            139   0   0;      %23 Ctx1
            255  140  0;     %24 Ctx2
            255  215 0;     %25 Ctx3
            85  107  47;    %26 Ctx4
            0   206  209;     %27 Ctx5
            65  105  225;     %28 Ctx6
            205    205   205; % 254 undefined
            255    0   255;];% 22 brain -> 255

    case 'v7'
        cmap=[0     0     0; % 0  background
            0   255     0; % 1  cor
            0     0   255; % 2  EC
            153    76     0; % 3  IN
            128   255     0; % 4  SN
            255   128     0; % 5  CA2
            0   128   255;   % 6  PG
            255     0   127; % 7  THAL
            255   255     0; % 8  CP
            0     0   153;   % 9  MB
            0   153     0;   % 10 DG
            153   153     0; % 11 CA1
            0   255   128;   % 12 CA3
            0   153    76;   % 13 Pons
            %0   255   255;   % 14 HPC_S
            %153     0    76; % 15 IC
            76   153     0;  % 14 HPC
            153     0     0; % 15 STRI
            76     0   153;  % 16 GP
            0    76   153;   % 17 BF
            128     0   255; % 18 AC
            255     0     0; % 19 CC
            0   153     153;   % 20 OT
            255   255   102;   % 21 Chp
            148   0  211;  %  22 RT
            139   0   0;      %23 Ctx1
            255  140  0;      %24 Ctx2
            255  215 0;       %25 Ctx3
            85  107  47;      %26 Ctx4
            0   206  209;     %27 Ctx5
            65  105  225;     %28 Ctx6
            255 127  80;      %29 CA1_SO
            34  139 34;       %30 CA1_SL
            0  191 255;       %31 CA1_SR
            255 165 0;       %32 CA2_SO
            154 205 50;       %33 CA2_SL
            30 144 255;       %34 CA2_SR
            255 99 71;     %35 CA3_SO
            60,179,113;       %36 CA3_SL
            135 206 235;      %37 CA3_SR
            210 105 30;       %38 SLM
            128 128 0;        %39 DG_ML
            65 105 225;       %40 DG_GL
            218 112 214;      %41 DG_H
 

            205    205   205; % 254 undefined
            255    0   255;];% 22 brain -> 255

     case {'v8'} % updata from v5
        cmap=[0     0     0; % 0  background
            0   255     0; % 1  cor
            0     0   255; % 2  EC
            153    76     0; % 3  IN
            128   255     0; % 4  SN
            255   128     0; % 5  CA2
            0   128   255;   % 6  PG
            255     0   127; % 7  THAL
            255   255     0; % 8  CP
            0     0   153;   % 9  MB
            0   153     0;   % 10 DG
            153   153     0; % 11 CA1
            0   255   128;   % 12 CA3
            0   153    76;   % 13 Pons
            %0   255   255;   % 14 HPC_S
            %153     0    76; % 15 IC
            76   153     0;  % 14 HPC
            153     0     0; % 15 STRI
            76     0   153;  % 16 GP
            0    76   153;   % 17 BF
            128     0   255; % 18 AC
            255     0     0; % 19 CC
            0   153     153;   % 20 OT
            255   255   102;   % 21 Chp
            148   0  211;  %  22 RT
            139   0   0;      %23 Ctx1
            255  140  0;      %24 Ctx2
            255  215 0;       %25 Ctx3
            85  107  47;      %26 Ctx4
            0   206  209;     %27 Ctx5
            65  105  225;     %28 Ctx6
            255 127  80;      %29 CA1_Or
            34  139 34;       %30 CA1_Py
            0  191 255;       %31 CA1_Rad
            255 165 0;        %32 CA2_Or
            154 205 50;       %33 CA2_Py
            30 144 255;       %34 CA2_Rad
            255 99 71;        %35 CA3_Or
            60,179,113;       %36 CA3_Py
            135 206 235;      %37 CA3_Rad
            255,228,181;      %38 CA3_SLu
            210 105 30;       %39 LMol
            128 128 0;        %40 MoDG
            65 105 225;       %41 GrDG
            218 112 214;      %42 PoDG
            173,216,230;      %43 dhc

            205    205   205; % 254 undefined
            255    0   255;];% 22 brain -> 255
    case {'v9'} % updata from v8
        cmap=[0     0     0; % 0  background
            0   255     0; % 1  cor
            0     0   255; % 2  EC
            153    76     0; % 3  IN
            128   255     0; % 4  SN
            255   128     0; % 5  CA2
            0   128   255;   % 6  PG
            255     0   127; % 7  THAL
            255   255     0; % 8  CP
            0     0   153;   % 9  MB
            0   153     0;   % 10 DG
            153   153     0; % 11 CA1
            0   255   128;   % 12 CA3
            0   153    76;   % 13 Pons
            %0   255   255;   % 14 HPC_S
            %153     0    76; % 15 IC
            76   153     0;  % 14 HPC
            153     0     0; % 15 STRI
            76     0   153;  % 16 GP
            0    76   153;   % 17 BF
            128     0   255; % 18 AC
            255     0     0; % 19 CC
            0   153     153;   % 20 OT
            255   255   102;   % 21 Chp
            148   0  211;  %  22 RT
            139   0   0;      %23 Ctx1
            255  140  0;      %24 Ctx22
            85  107  47;      %25 Ctx4
            0   206  209;     %26 Ctx5
            65  105  225;     %27 Ctx6
            255 127  80;      %28 CA1_Or
            34  139 34;       %29 CA1_Py
            0  191 255;       %30 CA1_Rad
            255 165 0;        %31 CA2_Or
            154 205 50;       %32 CA2_Py
            30 144 255;       %33 CA2_Rad
            255 99 71;        %34 CA3_Or
            60,179,113;       %35 CA3_Py
            135 206 235;      %36 CA3_Rad
            255,228,181;      %37 CA3_SLu
            210 105 30;       %38 LMol
            128 128 0;        %39 MoDG
            65 105 225;       %40 GrDG
            218 112 214;      %41 PoDG
            173,216,230;      %42 dhc

            205    205   205; % 254 undefined
            255    0   255;];% 22 brain -> 255


    case {'v10','v11'} % updata from v8
        cmap=[0     0     0; % 0  background
            0   255     0; % 1  cor
            0     0   255; % 2  EC
            153    76     0; % 3  IN
            128   255     0; % 4  SN
            255   128     0; % 5  CA2
            0   128   255;   % 6  PG
            255     0   127; % 7  THAL
            255   255     0; % 8  CP
            0     0   153;   % 9  MB
            0   153     0;   % 10 DG
            153   153     0; % 11 CA1
            0   255   128;   % 12 CA3
            0   153    76;   % 13 Pons
            76   153     0;  % 14 HPC
            153     0     0; % 15 STRI
            76     0   153;  % 16 GP
            0    76   153;   % 17 BF
            128     0   255; % 18 AC
            255     0     0; % 19 CC
            0   153     153; % 20 OT
            255   255   102; % 21 Chp
            148   0  211;    % 22 RT
            211   148 0 ;    % 23 VPL,VPM
            139   0   0;     % 24 Ctx1
            255  140  0;     % 25 Ctx22
            85  107  47;     % 26 Ctx4
            0   206  209;    % 27 Ctx5
            65  105  225;    % 28 Ctx6
            255 127  80;     % 29 CA1_Or
            34  139 34;      % 30 CA1_Py
            0  191 255;      % 31 CA1_Rad
            255 165 0;       % 32 CA2_Or
            154 205 50;      % 33 CA2_Py
            30 144 255;      % 34 CA2_Rad
            255 99 71;       % 35 CA3_Or
            60,179,113;      % 36 CA3_Py
            135 206 235;     % 37 CA3_Rad
            255,228,181;     % 38 CA3_SLu
            210 105 30;      % 39 LMol
            128 128 0;       % 40 MoDG
            65 105 225;      % 41 GrDG
            218 112 214;     % 42 PoDG
            205 205 205;     % 254 undefined
            255   0 255;];   % 22 brain -> 255

    case {'v12'} % updata from v8
        cmap=[0     0     0; % 0  background
            0   255     0;   % 1  CTX
            64    240   255;   % 2  EC
            153    76     0; % 3  HPF
            128   255     0; % 4  CPU
            255   128     0; % 5  GPVP
            0   128   255;   % 6  BF
            255     0   127; % 7  THAL
            255   255     0; % 8  PONS
            0     0   153;   % 9  CHP
            130    0     0;   % 10 AC
            153   153     0; % 11 IC
            0   255   128;   % 12 CC
            0   153    76;   % 13 CG
            76   153     0;  % 14 SEPT
            153     0     0; % 15 SC
            255 191 128;  % 16 MB
           217 255 25;   % 17 SN
            128     0   255; % 18 PG
            255     0     0; % 19 CFT
            0   153     153; % 20 DG
            255   255   102; % 21 CA1
            102   148   102; % 22 CA3
            148   0  211;    % 23 RT
            153   0  153;    % 24 STRI
            211   148 0 ;    % 25 VPL,VPM
            139   0   0;     % 26 Ctx1  -> S1-L1
            255  140  0;     % 27 Ctx22 -> S1-L2L3
            85  107  47;     % 28 Ctx4  -> S1-L4
            0   206  209;    % 29 Ctx5  -> S1-L5
            65  105  225;    % 30 Ctx6  -> S1-L6
            255 127  80;     % 31 CA1_Or
            34  139 34;      % 32 CA1_Py
            0  191 255;      % 33 CA1_Rad
            255 165 0;       % 34 CA2_Or
            154 205 50;      % 35 CA2_Py
            30 144 255;      % 36 CA2_Rad
            255 99 71;       % 37 CA3_Or
            60,179,113;      % 38 CA3_Py
            135 206 235;     % 39 CA3_Rad
            255,228,181;     % 40 CA3_SLu
            210 105 30;      % 41 LMol
            128 128 0;       % 42 MoDG
            65 105 225;      % 43 GrDG
            218 112 214;     % 44 PoDG
            205 205 205;     % 254 undefined
            255   0 255;];   % 255 brain -> 255
    case 'v0'
         cmap=[0     0     0;
              255    0   255;];
end
%}
cmap(1,:)=0;
for aa=1:size(data1.atlas_table,1)
    if aa==size(data1.atlas_table,1)
        data1.atlas_table.RGB{aa}=[255 0 255];
        data1.atlas_table.RGBnum{aa}=255*1000000+0*1000+255;
    else
        data1.atlas_table.RGB{aa}=cmap(aa,:);
        data1.atlas_table.RGBnum{aa}=cmap(aa,1)*1000000+cmap(aa,2)*1000+cmap(aa,3);
    end
end

% if flag.Low_res~=-1
%     im_size=size(data1.im0);
%     if isfield(data1,'atlas_brain')==1
%         data1.atlas_brain=imresize(data1.atlas_brain,[im_size(1) im_size(2)],'Method','nearest');
%     end
%     if isfield(data1,'atlas_brain_dec')==1
%         data1.atlas_brain_dec=imresize(data1.atlas_brain_dec,[im_size(1) im_size(2)],'Method','nearest');
%     end
%     if isfield(data1,'atlas_brain_badFM')==1
%         data1.atlas_brain_badFM=imresize(data1.atlas_brain_badFM,[im_size(1) im_size(2)],'Method','nearest');
%     end
% end

if dispfig==1
    % cmap=jet(double(max(data1.atlas_brain(:))));
    cmap=vertcat(data1.atlas_table.RGB{2:end,1})./255;

    if flag.Low_res==-1
        atlas0S=imresize3D(data1.atlas_brain,size(data1.atlas_brain)/20,'atlas');
        imp=imresize(data1.im0,size(atlas0S));
        
    else
        atlas0S=imresize3D(data1.atlas_brain,size(data1.im0),'atlas');
        imp=data1.im0;
    end
    atlas0S(atlas0S==254)=0;
    if flag1.get_atlas_from_background==1
        cmap=ones(max(atlas0S(:)),3);cmap(:,2)=0;
    end
    anum=unique(atlas0S);
    if max(unique(atlas0S))>size(cmap,1)
        cmap=ones(max(atlas0S(:)),3);cmap(:,2)=0;
        for aa=2:length(anum)
            ia=find(data1.atlas_table.id==anum(aa));
            cmap(anum(aa),:)=data1.atlas_table.RGB{ia}/255;
        end
    end
   % atlas0L=getAtlasEdge(atlas0S,1);
    %atlas0L(atlas0L==254)=0;
%  imp=data1.im0;
%  atlas0L=uint8(imresize3D(atlas0L,size(data1.im0,1:2),'atlas'));
%  atlas0S=uint8(imresize3D(atlas0S,size(data1.im0,1:2),'atlas'));

%    imF1 = labeloverlay(imp,atlas0L,'Colormap',cmap,'Transparency',0);
    imF1 = labeloverlay(imp,atlas0S,'Colormap',cmap,'Transparency',0.8);
%f11=figure(998);imshow(imp(3217:13353,11824:26582,:))
    %f1=figure(999);imshow(imF1(3217:13353,11824:26582,:))
    f1=figure(999);imshow(imF1)
    imwrite(imF1,[file_brainatlas(1:end-4) '_notext.jpg'])

    num1=unique(atlas0L);
    for aa=2:size(data1.atlas_table,1)-2
        ia=find(num1==data1.atlas_table.id(aa));
        if isempty(ia)~=1

            bwa0=false(size(atlas0S));
            bwa0(atlas0S==num1(ia))=1;

            [xc,yc]=getbwcenterOnmaxCC(bwa0);%if flag.Low_res==-1;xc=xc*20;yc=yc*20;end        %10
            text(xc,yc,[data1.atlas_table.atlas_name{aa} ' (' num2str(num1(ia)) ')'],'FontSize',8,'color',[0 0 0],'FontWeight','bold','Interpreter','none','HorizontalAlignment','center');
        end
    end
    title(data1.info.filename_image(1:end-4))
    pause(3)
    saveas(f1,[file_brainatlas(1:end-4) '.jpg'])

end

if isdir([data1.info.filepath_image 'brain_atlas'])~=1;mkdir([data1.info.filepath_image 'brain_atlas']);end
if ~exist([file_brainatlas(1:end-4) '.xls'],'file') || flag.update_atlas>0 || flag.update_atlasname>0
    writetable(data1.atlas_table,[file_brainatlas(1:end-4) '.xls'])
end






