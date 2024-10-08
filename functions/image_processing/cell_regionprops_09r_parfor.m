function [tableN,tableNr,atlas_allcellcore_N,iex]=cell_regionprops_09r(data1,select_data,flag,save_filename,mpara,varargin)
mpara.threshold_size=[15 4];
mpara.threshold_length=[3 3];
mpara.fm_size_increase_ratio=1.2;
mpara.FD_size_increase=10;
mpara.reduc_p=2;
mparaFrac.case_sampling='power_of_2';%'power_of_2';% 2 4 8 16 32 64 128 256,
%'power_series'; % 2 4 16 64 256
mparaFrac.set_im_dimmension='greater';
mparaFrac.set_max_box_ratio=0.45;
mparaFrac.num_grid=12;
mparaFrac.flag_bbox=0;
mparaFrac.startpoint='fixed';%'rand'
save_filename_temp=[save_filename(1:end-4) '_temp.mat'];
save_filename_temp2=[save_filename(1:end-4) '_temp2.mat'];
if isempty(varargin)==1
    opt.core_CA=1;opt.core_rCA=1;opt.core_CP=1;
    opt.core_rCP=1;opt.core_CC=1;opt.core_Cdist=1;  %distance between core center and cell center
    opt.core_rCdistM=1;opt.core_mean=1;opt.core_std=1;
    opt.bbox_core=1;opt.segmentation_core=1;
    
    opt.CA=1;opt.MajorAxisLength=1;opt.MinorAxisLength=1;
    opt.Eccentricity=1;opt.CHA=1;opt.Density=1;opt.Extent=1;
    opt.FD=1;opt.LC=1;opt.LCstd=1;opt.CP=1;opt.CC=1;opt.CHC=1;
    opt.MaxSACH=1;opt.MinSACH=1;opt.CHSR=1;opt.Roughness=1;
    opt.diameterBC=1;opt.rMmCHr=1;opt.meanCHrd=1;opt.MeanIntensity=1;
    opt.MinIntensity=1;opt.MaxIntensity=1;opt.StdIntensity=1;opt.MedianIntensity=1;
    opt.FM_BREN_bbox1p2=1;opt.distCE=1;
    opt.distCE=1;
    opt.soma=1;opt.distS=1;
    if opt.distCE==1
        %distC_slr distE_slr dist_para
        opt.distC_mean=1;opt.distC_std=1;opt.distC_median=1;opt.distC_N=1;opt.distE_mean=1;opt.distE_std=1;opt.distE_median=1;
        opt.distC_slr=1;opt.distE_slr=1;
    end
else
    opt.core_CA=0;opt.core_rCA=0;opt.core_CP=0;
    opt.core_rCP=0;opt.core_CC=0;opt.core_Cdist=0;
    opt.core_rCdistM=0;opt.core_mean=0;opt.core_std=0;
    opt.bbox_core=0;opt.segmentation_core=0;
    opt.CA=0;opt.MajorAxisLength=0;opt.MinorAxisLength=0;
    opt.Eccentricity=0;opt.CHA=0;opt.Density=0;opt.Extent=0;
    opt.FD=0;opt.LC=0;opt.LCstd=0;opt.CP=0;opt.CC=0;opt.CHC=0;
    opt.MaxSACH=0;opt.MinSACH=0;opt.CHSR=0;opt.Roughness=0;
    opt.diameterBC=0;opt.rMmCHr=0;opt.meanCHrd=0;opt.MeanIntensity=0;
    opt.MinIntensity=0;opt.MaxIntensity=0;opt.StdIntensity=0;opt.MedianIntensity=0;
    opt.FM_BREN_bbox1p2=0;opt.distCE=0;
    opt.distC_mean=0;opt.distC_std=0;opt.distC_median=0;opt.distC_N=0;opt.distE_mean=0;opt.distE_std=0;opt.distE_median=0;
    opt.soma=0;opt.distS=0;
    for rr=1:length(varargin{1})
        opt.(varargin{1}{rr})=1;
    end
    if opt.distCE==1 
        opt.distS_mean=1;opt.distS_std=1;opt.distS_median=1;opt.distS_N=1;opt.distS_slr=1; %soma temp
        opt.distS_slr=1;opt.distS_slr=1;
        opt.distC_mean=1;opt.distC_std=1;opt.distC_median=1;opt.distC_N=1;opt.distE_mean=1;opt.distE_std=1;opt.distE_median=1;
        opt.distC_slr=1;opt.distE_slr=1;
    end
end
if mpara.save_figure==1
    if exist(mpara.folder_fig_temp,'dir')==0;mkdir(mpara.folder_fig_temp);end
end
rng(6,'twister'); % keep same result from kmean
src=get(0,'ScreenSize');

%psize=data1.info.pixel_size;
psize=0.464; % images must resize into the training image resolution: 0.464um

% for testing data before July,2023, Area must *(0.464/DataSetInfo.im_pixel_size).^2

% len=100;
if isfield(data1.(select_data),'coco')==1
    table_cocoA=struct2table(data1.(select_data).coco.annotations);
    try
        table_cocoA_sort=sortrows(table_cocoA,'id_chh');
    catch
        table_cocoA_sort=sortrows(table_cocoA,'id_masknii');
    end
    %table_cocoA_sort=table_cocoA_sort(1:len,:);
else
    if isfield(data1.(select_data),'cocoP')==1
        table_cocoA=struct2table(data1.(select_data).cocoP.annotations);
        
        try
            table_cocoA_sort=sortrows(table_cocoA,'id_chh');
        catch
            table_cocoA_sort=sortrows(table_cocoA,'id_masknii');
        end
    
        %table_cocoA_sort=table_cocoA_sort(1:len,:);
    end
    
end
% len=size(table_cocoA_sort,1);
qnum=unique(data1.(select_data).atlas_allcell_N);qnum=qnum(qnum~=0);

stats0=regionprops(data1.(select_data).atlas_allcell_N,data1.im0gray,'MeanIntensity','MaxIntensity','MinIntensity','PixelValues','WeightedCentroid');
stats0=stats0(qnum);
len=length(stats0);
if len==1
    table0=struct2table(stats0(1:len),'AsArray',1);
else
    table0=struct2table(stats0(1:len));
end

pv=table2cell(table0);
pv=pv(:,1);pv=cellfun(@double,pv,'UniformOutput',false);

StdIntensity=cellfun(@std,pv);table0= addvars(table0,StdIntensity);
MedianIntensity=cellfun(@median,pv);table0= addvars(table0,MedianIntensity);
table0r=table0(:,{'PixelValues','WeightedCentroid'});
table0= removevars(table0,{'PixelValues'}); table0= removevars(table0,{'WeightedCentroid'});

stats1=regionprops(data1.(select_data).atlas_allcell_N,'BoundingBox','ConvexImage','ConvexHull','Image','Area','Extent','ConvexArea','Solidity',...
    'Eccentricity','MajorAxisLength','MinorAxisLength');

%stats1=regionprops(data1.(select_data).atlas_allcell_N,'ConvexImage','Image','Area','BoundingBox','Extent','ConvexArea','Solidity',...
%            'Perimeter','Circularity','Eccentricity','MajorAxisLength','MinorAxisLength','Orientation','centroid');

stats1=stats1(qnum(1:len));
if len==1
    table1=struct2table(stats1(1:len),'AsArray',1);
else
    table1=struct2table(stats1(1:len));
