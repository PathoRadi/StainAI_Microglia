function [atlas_allcell,mind,mbarea,eqid,fremove,bw2du1_r,bw_existu1_r,be_rnum]=MergeOverlap_v6(kk,bb,be_r,mpara,flag_bxcorrdorig,im0,ims1,bw2d,num_bw2d,mask1,atlas_allcell,corrd_on_image,parfill,mind,eqid,mbarea)
bw2du1_r{1}=0;bw_existu1_r{1}=0;
if kk>length(mind)
    mind{kk,1}='';
end
if isempty(mind{kk,1})==1
    if be_r==0
        mind{kk,1}=bb;
    else
        mind{kk,1}=be_r;
    end
else
    mind{kk,1};
end

fremove=0;
mean_bw2d=mean(ims1(bw2d==1));
mbarea{kk,1}=num_bw2d;
bw_overlapAll=false(size(bw2d));bw_overlapAll(mask1~=0 & bw2d==1)=true;  % overlap area
ainfo=whos('atlas_allcell');
be_rnum={''};
%if corrd_on_image(bb,1)> 1400 && corrd_on_image(bb,2)< 1950 && corrd_on_image(bb,3)> 4300 && corrd_on_image(bb,4)< 4890
%     if bb>60366
%         bb
%         aaa=atlas_allcell(1427:1938,4352:4863);
%         ima=im0(1427:1938,4352:4863);
%         cmap=parula(max(aaa(:)));
%         imF = labeloverlay(ima,aaa,'Colormap',cmap,'Transparency',0.7);
%         figure(11502);imshow(imF);set(gcf,'color','w');
%         figure(11503);imagesc(aaa);axis image;set(gcf,'color','w');
%     end
%end


%             figure(1312);imagesc(mask1);axis image
%             umask1=unique(mask1);
%             cmap=parula(max(length(umask1)));
%             figure(3);imagesc_bw(ims1,[0 255],'gray',255,mask1,cmap,-1,-1)
if sum(bw_overlapAll(:))~=0
    %im_bw2d=ims1*0;im_bw2d(bw2d==1)=ims1(bw2d==1);
    %max_bw2d=max(im_bw2d(bw2d==1));idt=find(im_bw2d==max_bw2d(1));bw_bw2d_max=false(size(bw2d));bw_bw2d_max(idt)=true;
    
    mask2=mask1;bw2du=bw2d;bw2du(bw_overlapAll==1)=false;% un overlap region  %mean_bw2du=mean(ims1(bw2du==1));
    switch ainfo.class
        case 'uint16'
            atlas_overlap=uint16(false(size(bw2d)));
        case 'uint32'
            atlas_overlap=uint32(false(size(bw2d)));
    end
    
    atlas_overlap(bw_overlapAll==1)=mask1(bw_overlapAll==1); %overlap region atlas
    numask1=unique(atlas_overlap);numask1=numask1(numask1~=0);
    %figure(2);imagesc_bw(ims1,[0 255],'gray',255,{bw_overlapAll},{'g','g','r','c'},-1,-1);
    %figure(3);imagesc_bw(ims1,[0 255],'gray',255,{bw2d},{'b','g','r','c'},-1,-1);
    %  if sum(bw2d(:))<=8000
    for ee=1:length(numask1)
        bw_exist=false(size(bw2d));bw_exist(mask1==numask1(ee))=true;
        
        %figure(2);imagesc_bw(ims1,[0 255],'gray',255,{bw_overlap},{'b','g','r','c'},-1,-1)
        
        bw_overlap=false(size(bw2d));bw_overlap(bw_exist==1 & bw2d==1)=true;  % overlap area
        bw2du=bw2d;bw2du(bw_overlap==1)=false; % un overlap region
        bw_existu=bw_exist;bw_existu(bw_overlap==1)=false;
        num_exist=sum(bw_exist(:));num_overlap=sum(bw_overlap(:));
        %{
     figure(3);subplot(1,3,1);imagesc_bw(ims1,[0 255],'gray',255,{bw2d,bw2du},{'b','c','r','c'},-1,-1);
     figure(3);subplot(1,3,2);imagesc_bw(ims1,[0 255],'gray',255,{bw_overlapAll},{'r','g','r','c'},-1,-1);
     figure(3);subplot(1,3,3);imagesc_bw(ims1,[0 255],'gray',255,{bw_exist},{'g','g','r','c'},-1,-1);
        %}
        % title([num2str(kk) ':' num2str(num_overlap/num_bw2d) '-' num2str(num_overlap/num_exist)])
