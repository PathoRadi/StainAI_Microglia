function bwfillholes=BW_Fill_Holes_v02(bw0, varargin)
% (I1) bwfillholes=BW_Fill_Holes_v02(bw0, par);
%          old version: bw_remove=BW_Fillholes(bw_remove);
%      filled holes or remove spots in the mask, bw0
%{
      input:
          bw0: 2d or 3d bwmask matrix
          par.fill_orient = 'z','cor','coronal';'x','sag','sagittal';'y','axial','3d'
          par.fill_range = [n1 n2]: when n2>0, fill black hole in the pixel range [n1, n2]
                          when n2<0, remove the white spots in the pixel range of abs([n1, n2])
          par.fill_connectivity = 4,8 (for 2d) = 6,18,26 (for 3d)
      output:
          bwfillholes: mask after filled holes or remove spots       
%}
% history: 2019/06/07
%          BW_Fill_Holes_v02: to remove spots
% Created by Chao-Hsiung Hsu, 2018/10/24
% Email: hsuchaohsiung@gmail.com
bw0=logical(bw0);
bwsize=size(bw0);
bwsize0=bwsize;
if length(size(bw0))==2
    bw0i=bw0;clear bw0
    bw0(1,:,:)=bw0i;
    bwsize=size(bw0);
    par.fill_orient='y';
end
if isempty(varargin)~=1
    par=varargin{1};
    bwfillholes=false(size(bw0));
    switch par.fill_orient
        case {'cor','coronal','z'}
            bwfillholes=fillz(bw0,bwsize,par);
        case {'y','axial'}
            bwfillholes=filly(bw0,bwsize,par);
            
        %    figure(111);imagesc(squeeze(bwfillholes));
            
        case {'x','sag','sagittal'}
            bwfillholes=fillx(bw0,bwsize,par);
        case {'zyx'}
            bwfillholes=fillz(bw0,bwsize,par);
            bwfillholes=filly(bwfillholes,bwsize,par);
            bwfillholes=fillx(bwfillholes,bwsize,par);
        case {'xyz'}
            bwfillholes=fillx(bw0,bwsize,par);
            bwfillholes=filly(bwfillholes,bwsize,par);
            bwfillholes=fillz(bwfillholes,bwsize,par);
        case {'yxz'}
            bwfillholes=filly(bw0,bwsize,par);
            bwfillholes=fillx(bwfillholes,bwsize,par);
            bwfillholes=fillz(bwfillholes,bwsize,par);
        case '3d'
            if sign(par.fill_range(2))>0
                bwfillholes=bw0;
                bwtemp=abs(bw0-1);
                CC_t=bwconncomp(bwtemp);
                numPixels_t = cellfun(@numel,CC_t.PixelIdxList);
                
                if CC_t.NumObjects~=0
                    for nn=1:length(numPixels_t)
                        if numPixels_t(nn)>= par.fill_range(1) && numPixels_t(nn) <= par.fill_range(2)
                            bwfillholes(CC_t.PixelIdxList{nn})=true;
                        end
                    end
                end
            elseif sign(par.fill_range(2))<0
                rm=abs(par.fill_range);
                bwfillholes=bw0;
                CC_t=bwconncomp(bw0);
                numPixels_t = cellfun(@numel,CC_t.PixelIdxList);
                if CC_t.NumObjects~=0
                    for nn=1:length(numPixels_t)
                        if numPixels_t(nn)>= min(rm) && numPixels_t(nn) <= max(rm)
                            bwfillholes(CC_t.PixelIdxList{nn})=false;
                        end
                    end
                end
            else % get biggest and filled
                bwfillholes=bw0;
                %                 bwsize=size(bw0);
                %                 bwtemp=abs(bw0-1);
                %                 CC_t=bwconncomp(bwtemp);
                %                 numPixels_t = cellfun(@numel,CC_t.PixelIdxList);
                %                 [biggest_t,idx_t] = max(numPixels_t);
                %                 bwfillholes=false(size(bw0));
                %                 bwfillholes(CC_t.PixelIdxList{1,idx_t})=1;
                %                 %bwfillholes=reshape(bwfillholes,fn,fn1);
                %                 bwfillholes=abs(bwfillholes-1);
            end
            
    end
    
