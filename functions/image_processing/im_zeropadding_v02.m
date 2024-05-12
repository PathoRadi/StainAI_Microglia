function data1=im_zeropadding_v02(data1,flag,size_zpe)
% (Dp3) data1=im_zeropadding_v02(data1,flag,size_zpe)
%     padding extend zeros (size_zpe) to original images
%{
      input:
          data1.im0
               .imbackground
          size_zpe=[256, 256];  %padding size, ex:%      128  
                                                  % 128 - [] - 128
                                                  %      128 
          flag.imzp=1;   %=1 to padding zeros
      output:
          data1.zeropadding_sizeext=size_zpe;
          data1.im0
               .imbackground
               .im0gray
      check:
          if isfield(data1,'masks_CRBG')==1 
              data1.masks_CRBG.bbox2=bboxN % box position [x,y,rx,ry] of small image
              data1.masks_CRBG.atlas_allcellsort => data1.masks_CRBG.atlas_allcell_N
              data1.masks_CRBG.bbox=bboxD0 % bounding box [x,y,dx,dy] from data1.masks_CRBG.atlas_allcell_N
          if isfield(data1,'masks_URBG')==1
              data1.masks_URBG.atlas_allcellsort => data1.masks_URBG.atlas_allcell_N
       save files: in [data1.info.filepath_image 'results']
           (1) [data1.info.filename_image(1:end-4) '_gray.jpg']
           (2) [data1.info.filename_image(1:end-4) '.jpg']
           (3) [data1.info.filename_image(1:end-4) '__L5.png'] % reduce resolution /5
           (4) [data1.info.filename_image(1:end-4) '__L10.png'] % reduce resolution /10
           (5) [data1.info.filename_image(1:end-4) '__L20.png'] % reduce resolution /20
           (6) [data1.info.filename_image(1:end-4) '__L40.png'] % reduce resolution /40
           (7) [data1.info.filename_image(1:end-4) '_grayM.jpg'] % grayscale with brain mask

%}

if flag.imzp==1; %train_imsize{2};
    if size(data1.im0,1) == data1.info.imOrig_size(1) && size(data1.im0,2) == data1.info.imOrig_size(2) || data1.info.pixel_size~=0.464
        %if data1.info.pixel_size~=0.464 % move to loadimage_and_getBackground_v06
        %end
        data1.zeropadding_sizeext=size_zpe;
        if flag.im_reverse==1 % fill 255 in white background image
            im0zp=uint8(255*ones(size(data1.im0,1)+size_zpe(1),size(data1.im0,2)+size_zpe(2),size(data1.im0,3)));
        else % 0 255 in black background image
            im0zp=uint8(zeros(size(data1.im0,1)+size_zpe(1),size(data1.im0,2)+size_zpe(2),size(data1.im0,3)));
        end
        im0zp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.im0,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.im0,2),:)=data1.im0;clear data1.im0
        data1.im0=im0zp;clear im0zp;data1.info.im0_size=size(data1.im0,[1 2]);
        if isfield(data1,'imbackground')==1
            imbackgroundzp=uint8(false(size(data1.imbackground,1)+size_zpe(1),size(data1.imbackground,2)+size_zpe(2),size(data1.imbackground,3)));
            imbackgroundzp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.imbackground,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.imbackground,2),:)=data1.imbackground;clear data1.imbackground
            data1.imbackground=imbackgroundzp;clear imbackgroundzp
        end
        im0grayzp=uint8(false(size(data1.im0gray,1)+size_zpe(1),size(data1.im0gray,2)+size_zpe(2),size(data1.im0gray,3)));
        im0grayzp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.im0gray,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.im0gray,2),:)=data1.im0gray;clear data1.imbackground

        data1.im0gray=im0grayzp; clear im0grayzp
