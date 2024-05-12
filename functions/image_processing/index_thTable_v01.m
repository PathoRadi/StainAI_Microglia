function [ind,dataA_bar]=index_thTable_v01(tableA,threshold_para, varargin)
if isempty(varargin)~=1
    sample_ID=varargin{1};
    disp=varargin{2};
    if isfield(disp,'th_FM')==0
        disp.th_FM=0;
    end
else
    disp.th_FM=0;
end
    
for hh=1:length(threshold_para.name)
    if isempty(threshold_para.name{hh})~=1
        if isempty(threshold_para.max{hh})~=1;
            thmax{hh}=find(tableA.(threshold_para.name{hh})<=threshold_para.max{hh});
        else;
            thmax{hh}=1:size(tableA.(threshold_para.name{hh}),1);
        end
        if isempty(threshold_para.min{hh})~=1;thmin{hh}=find(tableA.(threshold_para.name{hh})>=threshold_para.min{hh});else;thmin{hh}=1:size(tableA.(threshold_para.name{hh}),1);end
        if hh==1;ind.th=intersect(thmax{hh},thmin{hh});else;ind.th0=intersect(thmax{hh},thmin{hh});ind.th=intersect(ind.th,intersect(thmax{hh},thmin{hh}));end
    else
        ind.th=1:size(tableA,1);
    end
end
if istablefield(tableA,'FM_BREN_bbox1p2')
    ind.FMge=find(tableA.FM_BREN_bbox1p2>=disp.th_FM);  % >=disp.th_FM
    ind.thFMge=intersect(ind.FMge,ind.th);    % parameter threshold + >= disp.th_FM
    ind.FMlt=find(tableA.FM_BREN_bbox1p2<disp.th_FM);     % < disp.th_FM
    ind.thFMlt=intersect(ind.FMlt,ind.th);        % parameter threshold + < disp.th_FM
else
    ind.FMge=find(tableA.FM>=disp.th_FM);  % >=disp.th_FM
    ind.thFMge=intersect(ind.FMge,ind.th);    % parameter threshold + >= disp.th_FM
    ind.FMlt=find(tableA.FM<disp.th_FM);     % < disp.th_FM
    ind.thFMlt=intersect(ind.FMlt,ind.th);        % parameter threshold + < disp.th_FM
end

ind.Ntype=zeros(size(tableA,1),1);
for si=1:length(sample_ID)
    sample_ID_name=regexprep(sample_ID{si},' ','_');

    if istablefield(tableA,'filename')
        ind.(sample_ID_name)=find(contains(tableA.filename,sample_ID_name)==1); % sample, all slides
    else
        ind.(sample_ID_name)=1:size(tableA,1);

    end
    id_FM0=intersect(ind.FMlt,ind.(sample_ID_name)); 

   % areaCH_badFM(si)=sum([tableA.CHA(id_FM0)]);                           % sum of bad focus CHA
    
    for ll=1:length(disp.type_name0)
        ind_type_C50=find(strcmp(tableA.C50,disp.type_name0{ll})==1);  % ind of cell type
        cId0{ll,si}=intersect(ind_type_C50, ind.(sample_ID_name));         % ind of cell type in each sample
        dataA_bar.numtype0(ll,si)=length(cId0{ll,si});                    % number of cell type (ll) in sample (si)
        cId_FM0{ll,si}=intersect(ind.FMge,cId0{ll,si});                  % ind of cell type in each sample > disp.th_FM
        dataA_bar.numtype0_FMge(ll,si)=length(cId_FM0{ll,si});                % number of cell type (ll) in sample (si) > disp.th_FM
        cId{ll,si}=intersect(ind.th,cId0{ll,si});                         % ind of cell type in each sample with threshold_para
        dataA_bar.numtype(ll,si)=length(cId{ll,si});                          % number of cell type (ll) in sample (si) with threshold_para
        cId_FM{ll,si}=intersect(ind.thFMge,cId{ll,si});
        dataA_bar.numtype_FMge(ll,si)=length(cId_FM{ll,si});                  % number of cell type (ll) in sample (si) with threshold_para, > disp.th_FM
        ind.Ntype(ind_type_C50)=ll;
    end
end


