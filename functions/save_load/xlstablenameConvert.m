function [xls1,xlsinfo]=xlstablenameConvert(xlsfile,varargin)
%for newAppversion >v1p20

if istable(xlsfile)==1
    xlsNew{1}=xlsfile;
    if isempty(varargin)~=1
        xlsNew{2}=varargin{1};
        sheets{2,1}='info';
    end
    sheets{1,1}='Sheet1';
    
else
    [filepah,filename,fileext]=fileparts(xlsfile);
    sheets = sheetnames(xlsfile);
    for nn=1:length(sheets)
        xlsOld{nn}=readtable(xlsfile,'sheet',sheets{nn});
        xlsNew{nn}=xlsOld{nn};
    end
end
%xlsfile='D:\GoogleDrive_005\matlab_program\IHC_APP_v01\test_data\demo\demo_CA.xls';
%[filepah,filename,fileext]=fileparts(xlsfile);
%sheets = sheetnames(xlsfile);
t0=15;
for nn=1:length(sheets)
    if strcmpi(sheets{nn},'info')==0
        if istablefield(xlsNew{nn},'CA')==1
            xlsNew{nn} = renamevars(xlsNew{nn},'CA','CArea');
            xlsNew{nn} = renamevars(xlsNew{nn},'Extent','Ext');
            xlsNew{nn} = renamevars(xlsNew{nn},'Density','Den');
            xlsNew{nn} = renamevars(xlsNew{nn},'NA','SArea');
            xlsNew{nn} = renamevars(xlsNew{nn},'NCAr','rSACA');
            xlsNew{nn} = renamevars(xlsNew{nn},'CP','CPM');
            xlsNew{nn} = renamevars(xlsNew{nn},'NP','SPM');
            xlsNew{nn} = renamevars(xlsNew{nn},'NCPr','rSPCP');
            xlsNew{nn} = renamevars(xlsNew{nn},'MajorAxisLength','majAL');
            xlsNew{nn} = renamevars(xlsNew{nn},'MinorAxisLength','minAL');
            xlsNew{nn} = renamevars(xlsNew{nn},'diameterBC','DBC');
            xlsNew{nn} = renamevars(xlsNew{nn},'meanCHrd','mCHR');
            xlsNew{nn} = renamevars(xlsNew{nn},'rMmCHr','rCHSR');
            xlsNew{nn} = renamevars(xlsNew{nn},'Eccentricity','ECC');
            xlsNew{nn} = renamevars(xlsNew{nn},'CC','CCIR');
            xlsNew{nn} = renamevars(xlsNew{nn},'NC','SCIR');
            xlsNew{nn} = renamevars(xlsNew{nn},'FM_BREN_bbox1p2','FM');
            xlsNew{nn} = renamevars(xlsNew{nn},'NC_cdist','DSC');
            xlsNew{nn} = renamevars(xlsNew{nn},'NC_cdist2MaxSACHr','rSCMaxSACH');
            xlsNew{nn} = renamevars(xlsNew{nn},'distC_mean','mDC');
            xlsNew{nn} = renamevars(xlsNew{nn},'distC_std','mDCstd');
            xlsNew{nn} = renamevars(xlsNew{nn},'distC_median','medianDC');
            xlsNew{nn} = renamevars(xlsNew{nn},'distC_slr','rMinMaxDC');
            xlsNew{nn} = renamevars(xlsNew{nn},'distE_mean','mDP');
            xlsNew{nn} = renamevars(xlsNew{nn},'distE_std','mDPstd');
            xlsNew{nn} = renamevars(xlsNew{nn},'distE_median','medianDP');
            xlsNew{nn} = renamevars(xlsNew{nn},'distE_slr','rMinMaxDP');
            xlsNew{nn} = renamevars(xlsNew{nn},'distN_mean','mDS');
            xlsNew{nn} = renamevars(xlsNew{nn},'distN_std','mDSstd');
            xlsNew{nn} = renamevars(xlsNew{nn},'distN_median','medianDS');
            xlsNew{nn} = renamevars(xlsNew{nn},'distN_slr','rMinMaxDS');
            xlsNew{nn} = renamevars(xlsNew{nn},'distC_N','adjNum');
            xlsNew{nn} = renamevars(xlsNew{nn},'score','YOLOscore');
            xlsNew{nn} = renamevars(xlsNew{nn},'N_bbox','S_bbox');
            xlsNew{nn} = renamevars(xlsNew{nn},'N_segmentation','S_segmentation');
            xlsNew{nn} = renamevars(xlsNew{nn},'N_MeanIntensity','S_MeanIntensity');
            xlsNew{nn} = renamevars(xlsNew{nn},'N_StdIntensity','S_StdIntensity');
        end
    else
        xlsNew{nn}=xlsNew{nn};
        xlsNew{nn}{t0,1}='Parameters:';
        xlsNew{nn}{t0+1,1}='YOLOscore';
        xlsNew{nn}{t0+1,2}='score from YOLO after merged the segmentations from UNET';
        xlsNew{nn}{t0+2,1}='image_id';
        xlsNew{nn}{t0+2,2}='image id for cocoAPI';
        xlsNew{nn}{t0+3,1}='segmentation';
        xlsNew{nn}{t0+3,2}='cell segmentation for cocoAPI, RLE form in json file';
        xlsNew{nn}{t0+4,1}='bbox';
        xlsNew{nn}{t0+4,2}='bounding box of cells';
        xlsNew{nn}{t0+5,1}='area';
        xlsNew{nn}{t0+5,2}='area for cocoAPI, unit in pixels';
        xlsNew{nn}{t0+6,1}='iscrowd';
        xlsNew{nn}{t0+6,2}='iscrowd for cocoAPI';
        xlsNew{nn}{t0+7,1}='category_id';
        xlsNew{nn}{t0+7,2}='category_id for cocoAPI';
        xlsNew{nn}{t0+8,1}='id';
        xlsNew{nn}{t0+8,2}='id for cocoAPI';
        xlsNew{nn}{t0+9,1}='id_masknii';
        xlsNew{nn}{t0+9,2}='id of cells for StainAI .nii file';
        xlsNew{nn}{t0+10,1}='category_id1';
        xlsNew{nn}{t0+10,2}='category_id1: for cell type';
        xlsNew{nn}{t0+11,1}='category_id1_name';
        xlsNew{nn}{t0+11,2}='name of category_id1, ex: microglia';
        xlsNew{nn}{t0+12,1}='category_id2';
        xlsNew{nn}{t0+12,2}='category_id2: for brain atlas';
        xlsNew{nn}{t0+13,1}='category_id2_name';
        xlsNew{nn}{t0+13,2}='name of brain atlas, ex: und: undefined, CTX: cortex';
        xlsNew{nn}{t0+14,1}='S_segmentation';
        xlsNew{nn}{t0+14,2}='soma segmentation, RLE form in json file';
        xlsNew{nn}{t0+15,1}='S_bbox';
        xlsNew{nn}{t0+15,2}='soma bounding box';
        xlsNew{nn}{t0+16,1}='SArea';
        xlsNew{nn}{t0+16,2}='soma area, [um^2]';
        xlsNew{nn}{t0+17,1}='rSACA';
        xlsNew{nn}{t0+17,2}='the ratio of soma and cell area, SArea/CArea';
        xlsNew{nn}{t0+18,1}='SPM';
        xlsNew{nn}{t0+18,2}='soma perimeter, [um]';
        xlsNew{nn}{t0+19,1}='rSPCP';
        xlsNew{nn}{t0+19,2}='the ratio of soma and cell perimeter, CPM/SPM';
        xlsNew{nn}{t0+20,1}='SCIR';
        xlsNew{nn}{t0+20,2}='soma circularity, (when area too small, might > 1 due to digitization errors)';
        xlsNew{nn}{t0+21,1}='DSC';
        xlsNew{nn}{t0+21,2}='distance between some and cell center, [um]';
        xlsNew{nn}{t0+22,1}='rDSCMaxSACH';
        xlsNew{nn}{t0+22,2}='ratio of soma-cell center distance to maximum span across the convex hull, DSC/MaxSACH';
        xlsNew{nn}{t0+23,1}='S_MeanIntensity';
        xlsNew{nn}{t0+23,2}='mean intensity of soma';
        xlsNew{nn}{t0+24,1}='S_StdIntensity';
        xlsNew{nn}{t0+24,2}='intensity std of soma';
        xlsNew{nn}{t0+25,1}='CArea';
        xlsNew{nn}{t0+25,2}='cell area, [um^2]';
        xlsNew{nn}{t0+26,1}='majAL';
        xlsNew{nn}{t0+26,2}='the major axis length of the ellipse, [um]';
        xlsNew{nn}{t0+27,1}='minAL';
        xlsNew{nn}{t0+27,2}='the minor axis length of the ellipse, [um]';
        xlsNew{nn}{t0+28,1}='ECC';
        xlsNew{nn}{t0+28,2}='eccentricity';
        xlsNew{nn}{t0+29,1}='CHA';
        xlsNew{nn}{t0+29,2}='convex hull area, [um^2]';
        xlsNew{nn}{t0+30,1}='Den';
        xlsNew{nn}{t0+30,2}='density, CArea/CHA';
        xlsNew{nn}{t0+31,1}='Ext';
        xlsNew{nn}{t0+31,2}='extent , bbox Area [um^2]';
        xlsNew{nn}{t0+32,1}='FD';
        xlsNew{nn}{t0+32,2}='fractal dimension';
        xlsNew{nn}{t0+33,1}='LC';
        xlsNew{nn}{t0+33,2}='lacunarity';
        xlsNew{nn}{t0+34,1}='LCstd';
        xlsNew{nn}{t0+34,2}='the standard deviation of lacunarity';
        xlsNew{nn}{t0+35,1}='CPM';
        xlsNew{nn}{t0+35,2}='cell perimeter';
        xlsNew{nn}{t0+36,1}='CCIR';
        xlsNew{nn}{t0+36,2}='cell circularity, (when area too small, might > 1 due to digitization errors)';    
        xlsNew{nn}{t0+37,1}='CHC';
        xlsNew{nn}{t0+37,2}='convex hull circularity, (when area too small, might > 1 due to digitization errors)';
        xlsNew{nn}{t0+38,1}='CHP';
        xlsNew{nn}{t0+38,2}='convex hull perimeter, [um]';
        xlsNew{nn}{t0+39,1}='MaxSACH';
        xlsNew{nn}{t0+39,2}='maximum span across the convex hull, [um]';
        xlsNew{nn}{t0+40,1}='MinSACH';
        xlsNew{nn}{t0+40,2}='minimum span across the convex hull, [um]';
        xlsNew{nn}{t0+41,1}='CHSR';
        xlsNew{nn}{t0+41,2}='convex hull span ratio';
        xlsNew{nn}{t0+42,1}='Roughness';
        xlsNew{nn}{t0+42,2}='ratio of cell perimeter to convex hull perimeter, (CPM/CHP)';
        xlsNew{nn}{t0+43,1}='DBC';
        xlsNew{nn}{t0+43,2}='the diameter of the bounding circle, [um]';
        xlsNew{nn}{t0+44,1}='rCHSR';
        xlsNew{nn}{t0+44,2}='the ratio maximum/minimum convex hull radii';
        xlsNew{nn}{t0+45,1}='mCHR';
        xlsNew{nn}{t0+45,2}='the mean convex hull radius, [um]';
        xlsNew{nn}{t0+46,1}='MeanIntensity';
        xlsNew{nn}{t0+46,2}='mean intensity of cell';
        xlsNew{nn}{t0+47,1}='MinIntensity';
        xlsNew{nn}{t0+47,2}='minimum intensity of cell';
        xlsNew{nn}{t0+48,1}='MaxIntensity';
        xlsNew{nn}{t0+48,2}='maximum intensity of cell';
        xlsNew{nn}{t0+49,1}='StdIntensity';
        xlsNew{nn}{t0+49,2}='the standard deviation of cell intensity';
        xlsNew{nn}{t0+50,1}='MedianIntensity';
        xlsNew{nn}{t0+50,2}='the median of cell intensity';
        xlsNew{nn}{t0+51,1}='FM';
        xlsNew{nn}{t0+51,2}='Brenner focus measurement';
        xlsNew{nn}{t0+52,1}='mDC';
        xlsNew{nn}{t0+52,2}='mean distance between cell mass center, [um]';
        xlsNew{nn}{t0+53,1}='mDCstd';
        xlsNew{nn}{t0+53,2}='the standard deviation of distance between cell mass center';
        xlsNew{nn}{t0+54,1}='medianDC';
        xlsNew{nn}{t0+54,2}='median of distance between cell mass center';
        xlsNew{nn}{t0+55,1}='rMinMaxDC';
        xlsNew{nn}{t0+55,2}='ratio of maximum/minimum distance between cell mass center';
        xlsNew{nn}{t0+56,1}='adjNum';
        xlsNew{nn}{t0+56,2}='adjacent cell number';
        xlsNew{nn}{t0+57,1}='mDP';
        xlsNew{nn}{t0+57,2}='mean distance between processes, [um]';
        xlsNew{nn}{t0+58,1}='mDPstd';
        xlsNew{nn}{t0+58,2}='the standard deviation of distance between processes';
        xlsNew{nn}{t0+59,1}='medianDP';
        xlsNew{nn}{t0+59,2}='median of distance between cell processes';
        xlsNew{nn}{t0+60,1}='rMinMaxDP';
        xlsNew{nn}{t0+60,2}='ratio of maximum/minimum distance between processes';
        xlsNew{nn}{t0+61,1}='mDS';
        xlsNew{nn}{t0+61,2}='mean distance between somas, [um]';
        xlsNew{nn}{t0+62,1}='mDSstd';
        xlsNew{nn}{t0+62,2}='the standard deviation of distance between somas';
        xlsNew{nn}{t0+63,1}='medianDS';
        xlsNew{nn}{t0+63,2}='median of distance between somas';
        xlsNew{nn}{t0+64,1}='rMinMaxDS';
        xlsNew{nn}{t0+64,2}='ratio of maximum/minimum distance somas';
        xlsNew{nn}{t0+65,1}='C50';
        xlsNew{nn}{t0+65,2}='cell classification by C50';
    end
end
xls1=xlsNew{1};

if isempty(varargin)~=1
    xlsinfo=xlsNew{2};
    if istable(xlsfile)~=1
        for nn=1:length(sheets)
            if strcmpi(sheets{nn},'info')==0
                writetable(xlsNew{nn},xlsfile);
            else
                writetable(xlsNew{nn},xlsfile,'WriteMode','overwritesheet','Sheet','info');
            end
        end
    end
end