%         if flag.im_reverse==1
%             data1.im0gray = 255-rgb2gray(data1.im0);
%         else
%             data1.im0gray = rgb2gray(data1.im0);
%         end

    end
    if isfield(data1,'masks_CRBG')==1
        if isfield(data1.masks_CRBG,'bbox2')==1;bboxN=data1.masks_CRBG.bbox2(:,1:4);bboxN(:,1)=data1.masks_CRBG.bbox2(:,1)+ceil(size_zpe(2)/2);bboxN(:,2)=data1.masks_CRBG.bbox2(:,2)+ceil(size_zpe(1)/2); %x-y
            data1.masks_CRBG.bbox2=bboxN;clear bboxN
        end
        data1.masks_CRBG.atlas_allcell_N=uint16(false(size(data1.masks_CRBG.atlas_allcellsort,1)+size_zpe(1),size(data1.masks_CRBG.atlas_allcellsort,2)+size_zpe(2),size(data1.masks_CRBG.atlas_allcellsort,3)));
        data1.masks_CRBG.atlas_allcell_N(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.masks_CRBG.atlas_allcellsort,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.masks_CRBG.atlas_allcellsort,2),:)=data1.masks_CRBG.atlas_allcellsort;
        data1.masks_CRBG=rmfield(data1.masks_CRBG,'atlas_allcellsort');
    end
    %10932
    pause(3);%close all
    if isfield(data1,'masks_CRBG')==1
        cmap=parula(max(data1.masks_CRBG.atlas_allcell_N(:)));
        imF1 = labeloverlay(data1.im0gray,data1.masks_CRBG.atlas_allcell_N,'Colormap',cmap,'Transparency',0.7);
        %figure(10801);imshow(imF1);set(gcf,'color','w');
        %figure(1);imshow(data1.im0gray);set(gcf,'color','w');
        stats = regionprops(data1.masks_CRBG.atlas_allcell_N,'BoundingBox','Centroid');
        bboxD0=ceil(cell2mat({stats(:).BoundingBox}'));
        bcenter=[reshape([stats.Centroid],2,length(stats))]';idn=find(isnan(bcenter(:,1))==0);
        data1.masks_CRBG.bbox=bboxD0(idn,:);clear bboxD0 bcenter stats
    end
    
    if isfield(data1,'masks_URBG')==1
        data1.masks_URBG.atlas_allcell_N=uint16(false(size(data1.masks_URBG.atlas_allcellsort,1)+size_zpe(1),size(data1.masks_URBG.atlas_allcellsort,2)+size_zpe(2),size(data1.masks_URBG.atlas_allcellsort,3)));
        data1.masks_URBG.atlas_allcell_N(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.masks_URBG.atlas_allcellsort,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.masks_URBG.atlas_allcellsort,2),:)=data1.masks_URBG.atlas_allcellsort;
        data1.masks_URBG=rmfield(data1.masks_URBG,'atlas_allcellsort');
    end
    
    
    
    %             xL=data1.masks_CRBG.bbox(:,3); max(xL)
    %             yL=data1.masks_CRBG.bbox(:,4); max(yL)
    %             im0=data1.im0gray(data1.masks_CRBG.bbox(dn,2):data1.masks_CRBG.bbox(dn,2)+data1.masks_CRBG.bbox(dn,4),data1.masks_CRBG.bbox(dn,1):data1.masks_CRBG.bbox(dn,1)+data1.masks_CRBG.bbox(dn,3));
    %             bw0=data1.masks_CRBG.atlas_allcell_N(data1.masks_CRBG.bbox(dn,2):data1.masks_CRBG.bbox(dn,2)+data1.masks_CRBG.bbox(dn,4),data1.masks_CRBG.bbox(dn,1):data1.masks_CRBG.bbox(dn,1)+data1.masks_CRBG.bbox(dn,3));
    %             bw0(bw0~=dn)=0;bw0(bw0==dn)=1;
    %             %figure(123424);imagesc_bw(im0,[0 255],'gray',255,{bw0},{'c','g','r'},-1 ,-1);
    %
    
    
    %%% save image
   % imsize=size(data1.im0);

%     result_folder=[data1.info.filepath_image 'results' filesep 'images' filesep];
%     if ~exist(result_folder,'dir');mkdir(result_folder);end


%     if ~exist([result_folder data1.info.filename_image(1:end-4) '_gray_zp.jpg'],'file')
%         imt0=data1.im0gray(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+data1.info.imOrig_size(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+data1.info.imOrig_size(2),:);
%         imwrite(imt0, [result_folder data1.info.filename_image(1:end-4) '_gray.jpg']);
%         cmap=[1,0,0];%parula(max(bwtemp(:)));
%         imF1 = labeloverlay(imt0,data1.imbackground(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+data1.info.imOrig_size(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+data1.info.imOrig_size(2)),'Colormap',cmap,'Transparency',0.85);
%         imwrite(imF1, [result_folder data1.info.filename_image(1:end-4) '_grayM.jpg']);
%         imt0=data1.im0(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+data1.info.imOrig_size(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+data1.info.imOrig_size(2),:);
%         imwrite(imt0, [result_folder data1.info.filename_image(1:end-4) '.jpg']);
% 
%         imwrite(data1.im0gray, [result_folder data1.info.filename_image(1:end-4) '_gray_zp.jpg']);
%         imwrite(data1.im0,[result_folder data1.info.filename_image(1:end-4) '_zp.jpg']);
%     end

% 
%     if ~exist([result_folder data1.info.filename_image(1:end-4) '_gray.jpg'],'file')
%         imwrite(data1.im0gray, [result_folder data1.info.filename_image(1:end-4) '_gray.jpg']);
%     end
%     if exist([result_folder data1.info.filename_image(1:end-4) '_gray.png'],'file')
%         delete(data1.im0gray, [result_folder data1.info.filename_image(1:end-4) '_gray.png']);
%     end


%     if ~exist([result_folder data1.info.filename_image(1:end-4) '__L5.jpg'],'file');
%         im0L=imresize(data1.im0,[imsize(1) imsize(2)]/5,'Method','bilinear');
%         imwrite(im0L,[result_folder data1.info.filename_image(1:end-4) '__L5.jpg']);
%     end
%     if ~exist([result_folder data1.info.filename_image(1:end-4) '__L10.jpg'],'file');
%         im0L=imresize(data1.im0,[imsize(1) imsize(2)]/10,'Method','bilinear');
%         imwrite(im0L,[result_folder data1.info.filename_image(1:end-4) '__L10.jpg']);
%     end
%     if ~exist([result_folder data1.info.filename_image(1:end-4) '__L20.jpg'],'file');
%         im0L=imresize(data1.im0,[imsize(1) imsize(2)]/20,'Method','bilinear');
%         imwrite(im0L,[result_folder data1.info.filename_image(1:end-4) '__L20.jpg']);
%     end
%     if ~exist([result_folder data1.info.filename_image(1:end-4) '__L40.jpg'],'file');
%         im0L=imresize(data1.im0,[imsize(1) imsize(2)]/20,'Method','bilinear');
%         imwrite(im0L,[result_folder data1.info.filename_image(1:end-4) '__L40.jpg']);
%     end
%     if exist([result_folder data1.info.filename_image(1:end-4) '.png'],'file');
%         delete([result_folder data1.info.filename_image(1:end-4) '.png']);
%     end
%     if exist([result_folder data1.info.filename_image(1:end-4) '_gray.png'],'file');
%         delete([result_folder data1.info.filename_image(1:end-4) '_gray.png']);
%     end   
%     if exist([result_folder data1.info.filename_image(1:end-4) '_grayM.png'],'file');
%         delete([result_folder data1.info.filename_image(1:end-4) '_grayM.png']);
%     end



    %             bboxD2=changeBoxsize2(bboxD,[256 256]);
    %             imsize=size(data1.masks_CRBG.atlas_allcell_N); dd=122;
    %             [bboxS,corrd_on_image,corrd_on_smallbox]=shiftbox2imsize(bboxD2,imsize);
    %             bwtemp0(corrd_on_smallbox(dd,1):corrd_on_smallbox(dd,2),corrd_on_smallbox(dd,3):corrd_on_smallbox(dd,4))=data1.masks_CRBG.atlas_allcell_N(corrd_on_image(dd,1):corrd_on_image(dd,2),corrd_on_image(dd,3):corrd_on_image(dd,4));
    %             bwtemp=uint16(false(size(bwtemp0)));
    %             bwtemp(bwtemp0==dd)=1;bwtemp(bwtemp0~=dd)=0;
    %             bwtemp2=squeeze(bbmask2(dd,:,:));
    %             ims1(corrd_on_smallbox(dd,1):corrd_on_smallbox(dd,2),corrd_on_smallbox(dd,3):corrd_on_smallbox(dd,4))=data1.im0gray(corrd_on_image(dd,1):corrd_on_image(dd,2),corrd_on_image(dd,3):corrd_on_image(dd,4));
    %             %figure(10711);imagesc_bw(ims1,[0 255],'gray',255,{bwtemp,bwtemp2},{'b','g','r'},[2 -2],-1);
    
    % outputImage = insertObjectAnnotation(data1.im0gray, 'rectangle', bboxD, {''},'color',{'g'});
    %imwrite(imF1,[data1.info.filepath_output filesep data1.info.imat_name '_Im_masks.png']);
    %imwrite(data1.masks_CRBG.atlas_allcell_N,[data1.info.filepath_output filesep data1.info.imat_name '_masks.png']);
    %  imt=single(data1.im0);im1gray=uint8(255-((imt(:,:,1).^2+imt(:,:,2).^2+imt(:,:,3).^2)/3).^0.5);clear imt
end