end
dd=find(strcmp(table1.Properties.VariableNames,'Area')==1);table1.Properties.VariableNames(dd)={'CA'}; table1.CA = table1.CA.*(psize).^2;        % C
%dd=find(strcmp(table1.Properties.VariableNames,'Perimeter')==1);table1.Properties.VariableNames(dd)={'CP'};table1.CP = table1.CP.*(psize);  % F
dd=find(strcmp(table1.Properties.VariableNames,'Solidity')==1);table1.Properties.VariableNames(dd)={'Density'}; % E
dd=find(strcmp(table1.Properties.VariableNames,'ConvexArea')==1);table1.Properties.VariableNames(dd)={'CHA'};table1.CHA = table1.CHA.*(psize).^2;   % D
%dd=find(strcmp(table1.Properties.VariableNames,'Circularity')==1);table1.Properties.VariableNames(dd)={'CC'};   % J
table1.MajorAxisLength = table1.MajorAxisLength.*(psize);
table1.MinorAxisLength = table1.MinorAxisLength.*(psize);

table1r=table1(:,{'ConvexImage','Image'});
table1= removevars(table1,{'ConvexImage','Image','BoundingBox'});
%idath=find(table1.CA>500);

statsCH = struct('Centroid', cell(len, 1), 'ConvexHull', cell(len, 1), 'Circularity', cell(len, 1), 'Perimeter', cell(len, 1),...
    'MaxFeretDiameter', cell(len, 1), 'MaxFeretAngle', cell(len, 1),'MaxFeretCoordinates', cell(len, 1),...
    'MinFeretDiameter', cell(len, 1), 'MinFeretAngle', cell(len, 1),'MinFeretCoordinates', cell(len, 1));

CA=zeros(len,1);
CP=zeros(len,1);
CC=zeros(len,1);
CHC=zeros(len,1);

diameterBC=zeros(len,1); %L
rMmCHr=zeros(len,1);
meanCHrd=zeros(len,1);
FD=zeros(len,1);
LC=zeros(len,1);
LCstd=zeros(len,1);
%FD1=zeros(len,1);
%LC1=zeros(len,1);
%LCstd1=zeros(len,1);

%LC2=zeros(len,1);
%FM_BREN_bbox=zeros(len,1);
FM_BREN_bbox1p2=zeros(len,1);
%FM_BREN_bbox2=zeros(len,1);
%prop=repmat({'Circularity'},length(cvIm),1);stats=cellfun(@(x,y) regionprops(x,y),cvIm,prop,'UniformOutput',0);toc

core_CA=zeros(len,1);
core_mean=zeros(len,1);
core_std=zeros(len,1);
core_CP=zeros(len,1);
core_CC=zeros(len,1);
core_rCA=zeros(len,1);
core_rCP=zeros(len,1);
core_Cdist=zeros(len,1);
core_rCdistM=zeros(len,1);
distC_slr=zeros(len,1);distC_mean=zeros(len,1);distC_std=zeros(len,1);distC_median=zeros(len,1);distC_N=zeros(len,1); % distance of cell center
distE_slr=zeros(len,1);distE_mean=zeros(len,1);distE_std=zeros(len,1);distE_median=zeros(len,1);iex=zeros(1,len);     % distance of edge
dist_para=repmat({''},len,1);

distN_slr=zeros(len,1);distN_mean=zeros(len,1);distN_std=zeros(len,1);distN_median=zeros(len,1);   % distance from nuclei core
bwcoreCell=repmat({''},len,1);

    
bcpr='';bn='';
%figure(1);imagesc(atlas_allcellcore_N)
if exist(save_filename_temp,'file')~=0
    load(save_filename_temp)
    if isempty(bcpr)==1
        bn=bcp+1:len;
    else
        bn=bcpr+1:len;
    end
else
    if exist(save_filename,'file')~=0
        bcp='';bcpr='';
        features=load(save_filename);%if isempty(bcp)==1;bcp=bb;end
        % figure(1);imagesc(atlas_allcellcore_N)

        CA=features.tableN.CA;
        CP=features.tableN.CP;
        CC=features.tableN.CC;
        CHC=features.tableN.CHC;
        diameterBC=features.tableN.diameterBC;
        rMmCHr=features.tableN.rMmCHr;
        meanCHrd=features.tableN.meanCHrd;
        FD=features.tableN.FD;
        LC=features.tableN.LC;
        LCstd=features.tableN.LCstd;
        FM_BREN_bbox1p2=features.tableN.FM_BREN_bbox1p2;
        atlas_allcellcore_N=features.atlas_allcellcore_N;
        core_CA=features.tableN.NA;
        core_mean=features.tableN.N_MeanIntensity;
        core_std=features.tableN.N_StdIntensity;
        core_CP=features.tableN.NP;
        core_CC=features.tableN.NC;
        core_rCA=features.tableN.NCAr;
        core_rCP=features.tableN.NCPr;
        core_Cdist=features.tableN.NC_cdist;
        core_rCdistM=features.tableN.NC_cdist2MaxSACHr;
        distC_mean=features.tableN.distC_mean;
        distC_std=features.tableN.distC_std;
        distC_median=features.tableN.distC_median;
        distC_N=features.tableN.distC_N;
        dist_para=features.tableNr.dist_para;
        distC_slr=features.tableN.distC_slr;
        distE_slr=features.tableN.distE_slr;
        distE_mean=features.tableN.distE_mean;
        distE_std=features.tableN.distE_std;
        distE_median=features.tableN.distE_median;
        iex=features.iex;
        %statsCH(bcp,1)=regionprops(stats1(bcp).ConvexImage,'Perimeter','Circularity','MaxFeretProperties','MinFeretProperties','Centroid','ConvexHull');
        if isempty(varargin)==1
            bn=bcp+1:len;
        else
            if isempty(bcpr)~=1
                bn=bcpr+1:len;
            else
                bn=1:len;
            end
        end

    else
        atlas_allcellcore_N=data1.(select_data).atlas_allcell_N*0;
        bn=1:len;
    end
end
 

% bn=fix(len/24)*24+1:len;
%bbi=1;%red_pixel=3;
if flag.rcal_all==1
    bn=1:len;
end

%%% paper figureS4 k-means Shrink Edge Algorithm  
%figure(1);imagesc(data1.(select_data).atlas_allcell_N);axis image
%(A) 33206 (B) bs=[31723 27558  39159 44970  35782 9304 37190 12329];% 
%for ii=1:length(bs);bns(ii)=bn(find(qnum==bs(ii)));end;tttk=1;
% if mpara.save_figure==1
%     bn=find(qnum==12546);  %12546 <=vip: paper figure cell distance
% end
if isempty(bn)~=1
    delete(gcp('nocreate'))
    
    parpool('local', maxNumCompThreads);
    bLength=length(bn);
    % Preallocate necessary variables
    iex = zeros(1, bLength);  % Assuming iex is initialized to a size of 10

