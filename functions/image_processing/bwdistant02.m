function [dist,varargout]=bwdistant02(bw1,bw2,varargin)
% (I5) [dist,varargout]=bwdistant02(bw1,bw2,varargin)
%     calculate shortest distance bwtween two bwmap, for bwbridge connect points one by one to save processing time
%{
    Input:
        bw1: bw mask1
        bw2: bw mask2
        varargin{1}=par.short_dist_threshold   if <=0 => get min distance between edge of bwmaps; else get all points < short_dist_threshold
                       .long_dist_threshold    if <=0 => get max distance between edge of bwmaps; else get all points > long_dist_threshold 
                       .cc_conn
    Output:
        dist.shortest_dist
            .shortest_pixel
            .short_threshold_dist
            .short_threshold_pixel
            .shortest_line
            .longest_dist
            .longest_pixel
            .long_threshold_dist
            .long_threshold_pixel
            .longest_line
        varargout{1}=bwbridge          % bw mask of bridge between bw1 and bw2 < par.short_dist_threshold
        varargout{2}=bwshort_cpixel    % pixel coordinate on the edge of bwbridge
    Functions: (I2) BW_Edge_Modified_v09, (I6) ptconnect_02 
%}

% Chao-Hsiung Hsu, 20200313 at Howard University

if isempty(varargin)==1
    par.short_dist_threshold=-1;
    par.long_dist_threshold=-1;
    par.cc_conn=4;
else
    par=varargin{1};
    if isfield(par,'short_dist_threshold')==0
        par.short_dist_threshold=-1;
    end
    if isfield(par,'long_dist_threshold')==0
        par.long_dist_threshold=-1;
    end
end

bwt{1}=bw1;bwt{2}=bw2;clear bw1 bw2   
ccbw1=bwconncomp(bwt{1},par.cc_conn);
ccbw2=bwconncomp(bwt{2},par.cc_conn);


bw1_stats = regionprops(bwt{1},'Centroid');
bw2_stats = regionprops(bwt{2},'Centroid');
%  figure(21313);
%  imagesc_bw(bwt{1},[0 255],'gray',255,{bwt{1},bwt{2}},{'r','b','g','y','m'},-1,-1);axis image;axis off

if ccbw1.NumObjects>1
    bw1_CH = bwconvhull(bwt{1});
    bw1_CH_stats = regionprops(bw1_CH,'Centroid');
    dist.center_dist=bw1_CH_stats.Centroid;
else
    bw1_stats = regionprops(bwt{1},'Centroid');
    dist.center_dist=bw1_stats.Centroid;
end

if ccbw2.NumObjects>1
    bw2_CH = bwconvhull(bwt{2});
    bw2_CH_stats = regionprops(bw2_CH,'Centroid');
    dist.center_dist=bw2_CH_stats.Centroid;
else
    bw2_stats = regionprops(bwt{2},'Centroid');
    dist.center_dist=bw2_stats.Centroid;
end


for bb2=1:length(bw2_stats)
    
    bwt2=false(size(bwt{2}));
    bwt2(ccbw2.PixelIdxList{bb2})=true;
    bwt2_stats = regionprops(bwt2,'Centroid');
    for bb1=1:ccbw1.NumObjects
        bwt1=false(size(bwt{1}));
        bwt1(ccbw1.PixelIdxList{bb1})=true;
        %bwd12=bwt1.*bwt2;
%  figure(21313);
%  imagesc_bw(bwt{1},[0 255],'gray',255,{bwt1,bwt{2}},{'r','b','g','y','m'},-1,-1);axis image;axis off

     %   if sum(bwd12(:))==0
            bwt1_stats = regionprops(bwt1,'Centroid');
            dist0{bb2,bb1}.center_dist=(sum((bwt1_stats.Centroid-bwt2_stats.Centroid).^2)).^0.5;
            [bw_edgef{1}]=BW_Edge_Modified_v09(bwt1, -1);
            [bw_edgef{2}]=BW_Edge_Modified_v09(bwt2, -1);
            if sum(bw_edgef{1}(:))==0;bw_edgef{1}=bwt1;end
            if sum(bw_edgef{2}(:))==0;bw_edgef{2}=bwt2;end
        
           
            clear dist00
            perim=[sum(bw_edgef{1}(:)) sum(bw_edgef{2}(:))];
            [~,ids]=min(perim);[~,idb]=max(perim);
            if ids==idb
                ids=1;idb=2;
            end
            [ys xs]=find(bw_edgef{ids}==true);
            [yb xb]=find(bw_edgef{idb}==true);
            
