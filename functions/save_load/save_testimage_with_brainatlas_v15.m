function [index_exit_atlas]=save_testimage_with_brainatlas_v15(imp,im0rgb,train_imsize,mpara)
imsize0=size(imp);
imt_4d=imsplit4d(imp,train_imsize); %clear imp
imtrgb_4d=uint8(false([size(imt_4d),3]));
imtrgb_4d(:,:,:,1)=imsplit4d(im0rgb(:,:,1),train_imsize);
imtrgb_4d(:,:,:,2)=imsplit4d(im0rgb(:,:,2),train_imsize);
imtrgb_4d(:,:,:,3)=imsplit4d(im0rgb(:,:,3),train_imsize);
%clear im0rgb


if isfield(mpara,'brain_atlas')==1
    atb_4d=imsplit4d(mpara.brain_atlas,train_imsize);
    %atlas_table=mpara.brain_atlas_table;
    atlas_table(:,1)=mpara.brain_atlas_table.atlas_name;  % change atlas table format
    atlas_table(:,2)=mat2cell(mpara.brain_atlas_table.id,ones(1,size(mpara.brain_atlas_table,1)),1);
    for aa=1:size(atlas_table,1)
        atlas_table{aa,1}=regexprep(atlas_table{aa,1},'_','');
    end
else
    atb_4d=true(size(imt_4d));
    atlas_table={'wholeimage',1;'wholeimage',1};
end
% un=unique(mpara.brain_atlas);un=un(un~=0);
% cmap=jet(length(un));
% imF1 = labeloverlay(imp,mpara.brain_atlas,'Colormap',cmap,'Transparency',0.7);
% figure(1);imshow(imF1)

bboxedge_4d=uint8(false(size(imt_4d)));
bboxedge_4d(:,1:15,:)=1;
bboxedge_4d(:,train_imsize(1)-15+1:train_imsize(1),:)=1;
bboxedge_4d(:,:,1:15)=1;
bboxedge_4d(:,:,train_imsize(2)-15+1:train_imsize(2))=1;

% figure(1);imagesc(squeeze(bw_gt_4d(384,:,:)))
% figure(2);imagesc(squeeze(atbw_4d(384,:,:)))

%cmap_at=parula(size(mpara.brain_atlas,1)-1);
drc=ceil(imsize0./train_imsize);