else
    if sign(par.fill_range(2))>0
        bwfillholes=bw0;
        bwtemp=abs(bw0-1);
        CC_t=bwconncomp(bwtemp);
        numPixels_t = cellfun(@numel,CC_t.PixelIdxList);
        
        if CC_t.NumObjects~=0
            for nn=1:length(numPixels_t)
                if numPixels2i(nn)>= par.fill_range(1) && numPixels2i(nn) <= par.fill_range(2)
                    bwfillholes(CC_t.PixelIdxList{nn})=true;
                end
            end
        end
    elseif sign(par.fill_range(2))<0
        rm=abs(par.fill_range);
        bwfillholes=bw0;
        CC_t=bwconncomp(bw0);
        numPixels_t = cellfun(@numel,CC_t.PixelIdxList);
        if CC_t.NumObjects~=0
            for nn=1:length(numPixels_t)
                if numPixels_t(nn)>= min(rm) && numPixels_t(nn) <= max(rm)
                    bwfillholes(CC_t.PixelIdxList{nn})=false;
                end
            end
        end
    else % get biggest and filled
        bwfillholes=bw0;
        %         bwsize=size(bw0);
        %         bwtemp=abs(bw0-1);
        %         CC_t=bwconncomp(bwtemp);
        %         numPixels_t = cellfun(@numel,CC_t.PixelIdxList);
        %         [biggest_t,idx_t] = max(numPixels_t);
        %         bwfillholes=false(size(bw0));
        %         bwfillholes(CC_t.PixelIdxList{1,idx_t})=1;
        %         %bwfillholes=reshape(bwfillholes,fn,fn1);
        %         bwfillholes=abs(bwfillholes-1);
    end
end
if length(bwsize0)==2
    bwfillholes=squeeze(bwfillholes);
end

end
%         CC=bwconncomp(bw0,6);numPixels = cellfun(@numel,CC.PixelIdxList);
%
%         [biggest,idx] = max(numPixels);    bw_2=false(bwsize);bw_2(CC.PixelIdxList{idx})=1;
%
%
%         dsp.fignum=5000;dsp.type='2dslice';dsp.ctableflag=0; % 0,1,2
%         dsp.clim=[0 1];dsp.colormap='gray';dsp.nx=250;dsp.ny=350;dsp.nz=250;
%         im_meta_temp.myp=1:size(bw0,1);
%         im_meta_temp.mxp=1:size(bw0,2);
%         im_meta_temp.mzp=1:size(bw0,3);
%         plot3dImAtlas(dsp, bw_2, im_meta_temp);




function bwfillholes=fillz(bw0,bwsize,par)
if sign(par.fill_range(2))>0
    bwfillholes=false(size(bw0));
    for zz=1:bwsize(3)
        bwt=squeeze(bw0(:,:,zz));
        bwtf2d=false(size(bwt));
        bw_2i=abs(bwt-1);
        CC2i=bwconncomp(bw_2i,par.fill_connectivity);
        numPixels2i = cellfun(@numel,CC2i.PixelIdxList);
        if CC2i.NumObjects~=0
            for nn=1:length(numPixels2i)
                if numPixels2i(nn)>= par.fill_range(1) && numPixels2i(nn) <= par.fill_range(2)
                    bwtf2d(CC2i.PixelIdxList{nn})=true;
                end
            end
        end
        bwfillholes(:,:,zz)=bwt+bwtf2d;
       
    end
elseif sign(par.fill_range(2))<0
    rm=abs(par.fill_range);
    bwfillholes=false(size(bw0));
    %close all;figure(1)
    %imagesc_bw(squeeze(bw0), [0 2], 'gray', 255, {squeeze(bw0)}, {[255,0,0]}, 1, 1);    
    for zz=1:bwsize(3)
        bwt=squeeze(bw0(:,:,zz));
        %bwtf2d=false(size(bwt));
        CC2i=bwconncomp(bwt,par.fill_connectivity);
        numPixels2i = cellfun(@numel,CC2i.PixelIdxList);
        if CC2i.NumObjects~=0
            for nn=1:length(numPixels2i)
                if numPixels2i(nn)>= min(rm) && numPixels2i(nn) <= max(rm)
                    bwt(CC2i.PixelIdxList{nn})=false;
                end
            end
        end
        bwfillholes(:,:,zz)=bwt;
    end