% FM_BREN_bbox1p2 = zeros(bLength, 1);  % Preallocate FM_BREN_bbox1p2
%     CA = zeros(bLength, 1);
%     CP = zeros(bLength, 1);
%     CC = zeros(bLength, 1);
%     core_CA = zeros(bLength, 1);
%     core_mean = zeros(bLength, 1);
%     core_std = zeros(bLength, 1);
%     core_CP = zeros(bLength, 1);
%     core_CC = zeros(bLength, 1);
%     core_rCA = zeros(bLength, 1);
%     core_rCP = zeros(bLength, 1);
%     core_Cdist = zeros(bLength, 1);
%     core_rCdistM = zeros(bLength, 1);
%     LC = zeros(bLength, 1);
%     LCstd = zeros(bLength, 1);
%     FD = zeros(bLength, 1);
%     CHC = zeros(bLength, 1);
%     diameterBC = zeros(bLength, 1);
%     rMmCHr = zeros(bLength, 1);
%     meanCHrd = zeros(bLength, 1);
%     bwcoreCell=repmat({''},bLength,1);

    %bwcoreCC = zeros(bLength, 1);
    % Parfor loop version
    parfor bcp = bn
        boxtemp = ceil(stats1(bcp).BoundingBox);

        % Avoid shared variables (intersect function should return to local variable within parfor)
        if sum(table_cocoA_sort.bbox(bcp, :) - boxtemp) ~= 0
            ie1 = find(table_cocoA_sort.bbox(:, 1) == boxtemp(1));
            ie2 = find(table_cocoA_sort.bbox(:, 2) == boxtemp(2));
            iex(bcp) = intersect(ie1, ie2);  % Storing results in preallocated array
        else
            iex(bcp) = bcp;
        end
        % Conditional block for focus measure calculation
        if opt.FM_BREN_bbox1p2 == 1
            % Calculate bounding box size
            bfcsize = fix((boxtemp(3:4) / 2) * mpara.fm_size_increase_ratio);
            bfc = fix([fix(boxtemp(2) + boxtemp(4) / 2) - bfcsize(2), fix(boxtemp(2) + boxtemp(4) / 2) + bfcsize(2), ...
                fix(boxtemp(1) + boxtemp(3) / 2) - bfcsize(1), fix(boxtemp(1) + boxtemp(3) / 2) + bfcsize(1)]);

            % Extract sub-image for focus measure
            ims1p2 = double(data1.im0gray(bfc(1):bfc(2), bfc(3):bfc(4)));

            % Apply focus measure calculation
            FM_BREN_bbox1p2(bcp, 1) = fmeasure(ims1p2, 'BREN');
        end
        %%if opt.core_Cdist==1 || opt.core_rCdistM==1
        state_cell=regionprops(uint8(stats1(bcp).Image),'Centroid','MaxFeretProperties');
        %end
        if opt.CA==1 || opt.core_rCA;
            CA(bcp,1)=sum(stats1(bcp).Image(:)).*psize.*psize;
        end
        rp_bwt=regionprops(stats1(bcp).Image, 'Perimeter');

        if opt.CP==1 || opt.core_rCP==1 || opt.CC==1
            %cpi=[state_cell(:).Perimeter];
            cpi=[rp_bwt(:).Perimeter];
            CP(bcp,1)=sum(cpi)*psize;
        end

        if opt.CC==1;
            %rp_bwt=regionprops(stats1(bcp).Image, 'Perimeter','Area');
            CA0=sum(stats1(bcp).Image(:)).*psize.*psize;
            cpi=[rp_bwt(:).Perimeter];
            CP0=sum(cpi)*psize;
            CC(bcp,1)=4*pi*CA0./(CP0.^2);%clear CA0 CP0

            %bwim2=imresize(stats1(bcp).Image,size(stats1(bcp).Image)*10,'nearest');
            %figure(1);imagesc(bwim2);axis image
            %stats1_cc=regionprops(uint8(bwim2), 'Perimeter','Circularity','Area');
            %ca0=sum(bwim2(:));cpi=[stats1_cc(:).Perimeter];cp0=sum(cpi);
            %stats1_cc0=regionprops(uint8(stats1(bcp).Image), 'Perimeter','Circularity','Area');
            %CC(bcp,1)=4*pi*ca0./(cp0.^2);
        end

        if opt.core_CA==1 || opt.core_rCA==1 || opt.core_CP==1 || opt.core_rCP==1 || opt.core_CC==1 || opt.core_Cdist==1 || opt.core_rCdistM==1 || opt.core_mean==1 || opt.core_std==1
            ims2=double(data1.im0gray(boxtemp(2):boxtemp(2)+boxtemp(4)-1,boxtemp(1):boxtemp(1)+boxtemp(3)-1));
            if sum(stats1(bcp).Image(:))<=mpara.threshold_size(1)
                bwcore=stats1(bcp).Image;
            else
                % bwcore=get_cellcore_v02(ims2,stats1(bb).Image,3);  %reduce-edge , kmean, intersect
                bwcore=get_cellcore_v03(ims2,stats1(bcp).Image,mpara.reduc_p); % kmean => reduce edge
            end
            bwcoreCell{bcp}=bwcore;
 
            % % set uint8, only area will be merge
            state_core=regionprops(uint8(bwcore), 'Perimeter','Circularity','Area','Centroid');
            if opt.core_CA==1 || opt.core_rCA;
                core_CA(bcp,1)=sum(bwcore(:)).*psize.*psize;end
            if opt.core_mean==1;
                core_mean(bcp,1)=mean(ims2(bwcore==1));end
            if opt.core_std==1;
                core_std(bcp,1)=std(ims2(bwcore==1));end
            if opt.core_CP==1 || opt.core_rCP==1;
                rp_bwt=regionprops(bwcore, 'Perimeter');
                core_cpi=[rp_bwt(:).Perimeter];
                core_CP(bcp,1)=sum(core_cpi)*psize;
            end
            if opt.core_CC==1;
                %bwcore2=imresize(bwcore,size(bwcore)*10,'nearest');
                state_core2=regionprops(bwcore, 'Perimeter','Circularity','Area');
                core_ca0=sum(bwcore(:));core_cpi=[state_core2(:).Perimeter];core_cp0=sum(core_cpi);
                core_CC(bcp,1)=4*pi*core_ca0./(core_cp0.^2);
            end
            if opt.core_rCA==1;
                core_rCA(bcp,1)=core_CA(bcp,1)./CA(bcp,1);end
            if opt.core_rCP==1;
                core_rCP(bcp,1)=core_CP(bcp,1)./CP(bcp,1);end
            if opt.core_Cdist==1;
                core_Cdist(bcp,1)=(sum((state_cell.Centroid-state_core.Centroid).^2).^0.5)*psize;end
            if opt.core_rCdistM==1
                core_rCdistM(bcp,1)=(sum((state_cell.Centroid-state_core.Centroid).^2).^0.5)./state_cell.MaxFeretDiameter;end

        end

        if opt.FD==1 || opt.LC==1
            % figure(1);imagesc(stats1(bcp).Image)
            %  rsizeN=256/max(size(stats1(bcp).Image));
            %  bwfd2=imresize(stats1(bcp).Image,size(stats1(bcp).Image)*rsizeN,'nearest');


            bwfdsize=size(stats1(bcp).Image)+mpara.FD_size_increase;
            bwfd=zeros(bwfdsize);
            bwfd(fix(size(bwfd,1)/2)-fix(size(stats1(bcp).Image,1)/2)+1:fix(size(bwfd,1)/2)-fix(size(stats1(bcp).Image,1)/2)+size(stats1(bcp).Image,1),...
                fix(size(bwfd,2)/2)-fix(size(stats1(bcp).Image,2)/2)+1:fix(size(bwfd,2)/2)-fix(size(stats1(bcp).Image,2)/2)+size(stats1(bcp).Image,2))=stats1(bcp).Image;


            [fracL]=lacunarity_Fraclac_chh02(bwfd,mparaFrac);
            if opt.LC==1;
                LC(bcp,1)=fracL.Lacunarity;
                LCstd(bcp,1)=fracL.Lacunarity_std;end
            if opt.FD==1;
                %FD1(bcp,1)=fractalanalysis_chh01(stats1(bcp).Image);
                %FD1(bcp,1)=fractalanalysis_chh01(bwfd);
                FD(bcp,1)=-mean(fracL.F__logSlope__DBcounts);
            end
        end

        % if opt.CHC==1 || opt.diameterBC==1 || opt.rMmCHr==1 || opt.meanCHrd==1
        % end
        %     if opt.CHC==1 || opt.rMmCHr==1
        %         imCH2=imresize(stats1(bcp).ConvexImage,size(stats1(bcp).ConvexImage)*10,'nearest');
        %     end
        if opt.CHC==1 || opt.diameterBC==1 || opt.rMmCHr==1 || opt.meanCHrd==1
            statsCH(bcp)=regionprops(stats1(bcp).ConvexImage,'Perimeter','Circularity','MaxFeretProperties','MinFeretProperties','Centroid','ConvexHull');
        end

        if opt.CHC==1
            stats1_chc=regionprops(stats1(bcp).ConvexImage, 'Perimeter','Circularity','Area');
            % figure(1);imagesc(imCH2);figure(2);imagesc(stats1(bcp).ConvexImage)
            ca0=sum(stats1(bcp).ConvexImage(:));cpi=[stats1_chc(:).Perimeter];cp0=sum(cpi);
            CHC(bcp,1)=4*pi*ca0./(cp0.^2);
        end
        %if opt.diameterBC==1 || opt.rMmCHr==1
            [c1,R1] = minboundcircle(stats1(bcp).ConvexHull(:,1),stats1(bcp).ConvexHull(:,2));   % L
            diameterBC(bcp,1)=R1*2*psize;
        %end

        if opt.rMmCHr==1 % cal from resize image v07r
            %figure(1);imagesc(imCH2);axis image
            %stats1_chc=regionprops(uint8(imCH2),'ConvexHull');
            %[~,R1] = minboundcircle(stats1_chc.ConvexHull(:,1),stats1_chc.ConvexHull(:,2));
            %[bwch_edgef]=BW_Edge_Modified_v09(imCH2, -1);[yb, xb]=find(bwch_edgef==true);[C2,R2] = incircle(xb,yb);
            %rMmCHr(bcp,:)=R1/R2;


            if size(stats1(bcp).ConvexImage,1)<=mpara.threshold_length(1) || size(stats1(bcp).ConvexImage,2)<=mpara.threshold_length(2)
                rMmCHr(bcp,:)=1;   %N
            else
                [bwch_edgef]=BW_Edge_Modified_v09(stats1(bcp).ConvexImage, -1);
                [yb, xb]=find(bwch_edgef==true);
                [C2,R2] = incircle(xb,yb);
                rMmCHr(bcp,:)=R1/R2;   %N
            end
        end
        if opt.meanCHrd==1
            if size(stats1(bcp).ConvexImage,1)<=mpara.threshold_length(1) || size(stats1(bcp).ConvexImage,2)<=mpara.threshold_length(1) || sum(stats1(bcp).ConvexImage(:))<=mpara.threshold_size(2)
                meanCHrd(bcp,1)=0;
            else
                [bwch_edgef]=BW_Edge_Modified_v09(stats1(bcp).ConvexImage, -1);
                [yb, xb]=find(bwch_edgef==true);
                ys=round(statsCH(bcp).Centroid(2));xs=round(statsCH(bcp).Centroid(1));
                dist00_bwch=((yb-repmat(ys,length(yb),1)).^2+(xb-repmat(xs,length(xb),1)).^2).^0.5;
                meanCHrd(bcp,1)=psize*mean(dist00_bwch);               % mean radii of convex hull
            end
        end
    end
    delete(gcp('nocreate'))
   

    for bcp=bn
        boxtemp = ceil(stats1(bcp).BoundingBox);
        atmask0=atlas_allcellcore_N(boxtemp(2):boxtemp(2)+boxtemp(4)-1,boxtemp(1):boxtemp(1)+boxtemp(3)-1);
        atmask0(bwcoreCell{bcp}==1)=qnum(bcp);% figure(1);imagesc(atmask0)
        atlas_allcellcore_N(boxtemp(2):boxtemp(2)+boxtemp(4)-1,boxtemp(1):boxtemp(1)+boxtemp(3)-1)=atmask0;
    end