%% get index in brain_atlas
for aa=2:size(atlas_table,1)
    atbw_4d=false(size(imt_4d));
    atbw_4d(atb_4d==atlas_table{aa,2})=true;
    num_exit_atbw=sum(sum(atbw_4d,2),3);
    index_exit_atbw=find(num_exit_atbw~=0);
    bboxnum_4d=uint8(false(size(imt_4d)));
    index_exit_atlas{aa}=index_exit_atbw;
    ia=index_exit_atlas{aa};
   % [~,ia,ib]=intersect(index_exit_atlas{aa},index_exitbw);
    if isempty(ia)~=1
        for nn=1:length(ia)
            if mod(nn,500)==1;tic;end
            mm=ia(nn);
            imt1rgb=squeeze(imtrgb_4d(mm,:,:,:));
            imt1=squeeze(imt_4d(mm,:,:)); %figure(1234);imagesc(att1)
            att1=squeeze(atb_4d(mm,:,:));
            switch mpara.save_train_path_case
                case 3
                    an=unique(att1);
                    clear atname
                    for ian=1:length(an)
                        tablemat=cell2mat(atlas_table(:,2));
                        id=find(tablemat==an(ian));
                        if ian==1
                            atname= atlas_table{id,1};
                        else
                            atname=[atname '_' atlas_table{id,1}];
                        end
                    end


                    if mpara.flag.save_maskrcnn>=1
                        filename_temp=[mpara.filename_maskrcnn '_' num2str(mm) '_' atname];
                        filepath_opt01=mpara.filepath_maskrcnn;
                        if ~exist([filepath_opt01 filesep 'images'], 'dir');mkdir([filepath_opt01 filesep 'images']);end
                        %if ~exist([filepath_opt01 filesep 'imagesRGB'], 'dir');mkdir([filepath_opt01 filesep 'imagesRGB']);end
        
                        ims(:,:,1)=imt1;ims(:,:,2)=imt1;ims(:,:,3)=imt1;
                        imwrite(ims,[filepath_opt01 filesep 'images' filesep filename_temp '.png']);
                        %imwrite(imt1rgb,[filepath_opt01 filesep 'imagesRGB' filesep filename_temp '.png']);
                    end


                case 1
                    an=unique(att1);
                    clear atname
                    for ian=1:length(an)
                        tablemat=cell2mat(atlas_table(:,2));
                        id=find(tablemat==an(ian));
                        if ian==1
                            atname= atlas_table{id,1};
                        else
                            atname=[atname '_' atlas_table{id,1}];
                        end
                    end
                    
                    filename_temp=[mpara.filename_maskrcnn '_' num2str(mm) '_' atname];
                    filepath_opt01=[mpara.filepath_maskrcnn filesep 'imageJroi' filesep];
                    if ~exist([filepath_opt01], 'dir');mkdir([filepath_opt01]);end
                    %if ~exist([filepath_opt01 filesep 'masks'], 'dir');mkdir([filepath_opt01 filesep 'masks']);end
                    %if exist([filepath_opt01 filesep 'images' filesep filename_temp '.png'],'file')==0
                    
                    ims(:,:,1)=imt1;ims(:,:,2)=imt1;ims(:,:,3)=imt1;
                    imwrite(ims,[filepath_opt01 filesep filename_temp '.png']);
                    imwrite(imt1rgb,[filepath_opt01 filesep filename_temp '_rgb.png']);
                    
                    
                case 2
                    %==== with cell touch the edge of the image
                        an=unique(att1);
                        clear atname
                        for ian=1:length(an)
                            tablemat=cell2mat(atlas_table(:,2));
                            id=find(tablemat==an(ian));
                            if ian==1
                                atname= atlas_table{id,1};
                            else
                                atname=[atname '_' atlas_table{id,1}];
                            end
                        end
                        
                        if mpara.flag.save_maskrcnn>=1
                            filename_temp=[mpara.filename_maskrcnn '_' num2str(mm) '_' atname];
                            filepath_opt01=[mpara.filepath_maskrcnn filesep filename_temp];
                            if ~exist([filepath_opt01 filesep 'images'], 'dir');mkdir([filepath_opt01 filesep 'images']);end
                            %if ~exist([filepath_opt01 filesep 'imagesRGB'], 'dir');mkdir([filepath_opt01 filesep 'imagesRGB']);end
                            
                            %%if ~exist([filepath_opt01 filesep 'masks'], 'dir');mkdir([filepath_opt01 filesep 'masks']);end
                            %%if exist([filepath_opt01 filesep 'images' filesep filename_temp '.png'],'file')==0
                            
                            ims(:,:,1)=imt1;ims(:,:,2)=imt1;ims(:,:,3)=imt1;
                            imwrite(ims,[filepath_opt01 filesep 'images' filesep filename_temp '.png']);
                            %imwrite(imt1rgb,[filepath_opt01 filesep 'imagesRGB' filesep filename_temp '.png']);
                        end
            end
            bwfornum=false(train_imsize);
            J = insertText(uint8(bwfornum), [train_imsize(1)/2 train_imsize(2)/2 ], num2str(mm), 'FontSize',180,'TextColor','white','BoxOpacity',0,'AnchorPoint','Center');
            bwJ=J(:,:,1);bwJ(bwJ~=0)=1;bwJ=uint8(bwJ);
            bboxnum_4d(mm,:,:)=bwJ;

            if mod(nn,500)==0;nn
                toc
            end
        end
   
        atF=dmib2(atbw_4d,drc(1),drc(2));
        bboxedge=dmib2(bboxedge_4d,drc(1),drc(2));
        bboxnum=dmib2(bboxnum_4d,drc(1),drc(2));

        if isfield(mpara,'brain_atlas')==1
            if ~exist(mpara.filepath_brainatlasnum, 'dir');mkdir(mpara.filepath_brainatlasnum);end
            imF=dmib2(imt_4d,drc(1),drc(2));
            imF = labeloverlay(imF,bboxedge,'Colormap',[1,0,0],'Transparency',0.5);
            imF = labeloverlay(imF,atF,'Colormap',[0,255,128]/255,'Transparency',0.9);
            imF = labeloverlay(imF,bboxnum,'Colormap',[255,255,0]/255,'Transparency',0);
            f1=figure(1221);imshow(imF)
            %saveas(f1,[save_path_01 filesep optpars.atlas_table{aa,1} '__num.jpg'],'jpeg');
            try
            imwrite(imF,[mpara.filepath_brainatlasnum filesep atlas_table{aa,1} '__num.jpg']);
            catch
            imwrite(imresize(imF,0.5),[mpara.filepath_brainatlasnum filesep atlas_table{aa,1} '__num.jpg']);

            end
        end
    end
end