%%%% if num_overlap>mpara.num_overlap_threshold %15
            if num_overlap>sum(bw2du(:))
                if sum(bw2du(:))==0
                    mergebw=1;
                else
                    if mean(ims1(bw_overlapAll))>mean(ims1(bw2du))
                        mergebw=1;
                    else
                        mergebw=0;
                    end
                end
            else
                mergebw=0;
            end
            if (num_overlap/num_bw2d>=mpara.overlap_threshold_max) || num_overlap/num_exist>=mpara.overlap_threshold_max || mergebw==1
                if num_exist>mpara.num_exist_threshold %4000
                    if num_bw2d>mpara.num_bw2d_threshold %500
                        bw_existu(bw_overlap==1)=false;
                        bw2du(bw_overlap==1)=true;
                    else
                        mergebw=0;
                    end
                else
                    if flag_bxcorrdorig==1
                        be=numask1(ee);
                        bw_existu(bw2d==1)=true; %figure(1);imagesc(bw_existu)
                        bw2du=false(size(bw2d));
                        
                        if fremove==0
                            %                             if kk>length(mpara.bn)
                            %                                 kk
                            %                                 mind{be,1}=[mind{be,1}, mind{kk,1}];mind{kk,1}='';
                            %                             else
                            %                                 mind{be,1}=[mind{be,1}, kk];mind{kk,1}='';
                            %                             end
                            mind{be,1}=[mind{be,1}, mind{kk,1}];mind{kk,1}='';
                            mbarea{be,1}=[mbarea{be,1}, num_bw2d];mbarea{kk,1}='';
                            fremove=1;be0=numask1(ee);
                        else
                            if kk>length(mpara.bn)
                                kk
                            end
                            
                            bw_existu(mask2==be0)=true;
                            mind{be,1}=[mind{be0,1} mind{be,1}];mind{be0,1}='';
                            mbarea{be,1}=[mbarea{be0,1}, mbarea{be,1}];mbarea{be0,1}='';
                            be0=numask1(ee);
                        end
                    end
                    
                end
            else
                mergebw=0;
            end
            if mergebw==0;
                if sum(bw2du(:))~=0 && sum(bw_existu(:))~=0 && sum(bw_overlap(:))~=0
                    cc_overlap = bwconncomp(bw_overlap,4);
                    cc_existu = bwconncomp(bw_existu,4);
                    cc_bw2du = bwconncomp(bw2du,4);
                    numPixels = cellfun(@numel,cc_bw2du.PixelIdxList);
                    [~,idx] = max(numPixels);bw2du_big=false(size(bw2d));bw2du_big(cc_bw2du.PixelIdxList{idx})=1;
                    numPixels = cellfun(@numel,cc_existu.PixelIdxList);
                    [~,idx] = max(numPixels);existu_big=false(size(bw2d));existu_big(cc_existu.PixelIdxList{idx})=1;

                    % im_existu=ims1*0;im_existu(bw_existu==1)=ims1(bw_existu==1);
                    clear numPixelsO
                    numPixelsO(:,1) = cellfun(@numel,cc_overlap.PixelIdxList);
                    numPixelsO(:,2)=1:cc_overlap.NumObjects;numPixelsOs=sortrows(numPixelsO,-1);
                    for ci=1:cc_overlap.NumObjects
                        bw_ovc=false(size(bw2d));bw_ovc(cc_overlap.PixelIdxList{ci})=true;
                        
                        %  figure(111);imagesc(bw_overlap)
                        %[dist_existu]=bwdistant02(bw_existu,bw_ovc);
                        %  [dist2_bw2du]=bwdistant02(bw2du,bw_ovc);
                        
                        [dist_existu]=bwdistant02(existu_big,bw_ovc);
                        [dist2_bw2du]=bwdistant02(bw2du_big,bw_ovc);
                        
                        % [dist_existu]=bwdistant02(bw_existu_max,bw_ovc); [dist_existu,bwbridge{ci}]=bwdistant02(bw_existu_max,bw_ovc);dist_existu.shortest_dist
                        % [dist2_bw2du]=bwdistant02(bw_bw2d_max,bw_ovc);   [dist2_bw2du,bwbridge2{ci}]=bwdistant02(bw_bw2d_max,bw_ovc);dist2_bw2du.shortest_dist
                        %     figure(3);imagesc_bw(ims1,[0 255],'gray',255,{bw_exist,bw2d,bw_ovc,existu_big,bw2du_big},{'b','g','r','c',[255, 128, 0],'y','y'},[-1,-1,-1,-1,-1,-1,-1],[-1,-1,-1,-1,-1,1,1]);axis off
                        %%figure(133);imagesc_bw(ims1,[0 255],'gray',255,{bw_ovc},{'b','g','r'},-1,-1)
                        if dist_existu.shortest_dist == dist2_bw2du.shortest_dist;
                            bw_ch = bwconvhull(bw2d);rep_bw_ch=regionprops(bw_ch,'Centroid');
                            bw_bwchc=false(size(bw2d));bw_bwchc(round(rep_bw_ch.Centroid(2)),round(rep_bw_ch.Centroid(1)))=true;
                            
                            bw_existu_ch = bwconvhull(bw_existu);rep_bw_existu_ch=regionprops(bw_existu_ch,'Centroid');
                            bw_existu_chc=false(size(bw2d));bw_existu_chc(round(rep_bw_existu_ch.Centroid(2)),round(rep_bw_existu_ch.Centroid(1)))=true;
                            %      figure(3);imagesc_bw(ims1,[0 255],'gray',255,{bw_exist,bw2d,bw_ovc,bw_existu_chc,bw_bwchc},{'b','g','r','c',[255, 128, 0],'y','y'},[-1,-1,-1,1,1,1,1],[-1,-1,-1,1,1,1,1]);axis off
                            
                            [dist_existuC]=bwdistant02(bw_existu_chc,bw_ovc);
                            [dist2_bw2duC]=bwdistant02(bw_bwchc,bw_ovc);
                            if dist_existuC.shortest_dist < dist2_bw2duC.shortest_dist;
                                bw_existu(cc_overlap.PixelIdxList{ci})=true;
                                bw2du(cc_overlap.PixelIdxList{ci})=false;
                                existu_big(cc_overlap.PixelIdxList{ci})=true;
                            elseif dist_existuC.shortest_dist > dist2_bw2duC.shortest_dist;
                                bw_existu(cc_overlap.PixelIdxList{ci})=false;
                                bw2du(cc_overlap.PixelIdxList{ci})=true;
                                bw2du_big(cc_overlap.PixelIdxList{ci})=true;
                            else
                                im_bw_existu=ims1.*bw_existu;[~,idM]=max(im_bw_existu(:));
                                bw_existu_max = false(size(bw2d));bw_existu_max(idM)=1;
                                im_bw2du=ims1.*bw2du;[~,idM]=max(im_bw2du(:));
                                bw_2du_max = false(size(bw2d));bw_2du_max(idM)=1;
                                [dist_existuM]=bwdistant02(bw_existu_max,bw_ovc);
                                [dist2_bw2duM]=bwdistant02(bw_2du_max,bw_ovc);
                                % figure(31);imagesc(bw_existu);axis image
                                %  figure(3);imagesc_bw(ims1,[0 255],'gray',255,{bw_existu,bw2d,bw_ovc,bw_existu_max,bw_2du_max},{'b','g','r','c',[255, 128, 0],'y','y'},[-1,-1,-1,1,1,1,1],[-1,-1,-1,1,1,1,1]);axis off
                                
                                
                                if dist_existuM.shortest_dist < dist2_bw2duM.shortest_dist;
                                    bw_existu(cc_overlap.PixelIdxList{ci})=true;
                                    bw2du(cc_overlap.PixelIdxList{ci})=false;
                                    existu_big(cc_overlap.PixelIdxList{ci})=true;
                                elseif dist_existuM.shortest_dist > dist2_bw2duM.shortest_dist;
                                    bw_existu(cc_overlap.PixelIdxList{ci})=false;
                                    bw2du(cc_overlap.PixelIdxList{ci})=true;
                                    bw2du_big(cc_overlap.PixelIdxList{ci})=true;
                                else
                                    bw_existu(cc_overlap.PixelIdxList{ci})=true;
                                    bw2du(cc_overlap.PixelIdxList{ci})=false;
                                    existu_big(cc_overlap.PixelIdxList{ci})=true;
                                    eqid(kk)=1;
                                    
                                end
                            end
                        elseif dist_existu.shortest_dist < dist2_bw2du.shortest_dist;
                            bw_existu(cc_overlap.PixelIdxList{ci})=true;
                            bw2du(cc_overlap.PixelIdxList{ci})=false;
                            existu_big(cc_overlap.PixelIdxList{ci})=true;
                        else;
                            bw_existu(cc_overlap.PixelIdxList{ci})=false;
                            bw2du(cc_overlap.PixelIdxList{ci})=true;
                            bw2du_big(cc_overlap.PixelIdxList{ci})=true;
                        end
                        
                    end
                else
                    bw_existu(bw_overlap==1)=1;
                end
            end