%             [y1,y2]=meshgrid(yb,ys);
%             [x1,x2]=meshgrid(xb,xs);
%             dist00=((y1-y2).^2+(x1-x2).^2).^0.5;
            
          for pp=1:perim(ids)
              dist00(pp,:)=((yb-repmat(ys(pp),length(yb),1)).^2+(xb-repmat(xs(pp),length(xb),1)).^2).^0.5;
          end

            if par.short_dist_threshold<=0
                [dvmin,idmin]=min(dist00(:));
            else
                idmin=find(dist00<=par.short_dist_threshold);
                dvmin=dist00(idmin);
                if isempty(idmin)==1
                    [dvmin,idmin]=min(dist00(:));
                end
            end
            [ymin0 xmin0] = ind2sub(size(dist00),idmin);
            [mindis, idst]=min(dvmin);
            idst=find(dvmin==mindis);
            shortest_dist(bb2,bb1)=mindis(1);
            dist0{bb2,bb1}.shortest_dist=min(dvmin);
            dist0{bb2,bb1}.shortest_pixel{ids}(:,1)=ys(ymin0(idst));
            dist0{bb2,bb1}.shortest_pixel{ids}(:,2)=xs(ymin0(idst));
            dist0{bb2,bb1}.shortest_pixel{idb}(:,1)=yb(xmin0(idst));
            dist0{bb2,bb1}.shortest_pixel{idb}(:,2)=xb(xmin0(idst));
            dist0{bb2,bb1}.short_threshold_dist=dvmin;
            dist0{bb2,bb1}.short_threshold_pixel{ids}(:,1)=ys(ymin0);
            dist0{bb2,bb1}.short_threshold_pixel{ids}(:,2)=xs(ymin0);
            dist0{bb2,bb1}.short_threshold_pixel{idb}(:,1)=yb(xmin0);
            dist0{bb2,bb1}.short_threshold_pixel{idb}(:,2)=xb(xmin0);
            dist0{bb2,bb1}.shortest_line=ptconnect_02(dist0{bb2,bb1}.shortest_pixel{ids},dist0{bb2,bb1}.shortest_pixel{idb},size(bwt{1}));

            if par.long_dist_threshold<=0
                [dvmax,idmax]=max(dist00(:));
            else
                idmax=find(dist00>=par.long_dist_threshold);
                dvmax=dist00(idmax);
                if isempty(idmax)==1
                    [dvmax,idmax]=min(dist00(:));
                end
            end
            [ymax0 xmax0] = ind2sub(size(dist00),idmax);
            [maxdis, idst]=max(dvmax);
            idst=find(dvmax==maxdis);
            longest_dist(bb2,bb1)=maxdis(1);
            
            
%             dist0{bb2,bb1}.longest_dist=max(dvmax);
%             dist0{bb2,bb1}.longest_pixel{ids}(:,1)=ys(ymax0(idst));
%             dist0{bb2,bb1}.longest_pixel{ids}(:,2)=xs(ymax0(idst));
%             dist0{bb2,bb1}.longest_pixel{idb}(:,1)=yb(xmax0(idst));
%             dist0{bb2,bb1}.longest_pixel{idb}(:,2)=xb(xmax0(idst));
%             dist0{bb2,bb1}.long_threshold_dist=dvmax;
%             dist0{bb2,bb1}.long_threshold_pixel{ids}(:,1)=ys(ymax0);
%             dist0{bb2,bb1}.long_threshold_pixel{ids}(:,2)=xs(ymax0);
%             dist0{bb2,bb1}.long_threshold_pixel{idb}(:,1)=yb(xmax0);
%             dist0{bb2,bb1}.long_threshold_pixel{idb}(:,2)=xb(xmax0);
%             dist0{bb2,bb1}.longest_line=ptconnect_02(dist0{bb2,bb1}.longest_pixel{ids},dist0{bb2,bb1}.longest_pixel{idb},size(bwt{1}));

%             %         else
% %             % 
% %             shortest_dist(bb2,bb1)=numel(bwt{1});
% %             longest_dist(bb2,bb1)=0;
% %             dist0{bb2,bb1}.shortest_dist=numel(bwt{1});
% %             dist0{bb2,bb1}.short_threshold_dist=numel(bwt{1});
% %             
% %             
% %             
% %             dist0{bb2,bb1}.longest_dist=0;
% %             dist0{bb2,bb1}.long_threshold_dist=0;
% %             
% %         end
    end
