function dist=bwEdist(bw1,bw2,varargin) 
% x-y

if isempty(varargin)==1
    bwE1=BW_Edge_Modified_v09(bw1, -1);
    bwE2=BW_Edge_Modified_v09(bw2, -1);
else
    bwE1=bw1;
    bwE2=bw2;
end

dist='';
[ys xs]=find(bwE1==1);
[yb xb]=find(bwE2==1);
dLe=[length(ys) length(yb)];
[~,iM]=max(dLe);

[y2,y1]=meshgrid(yb,ys);
[x2,x1]=meshgrid(xb,xs);

dist00=((y1-y2).^2+(x1-x2).^2).^0.5;
[dvmin,idmin]=min(dist00(:));
[ymin0,xmin0] = ind2sub(size(dist00),idmin);
%idst=find(dvmin==mindis);

%((y1(ymin0,xmin0)-y2(ymin0,xmin0)).^2+(x1(ymin0,xmin0)-x2(ymin0,xmin0)).^2).^0.5

dist.shortest_dist=min(dvmin);
dist.shortest_pixel{1}(:,1)=x1(ymin0,xmin0);
dist.shortest_pixel{1}(:,2)=y1(ymin0,xmin0);
dist.shortest_pixel{2}(:,1)=x2(ymin0,xmin0);
dist.shortest_pixel{2}(:,2)=y2(ymin0,xmin0);