%figure(1);imagesc(atlas_allcellcore_N)


    if opt.distCE==1
        parpool('local', maxNumCompThreads);

        parfor bcp =bn1
            %mpara.save_figure=0;
            boxtemp=ceil(stats1(bcp).BoundingBox);
            qq = qnum(bcp);
            bfcsize=[170 170];%clear xyc cp
            bfc=fix([fix(boxtemp(2)+boxtemp(4)/2)-bfcsize(2)+1 fix(boxtemp(2)+boxtemp(4)/2)+bfcsize(2),...
                fix(boxtemp(1)+boxtemp(3)/2)-bfcsize(1)+1 fix(boxtemp(1)+boxtemp(3)/2)+bfcsize(1)]); %y-x
            if bfc(1)<=0;bfc(2)=abs(bfc(1))+bfc(2)+1;bfc(1)=1;end
            if bfc(3)<=0;bfc(4)=abs(bfc(3))+bfc(4)+1;bfc(3)=1;end
            if bfc(2)>size(data1.im0gray,1);bfc(1)=bfc(1)-(size(data1.im0gray,1)-bfc(2))+1;bfc(2)=size(data1.im0gray,1);end
            if bfc(4)>size(data1.im0gray,2);bfc(3)=bfc(3)-(size(data1.im0gray,2)-bfc(4))+1;bfc(4)=size(data1.im0gray,2);end

            ims1p2=double(data1.im0gray(bfc(1):bfc(2),bfc(3):bfc(4)));
            ims1p3=data1.im0(bfc(1):bfc(2),bfc(3):bfc(4),:);

            at_temp=data1.(select_data).atlas_allcell_N(bfc(1):bfc(2),bfc(3):bfc(4));
            at_tempN=atlas_allcellcore_N(bfc(1):bfc(2),bfc(3):bfc(4));
            at_tempRN=zeros(size(at_tempN));
            at_tempR=zeros(size(at_tempN));
            
            q1=unique(at_temp);q1=q1(q1~=0);
            q2=unique(at_tempN);q2=q2(q2~=0);
            qd=setdiff(q1,q2);
            at_temp2=at_temp;
            if isempty(qd)~=1
                for dd=1:length(qd)
                    at_temp(at_temp==qd(dd))=0;
                end
            end
            q1=unique(at_temp);q1=q1(q1~=0);
            an=find(q1==qq);
            %figure(3);imagesc(at_temp2);axis image
            % if bcp==15
            %     bcp;mpara.save_figure=1;
            % end
            for ar=1:length(q1);
                at_tempR(at_temp==q1(ar))=ar;
                at_tempRN(at_tempN==q1(ar))=ar;
            end;
            nqR=unique(at_tempR);nqR=nqR(nqR~=0);nqR=nqR(nqR~=an);
            % mpara.save_figure=1;
            at_temp_L=getAtlasEdge(at_tempR,3,0,1);
            % if mpara.save_figure==1
            %     cmap1=jet(double(max(at_tempR(:))));
            %     icmap=randperm(size(cmap1,1));
            %     cmap2=cmap1(icmap,:);cmap2(an,:)=[1 0 1];
            %     imF1 = labeloverlay(uint8(ims1p2),at_temp_L,'Colormap',cmap2,'Transparency',0);
            %     if mpara.save_figure==1
            %         figure(3);imshow(imF1);axis image;hold on
            %         bwxxx=zeros(size(at_tempR));bwxxx(at_tempR==an)=1;
            %         figure(1);imagesc(at_tempR);axis image
            %         bwxxxL=getAtlasEdge(bwxxx,1,0);
            %     end
            % end
            %if opt.distCE==1
            %clear xyc cp xycN cpN
            stats_at = regionprops(at_tempR,'centroid');
            xyc1=ones(length(stats_at),1)*stats_at(an).Centroid(1);
            xyc2=ones(length(stats_at),1)*stats_at(an).Centroid(2);
            cp=[reshape([stats_at.Centroid],2,length(stats_at))]';
            dn=((xyc1-cp(:,1)).^2+(xyc2-cp(:,2)).^2).^0.5;

            stats_atN = regionprops(at_tempRN,'centroid');
            xycN1=ones(length(stats_atN),1)*stats_atN(an).Centroid(1);
            xycN2=ones(length(stats_atN),1)*stats_atN(an).Centroid(2);
            cpN=[reshape([stats_atN.Centroid],2,length(stats_atN))]';
            dnN=((xycN1-cpN(:,1)).^2+(xycN2-cpN(:,2)).^2).^0.5;

            % if mpara.save_figure==1
            %     bw0Lall=uint8(false(size(ims1p2)));
            % end
            bw0Lkeep=uint8(false(size(ims1p2)));
            %if mpara.save_figure==1
            at_temp_L2=uint8(false(size(ims1p2)));
            %end
            at_tempR2=uint8(false(size(ims1p2)));
            % if mpara.save_figure==1
            %at_tempRN2=uint8(false(size(ims1p2)));
            %at_tempRN3=uint8(false(size(ims1p2)));
            % end
            %tt5=1;
            % if mpara.save_figure==1
            %     bw0Lkeep_disp=uint8(false(size(ims1p2)));
            %     bw0Lkeep_dispN2=uint8(false(size(ims1p2)));
            %     bw0Lkeep_dispN3=uint8(false(size(ims1p2)));
            % end
            for dd=1:length(stats_at)
                bw1a=uint8(false(size(ims1p2)));
                if dd~=an
                    if isnan(cp(dd,2))~=1
                        bw0L1=ptconnect_02(round([xyc2(dd) xyc1(dd)]),round([cp(dd,2) cp(dd,1)]),size(ims1p2));
                        %if mpara.save_figure==1
                        %    [~,bw0L1inc]=BW_Edge_Modified_v09(bw0L1, 1);
                        %    bw0L1N=ptconnect_02(round([xycN(dd,2) xycN(dd,1)]),round([cpN(dd,2) cpN(dd,1)]),size(ims1p2));
                        %    [~,bw0L1incN]=BW_Edge_Modified_v09(bw0L1N, 1);
                        %end
                        bw1a(bw0L1==1)=at_tempR(bw0L1==1);
                        uqb1a=unique(bw1a);uqb1a=uqb1a(uqb1a~=0);
                        uqb1a=uqb1a(uqb1a~=an);uqb1a=uqb1a(uqb1a~=dd);
                        if isempty(uqb1a)==1
                            bw0Lkeep(bw0L1==1)=dd;
                            %dnb0(dd)=dn(dd);%tt5=tt5+1;
                            at_temp_L2(at_temp_L==dd)=dd;
                            at_tempR2(at_tempR==dd)=dd;
                            % if mpara.save_figure==1
                            %     at_tempRN2(at_tempRN==dd)=dd;
                            %     bw0Lkeep_disp(bw0L1inc==1)=dd;
                            %     bw0Lkeep_dispN2(bw0L1incN==1)=dd;
                            % end
                        end
                        % if mpara.save_figure==1
                        %     bw0Lall(bw0L1inc==1)=dd;
                        % end
                    end
                end
            end

            %dnb=dnb0(dnb0~=0);
            uqL2=unique(at_temp_L2);uqL2=uqL2(uqL2~=0);
            at_temp_L2(at_temp_L==an)=an;
            % if mpara.save_figure==1
            %     %mean(dnb)
            %     imF2 = labeloverlay(uint8(imF1),bw0Lall,'Colormap',cmap2,'Transparency',0);
            %     figure(40);imshow(imF2);axis image;hold on
            %     imF1b = labeloverlay(uint8(ims1p2),at_temp_L2,'Colormap',cmap2,'Transparency',0);
            %     imF2b = labeloverlay(uint8(imF1b),bw0Lkeep_disp,'Colormap',cmap2,'Transparency',0);
            %     figure(41);imshow(imF2b);axis image;hold on
            % end
            bw2keep=uint8(false(size(ims1p2)));
            %if mpara.save_figure==1
            %    bw2keep_disp=uint8(false(size(ims1p2)));
            %    bw2keep_dispL=uint8(false(size(ims1p2)));
            %end
            at_temp_L3=uint8(false(size(ims1p2)));
            at_tempR3=uint8(false(size(ims1p2)));
            indkeep=zeros(1,length(uqL2));

            for dd=1:length(uqL2)
                bwt1=uint8(false(size(ims1p2)));
                bw2a=uint8(false(size(ims1p2)));
                %clear yxt bw0L1
                bwt1(at_temp_L2==uqL2(dd))=1;
                [yxt1,yxt2]=find(bwt1==1); %y-x
                bw0L1=ptconnect_02(round([stats_at(an).Centroid(2) stats_at(an).Centroid(1)]),[yxt1  yxt2],size(ims1p2),1);
                bw0L1=imfill(uint8(bw0L1));[~,bw0L1]=BW_Edge_Modified_v09(bw0L1, -2);
                bwt2=uint8(bw0L1)+bwt1;
                bwach=uint8(false(size(ims1p2)));bwach(at_tempR==uqL2(dd))=1;
                bCH = bwconvhull(bwach);
                bw0L1(bCH==1)=0;
                %figure(112);imagesc(bw0L1);axis image

                bw2a(bw0L1==1)=at_tempR(bw0L1==1); %figure(222); imagesc(bw0L1);axis image
                uqb2a=unique(bw2a);uqb2a=uqb2a(uqb2a~=0);
                uqb2a=uqb2a(uqb2a~=an);uqb2a=uqb2a(uqb2a~=uqL2(dd));
                if isempty(uqb2a)==1
                    bw2keep(bw0L1==1)=uqL2(dd);
                    indkeep(dd)=uqL2(dd);%tt5=tt5+1;
                    at_temp_L3(at_temp_L2==uqL2(dd))=uqL2(dd);
                    at_tempR3(at_tempR2==uqL2(dd))=uqL2(dd);
                    % if mpara.save_figure==1
                    %     at_tempRN3(at_tempRN2==uqL2(dd))=uqL2(dd);
                    % end
                else
                    %%check overlap size
                    % if mpara.save_figure==1
                    %     figure(113);imagesc(bw2a);axis image
                    % end
                    bw2a(bw2a==an)=0;
                    bw2a(bw2a~=0)=1;
                    if sum(bw2a(:))<=100
                        bw2keep(bw0L1==1)=uqL2(dd);
                        %figure(111);imagesc();axis image
                        indkeep(dd)=uqL2(dd);%tt5=tt5+1;
                        at_temp_L3(at_temp_L2==uqL2(dd))=uqL2(dd);
                        at_tempR3(at_tempR2==uqL2(dd))=uqL2(dd);
                        % if mpara.save_figure==1
                        %     at_tempRN3(at_tempRN2==uqL2(dd))=uqL2(dd);
                        % end
                    else
                        % if mpara.save_figure==1
                        %     bw0Lkeep_disp(bw0Lkeep_disp==uqL2(dd))=0;
                        %     bw0Lkeep_dispN2(bw0Lkeep_dispN2==uqL2(dd))=0;
                        % end
                    end


                end
                % if mpara.save_figure==1
                %     bw2keep_disp(bw0L1==1)=uqL2(dd);
                %     bw0L1E=BW_Edge_Modified_v09(bw0L1, -1);
                %     bw2keep_dispL(bw0L1E==1)=uqL2(dd);
                % 
                %     %                 imF2b = labeloverlay(uint8(imF1b),bw0Lkeep_disp,'Colormap',cmap2,'Transparency',0);
                %     %                 at_temp_L4=at_temp_L3;at_temp_L4(at_temp_L3~=an)=0;
                %     %                 imF2b = labeloverlay(imF2b,at_temp_L4,'Colormap',cmap2,'Transparency',0.5);
                %     %                 figure(51);imshow(imF2b);axis image;hold on
                % 
                % end
            end

            % if mpara.save_figure==1
            %     imF2 = labeloverlay(uint8(imF1),bw0Lall,'Colormap',cmap2,'Transparency',0);
            %     cn=unique(at_temp_L3);cn=cn(cn~=0);
            %     cmap3=jet(length(cn));cmap4=cmap2;
            %     for nn=1:length(cn);cmap4(cn(nn),:)=cmap3(nn,:);end;cmap4(an,:)=[1 0 1];
            %     %cmap2=cmap4;
            %     %cmap2=cmap2(randperm(size(cmap1,1)),:)
            %     imF1b = labeloverlay(uint8(ims1p2),at_temp_L2,'Colormap',cmap2,'Transparency',0);
            %     imF2b = labeloverlay(uint8(imF1b),bw2keep_disp,'Colormap',cmap2,'Transparency',0.7);
            %     imF2b = labeloverlay(imF2b,bw2keep_dispL,'Colormap',cmap2,'Transparency',0.1);
            %     at_temp_L3(at_temp_L==an)=an;
            %     imF1b = labeloverlay(uint8(ims1p2),at_temp_L3,'Colormap',cmap2,'Transparency',0.5);
            %     figure(50);imshow(imF2b);axis image;hold on
            %     imF2b = labeloverlay(uint8(imF1b),bw0Lkeep_disp,'Colormap',cmap2,'Transparency',0);
            %     at_temp_L4=at_temp_L3;at_temp_L4(at_temp_L3~=an)=0;
            %     imF2b = labeloverlay(imF2b,at_temp_L4,'Colormap',cmap2,'Transparency',0.0);
            %     figure(51);imshow(imF2b);axis image;hold on
            % 
            %     bwL3=at_temp_L3;
            %     bwL3(at_temp_L3~=0)=1;
            %     rbwl3=roical_02(bwL3,bwL3);
            % 
            %     figure(52);imshow(imF2b(rbwl3.udlr(1):rbwl3.udlr(2),rbwl3.udlr(3):rbwl3.udlr(4),:));axis image;hold on
            % 
            %     imF1b = labeloverlay(uint8(ims1p2),at_temp_L2,'Colormap',cmap2,'Transparency',0);
            %     imF2b = labeloverlay(uint8(imF1b),bw2keep_disp,'Colormap',cmap2,'Transparency',0.7);
            %     imF2b = labeloverlay(imF2b,bw2keep_dispL,'Colormap',cmap2,'Transparency',0.1);
            %     at_temp_L3(at_temp_L==an)=an;
            %     imF1b = labeloverlay(uint8(ims1p2),at_temp_L3,'Colormap',cmap2,'Transparency',0.5);
            %     figure(55);imshow(imF2b);axis image;hold on
            %     imF2b = labeloverlay(uint8(imF1b),bw0Lkeep_disp,'Colormap',cmap2,'Transparency',0);
            %     at_temp_L4=at_temp_L3;at_temp_L4(at_temp_L3~=an)=0;
            %     imF2b = labeloverlay(imF2b,at_temp_L4,'Colormap',cmap2,'Transparency',0.5);
            %     figure(56);imshow(imF2b);axis image;hold on
            % 
            %     bwL3=at_temp_L3;
            %     bwL3(at_temp_L3~=0)=1;
            %     rbwl3=roical_02(bwL3,bwL3);
            % 
            %     figure(57);imshow(imF2b(rbwl3.udlr(1):rbwl3.udlr(2),rbwl3.udlr(3):rbwl3.udlr(4),:));axis image;hold on
            %     %%%%%%%%%%%%%%%
            %     at_tempRN3(at_tempRN==an)=an;
            %     at_tempRN3_L=getAtlasEdge(at_tempRN3,2,0,1);
            %     imF1b = labeloverlay(uint8(ims1p2),at_tempRN3_L,'Colormap',cmap2,'Transparency',0);
            %     figure(58);imshow(imF1b);axis image;hold on
            %     imF1b = labeloverlay(uint8(imF1b),bw0Lkeep_dispN2,'Colormap',cmap2,'Transparency',0.4);
            %     figure(59);imshow(imF1b);axis image;hold on
            % end

            at_temp_L3(at_temp_L==an)=an;
            %unique(at_temp_L3)
            indkeep=indkeep(indkeep~=0);
            if isempty(indkeep)==1
                indkeep=uqL2;
                at_temp_L3=at_temp_L2;
                dist_para{bcp}.ovpchk=0;
            else
                dist_para{bcp}.ovpchk=1;
            end

            indkeep=indkeep(indkeep~=an);  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            distadjc0=dn(indkeep);        %diststdth=(distadjc0-1)*psize;
            id_dist0=q1(indkeep);
            distC_mean(bcp,1)=mean(distadjc0-1)*psize;
            distC_std(bcp,1)=std(distadjc0-1)*psize;
            distC_median(bcp,1)=median(distadjc0-1)*psize;
            distC_N(bcp,1)=length(distadjc0);
            %distadjc0(:,2)=1:length(indkeep);
            %distadjc0_sort=sortrows(distadjc0,1);
            %distC_id(bcp,1:length(id_dist0))=id_dist0'; %[id_dist0(distadjc0_sort(:,2))]';

            % distance from nuclei mask
            %try
            distadjc0N=dnN(indkeep);
            % catch
            %     bcp
            % end
            id_dist0N=q1(indkeep);
            distN_mean(bcp,1)=mean(distadjc0N-1)*psize;
            distN_std(bcp,1)=std(distadjc0N-1)*psize;
            distN_median(bcp,1)=median(distadjc0N-1)*psize;

            dist_para{bcp}.box_udlr=bfc;
            dist_para{bcp}.center0_xy=stats_at(an).Centroid;
            dist_para{bcp}.center0N_xy=stats_atN(an).Centroid;
            dist_para{bcp}.idp=id_dist0;
            dist_para{bcp}.idpN=id_dist0N;
            dist_para{bcp}.centerp_xy=cp(indkeep,:);
            dist_para{bcp}.centerp_xyN=cpN(indkeep,:);

            %dist_para{bcp}.c_dist_px=distadjc0;

            if isempty(distadjc0)~=1
                if max(distadjc0-1)~=0
                    distC_slr(bcp,:)=min(distadjc0-1)./max(distadjc0-1);
                else
                    distC_slr(bcp,:)=1;
                end
            else
                distC_slr(bcp,:)=-1;
            end
            if isempty(distadjc0N)~=1
                if max(distadjc0N-1)~=0
                    distN_slr(bcp,:)=min(distadjc0N-1)./max(distadjc0N-1);
                else
                    distN_slr(bcp,:)=1;
                end
            else
                distN_slr(bcp,:)=-1;
            end
            bwLall0E=uint8(false(size(ims1p2)));
            bwE0=uint8(false(size(ims1p2)));
            bwE0(at_temp_L3==an)=1;
            dist_adjc0E=zeros(length(indkeep),1);
            %bwLkeep0E=uint8(false(size(ims1p2)));


            xy_e0=zeros(length(indkeep),2);
            xy_e1=zeros(length(indkeep),2);

            for dd=1:length(indkeep)
                bwE1=false(size(ims1p2));
                bwE1(at_temp_L3==indkeep(dd))=true;
                dist=bwEdist(bwE0,bwE1,1); %x-y
                %if mpara.save_figure==1
                %    %figure(112);imagesc(bwttt);axis image
                %    %ptconnect_02: y-x
                %    bwbridge=ptconnect_02(flip(dist.shortest_pixel{1}),flip(dist.shortest_pixel{2}),size(ims1p2),1);
                %    figure(111);imagesc(uint8(bwE1)+bwE0+uint8(bwbridge));axis image
                %end
                %bwLkeep0E(bwbridge==1)=indkeep(dd);
                dist_adjc0E(dd)=dist.shortest_dist;%tt5=tt5+1;
                xy_e0(dd,:)=dist.shortest_pixel{1};
                xy_e1(dd,:)=dist.shortest_pixel{2};
                %if mpara.save_figure==1
                %    [~,bwbridge]=BW_Edge_Modified_v09(bwbridge, 3);
                %    bwLall0E(bwbridge==1)=indkeep(dd);
                %end
            end

            % if mpara.save_figure==1
            %     %  imF3 = labeloverlay(uint8(imF1),bwLall0E,'Colormap',cmap2,'Transparency',0);
            %     % figure(70);imshow(imF3);axis image;hold on
            %     imF3b = labeloverlay(uint8(ims1p2),at_temp_L3,'Colormap',cmap2,'Transparency',0.5);
            %     imF3b = labeloverlay(uint8(imF3b),bwLall0E,'Colormap',cmap2,'Transparency',0);
            %     at_temp_L4=at_temp_L3;at_temp_L4(at_temp_L3~=an)=0;
            %     imF3b = labeloverlay(uint8(imF3b),at_temp_L4,'Colormap',cmap2,'Transparency',0);
            %     figure(71);imshow(imF3b);axis image;hold on
            % 
            %     bwL3=at_temp_L3;
            %     bwL3(at_temp_L3~=0)=1;
            %     rbwl3=roical_02(bwL3,bwL3);
            %     figure(72);imshow(imF3b(rbwl3.udlr(1):rbwl3.udlr(2),rbwl3.udlr(3):rbwl3.udlr(4),:));axis image;hold on
            % 
            %     imF3b = labeloverlay(uint8(ims1p3),at_temp_L3,'Colormap',cmap2,'Transparency',0.5);
            %     imF3b = labeloverlay(uint8(imF3b),bwLall0E,'Colormap',cmap2,'Transparency',0);
            %     at_temp_L4=at_temp_L3;at_temp_L4(at_temp_L3~=an)=0;
            %     imF3b = labeloverlay(uint8(imF3b),at_temp_L4,'Colormap',cmap2,'Transparency',0);
            %     figure(75);imshow(imF3b);axis image;hold on
            % 
            %     bwL3=at_temp_L3;
            %     bwL3(at_temp_L3~=0)=1;
            %     rbwl3=roical_02(bwL3,bwL3);
            %     figure(76);imshow(imF3b(rbwl3.udlr(1):rbwl3.udlr(2),rbwl3.udlr(3):rbwl3.udlr(4),:));axis image;hold on
            % end
            %distE01(bcp)=mean(dnb3-1)*psize;
            distE_mean(bcp,1)=mean(dist_adjc0E-1)*psize;
            distE_std(bcp,1)=std(dist_adjc0E-1)*psize;
            distE_median(bcp,1)=median(dist_adjc0E-1)*psize;

            dist_para{bcp}.edge0_xy=xy_e0;
            dist_para{bcp}.edgep_xy=xy_e1;
            %dist_adjc0E(:,2)=1:length(indkeep);
            %dist_adjc0E_sort=sortrows(dist_adjc0E,1);
            %distE_id(bcp,1:length(id_dist0))=[id_dist0(dist_adjc0E_sort(:,2))]';
            if isempty(dist_adjc0E)~=1
                if max(dist_adjc0E-1)~=0
                    distE_slr(bcp,:)=min(dist_adjc0E-1)./max(dist_adjc0E-1);
                else
                    distE_slr(bcp,:)=1;
                end
            else
                distE_slr(bcp,:)=-1;
            end
            %end
            %%{

            % if mpara.save_figure==1
            %     C_mean=mean(distadjc0-1)*psize
            %     C_std=std(distadjc0-1)*psize
            %     C_median=median(distadjc0-1)*psize
            %     size(distadjc0,1)
            % 
            %     E_mean=mean(dist_adjc0E-1)*psize
            %     E_std=std(dist_adjc0E-1)*psize
            %     E_median=median(dist_adjc0E-1)*psize
            % end
            %}
            %mpara.save_figure=0;
        end


    end



    save(save_filename_temp,'bcp','bcpr','CA','CP','CC','CHC','diameterBC','rMmCHr','meanCHrd','FD','LC','LCstd','FM_BREN_bbox1p2',...
        'statsCH','atlas_allcellcore_N','core_CA','core_mean','core_std','core_CP','core_CC','core_rCA','core_rCP','core_Cdist',...
        'core_rCdistM','distC_mean','distC_std','distC_median','distC_N','dist_para','distC_slr','distE_slr',...
        'distE_mean','distE_std','distE_median','iex',...
        'distN_mean','distN_std','distN_median','distN_slr','-v7.3');