else
    bwfillholes=bw0;
end



end


function bwfillholes=filly(bw0,bwsize,par)
if sign(par.fill_range(2))>0
    bwfillholes=false(size(bw0));
    for yy=1:bwsize(1)
        bwt=squeeze(bw0(yy,:,:));
        bwtf2d=false(size(bwt));
        bw_2i=abs(bwt-1); %figure(1);imagesc(bwtf2d)
        CC2i=bwconncomp(bw_2i,par.fill_connectivity);
        numPixels2i = cellfun(@numel,CC2i.PixelIdxList);
        if CC2i.NumObjects~=0
            for nn=1:length(numPixels2i)
                if numPixels2i(nn)>= par.fill_range(1) && numPixels2i(nn) <= par.fill_range(2)
                    bwtf2d(CC2i.PixelIdxList{nn})=true;
                end
            end
        end
        bwt(bwtf2d==1)=1;
        bwfillholes(yy,:,:)=bwt;
    end
elseif sign(par.fill_range(2))<0
    rm=abs(par.fill_range);
    bwfillholes=false(size(bw0));
    for yy=1:bwsize(1)
        bwt=squeeze(bw0(yy,:,:));
        %bwtf2d=false(size(bwt));
        CC2i=bwconncomp(bwt,par.fill_connectivity);
        numPixels2i = cellfun(@numel,CC2i.PixelIdxList);
        if CC2i.NumObjects~=0
            for nn=1:length(numPixels2i)
                if numPixels2i(nn)>= min(rm) && numPixels2i(nn) <= max(rm)
                    bwt(CC2i.PixelIdxList{nn})=false;
                end
            end
        end
        bwfillholes(yy,:,:)=bwt;
    end
else
    bwfillholes=bw0;
end
end

function bwfillholes=fillx(bw0,bwsize,par)
if sign(par.fill_range(2))>0 %par.fill_range(2)>par.fill_range(1)
    bwfillholes=false(size(bw0));
    for xx=1:bwsize(2)
        bwt=squeeze(bw0(:,xx,:));
        bwtf2d=false(size(bwt));
        bw_2i=abs(bwt-1);
        CC2i=bwconncomp(bw_2i,par.fill_connectivity);
        numPixels2i = cellfun(@numel,CC2i.PixelIdxList);
        if CC2i.NumObjects~=0
            for nn=1:length(numPixels2i)
                if numPixels2i(nn)>= par.fill_range(1) && numPixels2i(nn) <= par.fill_range(2)
                    bwtf2d(CC2i.PixelIdxList{nn})=true;
                end
            end
        end
        bwfillholes(:,xx,:)=bwt+bwtf2d;
    end
elseif sign(par.fill_range(2))<0 %par.fill_range(2)<par.fill_range(1)
    rm=abs(par.fill_range);
    bwfillholes=false(size(bw0));
    for xx=1:bwsize(2)
        bwt=squeeze(bw0(:,xx,:));
        %bwtf2d=false(size(bwt));
        CC2i=bwconncomp(bwt,par.fill_connectivity);
        numPixels2i = cellfun(@numel,CC2i.PixelIdxList);
        if CC2i.NumObjects~=0
            for nn=1:length(numPixels2i)
                if numPixels2i(nn)>= min(rm) && numPixels2i(nn) <= max(rm)
                    bwt(CC2i.PixelIdxList{nn})=false;
                end
            end
        end
        bwfillholes(:,xx,:)=bwt;
    end
else
    bwfillholes=bw0;
end
end





%figure(1003);imagesc_bw(im00t,spp.clim,'gray',{bwfillholes},{'b'});% pause(5);
%
% figure(1)
% for ii=410:1:bwsize(2)
% imt=squeeze(bwfillholes(:,ii,:));
% imagesc(imt);axis image;
% title([num2str(ii)])
% pause(0.5)
% end