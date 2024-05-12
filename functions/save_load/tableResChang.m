function [table_01]=tableResChang(table_00,size_zpe,pixel_size,flag);
table_01=table_00;
% bbox
bbox0=table_00.bbox;
N_bbox=table_00.N_bbox;

if flag.imzp==1
    bbox0(:,1)=bbox0(:,1)-ceil(size_zpe(2)/2)+1;
    bbox0(:,2)=bbox0(:,2)-ceil(size_zpe(1)/2)+1;
    N_bbox(:,1)=N_bbox(:,1)-ceil(size_zpe(2)/2)+1;
    N_bbox(:,2)=N_bbox(:,2)-ceil(size_zpe(1)/2)+1;

end
if pixel_size~=0.464
    %bboxtest=bbox0.*(0.464/pixel_size);
    bbox0=bbox0.*(0.464/pixel_size);
    N_bbox=N_bbox.*(0.464/pixel_size);

    if istablefield(table_01,'NA')==1
        table_01.NA=table_00.NA*(0.464/pixel_size).^2;
    end
    if istablefield(table_01,'NP')==1
        table_01.NP=table_00.NP*(0.464/pixel_size);
    end
    if istablefield(table_01,'NC_cdist')==1
        table_01.NC_cdist=table_00.NC_cdist*(0.464/pixel_size);
    end
    if istablefield(table_01,'CA')==1
        table_01.CA=table_00.CA*(0.464/pixel_size).^2;
    end
    if istablefield(table_01,'MajorAxisLength')==1
        table_01.MajorAxisLength=table_00.MajorAxisLength*(0.464/pixel_size);
    end
    if istablefield(table_01,'MinorAxisLength')==1
        table_01.MinorAxisLength=table_00.MinorAxisLength*(0.464/pixel_size);
    end
    if istablefield(table_01,'CHA')==1
        table_01.CHA=table_00.CHA*(0.464/pixel_size).^2;
    end
    if istablefield(table_01,'CP')==1
        table_01.CP=table_00.CP*(0.464/pixel_size);
    end
    if istablefield(table_01,'CHP')==1
        table_01.CHP=table_00.CHP*(0.464/pixel_size);
    end
    if istablefield(table_01,'MaxSACH')==1
        table_01.MaxSACH=table_00.MaxSACH*(0.464/pixel_size);
    end
    if istablefield(table_01,'MinSACH')==1
        table_01.MinSACH=table_00.MinSACH*(0.464/pixel_size);
    end
    if istablefield(table_01,'diameterBC')==1
        table_01.diameterBC=table_00.diameterBC*(0.464/pixel_size);
    end
    if istablefield(table_01,'meanCHrd')==1
        table_01.meanCHrd=table_00.meanCHrd*(0.464/pixel_size);
    end
    if istablefield(table_01,'distC_mean')==1
        table_01.distC_mean=table_00.distC_mean*(0.464/pixel_size);
    end
    if istablefield(table_01,'distC_std')==1
        table_01.distC_std=table_00.distC_std*(0.464/pixel_size);
    end
    if istablefield(table_01,'distC_median')==1
        table_01.distC_median=table_00.distC_median*(0.464/pixel_size);
    end
    if istablefield(table_01,'distE_mean')==1
        table_01.distE_mean=table_00.distE_mean*(0.464/pixel_size);
    end
    if istablefield(table_01,'distE_std')==1
        table_01.distE_std=table_00.distE_std*(0.464/pixel_size);
    end
    if istablefield(table_01,'distE_median')==1
        table_01.distE_median=table_00.distE_median*(0.464/pixel_size);
    end
    if istablefield(table_01,'distN_mean')==1
        table_01.distN_mean=table_00.distN_mean*(0.464/pixel_size);
    end
    if istablefield(table_01,'distN_std')==1
        table_01.distN_std=table_00.distN_std*(0.464/pixel_size);
    end
    if istablefield(table_01,'distN_median')==1
        table_01.distN_median=table_00.distN_median*(0.464/pixel_size);
    end
end

table_01.bbox=bbox0;
table_01.N_bbox=N_bbox;



  % 
  % table_01=table_00;
  %                                   bbox0=mat2cell(table_01.bbox,ones(length(table_01.bbox),1),4);
  %                                   bbox2=reshape(cell2mat(bbox0'),4,length(bbox0))';                                
  %                                   if flag.imzp==1
  %                                       bbox2(:,1)=bbox2(:,1)-setp.size_zpe(2)/2; %x
  %                                       bbox2(:,2)=bbox2(:,2)-setp.size_zpe(1)/2; %y
  %                                   end
  %                                   if data1{nn,1}.info.pixel_size~=0.464
  %                                       rz1=(size(data1{nn,1}.im0gray)-setp.size_zpe)./size(data1{nn,1}.im0gray_orig);
  %                                       bbox2=bbox2./rz1(1);
  %                                   end
  %                                   bbox0=mat2cell(bbox2,ones(length(table_01.bbox),1),4);
  %                                   %table_01 = renamevars(table_01,'bbox','Ntemp');
  %                                   table_01=renamevars_chh(table_01,'bbox','Ntemp');
  %                                   bbox=cellfun(@mat2str,bbox0,'UniformOutput',false);table_01= addvars(table_01,bbox,'after','Ntemp');table_01=removevars(table_01,'Ntemp');
  %                                   try
  %                                       N_bbox0=mat2cell(table_01.bbox_core,ones(length(table_01.bbox),1),4);
  %                                   catch
  %                                       N_bbox0=mat2cell(table_01.N_bbox,ones(length(table_01.N_bbox),1),4);
  %                                   end
  % 
  %                                   bbox2=reshape(cell2mat(N_bbox0'),4,length(N_bbox0))';
  %                                   if flag.imzp==1
  %                                       bbox2(:,1)=bbox2(:,1)-setp.size_zpe(2)/2; %x
  %                                       bbox2(:,2)=bbox2(:,2)-setp.size_zpe(1)/2; %y
  %                                   end
  %                                   if data1{nn,1}.info.pixel_size~=0.464
  %                                       rz1=(size(data1{nn,1}.im0gray)-setp.size_zpe)./size(data1{nn,1}.im0gray_orig);
  %                                       bbox2=bbox2./rz1(1);
  %                                   end
  %                                   N_bbox0=mat2cell(bbox2,ones(length(table_01.bbox),1),4);