%%%%      else
%%%%          bw2du(bw_overlap==1)=false;
%%%%      end
        
        
        if sum(bw_existu(:))>mpara.cell_size_chk_threshold
            parfill.fill_range=[-1  mpara.cell_fragment_size_rm_threshold(1)];
        else
            parfill.fill_range=[-1  mpara.cell_fragment_size_rm_threshold(2)];
        end
        bw_existu1=BW_Fill_Holes_v02(bw_existu, parfill);
        bw2du1=BW_Fill_Holes_v02(bw2du, parfill);
          %figure(20);imagesc_bw(ims1,[0 255],'gray',255,{bw_exist,bw_existu,bw2du},{'b','g','r'},-1,-1)
                                                                      %7                     ,500
        [bw_existu1, bw_existu1_r]=removebwdist_v02(bw_existu1, mpara.cell_dist_min_threshold, mpara.cell_size_min_threshold);
        if length(bw_existu1_r)>=2
            bel=length(be_rnum);
            for e2=1:length(bw_existu1_r)
                be_rnum{bel+e2-1}=numask1(ee);
            end
        else
            be_rnum{ee}=numask1(ee);
        end
        if sum(bw2du1(:))>mpara.cell_size_chk_threshold
            parfill.fill_range=[-1  mpara.cell_fragment_size_rm_threshold(1)];
        else
            parfill.fill_range=[-1  mpara.cell_fragment_size_rm_threshold(2)];
        end
        %                                              7                                 500
        [bw2du1, bw2du1_r]=removebwdist_v02(bw2du1, mpara.cell_dist_min_threshold, mpara.cell_size_min_threshold);
        %         figure(1);imagesc(bw2du1_r{1})
        %          figure(4);imagesc(mask2,[0 21]);colormap(jet)
        %         if sum(bw2du1_r{1}(:))~=0
        %             kk
        %         end
        
        
        if fremove==1
            mask2(mask2==kk)=0;
        end
        mask2(bw_existu==1)=0;
        mask2(bw_existu1==1)=numask1(ee);
        if fremove==0
            mask2(bw2du==1)=0;
            mask2(bw2du1==1)=kk;
        else
            mask2(bw2du==1)=0;
            mask2(bw2du1==1)=be;
        end
        %{
                            figure(1);imagesc(mask2);axis image;title([num2str(bb)]);pause(0.5)
                                          umask2=unique(mask2);
                                          cmap=parula(max(length(umask2)));
                                          figure(21);imagesc_bw(ims1,[0 255],'gray',255,mask2,cmap,-1,-1);title(num2str(bb));
                                       pause(0.5)
        %}
        bw2d=bw2du1;  %    figure(1);imagesc(bw2du1)
    end
    %  end
    
    atlas_allcell(corrd_on_image(bb,1):corrd_on_image(bb,2),corrd_on_image(bb,3):corrd_on_image(bb,4))=mask2;
    %%figure(1002);imagesc(atlas_allcell(8900:8900+2000,1:1+2000));axis image