end

[minvf, minidf]=min(shortest_dist(:));
[is2,is1] = ind2sub(size(shortest_dist),minidf);
  
dist.shortest_dist=dist0{is2,is1}.shortest_dist;
dist.shortest_pixel=dist0{is2,is1}.shortest_pixel;
dist.short_threshold_dist=dist0{is2,is1}.short_threshold_dist;
dist.short_threshold_pixel=dist0{is2,is1}.short_threshold_pixel;
dist.shortest_line=dist0{is2,is1}.shortest_line;

% [maxvf, maxidf]=max(longest_dist(:));
% [ib2,ib1] = ind2sub(size(longest_dist),maxidf);
% dist.longest_dist=dist0{ib2,ib1}.longest_dist;
% dist.longest_pixel=dist0{ib2,ib1}.longest_pixel;
% dist.long_threshold_dist=dist0{ib2,ib1}.long_threshold_dist;
% dist.long_threshold_pixel=dist0{ib2,ib1}.long_threshold_pixel;
% dist.longest_line=dist0{ib2,ib1}.longest_line;


%%figure(111);imagesc_bw(bwt2*0,[0 255],'gray',255,{bwt{1},bwt{2},dist.shortest_line,dist.longest_line},{'r','b','g','y','m'},-1,-1);axis image;axis off



if nargout>=2
    bwshort_cpixel=false(size(bwt{1}));
   % bwbridge=ptconnect_02(dist.short_threshold_pixel{1},dist.short_threshold_pixel{2},size(bwt{1}),1);
    bwbridge=ptconnect_02(dist.short_threshold_pixel{1},dist.short_threshold_pixel{2},size(bwt{1}));

    for jj=1:size(dist.short_threshold_pixel{1},1)
        bwbridge(dist.short_threshold_pixel{ids}(jj,1),dist.short_threshold_pixel{ids}(jj,2))=false;
        bwbridge(dist.short_threshold_pixel{idb}(jj,1),dist.short_threshold_pixel{idb}(jj,2))=false;
        if nargout==3
            bwshort_cpixel(dist.short_threshold_pixel{ids}(jj,1),dist.short_threshold_pixel{ids}(jj,2))=true;
            bwshort_cpixel(dist.short_threshold_pixel{idb}(jj,1),dist.short_threshold_pixel{idb}(jj,2))=true;
            varargout{2}=bwshort_cpixel;
        end
    end
    if sum(bwbridge(:))==0
        for jj=1:size(dist.shortest_pixel{1},1)
            bwbridge(dist.shortest_pixel{1}(jj,1),dist.shortest_pixel{1}(jj,2))=true;
            bwbridge(dist.shortest_pixel{2}(jj,1),dist.shortest_pixel{2}(jj,2))=true;
        end
    end
    varargout{1}=bwbridge;
end

%figure(111);imagesc_bw(bwt2*0,[0 255],'gray',255,{bwt1,bwt2,bwbridge,bwshort_cpixel},{'r','b','g','y','m'},-1,3);axis image;axis off









%figure(1);imagesc(bwline)









%%% area version
% [~,ids]=min(areat);[~,idb]=max(areat);
% [ys xs]=find(bwt{ids}==true);
% [yb xb]=find(bwt{idb}==true);
% for pp=1:areat(ids)
%     dist00(pp,:)=((yb-repmat(ys(pp),length(yb),1)).^2+(xb-repmat(xs(pp),length(xb),1)).^2).^0.5;
% end
% [dvmin,idmin]=min(dist00(:));
% [ymin0 xmin0] = ind2sub(size(dist00),idmin);
% dist.shortest_dist{ids}=dvmin;
% dist.shortest_pixel{ids}=[ys(ymin0) xs(ymin0)];
% dist.shortest_pixel{idb}=[yb(xmin0) xb(xmin0)];
% [dvmax,idmax]=max(dist00(:));
% [ymax0 xmax0] = ind2sub(size(dist00),idmax);
% dist.longest_dist{ids}=dvmax;
% dist.longest_pixel{ids}=[ys(ymax0) xs(ymax0)];
% dist.longest_pixel{idb}=[yb(xmax0) xb(xmax0)];





