function save_mask2unet_v14(im0gray,im0, bboxD, size_box2,mpara)
% if isempty(varargin)~=1
%     flag=varargin{1};
% end
%xxx=imread(['/media/chhsu/8T1/HU/DLdata_v2/Artur/project1/IHC/s01_imadjust__chh/AVG_10_1_001/Yolo512_Unet_256x256__test/AVG_10_1_001_n1_y147_x1/images/AVG_10_1_001_n1_y147_x1.png']);

xc=fix((bboxD(:,1)+bboxD(:,3)/2));
yc=fix((bboxD(:,2)+bboxD(:,4)/2));
%sbox=[ones(size(bboxD,1),1)*fix(size_box2(2)/2)-fix(bboxD(:,3)/2), ones(size(bboxD,1),1)*fix(size_box2(1)/2)-fix(bboxD(:,4)/2), bboxD(:,3), bboxD(:,4)];

for byu=1:size(bboxD,1)
    clear yolo5_txt
    if mod(byu,5000)==1;tic;end
    xp=xc(byu)-fix(size_box2(2)/2):xc(byu)+fix(size_box2(2)/2)-1;
    yp=yc(byu)-fix(size_box2(1)/2):yc(byu)+fix(size_box2(1)/2)-1;
    if xp(end)>size(im0gray,2) || yp(end)>size(im0gray,1) || xp(1)<1 || yp(1)<1
        imt1=uint8(zeros(size_box2));
        if xp(end)>size(im0gray,2);xp=xp(1):size(im0gray,2);end
        if yp(end)>size(im0gray,1);yp=yp(1):size(im0gray,1);end
        if xp(1)<1;xp=1:xp(end);end
        if yp(1)<1;yp=1:yp(end);end
        size_box2(2)/2-length(xp)/2+1:size_box2(2)/2-length(xp)/2+length(xp);
        imt1(size_box2(1)/2-fix(length(yp)/2)+1:size_box2(1)/2-fix(length(yp)/2)+length(yp),  size_box2(2)/2-fix(length(xp)/2)+1:size_box2(2)/2-fix(length(xp)/2)+length(xp))=im0gray(yp,xp);
    else
        imt1=im0gray(yp,xp);
    end
    switch mpara.case_filename
        case 'index_yi_xi'
            filename_temp=[mpara.filename_save '_n' num2str(byu) '_y' num2str(yp(1)) '_x' num2str(xp(1))];
            filepath_opt01=[mpara.filepath_save filename_temp];
    end;%figure(1);imshow(ims)

    ims(:,:,1)=imt1;ims(:,:,2)=imt1;ims(:,:,3)=imt1;
    imt1rgb=im0(yp,xp,:);
    if mpara.flag.save_unet==1
        switch  mpara.flag.save_train_path_case
            case {1,2}
                if ~exist([filepath_opt01 filesep 'images'], 'dir');mkdir([filepath_opt01 filesep 'images']);end
                %if ~exist([filepath_opt01 filesep 'imagesRGB'], 'dir');mkdir([filepath_opt01 filesep 'imagesRGB']);end
                imwrite(ims,[filepath_opt01 filesep 'images' filesep filename_temp '.png']);
                %imwrite(imt1rgb,[filepath_opt01 filesep 'imagesRGB' filesep  filesep filename_temp '.png']);
            case 3

        end
    end
    if isfield(mpara,'filepath_save2')==1
        filepath_opt02=[mpara.filepath_save2 filename_temp];
        if mpara.flag.save_matlabss~=0
            path_matss=[mpara.filepath_save2 'images' filesep];
            if ~exist(path_matss,'dir');mkdir(path_matss);end
            if mpara.flag.save_matlabss==1
                imwrite(imt1,[path_matss filename_temp '.png']);
            end
            if mpara.flag.save_matlabss==3
                imwrite(ims,[path_matss filename_temp '.png']);
            end
        end
    end

    switch mpara.case_save_mask
        case 'mask_from_groundtruth'
            if isfield(mpara,'mask_cells')==1
                bws0=mpara.mask_cells(yp,xp);
                if sum(bws0(:))==0
                    %bws=false(size(bws0));
                    %bwsu=uint8(bws);bwsu(bws==1)=255;
                    %imwrite(bwsu,[filepath_opt01 filesep 'masks' filesep  filesep filename_temp '_1.png']);
                else
                    bwsc=false(size(bws0));bwsc(fix(size(bws0,2)/2),fix(size(bws0,1)/2))=true;
                    bwsc2=double(bwsc).*double(bws0);
                    idbc=find(bwsc2~=0);
                    bws=false(size(bws0));
                    exist_groundtruth=1;
                    if isempty(idbc)~=1
                        bws(bws0==bwsc2(idbc))=true;
                        %                         figure(1);imagesc_bw(imt1,[0 255],'gray',255,{bws},{'r'},-1,-1)
                        %                         imF2 = insertObjectAnnotation(imt1, 'rectangle',sbox(bb,:), {''},'color',{'yellow'},'LineWidth',3);
                        %                         figure(21000);imshow(imF2);set(gcf,'Color','w');

                    else
                        
                        bws0yolo=mpara.mask_cells(bboxD(byu,2):bboxD(byu,2)+bboxD(byu,4)-1,bboxD(byu,1):bboxD(byu,1)+bboxD(byu,3)-1);
                       
                       % bws0yolo=data1{1, 1}.masks.atlas_allcell_N(bboxD(bb,2):bboxD(bb,2)+bboxD(bb,4)-1,bboxD(bb,1):bboxD(bb,1)+bboxD(bb,3)-1);

                        uniq=unique(bws0yolo);
                        
                        %figure(1);imagesc(bws0yolo)
                        clear qarea
                        if length(uniq)>=2
                            for qq=1:length(uniq)
                                if uniq(qq)~=0
                                    forsumbws=bws0yolo(bws0yolo==uniq(qq));
                                    qarea(qq)=length(double(forsumbws));
                                end
                            end
                            [m,idmaxv]=max(qarea);
                            bws=false(size(bws0));
                              
                            if length(idmaxv)==1
                                bws(bws0==uniq(idmaxv))=true;
                            else
                                for dd=1:length(idmaxv)
                                    bwd=false(size(bws0));
                                    bwd(bws0==uniq(idmaxv(dd)))=true;
                                    [dist_existu]=bwdistant02(bwsc,bwd);
                                    dis(dd)=dist_existu.shortest_dist;
                                end
                                [~,idminv]=min(dis);
                                bws(bws0==uniq(idmaxv(idminv)))=true;
                            end
                        else
                            exist_groundtruth=0;
                        end