end

%%
%if opt.segmentation_core==1
stats1_core=regionprops(atlas_allcellcore_N,'BoundingBox');
bsize0=size(atlas_allcellcore_N);
bbox_core=ceil(cell2mat(table2cell(struct2table(stats1_core))));
for qq=1:length(qnum)
    bwmask0=atlas_allcellcore_N(bbox_core(qnum(qq),2)-1:bbox_core(qnum(qq),2)+bbox_core(qnum(qq),4),bbox_core(qnum(qq),1)-1:bbox_core(qnum(qq),1)+bbox_core(qnum(qq),3));
    bwmask0(bwmask0~=qnum(qq))=0; sizb0=size(bwmask0);
    % get +1pixel small mask image from bbox to avoid "1" on the edge
    bwmask0(bwmask0==qnum(qq))=1;
    seg0=rle_chh(bwmask0); %figure(1);subplot(1,2,1);imagesc(bwmask0);axis image
    % increase 1 pixel on  each side to get the index of changing encoding number of RLE
    bwmask1=zeros(size(bwmask0)+2);
    bwmask1(2:size(bwmask0,1)+1,2:size(bwmask0,2)+1)=bwmask0;
    seg1=rle_chh(bwmask1);%figure(1);subplot(1,2,2);imagesc(bwmask1);axis image
    bboxt=[bbox_core(qnum(qq),1)-1,bbox_core(qnum(qq),2)-1, bbox_core(qnum(qq),3)+2, bbox_core(qnum(qq),4)+2];% get new box corrdinate for bwmask0
    segchange=find(seg0.counts~=seg1.counts); %find the difference between two small mask
    segf.counts=seg0.counts;
    segf.counts(segchange)= seg0.counts(segchange)+bboxt(2)-1+(bsize0(1)-bboxt(2)-bboxt(4)+1); % calculate the new RLE encoding depend on image size
    segf.counts(segchange(1))= (bboxt(1))*bsize0(1)+seg0.counts(segchange(1))+bboxt(2)-1-bboxt(4); % change of 1st RLE number
    segf.counts(end)=seg0.counts(end)+(bsize0(1)-bboxt(2)-bboxt(4)+1)+(1+bsize0(2)-(bboxt(1)+ bboxt(3)-1))*bsize0(1)-bboxt(4); % change of last RLE number
    segdiff=(seg1.counts-seg0.counts)-2; % find the zero line in column matrix in RLE encoding
    idz0=find(segdiff>0);
    if length(idz0)>=3;nL=segdiff(idz0)./2;idz=idz0(2:end-1);segf.counts(idz)=seg0.counts(idz)+(nL(2:end-1)+1)*(bsize0(1)-sizb0(1));end
    segmentation_core{qnum(qq),1}=segf;segmentation_core{qnum(qq)}.size=bsize0;
