function imF=morphometricMap(im1,clim1,cmap,tableA,ind,disp)


eval(['mColormap0=' cmap '(72);']);
bbox_t1=tableA.bbox;
ydata1=tableA.(disp.metric_name);

%clim1=[quantile(ydata1,0.01) quantile(ydata1,0.99)]; % 1-99%

for ll=1:length(disp.label_name);
    switch disp.label_name{ll}
        case {'badFM','bFM'}
            idp1=ind.thFMlt; 
            idc0{ll}=ind.thFMlt;
        otherwise;
            ind_L1=find(strcmp(tableA.C50,disp.type_name0{ll})==1);
            idp1=intersect(intersect(ind_L1,ind.th),ind.thFMge);
            idp0=intersect(ind_L1,ind.FMge);
            idc0{ll}=idp1;
    end
    if isempty(idp1)~=1;
        bbox_t1(idp1,1)=bbox_t1(idp1,1)-(bbox_t1(idp1,3)*disp.box_ratio1(ll)-bbox_t1(idp1,3))/2;
        bbox_t1(idp1,2)=bbox_t1(idp1,2)-(bbox_t1(idp1,4)*disp.box_ratio1(ll)-bbox_t1(idp1,4))/2;
        bbox_t1(idp1,3)=bbox_t1(idp1,3)*disp.box_ratio1(ll);
        bbox_t1(idp1,4)=bbox_t1(idp1,4)*disp.box_ratio1(ll);
    end
end
bbox_t1=bbox_t1./abs(disp.name_resL);

id1L=find(ydata1<clim1(1));
id1H=find(ydata1>clim1(2));
idc0th=find(ydata1>=clim1(1) & ydata1<=clim1(2));

indexCmap = fix((ydata1(idc0th)-clim1(1))/(clim1(2)-clim1(1))*length(mColormap0));
indexCmap(indexCmap<=0)=1;

dcmap=zeros(length(ydata1),3);
%dcmap(idc1,:) = app.mColormap0(indexCmap,:);
dcmap(idc0th,:) = mColormap0(indexCmap,:);

if isempty(id1H)~=1
    dcmap(id1H,:) =repmat(mColormap0(end,:),length(id1H),1);
end
if isempty(id1L)~=1
    dcmap(id1L,:) =repmat(mColormap0(1,:),length(id1L),1);
end

dcmap(ind.thFMlt,:)=repmat(disp.cmap_label{7}/255,length(ind.thFMlt),1);
dcmap2=zeros(length(ydata1(ind.th)),3);
dcmap2(ind.th,:)=dcmap(ind.th,:);
imF=im1;
for ll=1:7
    imF= insertShape(imF, 'FilledRectangle', bbox_t1(idc0{ll},:),'Color', dcmap2(idc0{ll},:)*255,'Opacity',disp.opacity(ll));
end