%                         if bb==14
%                         figure(2);imagesc_bw(imt1,[0 255],'gray',255,{bws},{'r'},-1,-1)
%                         end
                    end
                    
                    if exist_groundtruth==1
                        bwsu=uint8(bws);bwsu(bws==1)=255;
                        
                        roi=roical_02(double(bws),double(bws));% y-x
                        xcenter_norm=fix(roi.center(2))/size(bws,2);
                        ycenter_norm=fix(roi.center(1))/size(bws,1);
                        xbox_norm=bboxD(byu,3)/size(bws,2);
                        ybox_norm=bboxD(byu,4)/size(bws,1);
                        yolo5_txt=[0 xcenter_norm ycenter_norm xbox_norm ybox_norm];


                        if mpara.flag.save_unet==1
                            if ~exist([filepath_opt01 filesep 'masks'], 'dir');mkdir([filepath_opt01 filesep 'masks']);end
                            if ~exist([filepath_opt01 filesep 'labels'], 'dir');mkdir([filepath_opt01 filesep 'labels']);end
                            imwrite(bwsu,[filepath_opt01 filesep 'masks' filesep  filesep filename_temp '_1.png']);
                            writematrix(yolo5_txt,[filepath_opt01 filesep 'labels' filesep filename_temp '.txt'],'Delimiter',' ');
                        end
                        if isfield(mpara,'filepath_save2')==1
                            filepath_opt02=[mpara.filepath_save2 filename_temp];
                            if mpara.flag.save_matlabss~=0
                                path_matss_L=[mpara.filepath_save2 'labels' filesep];
                                if ~exist(path_matss_L,'dir');mkdir(path_matss_L);end
                                if mpara.flag.save_matlabss==1
                                    imwrite(ims,[path_matss_L filename_temp '_1.png']);
                                end
                                if mpara.flag.save_matlabss==3
                                    bwsu0=uint8(bws);bwsu0(bwsu0==1)=255;
                                    bwsu1(:,:,1)=bwsu0;bwsu1(:,:,2)=bwsu0;bwsu1(:,:,3)=bwsu0;
                                    path_matss_L=[path_matss0(1:end-1) filesep 'labels' filesep];
                                    if ~exist(path_matss_L,'dir');mkdir(path_matss_L);end
                                    imwrite(ims,[path_matss_L filename_temp '_1.png']);
                                end
                            end
                        end
                    end
                end
            end
            
        case 'One_cell'
            bws0=mpara.mask_cells(yp,xp);
            bws=false(size(bws0));bws(bws0==byu)=true;  
            bwsu=uint8(bws);bwsu(bws==1)=255;
            roi=roical_02(double(bws),double(bws));% y-x
            xcenter_norm=fix(roi.center(2))/size(bws,2);
            ycenter_norm=fix(roi.center(1))/size(bws,1);
            xbox_norm=bboxD(byu,3)/size(bws,2);
            ybox_norm=bboxD(byu,4)/size(bws,1);
            yolo5_txt=[0 xcenter_norm ycenter_norm xbox_norm ybox_norm];
 
            if mpara.flag.save_unet==1
                if ~exist([filepath_opt01 filesep 'masks'], 'dir');mkdir([filepath_opt01 filesep 'masks']);end
                if ~exist([filepath_opt01 filesep 'labels'], 'dir');mkdir([filepath_opt01 filesep 'labels']);end
                imwrite(bwsu,[filepath_opt01 filesep 'masks' filesep  filesep filename_temp '_1.png']);
                writematrix(yolo5_txt,[filepath_opt01 filesep 'labels' filesep filename_temp '.txt'],'Delimiter',' ');
            end
            if isfield(mpara,'filepath_save2')==1
                filepath_opt02=[mpara.filepath_save2 filename_temp];
                if mpara.flag.save_matlabss~=0
                    path_matss_L=[mpara.filepath_save2 'labels' filesep];
                    if ~exist(path_matss_L,'dir');mkdir(path_matss_L);end
                    if mpara.flag.save_matlabss==1
                        imwrite(bwsu,[path_matss_L filename_temp '_1.png']);
                    end
                    if mpara.flag.save_matlabss==3
                        bwsu0=uint8(bws);bwsu0(bwsu0==1)=255;
                        bwsu1(:,:,1)=bwsu0;bwsu1(:,:,2)=bwsu0;bwsu1(:,:,3)=bwsu0;
                        imwrite(bwsu1,[path_matss_L filename_temp '_1.png']);
                    end
                end
            end
    end
    
    if mod(byu,5000)==0;byu
        toc
    end
    
end