end
%stats1_core=stats1_core(qnum(1:len));
segmentation_core=segmentation_core(qnum(1:len));
bbox_core=bbox_core(qnum(1:len),:);
%end

%table0= addvars(table0,FM_BREN_bbox);
table0= addvars(table0,FM_BREN_bbox1p2);
if opt.distCE==1
    table0= addvars(table0,distC_mean,distC_std,distC_median,distC_slr,distC_N,distE_mean,distE_std,distE_median,distE_slr,...
        distN_mean,distN_std,distN_median,distN_slr);
end

%table0= addvars(table0,FM_BREN_bbox2);


table1= addvars(table1,FD);   % A
table1= addvars(table1,LC);   % B
table1= addvars(table1,LCstd);% B

%         table1= addvars(table1,FD1);   % A
%         table1= addvars(table1,LC1);   % B
%         table1= addvars(table1,LCstd1);% B

%table1= addvars(table1,LC2);  % B
table1= addvars(table1,CP);   % ***
table1= addvars(table1,CC);   % ***

% rename core props
N_segmentation=segmentation_core;clear segmentation_core;table1 = addvars(table1,N_segmentation,'Before','CA');
N_bbox=bbox_core;clear bbox_core;table1 = addvars(table1,N_bbox,'Before','CA');
NA=core_CA;clear core_CA;table1= addvars(table1,NA,'Before','CA');
NCAr=core_rCA;clear core_rCA;table1= addvars(table1,NCAr,'Before','CA');
NP=core_CP;clear core_CP;table1= addvars(table1,NP,'Before','CA');
NCPr=core_rCP;clear core_rCP;table1= addvars(table1,NCPr,'Before','CA');
NC=core_CC;clear core_CC;table1= addvars(table1,NC,'Before','CA');
NC_cdist=core_Cdist;clear core_Cdist;table1= addvars(table1,NC_cdist,'Before','CA');
NC_cdist2MaxSACHr=core_rCdistM;clear core_rCdistM;table1= addvars(table1,NC_cdist2MaxSACHr,'Before','CA');
N_MeanIntensity=core_mean;clear core_mean;table1= addvars(table1,N_MeanIntensity,'Before','CA');
N_StdIntensity=core_std;clear core_std;table1= addvars(table1,N_StdIntensity,'Before','CA');

