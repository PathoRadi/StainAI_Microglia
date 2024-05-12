function bwcoreF=get_cellcore_v03(im0,bw0,red_pixel)
%% get cell core form reduce mask and kmean
%%
%figure(9001);clf;imagesc_bw(im0,[0 255],'gray',255,{bw0},{'b'},-1,-1);axis image;axis off
if size(im0,1)==1 || size(im0,2)==1
    bwcoreF=bw0;
else
    rng(6,'twister');
    mpara.size_threohold=8;
    if sum(bw0(:))>=75;csizeth=75;
    else
        csizeth=sum(bw0(:));
    end

    kn=4;
    [bw_core2i,bw_peri2,kn2]=cellcorefromkmean_02(im0,bw0,kn,csizeth);
    while sum(bw_core2i(:))==0
        csizeth=fix(csizeth/2);
        [bw_core2i,bw_peri2,kn2]=cellcorefromkmean_02(im0,bw0,kn,csizeth);
        %bw_core2i=bw0;
    end

    if sum(bw_core2i(:))~=0
        CC=bwconncomp(bw_core2i,8);
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [~,idx] = max(numPixels);
        bw_core2=0*bw0;
        bw_core2(CC.PixelIdxList{idx}) = 1;
    else
        bw_core2=bw_core2i;
    end

    %figure(9003);imagesc_bw(im0,[0 255],'gray',255,{bw0,bw_core2},{'b','g'},1,-1);axis image;axis off

    par.fill_orient = 'y';
    par.fill_range = [0 75];
    par.fill_connectivity=4;
    bw_core2fh=BW_Fill_Holes_v02(bw_core2, par);

    bw_core2fh=bw_core2fh.*bw0;
    %figure(9004);imagesc_bw(im0,[0 255],'gray',255,{bw0,bw_core2fh},{'b','g'},-1,-1);axis image;axis off

    %im0=ims2;
    %bw0=stats1(bb).Image;
    %options.method=reduce_edge




    %stats_bw0 = regionprops(bw0,'ConvexImage');
    %roi_bw0ch=roical_02(stats_bw0.ConvexImage,stats_bw0.ConvexImage);
    %red_pixel=2
    % [~,bw1]=BW_Edge_Modified_v09(bw_core2fh, -red_pixel);
    % if sum(bw1(:))~=0
    %     CC1=bwconncomp(bw1,8);clear Area1
    %     for jj=1:CC1.NumObjects;bw1a=false(size(bw_core2fh));bw1a(CC1.PixelIdxList{jj}) = 1;Area1(jj,1)=sum(bw1a(:));end
    % else
    %     Area1=sum(bw_core2fh(1));
    % end
    %figure(22);imagesc_bw(im0,[0 255],'gray',255,{bw0,bw_core2fh},{'b','r'},-1,-1);axis image;axis off


    % kk=1;
    % red_pixelb=red_pixel;
    % while max(Area1)<=15
    %     red_pixelb=abs(-red_pixel+kk);
    %     [~,bw1]=BW_Edge_Modified_v09(bw_core2fh, -red_pixel+kk);
    %     if sum(bw1(:))~=0
    %         CC1=bwconncomp(bw1,8);
    %         clear Area1
    %         for jj=1:CC1.NumObjects
    %             bw1a=false(size(bw_core2fh));bw1a(CC1.PixelIdxList{jj}) = 1;
    %             Area1(jj,1)=sum(bw1a(:));
    %         end
    %     else
    %         Area1=0;
    %     end
    %     kk=kk+1;
    % end
    % figure(9005);imagesc_bw(im0,[0 255],'gray',255,{bw0,bw1a},{'b','r'},-1,-1);

    %if kk>=red_pixel

    kk=1;red_pixelb=red_pixel;
    [~,bw1]=BW_Edge_Modified_v09(bw_core2fh, -red_pixel);
    %figure(9005);imagesc_bw(im0,[0 255],'gray',255,{bw0,bw1},{'b','r'},-1,-1);axis off
    if sum(bw1(:))~=0
        CC1=bwconncomp(bw1,8);clear Area1
        for jj=1:CC1.NumObjects;bw1a=false(size(bw_core2fh));bw1a(CC1.PixelIdxList{jj}) = 1;Area1(jj,1)=sum(bw1a(:));end
    else
        Area1=0;
    end

    while max(Area1)<=15
        clear Area1
        red_pixelb=abs(-red_pixel+kk);
        [~,bw1]=BW_Edge_Modified_v09(bw_core2fh, -red_pixel+kk);
        if sum(bw1(:))~=0
            [~,bw1]=BW_Edge_Modified_v09(bw1, 1);
            CC1=bwconncomp(bw1,8);
            for jj=1:CC1.NumObjects
                bw1a=false(size(bw_core2fh));bw1a(CC1.PixelIdxList{jj}) = 1;
                Area1(jj,1)=sum(bw1a(:));
            end
        else
            Area1=0;
        end
        kk=kk+1;
    end
    %end
    %figure(4);clf;imagesc_bw(im0,[0 255],'gray',255,{bw0,bw1},{'b','r'},-1,-1);axis image;axis off
    %axis off
    clear stats_core0
    CC=bwconncomp(bw1,8);

    %figure(9006);imagesc_bw(im0,[0 255],'gray',255,{bw0,bw1},{'b','r'},-1,-1);axis off

    for jj=1:CC.NumObjects
        bw2=false(size(bw0));
        bw2(CC.PixelIdxList{jj}) = 1;
   
            stats_core0.MeanIntensity(jj,1)=mean(im0(bw2==1));

     
        stats_core0.Area(jj,1)=sum(bw2(:));
        stats_core0.vis(jj,1)=stats_core0.MeanIntensity(jj,1).*stats_core0.Area(jj,1).^0.5;
        %roi_bw2=roical_02(bw2,bw2);
        % stats_core0.distc(jj,1)=sum(((roi_bw0ch.center-roi_bw2.center).^2)).^0.5;
    end

    idAth=find(stats_core0.Area>=mpara.size_threohold);
    if isempty(idAth)~=1
        [~,idxV]=max([stats_core0.vis(idAth)]);
        if length(idxV)>=2
            [~,idxA]=max([stats_core0.Area(idAth)]);
            idxV=intersect(idxV,idxA);
        end
        idx=idAth(idxV);
    else
        bwcore1=bw0;
    end


    bw2=false(size(bw0));
    bw2(CC.PixelIdxList{idx}) = 1;
    %figure(9007);imagesc_bw(im0,[0 255],'gray',255,{bw0,bw2},{'b','r'},-1,-1);axis image;axis off


    [~,bw3]=BW_Edge_Modified_v09(bw2, red_pixelb);
    %figure(9008);imagesc_bw(im0,[0 255],'gray',255,{bw0,bw3},{'b','r'},-1,-1);axis image;axis off

    bwcore0=bw3.*bw0;
    CC=bwconncomp(bwcore0,8);
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [~,idx] = max(numPixels);
    bw_core1=0*bwcore0;
    bw_core1(CC.PixelIdxList{idx}) = 1;
    %figure(22);imagesc_bw(im0,[0 255],'gray',255,{bw0,bw_core1},{'b',[255 128 0]},-1,-1);axis image;axis off
    bwcoreF=bw_core1.*bw0;
end
%figure(9009);imagesc_bw(im0,[0 255],'gray',255,{bw0,bwcoreF},{'b','r'},-1,-1);axis image;axis off


%   figure(3);imagesc(im0);axis image;colormap(gray);axis image
%   figure(4);imagesc_bw(im0,[0 255],'gray',255,{bw0,bwcoreF},{'b',[0 255 255]},-1,-1);axis image;%axis off
%   figure(2);imagesc_bw(im0,[0 255],'gray',255,{bwcoreF},{'r','g'},1,-1);axis image;




%figure(4);clf;imagesc_bw(im0,[0 255],'gray',255,{bw0,bwcore},{'b','r'},-1,-1);axis image;

end