function [data_Cim2d,indLable,ydata]=insertLabelbox2imagefromTable(im0L,tableA,dinfo,ind,disp)
indLable='';
% if isfield(disp,'bboxalpha_01')==0
%     disp.bboxalpha_01=0.25;
% end
% if isfield(disp,'bboxalpha_02')==0
%     disp.bboxalpha_02=0.45;
% end
if isfield(disp,'opacity2')~=1
    disp.opacity2=disp.opacity;
end
if isfield(disp,'load_ULine')~=1
    disp.load_ULine=0;
end
if isfield(disp,'save_imsplit')~=1
    disp.save_imsplit=0;
end

ind_im=find(tableA.image_id==dinfo.imId);
if length(size(im0L))==3
    im0Lgray=255-rgb2gray(im0L);
else
    im0Lgray=im0L;
end
data_Cim2d.cboxA2_im0L=im0L;  % different extend size of bbox, 1.2,1.4
data_Cim2d.cboxA2_im0Lgray=im0Lgray;
data_Cim2d.cboxA_im0L = im0L;
data_Cim2d.cboxA_im0Lgray=im0Lgray;
if disp.load_ULine==1
    data_Cim2d.UM_A_im0L = im0L;
    data_Cim2d.UM_A_im0Lgray=im0Lgray;
    data_Cim2d.UM_A2_im0L = im0L;
    data_Cim2d.UM_A2_im0Lgray=im0Lgray;
    data_Cim2d.UL_A_im0L = im0L;
    data_Cim2d.UL_A_im0Lgray=im0Lgray;
    data_Cim2d.UL_A2_im0L = im0L;
    data_Cim2d.UL_A2_im0Lgray=im0Lgray;
end

cmap2=zeros(size(tableA,1),3);

for ll=1:length(disp.label_name);
    switch disp.label_name{ll}
        case {'badFM','bFM'}
            idp1=intersect(ind.thFMlt,ind_im);
        otherwise;
            ind_L1=find(strcmp(tableA.C50,disp.type_name0{ll})==1);
            idp1=intersect(intersect(intersect(ind_L1,ind_im),ind.th),ind.thFMge);
            idp0=intersect(intersect(ind_L1,ind_im),ind.FMge);
    end
    if isempty(idp1)~=1;
        bbox_t2=tableA.bbox(idp1,:);
        bbox_t2(:,1)=bbox_t2(:,1)-(bbox_t2(:,3)*disp.box_ratio2(ll)-bbox_t2(:,3))/2;
        bbox_t2(:,2)=bbox_t2(:,2)-(bbox_t2(:,4)*disp.box_ratio2(ll)-bbox_t2(:,4))/2;
        bbox_t2(:,3)=bbox_t2(:,3)*disp.box_ratio2(ll);
        bbox_t2(:,4)=bbox_t2(:,4)*disp.box_ratio2(ll);
                
        bbox_t2=bbox_t2./abs(disp.name_resL); %1 B,A 2.5xbbox, R,H1.4xbbox

        linecolor2{ll}=repmat(disp.cmap_label{ll},size(bbox_t2,1),1);
        if disp.save_imsplit==0
            data_Cim2d.cboxA2_im0L = insertShape(data_Cim2d.cboxA2_im0L, 'FilledRectangle', bbox_t2,'Color', linecolor2{ll},'Opacity',disp.opacity2(ll));
            data_Cim2d.cboxA2_im0Lgray = insertShape(data_Cim2d.cboxA2_im0Lgray, 'FilledRectangle', bbox_t2,'Color', linecolor2{ll},'Opacity',disp.opacity2(ll));
        else
            data_Cim2d.cboxA2_im0L = insertShapeSplit(disp.save_imsplit,data_Cim2d.cboxA2_im0L, 'FilledRectangle', bbox_t2,'Color', linecolor2{ll},'Opacity',disp.opacity2(ll));
            data_Cim2d.cboxA2_im0Lgray = insertShapeSplit(disp.save_imsplit,data_Cim2d.cboxA2_im0Lgray, 'FilledRectangle', bbox_t2,'Color', linecolor2{ll},'Opacity',disp.opacity2(ll));
        end
        %data_Cim2d.cboxL2_im0Lgray{ll}= insertShape(im0Lgray, 'FilledRectangle', bbox_t2,'Color', linecolor1{ll},'Opacity',disp.opacity(ll));
        %data_Cim2d.cboxL2_im0L{ll}= insertShape(im0L*0+255, 'FilledRectangle', bbox_t2,'Color', linecolor1{ll},'Opacity',disp.opacity(ll));
        
        bbox_t1=tableA.bbox(idp1,:);
        bbox_t1(:,1)=bbox_t1(:,1)-(bbox_t1(:,3)*disp.box_ratio1(ll)-bbox_t1(:,3))/2;
        bbox_t1(:,2)=bbox_t1(:,2)-(bbox_t1(:,4)*disp.box_ratio1(ll)-bbox_t1(:,4))/2;
        bbox_t1(:,3)=bbox_t1(:,3)*disp.box_ratio1(ll);
        bbox_t1(:,4)=bbox_t1(:,4)*disp.box_ratio1(ll);


        bbox_t1=bbox_t1./abs(disp.name_resL);
        linecolor1{ll}=repmat(disp.cmap_label{ll},size(bbox_t1,1),1);
        %linecolor1{ll}=repmat(disp.cmap_label1{ll},size(bbox_t1,1),1);
        %2 1.2xbbox
        if disp.save_imsplit==0
            data_Cim2d.cboxA_im0L = insertShape(data_Cim2d.cboxA_im0L, 'FilledRectangle', bbox_t1,'Color', linecolor1{ll},'Opacity',disp.opacity2(ll));
            data_Cim2d.cboxA_im0Lgray = insertShape(data_Cim2d.cboxA_im0Lgray, 'FilledRectangle', bbox_t1,'Color', linecolor1{ll},'Opacity',disp.opacity2(ll));
        else
            data_Cim2d.cboxA_im0L = insertShapeSplit(disp.save_imsplit,data_Cim2d.cboxA_im0L, 'FilledRectangle', bbox_t1,'Color', linecolor1{ll},'Opacity',disp.opacity2(ll));
            data_Cim2d.cboxA_im0Lgray = insertShapeSplit(disp.save_imsplit,data_Cim2d.cboxA_im0Lgray, 'FilledRectangle', bbox_t1,'Color', linecolor1{ll},'Opacity',disp.opacity2(ll));
        end
        %data_Cim2d.cboxL_im0Lgray{ll}= insertShape(im0Lgray, 'FilledRectangle', bbox_t1,'Color', linecolor1{ll},'Opacity',disp.opacity(ll));
        %data_Cim2d.cboxL_im0L{ll}= insertShape(im0L*0+255, 'FilledRectangle', bbox_t1,'Color', linecolor1{ll},'Opacity',disp.opacity(ll));
     
        if isempty(idp1)~=1
            ydata(ll)=length(idp1);
        else
            ydata(ll)=0;
        end
        try
            
        indLable.table{ll,1}=tableA.id_chh(idp1);
        indLable.id_chh{ll,1}=tableA.id_chh(idp1);
        catch
        indLable.table{ll,1}=tableA.id_masknii(idp1);
        indLable.id_chh{ll,1}=tableA.id_masknii(idp1);
        end
    else
        ydata(ll)=0;
    end
end