opt.N_segmentation=opt.segmentation_core;opt=rmfield(opt,'segmentation_core');
opt.N_bbox=opt.bbox_core;opt=rmfield(opt,'bbox_core');
opt.NA=opt.core_CA;opt=rmfield(opt,'core_CA');
opt.NCAr=opt.core_rCA;opt=rmfield(opt,'core_rCA');
opt.NP=opt.core_CP;opt=rmfield(opt,'core_CP');
opt.NCPr=opt.core_rCP;opt=rmfield(opt,'core_rCP');
opt.NC=opt.core_CC;opt=rmfield(opt,'core_CC');
opt.NC_cdist=opt.core_Cdist;opt=rmfield(opt,'core_Cdist');
opt.NC_cdist2MaxSACHr=opt.core_rCdistM;opt=rmfield(opt,'core_rCdistM');
opt.N_MeanIntensity=opt.core_mean;opt=rmfield(opt,'core_mean');
opt.N_StdIntensity=opt.core_std;opt=rmfield(opt,'core_std');

table1= removevars(table1,{'ConvexHull'});
if len==1
    table1CH=struct2table(statsCH(1:len),'AsArray',1);
else
    table1CH=struct2table(statsCH(1:len));
end
table1CHr=table1CH(:,{'MaxFeretAngle','MaxFeretCoordinates','MinFeretAngle','MinFeretCoordinates','Centroid'});
dd=find(strcmp(table1CHr.Properties.VariableNames,'MaxFeretAngle')==1);table1CHr.Properties.VariableNames(dd)={'CHMaxFeretAngle'};
dd=find(strcmp(table1CHr.Properties.VariableNames,'MaxFeretCoordinates')==1);table1CHr.Properties.VariableNames(dd)={'CHMaxFeretCoordinates'};
dd=find(strcmp(table1CHr.Properties.VariableNames,'MinFeretAngle')==1);table1CHr.Properties.VariableNames(dd)={'CHMinFeretAngle'};
dd=find(strcmp(table1CHr.Properties.VariableNames,'MinFeretCoordinates')==1);table1CHr.Properties.VariableNames(dd)={'CHMinFeretCoordinates'};
dd=find(strcmp(table1CHr.Properties.VariableNames,'Centroid')==1);table1CHr.Properties.VariableNames(dd)={'CHCentroid'};
table1CH= removevars(table1CH,{'MaxFeretAngle','MaxFeretCoordinates','MinFeretAngle','MinFeretCoordinates','Centroid','ConvexHull'});

