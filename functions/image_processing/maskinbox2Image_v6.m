function [atlas_allcell,bboxS,bbmask1, mind, mbarea, eqid]=maskinbox2Image_v6(im0,bbox0,bbmask0,mpara,varargin)
% (Dp1.2.1.4) [atlas_allcell,bboxS,bbmask1, mind, mbarea, eqid]=maskinbox2Image_v6(im0,bbox0,bbmask0,mpara,varargin)
%    merge bbmask (2d bwmask in 3dmatrix from the position at bbox of im0 with specific rules
%{
    Input:
        im0:            grayscale image
        bbox0:          box position of masks: [x,y,mpara.box_size(1) mpara.box_size(2)] 
        bbmask0:        bwmask, n+2d ex:(nn,256x256)
        mpara.sort=L;   %=L, merge start from largest cell area
                        %=S, merge start from smallest cell area
                        %=Others, merge start with the original order of input bbox0
        mpara.cell_size_max_threshold=12000;  % max merge mask size in pixels
        mpara.cell_size_min_threshold=500;    % create mask if the fragment > cell_size_min_threshold
     Save files:
        if isfield(mpara,'save_temp_file') % save parameters 'bbm','kk','atlas_allcell','mind','mbarea'
        varargin{1}=1   %=1 to shift coordinates, if coordinates in bbox < 0 or > size of im0
     Output:
        atlas_allcell: cell masks in atlas form
        bboxS: shifted box position of masks 
        bbmask1: mask after merge, n+2d
        mind: the index of merged masks
        mbarea: the original area of merged masks
        eqid(n)=1,  if the fragment cannot be assigned into the big components
%}



if isempty(varargin) == 1
    flag_bxcorrdorig=0;
else
    flag_bxcorrdorig=varargin{1};
end

% get total number of box
if iscell(bbox0)==1
    n1=cellfun(@numel,bbox0)/4;
    bbox1=zeros(sum(n1),4);
    bbmask1=uint8(false(sum(n1),size(bbmask0{1},2),size(bbmask0{1},3)));
    for bn=1:size(bbox0,1)
        if size(bbmask0{bn},1)~=0
            if bn==1
                bbox1(1:n1(bn),:)=bbox0{bn};
                bbmask1(1:n1(bn),:,:)=bbmask0{bn};
                blbn=n1(bn);
            else
                bbox1(blbn+1:blbn+n1(bn),:)=bbox0{bn};
                bbmask1(blbn+1:blbn+n1(bn),:,:)=bbmask0{bn};
                blbn=blbn+n1(bn);
            end
        end
    end
else
    bbox1=bbox0;
    bbmask1=bbmask0;
end
bbmask1(bbmask1>1)=0;
clear bbox0 bbmask0
area0=sum(sum(bbmask1,2),3);
area0(:,2)=1:size(bbmask1,1);
switch mpara.sort
    case 'L'
        area0s=sortrows(area0,-1);
    case 'S'
        area0s=sortrows(area0,1);
    otherwise
        area0s=area0;
end
clear area0


bEx=256+100;
imssize=[bbox1(:,3) bbox1(:,4)];
if flag_bxcorrdorig==1
    [bboxS,corrd_on_image,corrd_on_smallbox]=shiftbox2imsize(bbox1,size(im0));
    bbox1E=bbox1;bbox1E(:,3)=bEx;bbox1E(:,4)=bEx;bbox1E(:,1)=bbox1(:,1)-bEx/2+imssize(1)/2;bbox1E(:,2)=bbox1(:,2)-bEx/2+imssize(2)/2;
    [bboxSE,corrd_on_imageE,corrd_on_smallboxE]=shiftbox2imsize(bbox1E,size(im0));
    bbmask1E=false(size(bbmask1,1),bEx,bEx);
    bbmask1E(:,bEx/2-imssize(2)/2+1:bEx/2+imssize(2)/2,bEx/2-imssize(1)/2+1:bEx/2+imssize(1)/2)=bbmask1;
    
else
    bboxS=bbox1;
    corrd_on_image=[bboxS(:,2) bboxS(:,2)+bboxS(:,4)-1, bboxS(:,1) bboxS(:,1)+bboxS(:,3)-1];
end


if isfield(mpara,'save_temp_file')
    if exist(mpara.save_temp_file,'file')~=0
        bbm='';
        load(mpara.save_temp_file)
        if isempty(bbm)==1;bbm=bbi;
            save(mpara.save_temp_file,'bbm','kk','atlas_allcell','mind','mbarea','eqid','-v7.3');
        end
        bn=bbm+1:size(bbmask1,1);
    else
        mbarea=repmat({''},size(bbmask1,1),1);
        mind = repmat({''},size(bbmask1,1),1);
        bn=1:size(bbmask1,1);
        kk=size(bbmask1,1)+1;
        if size(bbmask1,1)<=55535
            atlas_allcell=uint16(false(size(im0,1),size(im0,2)));
        else
            atlas_allcell=uint32(false(size(im0,1),size(im0,2)));
        end
    end
else
    mbarea=repmat({''},size(bbmask1,1),1);
    mind = repmat({''},size(bbmask1,1),1);
    bn=1:size(bbmask1,1);
    kk=size(bbmask1,1)+1;
    if size(bbmask1,1)<=55535
        atlas_allcell=uint16(false(size(im0,1),size(im0,2)));
    else
        atlas_allcell=uint32(false(size(im0,1),size(im0,2)));
    end
end

parfill.fill_orient='y';parfill.fill_range = [-1 -8];parfill.fill_connectivity = 4;
%bmaskF0=bbmask1*0;
eqid=false(size(bbmask1,1),1);
% bn=3105:size(bbmask1,1);
mpara.bn=bn;
if isempty(bn)~=1  %<=size(bbmask1,1)
    for bbm=bn
        bb=area0s(bbm,2);
        fremove=0;
        flag_check_bw_r0=0;flag_check_bw_r1=0;bw2du1_r{1}=0;bw2du2_r{1}=0;
        flag_check_bw_r3=0;bw_existu1_r{1}=0;bw_existu2_r{1}=0;
        %bbi
        if mod(bbm,500)==1;tic;end
        %%% get the image ans mask in the box 
%         ims1=double(squeeze(im0(corrd_on_image(bb,1):corrd_on_image(bb,2),corrd_on_image(bb,3):corrd_on_image(bb,4))));
%         if flag_bxcorrdorig==1
%             bw2d=false(size(ims1));bw2d=logical(squeeze(bbmask1(bb,corrd_on_smallbox(bb,1):corrd_on_smallbox(bb,2),corrd_on_smallbox(bb,3):corrd_on_smallbox(bb,4))));
%             mask1=squeeze(atlas_allcell(corrd_on_image(bb,1):corrd_on_image(bb,2),corrd_on_image(bb,3):corrd_on_image(bb,4)));
%         else
%             bw2d=logical(squeeze(bbmask1(bb,:,:)));
%         end
   %    figure(2314);imagesc(mask1);axis image
%figure(1112);imagesc_bw(ims1,[0 255],'gray',255,{bw2d},{'b','g','r'},-1,-1);


        ims1=double(squeeze(im0(corrd_on_imageE(bb,1):corrd_on_imageE(bb,2),corrd_on_imageE(bb,3):corrd_on_imageE(bb,4))));
        if flag_bxcorrdorig==1
            bw2d=false(size(ims1));bw2d=logical(squeeze(bbmask1E(bb,corrd_on_smallboxE(bb,1):corrd_on_smallboxE(bb,2),corrd_on_smallboxE(bb,3):corrd_on_smallboxE(bb,4))));
            mask1=squeeze(atlas_allcell(corrd_on_imageE(bb,1):corrd_on_imageE(bb,2),corrd_on_imageE(bb,3):corrd_on_imageE(bb,4)));
        else
            bw2d=logical(squeeze(bbmask1(bb,:,:)));
        end
     %   figure(1113);imagesc_bw(ims1,[0 255],'gray',255,{bw2d},{'b','g','r'},-1,-1);
%             if bb>803
%                    umask1=unique(mask1);
%                                  cmap=parula(max(length(umask1)));
%                                  figure(20);imagesc_bw(ims1,[0 255],'gray',255,mask1,cmap,-1,-1);title(num2str(bb));
%                                   pause(1)      
%          end

%          if bb==20000
%             bb 
%          end
        bw2d=BW_Fill_Holes_v02(bw2d, parfill);
        [bw2d, bw2d_r0]=removebwdist(bw2d, 7);
        if sum(bw2d_r0{1}(:))~=0
            % figure(1111);imagesc_bw(ims1,[0 255],'gray',255,{bw2d,bw2d_r{1}},{'b','g','r'},-1,-1);
             flag_check_bw_r0=1;
        end
%         figure(1);imagesc_bw(ims1,[0 255],'gray',255,{bw2d},{'b','g','r'},-1,-1);
        %figure(2);imagesc_bw(ims1,[0 255],'gray',255,{bw_overlap,bw_exist,bw2d},{'b','g','r'},-1,-1);title(num2str(bb))
        %%% check the overlap in the box
        num_bw2d=sum(bw2d(:));
%         bw2de=false(size(bw2d));bw2de(1:end,1)=1;bw2de(1:end,end)=1;bw2de(1,1:end)=1;bw2de(end,1:end)=1;
%        
%         bw2de=bw2de.*bw2d;

        if num_bw2d~=0 && num_bw2d<=mpara.cell_size_max_threshold
            [atlas_allcell,mind,mbarea,eqid,fremove,bw2du1_r,bw_existu1_r,be_rnum1]=MergeOverlap_v6(bb,bb,0,mpara,flag_bxcorrdorig,im0,ims1,bw2d,num_bw2d,mask1,atlas_allcell,corrd_on_imageE,parfill,mind,eqid,mbarea);
            mask1=squeeze(atlas_allcell(corrd_on_imageE(bb,1):corrd_on_imageE(bb,2),corrd_on_imageE(bb,3):corrd_on_imageE(bb,4)));
            if sum(bw2du1_r{1}(:))~=0
                flag_check_bw_r1=1;
            end;%figure(1);imagesc(bw_existu1_r{1});axis image
            if sum(bw_existu1_r{1}(:))~=0
                flag_check_bw_r3=1;
            end
        else
            mind{bb,1}='';mbarea{bb,1}='';
        end
        
         %   %{
%          if bb>803
%                    umask1=unique(mask1);
%                                  cmap=parula(max(length(umask1)));
%                                  figure(21);imagesc_bw(ims1,[0 255],'gray',255,mask1,cmap,-1,-1);title(num2str(bb));
%                                   pause(1)      
%          end
    %}
        
        if fremove==1
            if isempty(find(atlas_allcell==bb))~=1
                fprintf('index wrong')
                break
            end
        end
        if  flag_check_bw_r0==1;
            for rr=1:length(bw2d_r0)
                bw2d=bw2d_r0{rr};
                num_bw2d=sum(bw2d(:));
                if num_bw2d>=mpara.cell_size_min_threshold;
                    [atlas_allcell,mind,mbarea,eqid,fremove,bw2du2_r,bw_existu2_r]=MergeOverlap_v6(kk,bb,bb,mpara,flag_bxcorrdorig,im0,ims1,bw2d,num_bw2d,mask1,atlas_allcell,corrd_on_imageE,parfill,mind,eqid,mbarea);
                    mask1=squeeze(atlas_allcell(corrd_on_imageE(bb,1):corrd_on_imageE(bb,2),corrd_on_imageE(bb,3):corrd_on_imageE(bb,4)));
                    kk=kk+1;
                end
            end
        end
        if  flag_check_bw_r1==1;
            for rr=1:length(bw2du1_r)
                bw2d=bw2du1_r{rr};
                num_bw2d=sum(bw2d(:));
                if num_bw2d>=mpara.cell_size_min_threshold;
                    [atlas_allcell,mind,mbarea,eqid,fremove]=MergeOverlap_v6(kk,bb,bb,mpara,flag_bxcorrdorig,im0,ims1,bw2d,num_bw2d,mask1,atlas_allcell,corrd_on_imageE,parfill,mind,eqid,mbarea);
                    mask1=squeeze(atlas_allcell(corrd_on_imageE(bb,1):corrd_on_imageE(bb,2),corrd_on_imageE(bb,3):corrd_on_imageE(bb,4)));
                    kk=kk+1;
                end
            end
        end
        if sum(bw2du2_r{1}(:))~=0
            for rr=1:length(bw2du2_r)
                bw2d=bw2du2_r{rr};
                num_bw2d=sum(bw2d(:));
                if num_bw2d>=mpara.cell_size_min_threshold;
                    [atlas_allcell,mind,mbarea,eqid,fremove]=MergeOverlap_v6(kk,bb,bb,mpara,flag_bxcorrdorig,im0,ims1,bw2d,num_bw2d,mask1,atlas_allcell,corrd_on_imageE,parfill,mind,eqid,mbarea);
                    mask1=squeeze(atlas_allcell(corrd_on_imageE(bb,1):corrd_on_imageE(bb,2),corrd_on_imageE(bb,3):corrd_on_imageE(bb,4)));
                    kk=kk+1;
                end
            end
        end
        if flag_check_bw_r3==1
            for rr=1:length(bw_existu1_r)
                bw2d=bw_existu1_r{rr};
                num_bw2d=sum(bw2d(:));
                if num_bw2d>=mpara.cell_size_min_threshold;
                    %if rr<=length(be_rnum1)  % only consider the biggest one if the overlap fragments from the same region
                    try    
                        [atlas_allcell,mind,mbarea,eqid,fremove]=MergeOverlap_v6(kk,bb,be_rnum1{rr},mpara,flag_bxcorrdorig,im0,ims1,bw2d,num_bw2d,mask1,atlas_allcell,corrd_on_imageE,parfill,mind,eqid,mbarea);
                    catch
                        bbm
                    end
                        mask1=squeeze(atlas_allcell(corrd_on_imageE(bb,1):corrd_on_imageE(bb,2),corrd_on_imageE(bb,3):corrd_on_imageE(bb,4)));
                        kk=kk+1;
                    %end
                end
            end
        end
%         if sum(bw_existu2_r{1}(:))~=0
%             for rr=1:length(bw_existu2_r)
%                 bw2d=bw_existu2_r{rr};
%                 num_bw2d=sum(bw2d(:));
%                if num_bw2d>=mpara.cell_size_min_threshold;
%                     [atlas_allcell,mind,mbarea,eqid,fremove]=MergeOverlap_v6(kk,bb,mpara,flag_bxcorrdorig,im0,ims1,bw2d,num_bw2d,mask1,atlas_allcell,corrd_on_imageE,parfill,mind,eqid,mbarea);
%                     kk=kk+1;
%                 end
%             end
%         end
        
        
        
        if mod(bbm,500)==0;bbm
            ddd=cellfun(@length, mind);
            snum=(find(ddd~=0));
            xxx=unique(atlas_allcell);xxx=xxx(xxx~=0);
            [v,ia]=setdiff(xxx,snum);
            if isfield(mpara,'save_temp_file')
                save(mpara.save_temp_file,'bbm','kk','atlas_allcell','mind','mbarea','eqid','-v7.3');
            end
            %if bb==10000
         %  figure(1);imagesc_bw(ims1,[0 255],'gray',255,{bw_exist,bw2d,bw_overlap},{'b','g','r'},-1,-1)
         if mod(bbm,10000)==0;
           %  cmap=parula(max(atlas_allcell(:)));
%             imF = labeloverlay(im0(8900:8900+2000,1:1+2000,:),atlas_allcell(8900:8900+2000,1:1+2000),'Colormap',cmap,'Transparency',0.7);
       %      imF = labeloverlay(im0,atlas_allcell,'Colormap',cmap,'Transparency',0.7);
           %  figure(1000+1);imshow(imF);
         end
          %  figure(1002);imagesc(atlas_allcell);axis image
           % end
            toc
        end
        if bbm==size(bbmask1,1)
            if isfield(mpara,'save_temp_file')
                save(mpara.save_temp_file,'bbm','kk','atlas_allcell','mind','mbarea','eqid','-v7.3');
            end
            toc
        end
    end
end