else
    mask1=squeeze(atlas_allcell(corrd_on_image(bb,1):corrd_on_image(bb,2),corrd_on_image(bb,3):corrd_on_image(bb,4)));
    %    figure(10);imagesc_bw(ims1,[0 255],'gray',255,{bw2d},{'b','g','r'},-1,-1);
    mask1(mask1==kk)=0;%figure(10);imagesc(mask1)
    bw2d1=BW_Fill_Holes_v02(bw2d, parfill);
    %                                                7                       500        
    [bw2d1,bw2du1_r]=removebwdist_v02(bw2d1, mpara.cell_dist_min_threshold, mpara.cell_size_min_threshold);
    
    mask1(bw2d==1)=0;
    mask1(bw2d1==1)=kk;
    %{
                                umask1=unique(mask1);
                                 cmap=parula(max(length(umask1)));
                                 figure(22);imagesc(mask1)
                                 figure(21);imagesc_bw(ims1,[0 255],'gray',255,mask1,cmap,-1,-1);title(num2str(kk));
                                  pause(0.5)
    %}
    atlas_allcell(corrd_on_image(bb,1):corrd_on_image(bb,2),corrd_on_image(bb,3):corrd_on_image(bb,4))=mask1;
end



%         if flag_bxcorrdorig==1
%             bmaskF0(kk,corrd_on_smallbox(kk,1):corrd_on_smallbox(kk,2),corrd_on_smallbox(kk,3):corrd_on_smallbox(kk,4))=mask1;
%         else
%             bmaskF0(kk,:,:)=mask1;
%         end
%         [y,x]=find(bw2du==true); %y,x
%         y1=bboxS(kk,2)+y-1;
%         x1=bboxS(kk,1)+x-1;
%         linearInd = sub2ind(size(im0), y1, x1);
%         atlas_allcell(linearInd)=kk;


%    cmap=parula(max(atlas_allcell(:)));
%imF = labeloverlay(im0(8900:8900+2000,1:1+2000,:),atlas_allcell(8900:8900+2000,1:1+2000),'Colormap',cmap,'Transparency',0.7);
%        imF = labeloverlay(im0,atlas_allcell,'Colormap',cmap,'Transparency',0.7);
%    figure(1000+1);imshow(imF)