dd=find(strcmp(table1CH.Properties.VariableNames,'Perimeter')==1);table1CH.Properties.VariableNames(dd)={'CHP'};

table1CH.CHP = table1CH.CHP.*(psize); % G

dd=find(strcmp(table1CH.Properties.VariableNames,'Circularity')==1);table1CH.Properties.VariableNames(dd)={'CHC'};   % K
%table1CH= removevars(table1CH,{'Circularity'});

dd=find(strcmp(table1CH.Properties.VariableNames,'MaxFeretDiameter')==1);table1CH.Properties.VariableNames(dd)={'MaxSACH'}; % M
table1CH.MaxSACH = table1CH.MaxSACH.*psize;
dd=find(strcmp(table1CH.Properties.VariableNames,'MinFeretDiameter')==1);table1CH.Properties.VariableNames(dd)={'MinSACH'}; % x
table1CH.MinSACH = table1CH.MinSACH.*psize;

CHSR=table1CH.MaxSACH./table1CH.MinSACH;table1CH= addvars(table1CH,CHSR); % I
Roughness=table1.CP./table1CH.CHP;table1CH=addvars(table1CH,Roughness);   % H

table1CH= addvars(table1CH,diameterBC); % L
table1CH= addvars(table1CH,rMmCHr);        % N
table1CH= addvars(table1CH,meanCHrd);      % O

if isfield(data1.(select_data),'coco')==1
    tableN=[table_cocoA_sort,table1,table1CH,table0];
elseif isfield(data1.(select_data),'cocoP')==1
    tname=fieldnames(opt);
    tableN=table_cocoA_sort;
    for rr=1:length(tname)
        if opt.(tname{rr})==1
            dd=find(strcmp(tableN.Properties.VariableNames,tname{rr})==1);
            if (exist (tname{rr}) == true)
                eval(['tableN.(tname{rr}) = ' tname{rr} ';']);
            end
        end
    end
else
    tableN=[table1,table1CH,table0];
end
Tname=fieldnames(tableN);
% remove nan, inf -inf
for tt=1:length(Tname)-3
    dmat=tableN{:,Tname{tt}};
    if isstruct(dmat)==0
        if iscell(dmat)==0
            idnan=find(isnan(dmat)==1);tableN.(Tname{tt})(idnan)=0;
            idinf=find(dmat==inf);tableN.(Tname{tt})(idinf)=0;
            idninf=find(dmat==-inf);tableN.(Tname{tt})(idninf)=0;
        end
    end
end
if opt.distCE==1
    table1r= addvars(table1r,dist_para);
end
tableNr=[table1r,table1CHr,table0r];



%end

