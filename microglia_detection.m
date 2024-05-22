function [data1,varargout]=microglia_detection(DataSetInfo,env,setp,opts,varargin)

% create category for cocoAPI
varargout{1}='';
if isempty(varargin)==1
    flag.load_data=1;
    data1='';%table1='';
else
    if iscell(varargin{1})~=1
        data1{1}='';
    else
        data1=varargin{1};
    end
    flag.load_data=0;
end

if isfield(opts,'operate_mode');flag.operate_mode=opts.operate_mode;else;flag.operate_mode='processing';end                                               % =1, to keep origimage

setp.size_box2=[256 256]; % training image size for one cell
setp.train_imsize={[512 512]};setp.ts=1;  % training image size for yolo or maskrcnn, set ts=1 to select ist cell
setp.edgelinewidth = 8;setp.edgelinewidth_sh2 = 12; % parameter to merge yolo
setp.type_name_C50={'R';'H';'B';'A';'RD';'HR';};

category_celltype={'microglia';'R';'RD';'H';'HR';'A';'B';};
DataSetInfo.coco_category=coco_category_v02('microglia',{'brain','background'},category_celltype);

env.filepath01=env.data_path0;
env.C50_Rscript_train_filename=[env.matlab_path 'R' filesep 'C50' filesep 'R_trainC50_v01.R'];
env.C50_Rscript_predict_filename=[env.matlab_path filesep 'R' filesep 'C50' filesep 'R_predicC50_v01.R'];
env.C50_Model_filename=[env.matlab_path filesep 'R' filesep 'C50' filesep 'C50_v01.RData'];
env.C50_Json_train_filename{1,1}='';
env.C50_Json_train_filename{2,1}='';
env.C50_Json_train_temp=[env.matlab_path filesep 'R' filesep 'temp' filesep 'C50_train_temp.json'];
if ~exist([env.matlab_path filesep 'R' filesep 'temp' filesep],'dir')
    mkdir([env.matlab_path filesep 'R' filesep 'temp' filesep]);
end



dinfo=data_info_v36__allusers(env.data_path0, DataSetInfo);
% end

% set atlas version if exist brain atlas
if isfield(DataSetInfo,'atlas_ver')~=1
    if isfield(opts,'atlas_ver')==1
        DataSetInfo.atlas_ver=opts.atlas_ver; %set atlas version by opts.atlas_ver
    else
        DataSetInfo.atlas_ver='v12';
        atlas_name0={'background'   ,'background','background'       ,0;              % 0
                     'brain'        ,'brain'     ,'brain'                   ,255;};       % > 255

        try
            DataSetInfo.atlas_rename=cell2table(atlas_name0,'VariableNames',{'atlas_name', 'atlas_name_N','atlas_namefull','id'});
        catch
            DataSetInfo.atlas_rename=cell2table(atlas_name0,'VariableNames',{'atlas_name', 'atlas_name_N','atlas_namefull'});
        end
    end
end

% initial opts
ts=setp.ts;
flag.DataSetInfo=DataSetInfo;
% Section-1 load image & clear background
if isfield(opts,'Low_res');flag.Low_res=opts.Low_res;else;flag.Low_res=-1;end
if isfield(opts,'tif_select');flag.tif_select=opts.tif_select;else;flag.tif_select=0;end
if isfield(opts,'imadj_function');flag.imadj_function=opts.imadj_function;else;flag.imadj_function='none';end              % ='none'
if isfield(opts,'im_reverse');flag.im_reverse=opts.im_reverse;else;flag.im_reverse=DataSetInfo.im_reverse;end              % =1 to reverse image intensity, black->white
if isfield(opts,'imzp');flag.imzp=opts.imzp;else;flag.imzp=1;end   % zerropadding                                                           % zeropadding
if flag.Low_res~=-1;flag.imzp=0;end                                % when load low resolution data, set zerropadding zero;
if isfield(opts,'keep_imorig');flag.keep_imorig=opts.keep_imorig;else;flag.keep_imorig=0;end                                               % =1, to keep origimage
if isfield(opts,'save_imsplit');flag.save_imsplit=opts.save_imsplit;else;flag.save_imsplit=0;end                                               % =1, to keep origimage


% Section-1.2 create or load rule base ground truth
mpara_getbox=parameters_Get_cell_box_optical_v14(dinfo);    %create parameters to get box location by thresholds
mpara_getmask=parameters_Get_cell_mask_optical_v14(dinfo);  %create paramaters to get mask by rule base thresholds
if isfield(opts,'load_URBG');flag.load_URBG=opts.load_URBG;else;flag.load_URBG=0;end %=1 to load unclearned groundtruth if exist
if isfield(opts,'load_clean_rule_base_groundtruth');flag.load_clean_rule_base_groundtruth=opts.load_clean_rule_base_groundtruth;else;flag.load_clean_rule_base_groundtruth=0;end %=1 to load manual clean groundtruth if exist
if isfield(opts,'get_rule_base');flag.get_rule_base=opts.get_rule_base;else;flag.get_rule_base=0;end %=1 force to get rule base ground truth
if isfield(opts,'get_box');flag.get_box=opts.get_box;else;flag.get_box=0;end      %=1 to get cell box by threshold in "mpara_getbox" or load cell boxfile *(1-2)
if isfield(opts,'get_mask');flag.get_mask=opts.get_mask;else;flag.get_mask=0;end  %=1 to get cell mask by "mpara_getmask" or load cell maskfile *(1-3)
if isfield(opts,'plot_rbdc');flag.plot_rbdc=opts.plot_rbdc;else;flag.plot_rbdc=0;end %=1 to save figures during processing
if isfield(opts,'data_clean');flag.data_clean=opts.data_clean;else;flag.data_clean=0;end %=1 for data cleaning from rule base mask; =2 clean 2nd time, 0 load clean mask if exist
if isfield(opts,'sort_cell');flag.sort_cell=opts.sort_cell;else;flag.sort_cell=2;end %=1 to sort or load clean rule base mask ; =2 sort or load 2nd clean data "cellatlas_f02.mat"

% Section-1.2.4 image zero padding & change resolution
% if isfield(opts,'imzp');flag.imzp=opts.imzp;else;flag.imzp=0;end   % in Section-1.1
% if isfield(opts,'Low_res');flag.Low_res=opts.Low_res;else;flag.Low_res=-1;end  % in Section-1.1


% Section-1.3 Load brain atlas
if isfield(opts,'load_brainAtlas');flag.load_brainAtlas=opts.load_brainAtlas;else;flag.load_brainAtlas=2;end

if isfield(opts,'update_atlasname');flag.update_atlasname=opts.update_atlasname;else;flag.update_atlasname=0;end
if isfield(opts,'update_atlas');flag.update_atlas=opts.update_atlas;else;flag.update_atlas=0;end
%if flag.update_atlas==1;flag.load_brainAtlas=1;end;%if flag.update_atlasname==1;flag.load_brainAtlas=1;end

%if flag.load_brainAtlas==0;flag.load_brainAtlas=0;end
if isfield(opts,'atlas_ver');flag.atlas_ver=opts.atlas_ver;else;flag.atlas_ver='v11';end
if isfield(opts,'atlas_ver_old');flag.atlas_ver_old=opts.atlas_ver_old;else;flag.atlas_ver_old='v10';end
if isfield(opts,'atlas_update_from_old_ver');flag.atlas_update_from_old_ver=opts.atlas_update_from_old_ver;else;flag.atlas_update_from_old_ver=0;end
if isfield(opts,'atlas_dec_ver');flag.atlas_dec_ver=opts.atlas_dec_ver;else;flag.atlas_dec_ver='v3dec';end
if isfield(opts,'old_atlas_remove');flag.old_atlas_remove=opts.old_atlas_remove;else;flag.old_atlas_remove={''};end


% Section-2. Load prediction/manual segmentation masks
if isfield(opts,'load_yolo');flag.load_yolo=opts.load_yolo;else;flag.load_yolo=0;end;idd.load_yolo=1;
if isfield(opts,'update_yoloscore');flag.update_yoloscore=opts.update_yoloscore;else;flag.update_yoloscore=0;end;

if isfield(opts,'load_UnetOneCell');flag.load_UnetOneCell=opts.load_UnetOneCell;else;flag.load_UnetOneCell=0;end;idd.load_UnetOneCell=1;%if flag.load_UnetOneCell==1;flag.load_yolo=0;end
if isfield(opts,'load_manual_imageJroi');flag.load_manual_imageJroi=opts.load_manual_imageJroi;else;flag.load_manual_imageJroi=0;end;idd.load_ch=[1 2];
if isfield(opts,'imageJ_manual_label');flag.imageJ_manual_label=opts.imageJ_manual_label;else;flag.imageJ_manual_label=0;end;
%if isfield(opts,'load_UnetAllCell');flag.load_Unet4AllCell=opts.load_UnetAllCell;else;flag.load_UnetAllCell=0;end;idd.load_UnetAllCell=0;
if isfield(opts,'load_MaskRCNN');flag.load_MaskRCNN=opts.load_MaskRCNN;else;flag.load_MaskRCNN=0;end;idd.load_MaskRCNN=1;
if isfield(opts,'load_yolact');flag.load_yolact=opts.load_yolact;else;flag.load_yolact=0;end;idd.load_yolact=1;
if isfield(opts,'load_MaskRCNN_train');flag.load_MaskRCNN_train=opts.load_MaskRCNN_train;else;flag.load_MaskRCNN_train=0;end;idd.load_MaskRCNN_train=1;


% Section-3. calculate mask regionprops
if isfield(opts,'regp_ver');flag.regp_ver=opts.regp_ver;else;flag.regp_ver='regp11';end;%flag.regp_ver='regp09';
if isfield(opts,'regp_verN');flag.regp_verN=opts.regp_verN;else;flag.regp_verN='regp11';end;
if isfield(opts,'cal_cell_props');flag.cal_cell_props=opts.cal_cell_props;else;flag.cal_cell_props=0;end;
if isfield(opts,'cal_cell_prop_rn');flag.cal_cell_prop_rn=opts.cal_cell_prop_rn;else;flag.cal_cell_prop_rn=0;end;
if isfield(opts,'rn_prop');flag.rn_prop=opts.rn_prop;else;flag.rn_prop={''};end % region property for recalculate in cell_regionprops_08r.m
if isfield(opts,'rcal_all');flag.rcal_all=opts.rcal_all;else;flag.rcal_all=0;end;%=1, re-calculate for all mask;
% =0, skip the calculated mask saved in [filepath_mat_temp select_data '__' flag.regp_ver '_temp.mat']
if isfield(opts,'save_coco_selected_prop');flag.save_coco_selected_prop=opts.save_coco_selected_prop;else;flag.save_coco_selected_prop=0;end;
if isfield(opts,'propname_select_C50');flag.propname_select_C50=opts.propname_select_C50;else;
    flag.propname_select_C50={'NA','NCAr','NP','NCPr','CA','MajorAxisLength','MinorAxisLength','Eccentricity','CHA','Density','Extent','FD','LC','LCstd','CP','CC','CHC','CHP','MaxSACH','MinSACH','CHSR','Roughness','diameterBC','rMmCHr','meanCHrd'};
end;


% Section-4. save small images for yolo, Unet, MaskRCNN training
if isfield(opts,'save_train_path_case');flag.save_train_path_case=opts.save_train_path_case;else;flag.save_train_path_case=2;end;
if isfield(opts,'save_maskrcnn');flag.save_maskrcnn=opts.save_maskrcnn;else;flag.save_maskrcnn=0;end;idd.save_maskrcnn=ts;
if isfield(opts,'save_imageJroi');flag.save_imageJroi=opts.save_imageJroi;else;flag.save_imageJroi=0;end;idd.save_imageJroi=1;
if isfield(opts,'save_imageLabel');flag.save_imageLabel=opts.save_imageLabel;else;flag.save_imageLabel='none';end;
if isfield(opts,'save_imageJroi256s');flag.save_imageJroi256s=opts.save_imageJroi256s;else;flag.save_imageJroi256s=0;end;
if isfield(opts,'save_test_maskrcnn');flag.save_test_maskrcnn=opts.save_test_maskrcnn;else;flag.save_test_maskrcnn=0;end;idd.save_test_maskrcnn=ts;
if isfield(opts,'save_unet');flag.save_unet=opts.save_unet;else;flag.save_unet=0;end;idd.save_unet=1;
if isfield(opts,'save_matlabss');flag.save_matlabss=opts.save_matlabss;else;flag.save_matlabss=0;end;idd.save_matlabss=1;
if isfield(opts,'save_test_yolo2unet');flag.save_test_yolo2unet=opts.save_test_yolo2unet;else;flag.save_test_yolo2unet=0;end;idd.save_test_yolo2unet=1;
if isfield(opts,'save_imJ2maskrcnn');flag.save_imJ2maskrcnn=opts.save_imJ2maskrcnn;else;flag.save_imJ2maskrcnn=0;end;idd.save_imJ2maskrcnn=1;
if isfield(opts,'save_atlasallcell_nii');flag.save_atlasallcell_nii=opts.save_atlasallcell_nii;else;flag.save_atlasallcell_nii=0;end;
if isfield(opts,'save_xls_table');flag.save_xls_table=opts.save_xls_table;else;flag.save_xls_table=1;end;


% Section-5 yolo detection (not finish)
if isfield(opts,'yolo_ver');flag.yolo_ver=opts.yolo_ver;else;flag.yolo_ver='v5';end;
if isfield(opts,'yolo_train');flag.yolo_train=opts.yolo_train;else;flag.yolo_train=0;end;% not finish
if isfield(opts,'yolo_detection');flag.yolo_detection=opts.yolo_detection;else;flag.yolo_detection=0;end;
if isfield(opts,'yolo_folder_result');flag.yolo_folder_result=opts.yolo_folder_result;end;
if isfield(opts,'yolo_folder_test');flag.yolo_folder_test=opts.yolo_folder_test;end;
if isfield(opts,'yolo_folder_train');flag.yolo_folder_train=opts.yolo_folder_train;end; % (not finish)
if isfield(opts,'yolo_pt');flag.yolo_pt=opts.yolo_pt;end;  % (not finish)
if isfield(opts,'yolo_IoU');flag.yolo_IoU=opts.yolo_IoU;else;flag.yolo_IoU=0.5;end;


% Section-6 segmentation (not finish)
if isfield(opts,'unet_train');flag.unet_train=opts.unet_train;else;flag.unet_train=0;end;
if isfield(opts,'unet_detection');flag.unet_detection=opts.unet_detection;else;flag.unet_detection=0;end;
if isfield(opts,'unet_file');flag.unet_file=opts.unet_file;else;flag.unet_file='';end;
if isfield(opts,'unet_num');flag.unet_num=opts.unet_num;else;flag.unet_num=1;end;
if isfield(opts,'unet_results_folderE');flag.unet_results_folderE=opts.unet_results_folderE;else;flag.unet_results_folderE='';end;
if isfield(opts,'unet_name');flag.unet_name=opts.unet_name;else;flag.unet_name='netC4';end;

% Section-7 classification <= need assigned the json file for input and output in code
if isfield(opts,'C50_train');flag.C50_train=opts.C50_train;else;flag.C50_train=0;end;
if isfield(opts,'C50_prediction');flag.C50_prediction=opts.C50_prediction;else;flag.C50_prediction=0;end;
%if isfield(opts,'load_cocofileforC50');flag.load_cocofileforC50=opts.load_cocofileforC50;else;flag.load_cocofileforC50={'Yolo512_Unet_256x256__result__UNET_ML'};end;
%if isfield(opts,'load_cocoC50');flag.load_cocoC50=opts.load_cocoC50;else;flag.load_cocoC50={''};end; % C50version
%if isfield(opts,'regp_verC50');flag.regp_verC50=opts.regp_verC50;else;flag.regp_verC50={'regp11s'};end;
if isfield(opts,'reduce_table');flag.reduce_table=opts.reduce_table;else;flag.reduce_table=0;end;


% Section-A1 save/load coco file
if isfield(opts,'result_ver');flag.result_ver=opts.result_ver;else;flag.result_ver='V04';end;
if isfield(opts,'save_coco');flag.save_coco=opts.save_coco;else;flag.save_coco=1;end;
if isfield(opts,'coco_add_info');flag.coco_add_info=opts.coco_add_info;else;flag.coco_add_info=0;end; % add brain area information to cocofile
if isfield(opts,'category_update');flag.category_update=opts.category_update;else;flag.category_update=0;end; % update coco category when atlas updata

if isfield(opts,'load_cocofileforC50');flag.load_cocofileforC50=opts.load_cocofileforC50;else;flag.load_cocofileforC50={'Yolo512_Unet_256x256__result__UNET_ML'};end;
if isfield(opts,'load_cocoC50');flag.load_cocoC50=opts.load_cocoC50;else;flag.load_cocoC50={''};end; % C50version
if isfield(opts,'regp_verC50');flag.regp_verC50=opts.regp_verC50;else;flag.regp_verC50={'regp11s'};end;
if isfield(opts,'optable');flag.optable=opts.optable;else;flag.optable={'Yolo512_Unet_256x256__result__UNET_ML'};end;

%old version: if isfield(opts,'save_train2coco');flag.save_train2coco=opts.save_train2coco;else;flag.save_train2coco=0;end;

% Section-A2 calculate precession by cocoapi (not finish)
if isfield(opts,'cal_precession');flag.cal_precession=opts.cal_precession;else;flag.cal_precession=0;end;

% For display image
if isfield(opts,'dispfig1');flag.dispfig1=opts.dispfig1;else;flag.dispfig1=0;end;
if isfield(opts,'th_FM');flag.th_FM=opts.th_FM;else;flag.th_FM=600;end;
if isfield(opts,'Load_decArea');flag.Load_decArea=opts.Load_decArea;else;flag.Load_decArea=0;end;

% Section-B1 save result and output for exchange data between different pc and website
if isfield(opts,'update_results');flag.update_results=opts.update_results;else;flag.update_results=0;end;
if isfield(opts,'folder_result01');flag.folder_result01=opts.folder_result01;else;flag.folder_result01='';end;

% Section-B2 copy cocoJson, mat_temp, atlas for exchange data between different pc
if isfield(opts,'data2exchange');flag.data2exchange=opts.data2exchange;else;flag.data2exchange=0;end;
if isfield(opts,'ex_folder_result02');flag.ex_folder_result02=opts.ex_folder_result02;else;flag.data2exchange='I:\DLresults__v04regp11\';end;

% Section-B3 for webserver
if isfield(opts,'data2webserver');flag.data2webserver=opts.data2webserver;else;flag.data2webserver=0;end;
if isfield(opts,'web_folder_result01');flag.web_folder_result01=opts.web_folder_result01;else;flag.web_folder_result01='I:\DLweb_v2\';end;

% Section-B4 copy selected cocofile to the output dir into zip file (not finished)
if isfield(opts,'data2zip');flag.data2zip=opts.data2zip;else;flag.data2zip=0;end;

% others
if isfield(opts,'mem_save');flag.mem_save=opts.mem_save;else;flag.mem_save=0;end
if isfield(opts,'edgelinewidth_sh2');flag.edgelinewidth_sh2=opts.edgelinewidth_sh2;else;flag.edgelinewidth_sh2=12;end
if isfield(opts,'edgelinewidth');flag.edgelinewidth=opts.edgelinewidth;else;flag.edgelinewidth=8;end
%if isfield(opts,'load_ULine');flag.load_ULine=opts.load_ULine;else;flag.load_ULine=0;end

if isfield(env,'data_path0temp');
    flag.data_path0temp=env.data_path0temp;
    flag.data_path0=env.data_path0;
else
    flag.data_path0temp=env.data_path0;
    flag.data_path0=env.data_path0;
end


flag.size_zpe=setp.size_zpe;

atlas_rename=DataSetInfo.atlas_rename;
coco_category=DataSetInfo.coco_category;
nn=0;

if isempty(DataSetInfo.sampleIdselect)~=1;snum=length(DataSetInfo.sampleIdselect);else;snum=length(DataSetInfo.sample_ID);end

for si=1:snum % loop for sample
    clear keywords;
    if isempty(opts.keywords{1})~=1
        keywords=opts.keywords;
        if isempty(DataSetInfo.sampleIdselect)~=1
            keywords{end+1}=DataSetInfo.sampleIdselect{si};
        else
            keywords{end+1}=DataSetInfo.sample_ID{si};
        end
    else
        keywords=opts.keywords;%DataSetInfo.sample_ID{si};
    end
    [fnum1{si}, fname1{si}]=getkeyword_02(dinfo,keywords,opts.Nkeywords);
    %  [fnum1{si} fname1{si}]=getkeyword(dinfo,{'N38 slide 11'},{''});
    if isempty(fname1{si}{1})~=1
        for ff0=1:length(fnum1{si}) % loop for slides,  cell_dist si=1, run ff0=5:7 undo ff0=8:16; si=2, ff0=2
            nn=nn+1;
            ff=fnum1{si}(ff0);ff0;
            dinfo1{nn,1}=dinfo{ff,1};

            %fname1{si}{ff0}
            if flag.mem_save==1;clear data1;end
            % turn off flag for loading ground truths
            flag.load_URBG=0;flag.load_clean_rule_base_groundtruth=0;
            
            % create path information for result output
            dinfo1{nn,1}.filepath_coco=[dinfo1{nn,1}.filepath_image dinfo1{nn,1}.foldername_coco{1}];
            if exist([dinfo1{nn,1}.filepath_image dinfo1{nn,1}.filename_image],'file')
                if ~exist(dinfo1{nn,1}.filepath_coco,'dir');mkdir(dinfo1{nn,1}.filepath_coco);end
            end
            dinfo1{nn,1}.result_ver=flag.result_ver;
            dinfo1{nn,1}.regp_ver=flag.regp_ver;dinfo1{nn,1}.regp_verN=flag.regp_verN;dinfo1{nn,1}.atlas_rename=atlas_rename;
            %if flag.load_data==1;
            if exist([dinfo1{nn,1}.filepath_image dinfo1{nn,1}.filename_image],'file')
                filepath_mat_temp=[dinfo1{nn,1}.filepath_image 'mat_temp' filesep];if ~exist(filepath_mat_temp,'dir');mkdir(filepath_mat_temp);end
                dinfo1{nn,1}.filepath_mat_temp=filepath_mat_temp;
            end

            data1{nn,1}.info=dinfo1{nn,1};data1{nn,1}.categories=coco_category;%end
            data1{nn,1}.info.atlas_ver=flag.atlas_ver;
            data1{nn,1}.info.atlas_dec_ver=flag.atlas_dec_ver;
            %result_folder_mask=[data1{nn,1}.info.filepath_image 'results' filesep 'masks' filesep];if ~exist(result_folder_mask,'dir');mkdir(result_folder_mask);end


            %% Section-1 load image and get rule base groundtruthdata1{nn,1}=load_cell_box_and_mpara_getboxmask_v03(data1{nn,1},flag,flag.dispfig1,env.filepath_old0,mpara_getbox{nn,1},mpara_getmask{nn,1},setp.size_box2);
            for section1=1 %
                % Section-1.1 load image & clear background
                data1{nn,2}=dinfo1{nn,1}.filename_image;
                if isfield(dinfo1{nn,1},'filename_orig')
                    data1{nn,3}=dinfo1{nn,1}.filename_orig;
                    imsavefilename=data1{nn,1}.info.filename_orig;
                else
                    imsavefilename=data1{nn,1}.info.filename_image;
                end

                if flag.load_data==1
                    %data1{nn,1}.info

                    [data1{nn,1}, flag]=loadimage_and_getBackground_v07(data1{nn,1},flag,setp,0);
                    % background still in original resoultion when load,
                    % chang it in "load_Atlas_v04"
                    %                                          figure(1);imshow(data1{1}.im0gray)
                    %                                          figure(2);imshow(data1{1}.im0)
                    %                                          figure(3);imshow(data1{1}.imbackground)
                    %if flag.Low_res==-1;if isfield(opts,'imzp');flag.imzp=opts.imzp;else;flag.imzp=0;end;end
                    %% Section-1.2 create or load rule base ground truth
                    if flag.load_URBG==1;flag.load_clean_rule_base_groundtruth=1;end %will load and create rule base ground truth
                    if flag.load_clean_rule_base_groundtruth~=0 || flag.get_rule_base~=0
                        data1{nn,1}=load_cell_box_and_mask_v03(data1{nn,1 },flag,flag.dispfig1,env.filepath_old0,mpara_getbox{nn,1},mpara_getmask{nn,1},setp.size_box2);
                    end
                    %% Section-1.3 image zero padding & change resolution for groundtruth
                    if flag.imzp==1 && flag.Low_res==-1
                        data1{nn,1}=im_zeropadding_v02(data1{nn,1},flag,setp.size_zpe);
                    end
                    % if ff0==4
                    %     ff0
                    % end
                    imsize0=size(data1{nn,1}.im0gray);
                    %% Section-1.4 Load brain atlas
                    %                   if flag.load_brainAtlas~=0
                    switch flag.atlas_ver
                        case {'v3','v4'}
                            data1{nn,1}=load_Atlas_v03(data1{nn,1},DataSetInfo,flag,setp.size_zpe,flag.dispfig1,env.filepath_old0);
                        otherwise  % > v5
                            data1{nn,1}=load_Atlas_v04(data1{nn,1},DataSetInfo,flag,setp.size_zpe,flag.dispfig1);
                    end
             
                   % figure(2);imagesc(data1{nn,1}.atlas_brain);axis image
                    %                     else
                    %                         data1{nn,1}.info.load_atlas_nii=0;
                    %                     end
                    %figure(111);imagesc( data1{nn,1}.atlas_brain_dec)

                    if flag.save_coco==1 % Section-A1
                        filename_coco=[data1{nn,1}.info.filename_image(1:end-4) '__masks_CRBG__' flag.result_ver '.json'];
                        select_data=['masks_CRBG'];%fprintf(['load ' select_data '\n']);
                        if isfield(data1{nn,1},select_data)==1
                            if ~exist([dinfo1{nn,1}.filepath_coco filesep filename_coco],'file')
                                data_source='masks_CRBG';cat_name_select='name';annotation_id_select='category_id1';
                                %data1{nn,1}.(select_data).coco=mask2cocoStructure_04(data1{nn,1},select_data,data_source,cat_name_select,annotation_id_select);
                                copt1.get_score=0;copt1.segmentation=1;copt1.case_coco='LargeIm';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                                data1{nn,1}.(select_data).coco=mask2cocoStructure_11(data1{nn,1},select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);
                                cocostring=gason(data1{nn,1}.(select_data).coco);fid = fopen([dinfo1{nn,1}.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                            else
                                try
                                    coco_temp=CocoApi([dinfo1{nn,1}.filepath_coco filesep filename_coco]);
                                catch
                                    data_source='masks_CRBG';cat_name_select='name';annotation_id_select='category_id1';
                                    %data1{nn,1}.(select_data).coco=mask2cocoStructure_04(data1{nn,1},select_data,data_source,cat_name_select,annotation_id_select);
                                    copt1.get_score=0;copt1.segmentation=1;copt1.case_coco='LargeIm';copt1.imfile_check=1;copt1.Low_res=flag.Low_res;
                                    data1{nn,1}.(select_data).coco=mask2cocoStructure_11(data1{nn,1},select_data,data_source,cat_name_select,annotation_id_select,filename_coco,copt1);
                                    cocostring=gason(data1{nn,1}.(select_data).coco);fid = fopen([dinfo1{nn,1}.filepath_coco filesep filename_coco], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                                    coco_temp=CocoApi([dinfo1{nn,1}.filepath_coco filesep filename_coco]);
                                end
                                cocostruct=cocoFilePathChange(coco_temp.data, [env.filepath01 data1{nn,1}.info.filename_image(1:3) filesep], data1{nn,1}.info.filename_image(1:end-4));
                                if flag.category_update>0;options.Low_res=flag.Low_res;options.case='atlas';
                                    cocostruct=coco_category_update_v02(cocostruct,data1{nn,1},options);end
                                data1{nn,1}.(select_data).coco=cocostruct;clear coco_temp
                            end
                            if flag.coco_add_info==1 % add brain area information to cocofile
                                coco_temp=data1{nn,1}.(select_data).coco;filepath_coco=data1{nn,1}.info.filepath_coco;
                                addinfo.brain_area=sum(data1{nn,1}.imbackground(:))*(data1{nn,1}.info.pixel_size).^2;
                                addinfo.resolution=data1{nn,1}.info.pixel_size;addinfo.dinfo1=data1{nn,1}.info;addinfo.select_data=select_data;
                                data1{nn,1}.(select_data).coco=coco_modified_v02(coco_temp,addinfo,filepath_coco,filename_coco);
                            end
                        end
                    end
                end
            end
            %% Section-2 load mask from other source

            foldername=foldernameFromTag(data1{nn,1},setp,idd);

            for section2=1
                flag.load_manual_imageJroi=0; % turn off load manu ROI
                if flag.load_manual_imageJroi==1
                    if isfield(data1{nn,1},[foldername.train_manual{1,1}{1} '_M'])==0
                        [data1{nn,1}]=load_human_label_v03(data1{nn,1},env,flag,idd,setp.train_imsize,flag.result_ver);
                    end
                end;clear atlas_cellmask_ch bw_ch_3d cocoGt
                % % if flag.imageJ_manual_label==1
                % %     filepath_imageJ_label=[data1{nn,1}.info.filepath_image 'manual_imageJ_label' filesep 'bFM_20230922'];
                % %     if ~exist([filepath_imageJ_label '.mat'],'file')
                % %         mpara_imJ.imageJ.path_jar{1,1}=[env.path_imageJ 'mij.jar'];
                % %         mpara_imJ.imageJ.path_jar{2,1}=[env.path_imageJ 'ij-1.53c.jar'];
                % %         mpara_imJ.imageJ.path_macro=[env.path_imageJ 'macros\'];
                % %         mpara_imJ.imageJ.path_scripts=[env.path_imageJ 'scripts'];
                % %         mpara_imJ.case_filename='case1';  % need change according to the data
                % %         mpara_imJ.filename0=regexprep(data1{nn,1}.info.filename_image(1:end-4),' ','_');
                % %         mpara_imJ.imsize=[prod(ceil(size(data1{nn,1}.im0gray)./setp.train_imsize{ts})) setp.train_imsize{ts}];
                % % 
                % %         [bw_ch_3d, ROIname]=loadimageJROI(filepath_imageJ_label,data1{nn,1}.info,mpara_imJ);
                % % 
                % %         drc=ceil(size(data1{nn,1}.im0gray)./setp.train_imsize{ts});
                % %         atlas_cellmask_ch0=dmib2(bw_ch_3d,drc(1),drc(2));
                % %         atlas_cellmask_ch(1:size(data1{nn,1}.im0gray,1),1:size(data1{nn,1}.im0gray,2))=atlas_cellmask_ch0(1:size(data1{nn,1}.im0gray,1),1:size(data1{nn,1}.im0gray,2));clear atlas_cellmask_ch0
                % %         cmap=parula(max(atlas_cellmask_ch(:)));
                % % 
                % %         imF1 = labeloverlay(data1{nn,1}.im0gray,atlas_cellmask_ch,'Colormap',cmap,'Transparency',0.7);
                % %         figure(121);imshow(imF1);set(gcf,'color','w');
                % %         save([filepath_imageJ_label '.mat'],'atlas_cellmask_ch','bw_ch_3d','ROIname');
                % %     else
                % %         load([filepath_imageJ_label '.mat']);
                % %     end
                % %     name_ROI_temp=vertcat(ROIname{:});
                % %     name_ROI_tem2=cellfun(@regexprep,name_ROI_temp(:,1),repmat({' '},[length(name_ROI_temp),1]),repmat({''},[length(name_ROI_temp),1]),'uni',false);
                % %     sn1 = strfind(name_ROI_tem2(:,1),'_');sn2 = strfind(name_ROI_tem2(:,1),'.roi');
                % %     name_ROI_temp3=cellfun(@(c,n,m)c(n(end)+1:m-1),name_ROI_tem2(:,1),sn1,sn2,'uni',false);
                % %     name_ROI_temp30=cellfun(@(c,n)c(n(end-1)+1:n(end)-1),name_ROI_tem2(:,1),sn1,'uni',false);
                % %     name_ROI_temp4=cellfun(@(c,m)c(2:m-1),name_ROI_tem2(:,1),sn1,'uni',false);
                % %     id_ROI=cellfun(@str2num,name_ROI_temp4,'UniformOutput',false);
                % %     data1{nn,1}.manual_imageJ_label.bFM_20230922.labelC50=name_ROI_temp30;
                % %     data1{nn,1}.manual_imageJ_label.bFM_20230922.label=name_ROI_temp3;
                % %     data1{nn,1}.manual_imageJ_label.bFM_20230922.id_ROI=id_ROI;
                % %     data1{nn,1}.manual_imageJ_label.bFM_20230922.atlas_allcell_N=atlas_cellmask_ch;
                % % 
                % %     %a=cell2mat(id_ROI);[au,ia] = unique(round(a),'stable');Same = ones(size(a));Same(ia) = 0;Result = [a Same];xxx=find(Same==1);find(a==Result(xxx(1),1))
                % %     %;811;859;a(2250);a(2379);name_ROI_temp30(2250);name_ROI_temp30(2379);name_ROI_temp(2250)
                % % 
                % % 
                % % end


                if flag.load_yolo==1 %paper figure1B, move to plot_step5_result_compare_v02.m
                    if isfield(data1{nn,1},[foldername.result_yolo{1} '_M' ])==0
                        env.filepath01=env.data_path0;

                        %flag.yoloshiftmerge_method='center-line'; %'center-line'

                        data1{nn,1}=load_yolo_train_and_result_v10(data1{nn,1},flag,setp,setp.train_imsize,foldername,env.filepath01,flag.dispfig1);
                        result_folder_mask=[data1{nn,1}.info.filepath_image 'results' filesep 'images' filesep];if ~isfolder(result_folder_mask);mkdir(result_folder_mask);end
                        %%{
                        if ~exist([result_folder_mask imsavefilename(1:end-4) '_yolo.jpg'],'file')
                            if isfield(data1{nn,1},'noGt_im_512x512__result__YOLO_conf_50_100_M')
                                Ybbox=data1{nn,1}.noGt_im_512x512__result__YOLO_conf_50_100_M.bbox;
                                cmap0=jet(size(Ybbox,1));s=rng(0,'twister');cmap1=cmap0(randperm(size(Ybbox,1)),:);

                                if flag.save_imsplit~=0
                                    imFs=insertShapeSplit(flag.save_imsplit, data1{nn,1}.im0gray, 'Rectangle', Ybbox,'Color', 255*cmap1,'LineWidth',4);
                                else
                                    imFs = insertShape(data1{nn,1}.im0gray, 'Rectangle', Ybbox,'Color', 255*cmap1,'LineWidth',4);
                                end
                                %%%imFs=imFs(fix(data1{nn,1}.zeropadding_sizeext(1)/2)+1:size(imFs,1)-fix(data1{nn,1}.zeropadding_sizeext(1)/2),fix(data1{nn,1}.zeropadding_sizeext(2)/2)+1:size(imFs,2)-fix(data1{nn,1}.zeropadding_sizeext(2)/2),:);


                                if flag.imzp==1
                                    imFs=imFs(ceil(setp.size_zpe(1)/2)+1:ceil(setp.size_zpe(1)/2)+size(imFs,1)-setp.size_zpe(1),ceil(setp.size_zpe(2)/2)+1:ceil(setp.size_zpe(2)/2)+size(imFs,2)-setp.size_zpe(2),:);
                                end
                                if data1{nn,1}.info.pixel_size~=0.464
                                    imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                                end
                                if flag.save_imsplit~=0
                                    imwriteSplit(imFs, [result_folder_mask imsavefilename(1:end-4) '_yolo.jpg'],flag.save_imsplit);
                                else
                                    imwrite(imFs, [result_folder_mask imsavefilename(1:end-4) '_yolo.jpg']);
                                end
                                figure(1);imshow(imFs);
                                clear cell_atlasL imFs cmap0 cmap1 Ybbox;
                            end
                        else
                            if flag.dispfig1==1;
                                Ybbox=data1{nn,1}.noGt_im_512x512__result__YOLO_conf_50_100_M.bbox;
                                cmap0=jet(size(Ybbox,1));s=rng(0,'twister');cmap1=cmap0(randperm(size(Ybbox,1)),:);
                                if flag.save_imsplit~=0
                                    imFs=insertShapeSplit(flag.save_imsplit, data1{nn,1}.im0gray, 'Rectangle', Ybbox,'Color', 255*cmap1,'LineWidth',4);
                                else
                                    imFs = insertShape(data1{nn,1}.im0gray, 'Rectangle', Ybbox,'Color', 255*cmap1,'LineWidth',4);
                                end
                                if flag.imzp==1
                                    imFs=imFs(ceil(setp.size_zpe(1)/2)+1:ceil(setp.size_zpe(1)/2)+size(imFs,1)-setp.size_zpe(1),ceil(setp.size_zpe(2)/2)+1:ceil(setp.size_zpe(2)/2)+size(imFs,2)-setp.size_zpe(2),:);
                                end
                                if data1{nn,1}.info.pixel_size~=0.464
                                    imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                                end
                                figure(1);imshow(imFs);
                            end
                        end

                        
                    else
                        if flag.dispfig1==1 && opts.load_UnetOneCell==0
                            Ybbox=data1{nn,1}.noGt_im_512x512__result__YOLO_conf_50_100_M.bbox;
                            cmap0=jet(size(Ybbox,1));s=rng(0,'twister');cmap1=cmap0(randperm(size(Ybbox,1)),:);
                            if flag.save_imsplit~=0
                                imFs=insertShapeSplit(flag.save_imsplit, data1{nn,1}.im0gray, 'Rectangle', Ybbox,'Color', 255*cmap1,'LineWidth',4);
                            else
                                imFs = insertShape(data1{nn,1}.im0gray, 'Rectangle', Ybbox,'Color', 255*cmap1,'LineWidth',4);
                            end
                            if flag.imzp==1
                                imFs=imFs(ceil(setp.size_zpe(1)/2)+1:ceil(setp.size_zpe(1)/2)+size(imFs,1)-setp.size_zpe(1),ceil(setp.size_zpe(2)/2)+1:ceil(setp.size_zpe(2)/2)+size(imFs,2)-setp.size_zpe(2),:);
                            end
                            if data1{nn,1}.info.pixel_size~=0.464
                                imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                            end
                            figure(1);imshow(imFs);
                        end
                    end

                end
                if flag.load_UnetOneCell==1 %paper figure 1C, move to plot_step5_result_compare_v02.m
                    if isempty(flag.unet_results_folderE)~=1
                        data1{nn, 1}.info.folderTag_result.UnetOneCell{2}=flag.unet_results_folderE;
                        foldername=foldernameFromTag(data1{nn,1},setp,idd);
                    end
                    if isfield(data1{nn,1},[foldername.result_UnetOneCell_M{end}])==0
                        [data1{nn,1}]=load_unet_v05(data1{nn,1},flag,env.filepath01,setp.size_box2,flag.dispfig1,foldername);
                        result_folder_mask=[data1{nn,1}.info.filepath_image 'results' filesep 'images' filesep];if ~isfolder(result_folder_mask);mkdir(result_folder_mask);end

                        if ~exist([result_folder_mask imsavefilename(1:end-4) 'unet.jpg'],'file')
                            cell_atlasL=getAtlasEdge(data1{nn,1}.(foldername.result_UnetOneCell_M{end}).atlas_allcell_N,1);
                            cmap0=jet(double(max(cell_atlasL(:))));s=rng(0,'twister');cmap1=cmap0(randperm(size(cmap0,1)),:);
                                       
                            if flag.save_imsplit~=0
                                imFs = labeloverlaySplit(flag.save_imsplit,data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                            else
                                imFs = labeloverlay(data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                            end

                            if flag.imzp==1
                                imFs=imFs(ceil(setp.size_zpe(1)/2)+1:ceil(setp.size_zpe(1)/2)+size(imFs,1)-setp.size_zpe(1),ceil(setp.size_zpe(2)/2)+1:ceil(setp.size_zpe(2)/2)+size(imFs,2)-setp.size_zpe(2),:);
                            end
                            if data1{nn,1}.info.pixel_size~=0.464
                                imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                            end

                            %imFs=imFs(fix(data1{nn,1}.zeropadding_sizeext(1)/2)+1:size(imFs,1)-fix(data1{nn,1}.zeropadding_sizeext(1)/2),fix(data1{nn,1}.zeropadding_sizeext(2)/2)+1:size(imFs,2)-fix(data1{nn,1}.zeropadding_sizeext(2)/2),:);
                            if ~exist([result_folder_mask imsavefilename(1:end-4) '_unet.jpg'],'file')
                                if flag.save_imsplit~=0
                                    imwriteSplit(uint8(imFs), [result_folder_mask imsavefilename(1:end-4) '_unet.jpg'],flag.save_imsplit);
                                else
                                    imwrite(uint8(imFs), [result_folder_mask imsavefilename(1:end-4) '_unet.jpg']);
                                end
                            end
                            if flag.dispfig1==1
                                cell_atlasL=getAtlasEdge(data1{nn,1}.(foldername.result_UnetOneCell_M{end}).atlas_allcell_N,1);
                                cmap0=jet(double(max(cell_atlasL(:))));s=rng(0,'twister');cmap1=cmap0(randperm(size(cmap0,1)),:);

                                if flag.save_imsplit~=0
                                    imFs = labeloverlaySplit(flag.save_imsplit,data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                                else
                                    imFs = labeloverlay(data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                                end

                                if flag.imzp==1
                                    imFs=imFs(ceil(setp.size_zpe(1)/2)+1:ceil(setp.size_zpe(1)/2)+size(imFs,1)-setp.size_zpe(1),ceil(setp.size_zpe(2)/2)+1:ceil(setp.size_zpe(2)/2)+size(imFs,2)-setp.size_zpe(2),:);
                                end
                                if data1{nn,1}.info.pixel_size~=0.464
                                    imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                                end
                                figure(1);imshow(imFs);
                            end
                            clear cell_atlasL imFs cmap0 cmap1 Ybbox;
                        else
                            if flag.dispfig1==1
                                cell_atlasL=getAtlasEdge(data1{nn,1}.(foldername.result_UnetOneCell_M{end}).atlas_allcell_N,1);
                                cmap0=jet(double(max(cell_atlasL(:))));s=rng(0,'twister');cmap1=cmap0(randperm(size(cmap0,1)),:);

                                if flag.save_imsplit~=0
                                    imFs = labeloverlaySplit(flag.save_imsplit,data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                                else
                                    imFs = labeloverlay(data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                                end

                                if flag.imzp==1
                                    imFs=imFs(ceil(setp.size_zpe(1)/2)+1:ceil(setp.size_zpe(1)/2)+size(imFs,1)-setp.size_zpe(1),ceil(setp.size_zpe(2)/2)+1:ceil(setp.size_zpe(2)/2)+size(imFs,2)-setp.size_zpe(2),:);
                                end
                                if data1{nn,1}.info.pixel_size~=0.464
                                    imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                                end
                                figure(1);imshow(imFs);
                            end
                        end
                    else

                        if flag.dispfig1==1
                            cell_atlasL=getAtlasEdge(data1{nn,1}.(foldername.result_UnetOneCell_M{end}).atlas_allcell_N,1);
                            cmap0=jet(double(max(cell_atlasL(:))));s=rng(0,'twister');cmap1=cmap0(randperm(size(cmap0,1)),:);

                            if flag.save_imsplit~=0
                                imFs = labeloverlaySplit(flag.save_imsplit,data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                            else
                                imFs = labeloverlay(data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                            end

                            if flag.imzp==1
                                imFs=imFs(ceil(setp.size_zpe(1)/2)+1:ceil(setp.size_zpe(1)/2)+size(imFs,1)-setp.size_zpe(1),ceil(setp.size_zpe(2)/2)+1:ceil(setp.size_zpe(2)/2)+size(imFs,2)-setp.size_zpe(2),:);
                            end
                            if data1{nn,1}.info.pixel_size~=0.464
                                imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                            end
                            figure(1);imshow(imFs);
                        end
                    end
                end
                if flag.load_MaskRCNN==1
                    if isfield(data1{nn,1}.info.folderTag_result,'MaskRCNN')==1;sh=1;ts=1;
                        foldername_select='result_MaskRCNN';
                        if isfield(data1{nn,1},[foldername.result_MaskRCNN{1}])==0
                            data1{nn,1}=load_detectron2txt_v01(data1{nn,1},flag,env.filepath01,foldername,foldername_select);
                        end
                    end
                end
                % if flag.load_MaskRCNN_train==1
                %     if isfield(data1{nn,1}.info.folderTag_train,'maskrcnn')==1;sh=1;ts=1;
                %         foldername_select='result_MaskRCNN';
                %         if isfield(data1{nn,1},[foldername.result_MaskRCNN{1}])==0
                %             data1{nn,1}=load_detectron2txt_v01(data1{nn,1},flag,env.filepath01,foldername,foldername_select);
                %         end
                %     end
                % end

                if flag.load_yolact==1
                    if isfield(data1{nn,1}.info.folderTag_result,'yolact')==1;sh=1;ts=1;
                        foldername_select='result_yolact';
                        if isfield(data1{nn,1},[foldername.result_yolact{1}])==0
                            data1{nn,1}=load_detectron2txt_v01(data1{nn,1},flag,env.filepath01,foldername,foldername_select);
                        end
                    end
                end

                % figure(1);imagesc(xxx.atlas_allcell)
                % figure(2);imagesc(data1{nn,1}.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N)
                % ddd=xxx.atlas_allcell-data1{nn,1}.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N;
                %                     path_tempU=[data1{nn, 1}.info.filepath_image 'results' filesep 'masks' filesep];
                %                     file_tempU=[data1{nn, 1}.info.filename_image(1:end-4) '__Yolo512_Unet_256x256__result__UNET_ML__V04.png'];
                %                     data1{nn,1}.im0Unet=imread([path_tempU file_tempU]);



                if flag.Low_res==-1
                    filepath_result_images0=[dinfo1{nn,1}.filepath_image 'results' filesep];   % new folder
                    if ~isfolder(filepath_result_images0);mkdir(filepath_result_images0);end
                    if isfield(data1{nn,1},'Yolo512_Unet_256x256__result__UNET_ML') || isfield(data1{nn,1},'Yolo512_Unet_256x256__result__netC4b1_ML')
                        %setp.train_imsize{2}=[1024 1024];
                        imsize0=size(data1{nn,1}.im0gray);
                        for ts=1
                            file_name_num=[filepath_result_images0 imsavefilename(1:end-4) '_' num2str(setp.train_imsize{ts}(1)) 'x' num2str(setp.train_imsize{ts}(2)) '_num.jpg'];
                            ts;
                            %end
                            for sh=1:2
                                if sh==1
                                    file_name_numL=[filepath_result_images0 imsavefilename(1:end-4) '_' num2str(setp.train_imsize{ts}(1)) 'x' num2str(setp.train_imsize{ts}(2)) '_numL.jpg'];
                                else
                                    file_name_numL=[filepath_result_images0 imsavefilename(1:end-4) '_' num2str(setp.train_imsize{ts}(1)) 'x' num2str(setp.train_imsize{ts}(2)) 'shift_numL.jpg'];
                                end

                                if ~exist(file_name_numL,'file') || flag.update_results==1;% save number with atlas

                                    Rshn=[0 fix(setp.train_imsize{ts}(2)/2) fix(setp.train_imsize{ts}(2)/2) 0];
                                    Dshn=[0 fix(setp.train_imsize{ts}(1)/2) 0 fix(setp.train_imsize{ts}(1)/2)];

                                    imp=data1{nn,1}.im0gray;      %.*uint8(bwbrain);  %bwbrain=logical(abs(data1{nn,1}.imbackground));
                                    imp=circshift(imp,Dshn(sh),1);imp=circshift(imp,Rshn(sh),2);
                                    %atlas_allcell_p=circshift(data1{nn,1}.masks_CRBG.atlas_allcell_N,Dshn(sh),1);atlas_allcell_p=circshift(atlas_allcell_p,Rshn(sh),2);
                                    %im0sh=circshift(data1{nn,1}.im0,Dshn(sh),1);im0sh=circshift(im0sh,Rshn(sh),2);
                                    %atlas_brain_sh=circshift(data1{nn,1}.atlas_brain,Dshn(sh),1);atlas_brain_sh=circshift(atlas_brain_sh,Rshn(sh),2);

                                    edgelinewidth_sh2=20;drc=ceil(imsize0./setp.train_imsize{ts}); % for paper figure
                                    bw_edge=false(size(data1{nn,1}.im0gray));
                                    bw_edge=circshift(bw_edge,Dshn(sh),1);bw_edge=circshift(bw_edge,Rshn(sh),2);

                                    bw_edge_4d=imsplit4d(bw_edge,[setp.train_imsize{ts}]);
                                    bw_edge_4d(:,1:edgelinewidth_sh2,:)=1;   bw_edge_4d(:,setp.train_imsize{ts}(1)-edgelinewidth_sh2+1:setp.train_imsize{ts}(1),:)=1;
                                    bw_edge_4d(:,:,1:edgelinewidth_sh2)=1;   bw_edge_4d(:,:,setp.train_imsize{ts}(2)-edgelinewidth_sh2+1:setp.train_imsize{ts}(2))=1;
                                    bw_edge=dmib2(bw_edge_4d,drc(1),drc(2)); bw_edge(1:edgelinewidth_sh2,:)=0;bw_edge(end-edgelinewidth_sh2+1:end,:)=0;bw_edge(:,1:edgelinewidth_sh2)=0;bw_edge(:,end-edgelinewidth_sh2+1:end)=0;

                                    %if isfield(data1{nn,1},'atlas_brain')~=0
                                    % atlas0L=getAtlasEdge(data1{nn,1}.atlas_brain,10);

                                    %atlas0L=circshift(atlas0L,Dshn(sh),1);atlas0L=circshift(atlas0L,Rshn(sh),2);

                                    % cmap=vertcat(data1{nn,1}.atlas_table.RGB{2:end-2,1})./255;
                                    % cmap(254,:)=data1{nn,1}.atlas_table.RGB{end-1,1}./255;
                                    % cmap(255,:)=data1{nn,1}.atlas_table.RGB{end,1}./255;

                                    %at_4d=imsplit4d(data1{nn,1}.atlas_brain,[setp.train_imsize{ts}]);
                                    %                                 try
                                    %                                     at_4d=imsplit4d(data1{nn,1}.masks_CRBG.atlas_allcell_N,[setp.train_imsize{ts}]);
                                    %                                 catch
                                    %                                     at_4d=imsplit4d(data1{nn,1}.atlas_brain,[setp.train_imsize{ts}]);
                                    %                                 end
                                    try
                                        atlas_allcell_p=circshift(data1{nn,1}.masks_CRBG.atlas_allcell_N,Dshn(sh),1);atlas_allcell_p=circshift(atlas_allcell_p,Rshn(sh),2);
                                    catch
                                        try
                                            atlas_allcell_p=circshift(data1{nn,1}.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N,Dshn(sh),1);atlas_allcell_p=circshift(atlas_allcell_p,Rshn(sh),2);
                                        catch
                                            atlas_allcell_p=circshift(data1{nn,1}.Yolo512_Unet_256x256__result__netC4b1_ML.atlas_allcell_N,Dshn(sh),1);atlas_allcell_p=circshift(atlas_allcell_p,Rshn(sh),2);
                                        end
                                    end

                                    atlas_allcell_p_4d=imsplit4d(atlas_allcell_p,[setp.train_imsize{ts}]);
                                    bwl1=sum(sum(atlas_allcell_p_4d,2),3);idexbw=find(bwl1~=0);

                                    bboxnum_4d=uint8(false(size(bw_edge_4d)));
                                    for mm=1:length(idexbw)
                                        bwfornum=false(setp.train_imsize{ts});
                                        J = insertText(uint8(bwfornum), [setp.train_imsize{ts}(1)/2 setp.train_imsize{ts}(2)/2 ], num2str(idexbw(mm)), 'FontSize',180,'TextColor','white','BoxOpacity',0,'AnchorPoint','Center');
                                        bwJ=J(:,:,1);bwJ(bwJ~=0)=1;bwJ=uint8(bwJ);
                                        bboxnum_4d(idexbw(mm),:,:)=bwJ;
                                    end
                                    %unique(atlas0L)
                                    bboxnum=dmib2(bboxnum_4d,drc(1),drc(2));
                                    if flag.save_imsplit~=0
                                        imF1 = labeloverlaySplit(flag.save_imsplit,imp,bw_edge(1:size(data1{nn,1}.im0gray,1),1:size(data1{nn,1}.im0gray,2)),'Colormap',[1 0 0],'Transparency',0.5);
                                        imF1 = labeloverlaySplit(flag.save_imsplit,imF1,bboxnum(1:size(data1{nn,1}.im0gray,1),1:size(data1{nn,1}.im0gray,2)),'Colormap',[255,255,0]/255,'Transparency',0);

                                    else
                                        imF1 = labeloverlay(imp,bw_edge(1:size(data1{nn,1}.im0gray,1),1:size(data1{nn,1}.im0gray,2)),'Colormap',[1 0 0],'Transparency',0.5);
                                        imF1 = labeloverlay(imF1,bboxnum(1:size(data1{nn,1}.im0gray,1),1:size(data1{nn,1}.im0gray,2)),'Colormap',[255,255,0]/255,'Transparency',0);
                                    end

                                    %imF1 = labeloverlay(imF1,atlas0L,'Colormap',cmap,'Transparency',0);
                                    %f1=figure(12211);imshow(imF1);
                                    if size(imF1,1)>5000
                                        imF1L=imresize(imF1,size(imF1,[1 2])/10);
                                    else
                                        imF1L=imresize(imF1,size(imF1,[1 2]));
                                    end
                                    if ~exist(file_name_numL,'file')
                                        imwrite(imF1L,file_name_numL);
                                    end
                                    %  imwrite(imF1,file_name_num);

                                    % atlas0L(atlas0L==255)=0;atlas0L(atlas0L==254)=0;
                                    %   imF1 = labeloverlay(data1{nn,1}.im0gray,atlas0L,'Colormap',cmap,'Transparency',0);
                                    %    f1=figure(12212);imshow(imF1)

                                end
                            end
                        end
                    end

                end
            end





            %% Section-3 calculate mask properties in large image
            for section3=1
                if flag.cal_cell_props==1 && flag.Low_res==-1%flag.cal_cell_prop_rn=0;flag.rcal_all=0; %=1 to reculate all cells
                    name_field=fieldnames(data1{nn,1});close all;
                    for ci=1:length(name_field)
                        select_data=name_field{ci};
                        if isfield(data1{nn,1}.(select_data),'atlas_allcell_N')==1
                            if isfield(data1{nn,1}.(select_data),'cocoP')~=1
                                fprintf(['Calculate/load mask properties for ' select_data ' \n'])
                                data1{nn,1}=cal_cell_regionprops_file_ver_08r(data1{nn,1},select_data,flag,env.filepath01);

                                if flag.save_coco_selected_prop==1 % for C50
                                    filename_coco=[dinfo1{nn,1}.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver '.json'];
                                    filename_coco_s=[filename_coco(1:end-5) 's.json'];
                                    %                   coco_temp9=CocoApi([dinfo1{nn,1}.filepath_coco filesep 'CR1 slide 1__Yolo512_Unet_256x256__result__UNET_ML__V04regp09.json']);
                                    %                   coco_temp4=CocoApi([dinfo1{nn,1}.filepath_coco filesep 'CR1 slide 1__Yolo512_Unet_256x256__result__UNET_ML__V04.json']);
                                    %                   coco_temp11=CocoApi([dinfo1{nn,1}.filepath_coco filesep 'CR1 slide 1__Yolo512_Unet_256x256__result__UNET_ML__V04regp11.json']);

                                    coco_temp=CocoApi([dinfo1{nn,1}.filepath_coco filesep filename_coco]);

                                    cocostruct=cocoFilePathChange(coco_temp.data, [env.filepath01 dinfo1{nn,1}.filename_image(1:3) filesep], dinfo1{nn,1}.filename_image(1:end-4));
                                    if flag.category_update>0;cocostruct=coco_category_update_v01(cocostruct,data1{nn,1});end
                                    table_temp=struct2table(cocostruct.annotations);
                                    table_name_All=table_temp.Properties.VariableNames;
                                    lasN=find(strcmpi(table_name_All,{'N_bbox'})==1);

                                    propname_select_C50=horzcat(table_name_All(1:lasN),flag.propname_select_C50);
                                    filename_coco_remove=setdiff(table_temp.Properties.VariableNames,propname_select_C50);

                                    %filename_coco_remove={'NC','core_mean','core_std','MeanIntensity','MinIntensity','MaxIntensity','StdIntensity','MedianIntensity','FM_BREN_bbox1p2'};
                                    for rm=1:length(filename_coco_remove)
                                        table_temp= removevars(table_temp,filename_coco_remove(rm));
                                    end
                                    coco_tempS=coco_temp;coco_tempS.data.annotations=table2struct(table_temp);
                                    cocostring=gason(coco_tempS.data);
                                    fid = fopen([dinfo1{nn,1}.filepath_coco filesep filename_coco_s], 'w');
                                    if fid == -1, error('Cannot create JSON file');end
                                    fwrite(fid, cocostring, 'char');fclose(fid);
                                end
                                clear annotations table0
                                if flag.reduce_table==1
                                    table0=struct2table(data1{nn,1}.(select_data).cocoP.annotations);
                                    try
                                        annotations = table0(:,{'score','image_id','bbox','id_masknii','category_id2_name','CA','CP','CHA','CHSR','FM_BREN_bbox1p2'});
                                    catch
                                        annotations = table0(:,{'image_id','bbox','id_masknii','category_id2_name','CA','CP','CHA','CHSR','FM_BREN_bbox1p2'});
                                    end
                                    data1{nn, 1}.(select_data).cocoP.annotations=table2struct(annotations);
                                    clear table0 annotations
                                end
                                % fix bug of save C50 in cocoP
                                fix_cocoP=0;
                                if isfield(data1{nn, 1}.(select_data).cocoP.annotations,'C50')
                                    table0=struct2table(data1{nn,1}.(select_data).cocoP.annotations);
                                    table0= removevars(table0,{'C50'});fix_cocoP=1;
                                end
                                if isfield(data1{nn, 1}.(select_data).cocoP.annotations,'C50_1');table0= removevars(table0,{'C50_1'});end
                                if isfield(data1{nn, 1}.(select_data).cocoP.annotations,'C50_2');table0= removevars(table0,{'C50_2'});end
                                if isfield(data1{nn, 1}.(select_data).cocoP.annotations,'C50_3');table0= removevars(table0,{'C50_3'});end
                                if isfield(data1{nn, 1}.(select_data).cocoP.annotations,'C50_4');table0= removevars(table0,{'C50_4'});end
                                if isfield(data1{nn, 1}.(select_data).cocoP.annotations,'C50_5');table0= removevars(table0,{'C50_5'});end
                                if fix_cocoP==1
                                    data1{nn, 1}.(select_data).cocoP.annotations=table2struct(table0);
                                    cocostring=gason( data1{nn, 1}.(select_data).cocoP);
                                    fid = fopen([dinfo1{nn,1}.filepath_coco filesep data1{nn, 1}.(select_data).filename_coco], 'w');
                                    if fid == -1, error('Cannot create JSON file');end
                                    fwrite(fid, cocostring, 'char');fclose(fid);
                                end

                            end
                        end
                    end
                    %                     select_data='ChImJroi_DCheckedv2_512x512__train_M';
                    %                     %data1{nn,1}.info=rmfield(data1{nn,1}.info,'regp_verN');data1{nn,1}.info.regp_ver='temp';
                    %                     if isfield(data1{nn,1},select_data)==1;
                    %                         data1{nn,1}=cal_cell_regionprops_08r(data1{nn,1},select_data,flag,env.filepath01);
                    %                     end
                    %                     select_data='ArStImJroi_20210812_512x512__train_M';
                    %                     if isfield(data1{nn,1},select_data)==1;data1{nn,1}=cal_cell_regionprops_08r(data1{nn,1},select_data,flag,env.filepath01);end
                    %                     select_data='Yolo512_Unet_256x256__result__UNET_ML';
                    %                     %si=1,ff0=1, %bn=1:len; in cell_regionprops_08
                    %                     if isfield(data1{nn,1},select_data)==1;data1{nn,1}=cal_cell_regionprops_08r(data1{nn,1},select_data,flag,env.filepath01);end
                    %                     select_data='masks_CRBG';
                    %                     if isfield(data1{nn,1},select_data)==1;data1{nn,1}=cal_cell_regionprops_08r(data1{nn,1},select_data,flag,env.filepath01);end
                    %                     select_data='CRBG_UnetOneCell_256x256__result__UNET_ML';
                    %                     if isfield(data1{nn,1},select_data)==1;data1{nn,1}=cal_cell_regionprops_08r(data1{nn,1},select_data,flag,env.filepath01);end

                end
                if flag.cal_precession==1
                    % plot_cell_parameters()
                    % compareBoxAP_CocoApiVsMatlab_v01(data1,foldername);
                    % UnetAP_CocoApi_v01(data1,foldername);
                    % cellprop_focuse_measurement()
                    % plot_statistical_cell_labels_spyder_plot_v02.m
                end
                %% display parameter maps FM paper Fig. S3 move to: plot_step5_result_compare_v01.m
            end

            %% Section-5 cell detection by Yolo5 train in python
            for section5=1
                switch flag.yolo_ver
                    case 'v5'
                        % create pytyolo environment
                        % Download "conda.m" from MathWorks File Exchange and put it in Matlab path
                        % Download yolo from github: https://github.com/mihir135/yolo
                        % open Anaconda Prompt
                        % >> conda create –n pytyolo python==3.8'
                        % >> cd F:\python\yolo-master
                        % >> pip install –U –r F:\python\yolo-master\requirements_02.txt
                        if flag.yolo_train == 1;
                            if isfield(flag,'yolo_folder_train')==1 && isempty(flag.yolo_folder_train{1})~=1
                                yolo_folder_train=flag.yolo_folder_train;
                            else;yolo_folder_train=foldername.train_yolo;end
                            %F:\anaconda3\envs\yotest\python H:\HU\yolo_test\ultralytics\yolo\train.py --img 512 --batch 2 --epochs 10 --data H:\HU\yolo_test\ytest1.yaml --cfg H:\HU\yolo_test\ultralytics\yolo\models\yolom.yaml --weights H:\HU\yolo_test\pretrain_pt\yolom.pt --name my_experiment
                        end
                        if flag.yolo_detection==1
                            if size(data1{nn,1}.im0gray,1)<=setp.train_imsize{ts}(1) && size(data1{nn,1}.im0gray,2)<=setp.train_imsize{ts}(2);shn=1;else;shn=1:2;end
                            if isfield(flag,'yolo_folder_test')==1 && isempty(flag.yolo_folder_test{1})~=1
                                yolo_folder_test=flag.yolo_folder_test;
                            else
                                if flag.save_test_maskrcnn>=1
                                    yolo_folder_test=foldername.test_yolo;
                                else
                                    yolo_folder_test=foldername.train_yolo;
                                end
                            end

                            if isfield(flag,'yolo_folder_result')==1 && isempty(flag.yolo_folder_result{1})~=1
                                yolo_folder_result=flag.yolo_folder_result;
                                %                         for yi=1:length(yolo_folder_result)
                                %                             yolo_folder_result__image{yi}=[yolo_folder_result{yi} '__im'];
                                %                         end
                            else
                                yolo_folder_result=foldername.result_yolo;
                            end

                            if isfield(env,'data_path0temp');data_path0temp=strrep(data1{nn, 1}.info.filepath_image,env.data_path0,env.data_path0temp);else;data_path0temp=data1{nn, 1}.info.filepath_image;end

                            path0=pwd;

                            env.path_yolo_temp=[data1{nn, 1}.info.filepath_image 'yolo_temp' filesep];
                            if ~isfolder(env.path_yolo_temp);mkdir(env.path_yolo_temp);end
                            copyfile(env.path_yolo,env.path_yolo_temp);

                            cd(env.path_yolo_temp);
                            sfp=findstr(env.path_conda_yolo,filesep);
                            conda_yolo=env.path_conda_yolo(sfp(end-1)+1:sfp(end)-1);
                            warning off



                            for sh=shn
                                conda.init(env.path_conda);
                                eval(['conda activate ' conda_yolo]);
                                switch flag.save_train_path_case
                                    case 2
                                        imenv.path_yolo0=[data_path0temp yolo_folder_test{sh} filesep];
                                        imfolder_yolo1=dir(imenv.path_yolo0);
                                        imfolder_yolo1=imfolder_yolo1(~ismember({imfolder_yolo1.name},{'.','..'}));
                                        imfolder_yolo1={imfolder_yolo1.name}';
                                        for yy=1:length(imfolder_yolo1)
                                            imenv.path_yolo2=['"' imenv.path_yolo0 imfolder_yolo1{yy} filesep 'images"'];
                                            string=[env.path_conda_yolo 'python ' env.path_yolo_temp 'detect.py --weights ' env.matlab_path 'yolopt' filesep 'yolo_0504_yolom.pt --img 512 --conf 0.5 --iou-thres ' num2str(flag.yolo_IoU) ' --source ' imenv.path_yolo2 ' --save-txt --save-conf'];
                                            if exist([env.path_yolo_temp 'runs' filesep 'detect'],'dir')
                                                rmdir([env.path_yolo_temp 'runs' filesep 'detect'], 's')
                                            end
                                            mkdir([env.path_yolo_temp 'runs' filesep 'detect']);

                                            [status, commandOut] = system(string);
                                            if ~exist([data_path0temp yolo_folder_result{sh}]);mkdir([dinfo1{nn,1}.filepath_image yolo_folder_result{sh}]);end
                                            %                           if ~exist([dinfo1{nn,1}.filepath_image yolo_folder_result__image{sh}]);mkdir([dinfo1{nn,1}.filepath_image yolo_folder_result__image{sh}]);end

                                            labletxt=dir([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp' filesep 'labels' filesep]);
                                            if length(labletxt)>2
                                                movefile([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp' filesep 'labels' filesep '*.*'],[dinfo1{nn,1}.filepath_image yolo_folder_result{sh}]);
                                            end
                                            %movefile([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp' filesep '*.png'],[dinfo1{nn,1}.filepath_image yolo_folder_result__image{sh}])

                                            %                             if exist([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp' filesep 'labels'],'dir')
                                            %                                 rmdir([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp' filesep 'labels']);end
                                            %
                                            %                             if exist([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp'],'dir')
                                            %                                 rmdir([env.path_yolo 'runs' filesep 'detect' filesep 'exp']);end

                                            % rmdir([env.path_yolo_temp 'runs' filesep 'detect'], 's')

                                        end
                                    case 3
                                        imenv.path_yolo0=[data_path0temp yolo_folder_test{sh} filesep 'images'];
                                        %how to use yolo to detect all images save in the folder "F:\HU\DLdata_v3\Burke\project1\IHC\UN1\UN1 slide 1\noGt_im_512x512__test\images"
                                        deimages=dir(imenv.path_yolo0);
                                        deimages=deimages(~ismember({deimages.name},{'.','..'}));

                                        nydec=2000;
                                        D = gpuDevice;%reset(D);
                                        
                                        %if length(deimages)<=nydec
                                            % %string=[env.path_conda_yolo 'python ' env.path_yolo_temp 'detect.py --weights ' env.matlab_path 'yolo' flag.yolo_ver 'pt' filesep 'yolo_0504_yolov5m.pt --img 512 --conf 0.5 --iou-thres ' num2str(flag.yolo_IoU) ' --source "' imenv.path_yolo0 '" --save-txt --save-conf'];
                                            % string=[env.path_conda_yolo 'python "' env.path_yolo_temp 'detect.py" --weights ' env.matlab_path 'yolo' flag.yolo_ver 'pt' filesep 'yolo_0504_yolov5m.pt --img 512 --conf 0.5 --iou-thres ' num2str(flag.yolo_IoU) ' --source "' path_yolo0_temp '" --save-txt --save-conf'];
                                            % 
                                            % if exist([env.path_yolo_temp 'runs' filesep 'detect'],'dir')
                                            %     rmdir([env.path_yolo_temp 'runs' filesep 'detect'], 's')
                                            % end
                                            % [status, commandOut] = system(string);
                                            % if ~exist([data_path0temp yolo_folder_result{sh}]);mkdir([data_path0temp yolo_folder_result{sh}]);end
                                            % labletxt=dir([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp' filesep 'labels' filesep]);
                                            % if length(labletxt)>2
                                            %     movefile([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp' filesep 'labels' filesep '*.*'],[data_path0temp yolo_folder_result{sh}])
                                            % end
                                        %else
                                            path_yolo0_temp=[data_path0temp yolo_folder_test{sh} filesep 'images_temp'];
                                            if ~isfolder(path_yolo0_temp);mkdir(path_yolo0_temp);end

                                            for yi=1:ceil(length(deimages)/nydec);
                                                if nydec*yi <= length(deimages)
                                                    ycn=(yi-1)*nydec+1:nydec*yi;
                                                else
                                                    ycn=(yi-1)*nydec+1:length(deimages);
                                                end
                                                for yc=ycn
                                                    copyfile([imenv.path_yolo0 filesep deimages(yc).name],[path_yolo0_temp filesep deimages(yc).name]);
                                                end

                                                string=[env.path_conda_yolo 'python "' env.path_yolo_temp 'detect.py" --weights ' env.matlab_path 'yolo' flag.yolo_ver 'pt' filesep 'yolo_0504_yolov5m.pt --img 512 --conf 0.5 --iou-thres ' num2str(flag.yolo_IoU) ' --source "' path_yolo0_temp '" --save-txt --save-conf'];
                                                

                                                if isfolder([env.path_yolo_temp 'runs' filesep 'detect'])
                                                    rmdir([env.path_yolo_temp 'runs' filesep 'detect'], 's')
                                                end

                                                [status, commandOut] = system(string);
                                                if status==1
                                                    fprintf('check pythorch version\n')
                                                    fprintf('see: https://github.com/ultralytics/yolov5/issues/6948 \n')
                                                    % comment out "recompute_scale_factor=self.recompute_scale_factor" in "E:\condaaa\lib\site-packages\torch\nn\modules\upsampling.py"
                                                    % def forward(self, input: Tensor) -> Tensor:
                                                    %     return F.interpolate(input, self.size, self.scale_factor, self.mode, self.align_corners,
                                                    %     #recompute_scale_factor=self.recompute_scale_factor
                                                    %     )
                                                end
                                                
                                                if ~exist([data_path0temp yolo_folder_result{sh}]);mkdir([data_path0temp yolo_folder_result{sh}]);end
                                                labletxt=dir([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp' filesep 'labels' filesep]);
                                                if length(labletxt)>2
                                                    movefile([env.path_yolo_temp 'runs' filesep 'detect' filesep 'exp' filesep 'labels' filesep '*.*'],[data_path0temp yolo_folder_result{sh}])
                                                end
                                                delete([path_yolo0_temp filesep '*.*'])
                                            end
                                            rmdir([path_yolo0_temp filesep], 's');
                                            exist([imenv.path_yolo0 filesep deimages(yc).name],'file');

                                        %end
                                end
                            end
                            try
                                rmdir(env.path_yolo_temp, 's');
                            end
                            cd(path0);
                        end
                    case 'v8'
                end
                      
            end

            %% Section-6 cell segmentation by matlab or Unet in R (not finish)
            for section6=1
                if isfield(env,'data_path0temp');data_path0temp=strrep(data1{nn, 1}.info.filepath_image,env.data_path0,env.data_path0temp);else;data_path0temp=data1{nn, 1}.info.filepath_image;end

                switch flag.unet_detection
                    case 'matlabss3'
                        load(flag.unet_file);
                        eval(['net=' flag.unet_name '{' num2str(flag.unet_num) '};']);
                        data1{nn, 1}.info.folderTag_result.UnetOneCell{2}=flag.unet_results_folderE;

                        foldername_save=folderTag2foldername(dinfo1{nn,1}.folderTag_test.yolo2unet(ts,:), setp.size_box2, 'test');

                        imgDir=[strrep([data_path0temp foldername_save filesep],'Unet','SS3') 'images' filesep];
                        if isfolder(imgDir)
                            imds = imageDatastore(imgDir);
                            foldername_saveM=folderTag2foldername(data1{nn, 1}.info.folderTag_result.UnetOneCell(idd.save_unet,:), setp.size_box2, 'result');
                            
                            dtemp=[data_path0temp foldername_saveM filesep];

                            if isfolder(dtemp);rmdir(dtemp,'s');end
                            % if ~exist([data_path0temp foldername_saveM] ,'dir')
                            %     mkdir([data_path0temp foldername_saveM])
                            % end
%                             tic;
                            if ~isfolder(dtemp);mkdir(dtemp);end
                            
                            %%%% only out put 0 and 255 for segmentation  
                            C = semanticseg_chh01(imds, net, 'MiniBatchSize',300,'WriteLocation',dtemp);

                            
                        end
                end
            end

            %% Section-7 Classification train, C50 in R
            for section7=1
                if flag.C50_train==1 %train, C50 in R
                    DataSetInfo.C50_case='train';  %='train'; or 'prediction'
                    %env.C50_Model_filename='F:\matlab_program\IHC\R\C50\C50_v01.RData';
                    %env.C50_Model_filename='F:\GoogleDrive_005\matlab_program\IHC_v2\R\C50\C50_v02a';

                    % env.C50_Json_train_filename{1,1}='H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\cocoJson\CR1 slide 10__ChImJroi_DChecked_512x512__train_M__V04regp11s.json';
                    % env.C50_Json_train_filename{2,1}='H:\HU\DLdata_v2\Shoykhet\project1\IHC\N25\N25 slide 10\cocoJson\N25 slide 10__ChImJroi_DChecked_512x512__train_M__V04regp11s.json';
                    % env.C50_Json_train_temp='F:\matlab_program\IHC\R\C50\C50_train_temp.json';
                    % DataSetInfo.C50_TrainLabel='category_id3_name'; %
                    %  DataSetInfo.C50_TrainPara={'NA','NCAr','NP','NCPr','CA','MajorAxisLength','MinorAxisLength','Eccentricity','CHA','Density','Extent',...
                    %                                                 'FD','LC','LCstd','CP','CC','CHC','CHP','MaxSACH','MinSACH','CHSR','Roughness','diameterBC','rMmCHr','meanCHrd'};
                    % DataSetInfo.C50_Json_test_filename{1}='H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\cocoJson\CR1 slide 10__Yolo512_Unet_256x256__result__UNET_ML__V04regp11s.json';
                    %                     DataSetInfo.C50_Json_pred_filename{1}='H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\cocoJson\CR1 slide 10__Yolo512_Unet_256x256__result__UNET_ML__V04regp11s__C50v01t.json';
                    % [status,cmdout]=R_predicC50_v01(DataSetInfo,env);
                end
                if flag.C50_prediction==1 %prediction by C50 in R
                    DataSetInfo.C50_case='predict'; %='train'; or 'prediction'
                    %env.C50_Model_filename='F:\matlab_program\IHC\R\C50\C50_v01.RData';
                    %                   env.C50_Json_train_filename{1,1}='H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\cocoJson\CR1 slide 10__ChImJroi_DChecked_512x512__train_M__V04regp11s.json';
                    %                   env.C50_Json_train_filename{2,1}='H:\HU\DLdata_v2\SC50_flagC50_flaghoykhet\project1\IHC\N25\N25 slide 10\cocoJson\N25 slide 10__ChImJroi_DChecked_512x512__train_M__V04regp11s.json';
                    %                   env.C50_Json_train_temp='F:\matlab_program\IHC\R\C50\C50_train_temp.json';
                    DataSetInfo.C50_TrainLabel='category_id3_name'; %
                    DataSetInfo.C50_TrainPara={'NA','NCAr','NP','NCPr','CA','MajorAxisLength','MinorAxisLength','Eccentricity','CHA','Density','Extent',...
                        'FD','LC','LCstd','CP','CC','CHC','CHP','MaxSACH','MinSACH','CHSR','Roughness','diameterBC','rMmCHr','meanCHrd'};
                    %env.C50_Rscript_train_filename='F:\matlab_program\IHC\R\C50\R_trainC50_v01.R';
                    %env.C50_Rscript_predict_filename='F:\matlab_program\IHC\R\C50\R_predicC50_v01.R';
                    select_data=[foldername.result_UnetOneCell_M{end}];
                    filename_coco=[dinfo1{nn,1}.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver '.json'];
                    %filename_coco_s=[filename_coco(1:end-5) 's.json'];
                    filename_coco_s=[filename_coco(1:end-5) '.json'];

                    DataSetInfo.C50_Json_test_filename{1}=[dinfo1{nn,1}.filepath_coco filesep filename_coco_s];
                    DataSetInfo.C50_Json_pred_filename{1}=[DataSetInfo.C50_Json_test_filename{1}(1:end-5) '__' flag.load_cocoC50{1} '.json'];
                    %DataSetInfo.C50_Json_pred_filename{1}=[DataSetInfo.C50_Json_test_filename{1}(1:end-5) '__' flag.load_cocoC50{1} '_t2.json'];
                    if ~exist(DataSetInfo.C50_Json_pred_filename{1},'file')
                        [status,cmdout]=R_predicC50_v01(DataSetInfo,env);
                    end


                    if flag.load_manual_imageJroi==1
                        for ci=1:length(foldername.train_manual{1})
                            %env.C50_Model_filename='F:\GoogleDrive_005\matlab_program\IHC_v2\R\C50\C50_v01.RData';
                            select_data=[foldername.train_manual{1}{ci} '_M'];
                            filename_coco_s=[dinfo1{nn,1}.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver 's.json'];
                            DataSetInfo.C50_Json_test_filename{1}=[dinfo1{nn,1}.filepath_coco filesep filename_coco_s];
                            if ~exist(DataSetInfo.C50_Json_test_filename{1},'file')
                            filename_coco_s=[dinfo1{nn,1}.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver '.json'];
                            DataSetInfo.C50_Json_test_filename{1}=[dinfo1{nn,1}.filepath_coco filesep filename_coco_s];
                            end
                            DataSetInfo.C50_Json_pred_filename{1}=[DataSetInfo.C50_Json_test_filename{1}(1:end-5) '__' flag.load_cocoC50{1} '.json'];
                            if ~exist(DataSetInfo.C50_Json_pred_filename{1},'file')
                                DataSetInfo.C50_case='predict';
                                DataSetInfo.C50_TrainLabel='category_id3_name';
                                DataSetInfo.C50_TrainPara={'NA','NCAr','NP','NCPr','CA','MajorAxisLength','MinorAxisLength','Eccentricity','CHA','Density','Extent',...
                                    'FD','LC','LCstd','CP','CC','CHC','CHP','MaxSACH','MinSACH','CHSR','Roughness','diameterBC','rMmCHr','meanCHrd'};
                                env.C50_Rscript_train_filename='F:\GoogleDrive_005\matlab_program\IHC_v2\R\C50\R_trainC50_v01.R';
                                env.C50_Rscript_predict_filename='F:\GoogleDrive_005\matlab_program\IHC_v2\R\C50\R_predicC50_v01.R';
                                [status,cmdout]=R_predicC50_v01(DataSetInfo,env);

                                %coco_temp=CocoApi(DataSetInfo.C50_Json_pred_filename{1});
                            end
                        end
                    end
                end

                if isempty(flag.load_cocoC50{1})~=1
                    if isempty(flag.unet_results_folderE)~=1
                        if isfield(foldername,'result_UnetOneCell_M')==1
                            select_data=[foldername.result_UnetOneCell_M{end}];
                            flag.load_cocofileforC50{1}=select_data;
                        else
                            load_cocoC50=0;
                        end
                    end
                    for nc=1:length(flag.load_cocofileforC50)   % selected result
                        %nc=2; flag.load_cocofileforC50{2}='masks_CRBG'
                        for nc50=1:length(flag.load_cocoC50)    % C50 version
                            if isfield(data1{nn,1},flag.load_cocofileforC50{nc})==1

                                filename_coco0=[dinfo1{nn,1}.filename_image(1:end-4) '__' flag.load_cocofileforC50{nc} '__' flag.result_ver flag.regp_verC50{nc50} '__' flag.load_cocoC50{nc50} '.json'];
                                if ~exist([dinfo1{nn,1}.filepath_coco filesep filename_coco0],'file')
                                    filename_coco0=[dinfo1{nn,1}.filename_image(1:end-4) '__' flag.load_cocofileforC50{nc} '__' flag.result_ver flag.regp_verC50{nc50} 's__' flag.load_cocoC50{nc50} '.json'];
                                end
                                % filename_coco0=[dinfo1{nn,1}.filename_image(1:end-4) '__ChImJroi_DChecked_512x512__train_M__' flag.result_ver flag.regp_verC50{nc50} '__' flag.load_cocoC50{nc50} 'N.json'];
                                % if isfield(data1{nn, 1}.(flag.load_cocofileforC50{nc}),'cocoP')==1
                                % data1{nn, 1}.(flag.load_cocofileforC50{nc}).cocoP.annotations.C50
                                % end
                                if exist([dinfo1{nn,1}.filepath_coco filesep filename_coco0],'file')
                                    nc
                                    coco_temp=CocoApi([dinfo1{nn,1}.filepath_coco filesep filename_coco0]);
                                    cocostruct=cocoFilePathChange(coco_temp.data, [env.filepath01 data1{nn,1}.info.filename_image(1:3) filesep], data1{nn,1}.info.filename_image(1:end-4));
                                    %if flag.category_update>0;cocostruct=coco_category_update_v01(cocostruct,data1{nn,1});end
                                    if flag.category_update>0;options.case='atlas_table';options.Low_res=flag.Low_res;
                                        cocostruct=coco_category_update_v02(cocostruct,data1{nn,1},options);end

                                    if isfield(data1{nn, 1}.(flag.load_cocofileforC50{nc}),'cocoP')==1
                                        annotations=struct2table(data1{nn, 1}.(flag.load_cocofileforC50{nc}).cocoP.annotations);
                                    else
                                        annotations=struct2table(data1{nn, 1}.(flag.load_cocofileforC50{nc}).coco.annotations);
                                    end
                                    c50i={cocostruct.annotations.C50}';
                                    sn1 = strfind(c50i,'__');
                                    if isempty(sn1{1})~=1
                                        C50=cellfun(@(c,n)c(n+2:end),c50i,sn1,'uni',false);
                                    else
                                        C50=c50i;
                                    end
                                    if ~istablefield(annotations,'C50')
                                        annotations = addvars(annotations,C50);
                                    end

                                    if isfield(data1{nn, 1}.(flag.load_cocofileforC50{nc}),'cocoP')==1
                                        data1{nn, 1}.(flag.load_cocofileforC50{nc}).cocoP.annotations=table2struct(annotations);
                                    else
                                        data1{nn, 1}.(flag.load_cocofileforC50{nc}).coco.annotations=table2struct(annotations);
                                    end
                                    clear annotations
                                end
                            end
                        end
                    end

                    % coco_temp=CocoApi('H:\HU\DLdata_v2\Shoykhet\project1\IHC\N25\N25 slide 10\cocoJson\N25 slide 10__ArStImJroi_20210812_512x512__train_M__V04regp11s__C50.json');


                     if flag.load_manual_imageJroi==1
                        for ci=1:length(foldername.train_manual{1})
                            select_data=[foldername.train_manual{1}{ci} '_M'];
                            filename_coco_s=[dinfo1{nn,1}.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver 's__' flag.load_cocoC50{1} '.json'];
                            DataSetInfo.C50_Json_pred_filename{ci}=[dinfo1{nn,1}.filepath_coco filesep filename_coco_s];

                            if ~exist(DataSetInfo.C50_Json_pred_filename{ci},'file')
                                filename_coco_s=[dinfo1{nn,1}.filename_image(1:end-4) '__' select_data '__' flag.result_ver flag.regp_ver '__' flag.load_cocoC50{1} '.json'];
                                DataSetInfo.C50_Json_pred_filename{ci}=[dinfo1{nn,1}.filepath_coco filesep filename_coco_s];
                            end

                            if exist(DataSetInfo.C50_Json_pred_filename{ci},'file')
                                coco_temp=CocoApi( DataSetInfo.C50_Json_pred_filename{ci});
                                C50=[{coco_temp.data.annotations.C50}]';
                                tableH=struct2table(data1{nn, 1}.(select_data).cocoP.annotations);
                                if ~istablefield(tableH,'C50')
                                    tableH=addvars(tableH,C50);
                                end
                                data1{nn, 1}.(select_data).cocoP.annotations=table2struct(tableH);
                            end
                        end
                    end
                   
                end
                % 



            end

            %% Section-4 save mask in to different formats
            for section4=1
                % for unet train with groundtruth
                if flag.save_unet>=1 %|| flag.save_matlabss~=0
                    mpara_saveUnet.filename_save=dinfo1{nn,1}.filename_image(1:end-4);
                    mpara_saveUnet.flag=flag;

                    switch flag.save_unet
                        case 1
                            if isfield(dinfo1{nn,1},'folderTag_train')==1
                                mpara_saveUnet.case_filename='index_yi_xi';
                                if isempty(strfind(dinfo1{nn,1}.folderTag_train.UnetOneCell{idd.save_unet,1},'URBG'))~=1
                                    foldername_save=folderTag2foldername(dinfo1{nn,1}.folderTag_train.UnetOneCell(idd.save_unet,:), setp.size_box2, 'test');
                                else
                                    foldername_save=folderTag2foldername(dinfo1{nn,1}.folderTag_train.UnetOneCell(idd.save_unet,:), setp.size_box2, 'train');
                                end

                                mpara_saveUnet.filepath_save=[data_path0temp foldername_save filesep];
                                switch flag.save_matlabss
                                    case 1
                                        mpara_saveUnet.filepath_save2=regexprep(mpara_saveUnet.filepath_save,'Unet','SS1');
                                        bboxG=data1{nn,1}.masks_CRBG.bbox;
                                    case 3
                                        mpara_saveUnet.filepath_save2=regexprep(mpara_saveUnet.filepath_save,'Unet','SS3');
                                        bboxG=data1{nn,1}.masks_CRBG.bbox;
                                    case 4
                                        mpara_saveUnet.filepath_save2=regexprep(mpara_saveUnet.filepath_save,'Unet','SS4');
                                    otherwise
                                        bboxG=data1{nn,1}.masks_CRBG.bbox;
                                end
                                mpara_saveUnet.case_save_mask='One_cell';mpara_saveUnet.mask_cells=data1{nn,1}.masks_CRBG.atlas_allcell_N;
                            end

                            save_mask2unet_v15(data1{nn,1}.im0gray, data1{nn,1}.im0, bboxG, setp.size_box2, mpara_saveUnet);
                        otherwise % save for transformer
                            selected_data2={'ChImJroi_DChecked_512x512__train_M','masks_CRBG','Yolo512_Unet_256x256__result__UNET_ML'};
                            save_folder={'ChImJroi_DChecked','masks_CRBG','Yolo512_Unet'};
                            mpara_saveUnet.case_filename='index_yi_xi_C5';
                            mpara_saveUnet.sext=10;
                            for ss=1:length(selected_data2)
                                if isfield(data1{nn,1},selected_data2{ss})
                                    foldername_save=folderTag2foldername(save_folder(ss), setp.size_box3, 'train');
                                    mpara_saveUnet.filepath_save=[data_path0temp foldername_save filesep];
                                    mpara_saveUnet.atlas_allcell_N=data1{nn,1}.(selected_data2{ss}).atlas_allcell_N;
                                    if isfield(data1{nn,1}.(selected_data2{ss}),'cocoP')
                                        mpara_saveUnet.table=struct2table(data1{nn,1}.(selected_data2{ss}).cocoP.annotations);
                                    end
                                    save_mask2unet_v16(data1{nn,1}.im0gray, data1{nn,1}.im0, 0, setp.size_box3, mpara_saveUnet);
                                end
                            end

                    end
                end
                % for unet test without groundtruth
                if flag.save_test_yolo2unet==1
                    for ts=1
                        clear mpara_saveUnet
                        idd.save_test_yolo2unet=ts;
                        % load yolo result
                        %flag.load_yolo=1;
                        if isfield(data1{nn,1},'CRBG_wEdge_512x512__result__YOLO_conf_50_100_M')==1 || isfield(data1{nn,1},'noGt_im_512x512__result__YOLO_conf_50_100_M')==1 
                        else
                            [data1{nn,1},foldername]=load_yolo_train_and_result_v03(data1{nn,1},flag,setp,setp.train_imsize,env.filepath01,flag.dispfig1);
                        end

                        if flag.load_yolo==1
                            if isfield(dinfo1{nn,1},'folderTag_test')==1
                                mpara_saveUnet.case_filename='index_yi_xi';
                                foldername_save=folderTag2foldername(dinfo1{nn,1}.folderTag_test.yolo2unet(ts,:), setp.size_box2, 'test');
                                mpara_saveUnet.filename_save=dinfo1{nn,1}.filename_image(1:end-4);
                                mpara_saveUnet.filepath_save=[data_path0temp foldername_save filesep];
                                %mpara_saveUnet.filepath_save=[dinfo1{nn,1}.filepath_image foldername_save filesep];
                                %mpara_saveUnet.case_save_mask='no_mask';
                                mpara_saveUnet.flag.save_unet=1;
                                mpara_saveUnet.case_save_mask='mask_from_groundtruth'; % get mask from groundtruth if exist
                                if isfield(data1{nn,1},'masks_CRBG')==1
                                    mpara_saveUnet.mask_cells=data1{nn,1}.masks_CRBG.atlas_allcell_N;
                                end
                            end
                            if isfield(data1{nn,1},[foldername.result_yolo{ts,1} '_M'])==1
                                if isempty(data1{nn,1}.([foldername.result_yolo{ts,1} '_M']).bbox)~=1
                                    boxP_yolo5=data1{nn,1}.([foldername.result_yolo{ts,1} '_M']).bbox;

                                    mpara_saveUnet.flag.save_matlabss=flag.save_matlabss;
                                    mpara_saveUnet.flag.save_train_path_case=flag.save_train_path_case;
                                    if flag.save_matlabss==1
                                        mpara_saveUnet.filepath_save2=strrep(mpara_saveUnet.filepath_save,'Unet','SS1');
                                    elseif flag.save_matlabss==3
                                        mpara_saveUnet.filepath_save2=strrep(mpara_saveUnet.filepath_save,'Unet','SS3');
                                    end
                                    save_mask2unet_v14(data1{nn,1}.im0gray, data1{nn,1}.im0, boxP_yolo5, setp.size_box2, mpara_saveUnet);
                                end
                            end
                        end
                    end
                end

            
                if flag.save_maskrcnn==1 || flag.save_imageJroi
                    mpara_save.path_style=3;
                    if mpara_save.path_style==3;im0sh='';end
                    if isfield(setp,'train_rot')==0;setp.train_rot=0;end
                    if isfield(setp,'train_flip')==0;setp.train_flip=0;end
                    mpara_save.atlas_ver=flag.atlas_ver;
                    %select_data1='masks_CRBG';%'Yolo512_Unet_256x256__result__UNET_ML'; %masks_CRBG
                    select_data1='Yolo512_Unet_256x256__result__UNET_ML';
                    for ts=1:length(setp.train_imsize)
                        for tfp=1:length(setp.train_flip)
                            if setp.train_flip(tfp)==0
                                imp0=data1{nn,1}.im0gray;
                                atlas_allcell_p0=data1{nn,1}.(select_data1).atlas_allcell_N;
                                brain_atlas0=data1{nn,1}.atlas_brain;
                                if mpara_save.path_style~=3;im0sh0=data1{nn,1}.im0;end
                                tfname='';
                            else
                                imp0=flip(data1{nn,1}.im0gray,setp.train_flip(tfp));
                                atlas_allcell_p0=flip(data1{nn,1}.(select_data1).atlas_allcell_N,setp.train_flip(tfp));
                                if mpara_save.path_style~=3;im0sh0=flip(data1{nn,1}.im0,setp.train_flip(tfp));end
                                brain_atlas0=flip(data1{nn,1}.atlas_brain,setp.train_flip(tfp));
                                tfname='F';
                            end

                            for tr=1:length(setp.train_rot)
                                if mod(setp.train_rot(tr),360)~=0

                                    imp = imrotate(imp0,setp.train_rot(tr));
                                    atlas_allcell_p = imrotate(atlas_allcell_p0,setp.train_rot(tr));
                                    if mpara_save.path_style~=3;im0sh=imrotate(im0sh0,setp.train_rot(tr));end

                                    mpara_save.brain_atlas = imrotate(brain_atlas0,setp.train_rot(tr));
                                    mpara_save.filenameRot=[tfname 'R' num2str(setp.train_rot(tr))];

                                else
                                    imp=imp0;
                                    atlas_allcell_p=atlas_allcell_p0;
                                    %im0sh=data1{nn,1}.im0;
                                    mpara_save.brain_atlas=brain_atlas0;
                                    mpara_save.filenameRot=[tfname ''];
                                end

                                Rshn=[0 fix(setp.train_imsize{ts}(2)/2) fix(setp.train_imsize{ts}(2)/2) 0];
                                Dshn=[0 fix(setp.train_imsize{ts}(1)/2) 0 fix(setp.train_imsize{ts}(1)/2)];

                                shn=1:2;
                                for sh=shn
                                    imp=circshift(imp,Dshn(sh),1);imp=circshift(imp,Rshn(sh),2);
                                    atlas_allcell_p=circshift(atlas_allcell_p,Dshn(sh),1);atlas_allcell_p=circshift(atlas_allcell_p,Rshn(sh),2);

                                    if mpara_save.path_style~=3;im0sh=circshift(im0sh,Dshn(sh),1);im0sh=circshift(im0sh,Rshn(sh),2);end

                                    mpara_save.brain_atlas=circshift(mpara_save.brain_atlas,Dshn(sh),1);mpara_save.brain_atlas=circshift(mpara_save.brain_atlas,Rshn(sh),2);
                                    mpara_save.brain_atlas_table=data1{nn,1}.atlas_table;
                                    mpara_save.filename_image=dinfo1{nn,1}.filename_image(1:end-4);
                                    mpara_save.flag_save_maskrcnn=flag.save_maskrcnn;
                                    if isempty(mpara_save.filenameRot)==1
                                        if isempty(strfind(dinfo1{nn,1}.folderTag_train.maskrcnn{1},'URBG'))~=1
                                            foldername_save=folderTag2foldername(dinfo1{nn,1}.folderTag_train.maskrcnn(sh), setp.train_imsize{ts}, 'test');
                                        else
                                            foldername_save=folderTag2foldername(dinfo1{nn,1}.folderTag_train.maskrcnn(sh), setp.train_imsize{ts}, 'train');
                                        end
                                    else
                                        foldtag1{sh}=[dinfo1{nn,1}.folderTag_train.maskrcnn{sh} mpara_save.filenameRot];
                                        foldername_save=folderTag2foldername([foldtag1(sh)], setp.train_imsize{ts}, 'train');
                                    end
                                    foldername_num=folderTag2foldername(dinfo1{nn,1}.folderTag_train.maskrcnn(sh), setp.train_imsize{ts}, 'num');

                                    switch select_data1
                                        case 'Yolo512_Unet_256x256__result__UNET_ML'
                                            foldername_save=strrep(foldername_save,'URBG','YoUnet');
                                            foldername_num=strrep(foldername_num,'URBG','YoUnet');
                                    end

                               
                                    mpara_save.filepath_maskrcnn=[data_path0temp foldername_save];
                                    mpara_save.filepath_brainatlasnum=[data_path0temp foldername_num];


                                    mpara_save.flag_save_noedge=1;mpara_save.path_style=3;% flag.save_train_path_case; % 2: yiyu, 3:new temp
                                    mpara_save.flag_save_imageJroi=flag.save_imageJroi;
                                    mpara_save.select_label=flag.save_imageLabel; %'C50';
                                    if flag.save_imageJroi==1;
                                        switch select_data1
                                            case 'Yolo512_Unet_256x256__result__UNET_ML'
                                                mpara_save.filepath_imageJroi=[data_path0temp 'imageJroi' filesep folderTag2foldername({'Yolo512_Unet_256x256__result__UNET_ML'}, setp.train_imsize{ts}, '')]
                                            otherwise
                                                if isempty(strfind(dinfo1{nn,1}.folderTag_train.maskrcnn{1},'URBG'))==1
                                                    if sh==1
                                                        mpara_save.filepath_imageJroi=[data_path0temp 'imageJroi' filesep folderTag2foldername({'CRBG_noEdge'}, setp.train_imsize{ts}, '')];
                                                    else
                                                        mpara_save.filepath_imageJroi=[data_path0temp 'imageJroi' filesep folderTag2foldername({'CRBG_noEdge_shift'}, setp.train_imsize{ts}, '')];
                                                    end
                                                else
                                                    if sh==1
                                                        mpara_save.filepath_imageJroi=[data_path0temp 'imageJroi' filesep folderTag2foldername({'URBG_noEdge'}, setp.train_imsize{ts}, '')];
                                                    else
                                                        mpara_save.filepath_imageJroi=[data_path0temp 'imageJroi' filesep folderTag2foldername({'URBG_noEdge_shift'}, setp.train_imsize{ts}, '')];
                                                    end
                                                end
                                        end
                                    end

                                    switch mpara_save.select_label
                                        case 'none'
                                            mpara_save.imJlabel=data1{nn,1}.masks_CRBG.coco.annotations;
                                            mpara_save.categories=data1{nn,1}.masks_CRBG.coco.categories;
                                            mpara_save.flag_save_noedge=1;
                                        case 'C50'
                                            mpara_save.imlabel=data1{nn,1}.(select_data1).cocoP.annotations;
                                            mpara_save.categories=data1{nn,1}.(select_data1).cocoP.categories;
                                            mpara_save.flag_save_noedge=1;  %1
                                            mpara_save.celltype=setp.type_name_C50; %
                                        otherwise
                                            %if flag.load_cocoC50Label==1
                                            %mpara_save.imJlabel=data1{nn,1}.masks_CRBG.cocoP_C50.annotations;
                                            %mpara_save.categories=data1{nn,1}.masks_CRBG.cocoP_C50.categories;
                                            %mpara_save.flag_save_noedge=1;  %1

                                            %end
                                    end
                                    mpara_save.flag_save_imageJroi=flag.save_imageJroi;
                                    mpara_save.sh=sh;
                                    %flag.save_train_path_case;
                                    [index_exitbw,index_exit_atlas]=save_trainimage_with_brainatlas_v16(imp,im0sh,atlas_allcell_p,setp.train_imsize{ts},env,mpara_save);
                                end
                            end
                        end
                    end
                end


                % for maskrcnn in 512x512 & yolo
                if flag.save_test_maskrcnn>=1
                    Rshn=[0 fix(setp.train_imsize{ts}(2)/2) fix(setp.train_imsize{ts}(2)/2) 0];
                    Dshn=[0 fix(setp.train_imsize{ts}(1)/2) 0 fix(setp.train_imsize{ts}(1)/2)];
                    if size(data1{nn,1}.im0gray,1)<=setp.train_imsize{ts}(1) && size(data1{nn,1}.im0gray,2)<=setp.train_imsize{ts}(2)
                        shn=1;
                    else
                        shn=1:2;
                    end
                    for sh=shn
                        mpara_test.filename_maskrcnn=dinfo1{nn,1}.filename_image(1:end-4);
                        mpara_test.flag.save_maskrcnn=flag.save_test_maskrcnn;
                        %foldername_save=folderTag2foldername(foldername.train_manual{ts, sh}{ch}, setp.train_imsize{1}, 'train');
                        foldername_save=folderTag2foldername(dinfo1{nn,1}.folderTag_test.maskrcnn(sh), setp.train_imsize{ts}, 'test');
                        mpara_test.filepath_maskrcnn=[data_path0temp foldername_save];
                        foldername_num =folderTag2foldername(dinfo1{nn,1}.folderTag_test.maskrcnn(sh), setp.train_imsize{ts}, 'num');
                        mpara_test.filepath_brainatlasnum=[data_path0temp foldername_num];
                        mpara_test.save_train_path_case=flag.save_train_path_case;  % 2 => for yiyu, 2
                        if ~exist([mpara_test.filepath_brainatlasnum '.zip'],'file')
                            imp=data1{nn,1}.im0gray;      %.*uint8(bwbrain);  %bwbrain=logical(abs(data1{nn,1}.imbackground));
                            imp=circshift(imp,Dshn(sh),1);imp=circshift(imp,Rshn(sh),2);
                            im0sh=circshift(data1{nn,1}.im0,Dshn(sh),1);im0sh=circshift(im0sh,Rshn(sh),2);
                            atlas_brain_sh=circshift(data1{nn,1}.atlas_brain,Dshn(sh),1);atlas_brain_sh=circshift(atlas_brain_sh,Rshn(sh),2);
                            mpara_test.brain_atlas_table=data1{nn,1}.atlas_table;
                            mpara_test.brain_atlas=atlas_brain_sh;
                            [index_exit_atlas]=save_testimage_with_brainatlas_v15(imp,im0sh,setp.train_imsize{ts},mpara_test);
                        end
                    end
                end
                % for maskrcnn in 512x512 & yolo
                if flag.save_imageJroi256s==1
                    select_data1={'Yolo512_Unet_256x256__result__UNET_ML', 'masks_CRBG','ChImJroi_DChecked_512x512__train_M'};%'masks_CRBG';
                    rbox=[256, 256]; %x y
                    for sd=1:3
                        if isfield(data1{nn,1},select_data1{sd})
                            javaaddpath([env.path_imageJ 'ij-1.53c.jar']) %'E:\MATLAB\R2020b\java\jar\mij.jar';
                            javaaddpath([env.path_imageJ 'mij.jar'])
                            macro_path=[env.path_imageJ 'macros' filesep];
                            Miji;

                            bbox=reshape([data1{nn, 1}.(select_data1{sd}).cocoP.annotations(:).bbox],4,length([data1{nn, 1}.(select_data1{sd}).cocoP.annotations.id]))';
                            for dd=1:size(bbox,1)
                                dbox=bbox(dd,:);
                                dbox=[fix(bbox(dd,1)+bbox(dd,3)/2-rbox(1)/2),fix(bbox(dd,2)+bbox(dd,4)/2-rbox(2)/2),rbox(1),rbox(2)];
                                im1=data1{nn,1}.im0gray(dbox(2):dbox(2)+dbox(4)-1,dbox(1):dbox(1)+dbox(3)-1);
                                bw1=data1{nn,1}.(select_data1{sd}).atlas_allcell_N(dbox(2):dbox(2)+dbox(4)-1,dbox(1):dbox(1)+dbox(3)-1);
                                label1=data1{nn, 1}.(select_data1{sd}).cocoP.annotations(dd).C50;
                                id1=fix(data1{nn, 1}.(select_data1{sd}).cocoP.annotations(dd).id_masknii);

                                path_imageJ=[data_path0temp 'imageJroi' filesep select_data1{sd} filesep label1];
                                if ~isfolder(path_imageJ);mkdir(path_imageJ);end
                                filename_ims=[data1{nn,1}.info.filename_image(1:end-4) '_id' num2str(id1) '_y' num2str(dbox(2)) '_x' num2str(dbox(1))];
                                imwrite(im1,[path_imageJ filesep filename_ims '.jpg'])

                                bw2=bw1;
                                bw2(bw2~=id1)=0;
                                bw2(bw2==id1)=1;

                                [bw2e]=BW_Edge_Modified_v09(bw2, -1, 'y');
                                bw2e(bw2e==1)=255;  bw2e=uint8(bw2e);
                                MIJ.run("ROI Manager...");
                                pause(0.02);
                                MIJ.createImage(bw2e);     pause(0.02);
                                MIJ.run("Create Selection");
                                pause(0.02);
                                MIJ.run("Add to Manager");
                                args0=strcat('roi_name=',[data1{nn,1}.info.filename_image(1:end-4) '_id' num2str(id1) '_'  label1],' roi_select=','0');
                                ij.IJ.runMacroFile(java.lang.String(fullfile(macro_path,'rename_roi__001.ijm')),java.lang.String(args0));
                                MIJ.selectWindow("Import from Matlab");
                                pause(0.02);
                                MIJ.run("Close");
                                pause(0.02);

                                save_path_roi=[path_imageJ filesep filename_ims '.zip'];
                                args=strcat(save_path_roi);
                                ij.IJ.runMacroFile(java.lang.String(fullfile(macro_path,'save_roi__001.ijm')),java.lang.String(args));
                                pause(0.1);
                                MIJ.selectWindow("ROI Manager");
                                pause(0.1);
                                MIJ.run("Close");
                                pause(0.1);

                            end
                            MIJ.closeAllWindows; % Close all MIJ windows
                            %MIJ.exit; % Exit MIJ
                        end
                    end
                end
            end

            %% varargout{1}
            if nargout>1
                for nno=1:nargout-1;
                    %if isfield(data1{nn, 1},flag.optable{nno})==1
                    filename_cocoN=[data1{nn,1}.info.filename_image(1:end-4) '__' flag.optable{nargout-1} '__' flag.result_ver flag.regp_verN '.json'];
                    filename_coco_C50=[dinfo1{nn,1}.filename_image(1:end-4) '__' flag.optable{nargout-1} '__' flag.result_ver flag.regp_verC50{1} '__' flag.load_cocoC50{1} '.json'];

                    if exist([data1{nn,1}.info.filepath_coco filesep filename_cocoN],'file')
                        coco_temp=CocoApi([data1{nn,1}.info.filepath_coco filesep filename_cocoN]);
                        cocostruct=cocoFilePathChange(coco_temp.data, [env.filepath01 data1{nn,1}.info.filename_image(1:3) filesep], data1{nn,1}.info.filename_image(1:end-4));
                        if flag.Low_res==-1
                            if flag.category_update>0;options.case='atlas'; options.Low_res=flag.Low_res;
                                cocostruct=coco_category_update_v02(cocostruct,data1{nn,1},options);end
                        end

                        table0=struct2table(cocostruct.annotations);
                        atq=unique(table0.category_id2_name);

                        if length(intersect(data1{nn,1}.atlas_table.atlas_name,atq))~=length(atq)
                            if flag.category_update>0;options.case='atlas'; options.Low_res=flag.Low_res;
                                cocostruct=coco_category_update_v02(cocostruct,data1{nn,1},options);end
                        end
                        table0=struct2table(cocostruct.annotations);
                        if flag.update_atlas>0 && flag.Low_res==-1
                            coco_temp.data.annotations=table2struct(table0)';
                            cocostring=gason(coco_temp.data);
                            fid = fopen([data1{nn,1}.info.filepath_coco filesep filename_cocoN], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                        end
                        clear cocostring coco_temp cocostruct

                        %% fix bug: get yolo score from old json file and and save coco json file again
                        if istablefield(table0,'score')~=1
                            filepath_coco_oldzip=['I:\IHC_json_mat_backup_old_cell_center_cditance\' data1{nn, 1}.info.filename_image(1:3) filesep data1{nn, 1}.info.filename_image(1:end-4) filesep 'cocoJson.zip'];
                            filepath_coco_old=['I:\IHC_json_mat_backup_old_cell_center_cditance\' data1{nn, 1}.info.filename_image(1:3) filesep data1{nn, 1}.info.filename_image(1:end-4) filesep];
                            unzip([filepath_coco_oldzip],filepath_coco_old);

                            filename_coco_old=[filepath_coco_old filesep 'cocoJson\' data1{nn,1}.info.filename_image(1:end-4) '__' flag.optable{nargout-1} '__' flag.result_ver flag.regp_verN '.json'];
                            coco_temp_old=CocoApi([filename_coco_old]);
                            table0_old=struct2table(coco_temp_old.data.annotations);
                            try
                                score=[table0_old.score];
                            catch
                                xxx
                            end
                            table0=addvars(table0,score,'before','image_id');
                            if istablefield(table0,'C50')==1;table0= removevars(table0,{'C50'});end
                            if istablefield(table0,'C50_1')==1;table0= removevars(table0,{'C50_1'});end
                            if istablefield(table0,'C50_2')==1;table0= removevars(table0,{'C50_2'});end
                            if istablefield(table0,'C50_3')==1;table0= removevars(table0,{'C50_3'});end
                            if istablefield(table0,'C50_4')==1;table0= removevars(table0,{'C50_4'});end
                            if istablefield(table0,'C50_5')==1;table0= removevars(table0,{'C50_5'});end
                            coco_temp.data.annotations=table2struct(table0)';
                            %filename_cocoN2=[data1{nn,1}.info.filename_image(1:end-4) '__' flag.optable{nargout-1} '__' flag.result_ver flag.regp_verN '2.json'];
                            %coco_temp2=CocoApi([data1{nn,1}.info.filepath_coco filesep filename_cocoN2]);

                            cocostring=gason(coco_temp.data);
                            fid = fopen([data1{nn,1}.info.filepath_coco filesep filename_cocoN], 'w');if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                            clear cocostring coco_temp
                        end



                        if flag.reduce_table==1
                            table0=table0(:,{'score','image_id','bbox','id_masknii','category_id2_name','CA','CP','CHA','CHSR','FM_BREN_bbox1p2'});
                        end
                        if exist([data1{nn,1}.info.filepath_coco filesep filename_coco_C50],'file')
                            coco_temp_C50=CocoApi([data1{nn,1}.info.filepath_coco filesep filename_coco_C50]);
                            c50i={coco_temp_C50.data.annotations.C50}';
                            sn1 = strfind(c50i,'__');if isempty(sn1{1})~=1;C50=cellfun(@(c,n)c(n+2:end),c50i,sn1,'uni',false);else;C50=c50i;end
                            table0 = addvars(table0,C50);
                            clear coco_temp_C50
                        end
                        sampleID=repmat(DataSetInfo.sample_ID(si),size(table0,1),1);
                        try
                            exp_cond1=repmat(dinfo1{nn,1}.exp_condition(1),size(table0,1),1);
                        catch
                            exp_cond1=repmat('unknow',size(table0,1),1);
                        end
                        filename=repmat({dinfo1{nn,1}.filename_image},size(table0,1),1);
                        table0=addvars(table0,filename,'before','image_id');
                        sn1=findstr(dinfo1{nn,1}.filename_image,'slide');
                        sn2=findstr(dinfo1{nn,1}.filename_image,'.');
                        numx=str2num(dinfo1{nn,1}.filename_image(sn1+5:sn2-1));
                        if numx <10
                            filenameS0=[dinfo1{nn,1}.filename_image(1:sn1+5) '00' num2str(numx)];
                        elseif numx <100 && numx>=10
                            filenameS0=[dinfo1{nn,1}.filename_image(1:sn1+5) '0' num2str(numx)];
                        else
                            filenameS0=dinfo1{nn,1}.filename_image(1:end-4);
                        end
                        filenameS=repmat({filenameS0},size(table0,1),1);
                        table0=addvars(table0,filenameS,'after','filename');

                        table0=xlstablenameConvert(table0);

                        % eval(['table' num2str(nno) '=table0;']);clear table0 filenameS;

                        if nn==1
                            %eval(['varargout{' num2str(nno) '}=table' num2str(nno) ';']);
                            varargout{nno}=[table0];
                            tablenames0{nno}=varargout{nno}.Properties.VariableNames;
                        else
                            tablenames{nno}=table0.Properties.VariableNames;

                            %eval(['tablenames{nno}=table' num2str(nno) '.Properties.VariableNames;']);
                            [~,ia,ib]=intersect(tablenames0{nno},tablenames{nno});
                            table1=table0(:,ib);
                            try
                                varargout{nno}=[varargout{nno};table1];
                            catch
                                xxx=1
                            end
                            %eval(['varargout{' num2str(nno) '}=[varargout{' num2str(nno) '};table' num2str(nno) '];'])
                        end
                        clear table0 table1
                    else
                        varargout{nno}='';
                    end
                   




                end
            end

       

            %% Section-B1
            %1 move to the folder for web_server in \....\results

            for SectionB1=1
                %if flag.Low_res~=-1
                
                filepath_result0=[dinfo1{nn,1}.filepath_image 'results' filesep];
                if ~isfolder([filepath_result0 'images' filesep]);mkdir([filepath_result0 'images' filesep]);end
                if ~isfolder([filepath_result0 'table' filesep]);mkdir([filepath_result0 'table' filesep]);end

                if flag.update_results==1
                    delete([filepath_result0 'images' filesep '*.*']);
                    delete([filepath_result0 'masks' filesep '*.*']);
                    delete([filepath_result0 'table' filesep '*.*']);
                    delete([filepath_result0 'Mmaps' filesep '*.*']);
                end
                if isempty(varargout)~=1
                    flag.load_data=1;
                end
                if ~isfield(data1{nn,1}.info,'imOrig_size')
                    imOrig=imread([data1{nn,1}.info.filepath_image data1{nn,1}.info.filename_image]);
                    data1{nn, 1}.info.imOrig_size=size(imOrig);
                end
                if flag.load_data==1 && flag.Low_res==-1 
                    if flag.imzp==1
                        size_zpe=setp.size_zpe;
                        if flag.Low_res==-1;
                            imsize_orig=data1{nn,1}.info.imOrig_size;
                        end
                    else
                        if flag.Low_res==-1;
                            size_zpe=[0,0];imsize_orig=size(data1{nn,1}.im0);
                        end
                    end

                    if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '.jpg'],'file')
                        if data1{nn,1}.info.pixel_size==0.464
                            if flag.imzp==1
                                imt0=data1{nn,1}.im0(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+imsize_orig(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+imsize_orig(2),:);
                            else
                                imt0=data1{nn,1}.im0;
                            end
                        else
                            imt0=data1{nn,1}.im0orig;
                        end
                        if flag.save_imsplit~=0
                            imwriteSplit(imt0,[filepath_result0 'images' filesep imsavefilename(1:end-4) '.jpg'],flag.save_imsplit);
                        else
                            imwrite(imt0,[filepath_result0 'images' filesep imsavefilename(1:end-4) '.jpg']);
                        end
                    end

                    if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '_gray.jpg'],'file');
                        if data1{nn,1}.info.pixel_size==0.464
                            if flag.imzp==1
                                imt0=data1{nn,1}.im0gray(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+imsize_orig(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+imsize_orig(2),:);
                            else
                                imt0=data1{nn,1}.im0gray;
                            end
                        else
                            imt0=data1{nn,1}.im0gray_orig;
                        end
                        if flag.save_imsplit~=0
                            imwriteSplit(imt0,[filepath_result0 'images' filesep imsavefilename(1:end-4) '_gray.jpg'],flag.save_imsplit);
                        else
                            imwrite(imt0,[filepath_result0 'images' filesep imsavefilename(1:end-4) '_gray.jpg']);
                        end

                    end
                    if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '_grayM.jpg'],'file');
                        cmap=[1,0,0];%parula(max(bwtemp(:)));
                        if flag.save_imsplit~=0
                            imF1 = labeloverlaySplit(flag.save_imsplit,data1{nn,1}.im0gray,data1{nn,1}.imbackground,'Colormap',cmap,'Transparency',0.85);
                        else
                            imF1 = labeloverlay(data1{nn,1}.im0gray,data1{nn,1}.imbackground,'Colormap',cmap,'Transparency',0.85);
                        end

                        if flag.imzp==1
                            imF1=imF1(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1{nn,1}.im0gray,1)-size_zpe(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1{nn,1}.im0gray,2)-size_zpe(2),:);
                        end

                        if data1{nn,1}.info.pixel_size~=0.464
                            imF1=imresize(imF1,size(data1{nn,1}.im0gray_orig));
                        end

                        if flag.save_imsplit~=0
                            imwriteSplit(imF1,[filepath_result0 'images' filesep imsavefilename(1:end-4) '_grayM.jpg'],flag.save_imsplit);
                        else
                            imwrite(imF1,[filepath_result0 'images' filesep imsavefilename(1:end-4) '_grayM.jpg']);
                        end
                      
                    end


                    if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '__L10x.jpg'],'file');
                        %if data1{nn,1}.info.pixel_size==0.464
                        im0L=imresize(data1{nn,1}.im0,[size(data1{nn,1}.im0,[1,2])]/10,'Method','bilinear');
                        %else
                        %    im0L=imresize(data1{nn,1}.im0orig,[imsize0(1) imsize0(2)]/10,'Method','bilinear');
                        %end
                        imwrite(im0L,[filepath_result0 'images' filesep imsavefilename(1:end-4) '__L10x.jpg']);
                    end
                    if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '__L20x.jpg'],'file');
                        %if data1{nn,1}.info.pixel_size==0.464
                        im0L=imresize(data1{nn,1}.im0,[size(data1{nn,1}.im0,[1,2])]/20,'Method','bilinear');
                        %else
                        %    im0L=imresize(data1{nn,1}.im0orig,[imsize0(1) imsize0(2)]/20,'Method','bilinear');
                        %end
                        imwrite(im0L,[filepath_result0 'images' filesep imsavefilename(1:end-4) '__L20x.jpg']);
                    end
                    if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '__L10.jpg'],'file');
                        imt0=data1{nn,1}.im0(ceil(size_zpe(1)/2)+1:size(data1{nn,1}.im0,1)-ceil(size_zpe(1)/2),ceil(size_zpe(2)/2)+1:size(data1{nn,1}.im0,2)-ceil(size_zpe(2)/2),:);
                        if data1{nn,1}.info.pixel_size~=0.464
                            imt0=imresize(imt0,size(data1{nn,1}.im0gray_orig));
                        end
                        im0L=imresize(imt0,size(imt0,[1,2])/10,'Method','bilinear');
                        imwrite(im0L,[filepath_result0 'images' filesep imsavefilename(1:end-4) '__L10.jpg']);
                    end
                    if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '__L20.jpg'],'file');
                        imt0=data1{nn,1}.im0(ceil(size_zpe(1)/2)+1:size(data1{nn,1}.im0,1)-ceil(size_zpe(1)/2),ceil(size_zpe(2)/2)+1:size(data1{nn,1}.im0,2)-ceil(size_zpe(2)/2),:);
                        if data1{nn,1}.info.pixel_size~=0.464
                            imt0=imresize(imt0,size(data1{nn,1}.im0gray_orig));
                        end
                        im0L=imresize(imt0,size(imt0,[1,2])/20,'Method','bilinear');
                        imwrite(im0L,[filepath_result0 'images' filesep imsavefilename(1:end-4) '__L20.jpg']);
                    end

                    if isfield(data1{nn,1},'masks_CRBG')==1
                        if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '_GT.jpg'],'file')
                            cell_atlasL=getAtlasEdge(data1{nn,1}.masks_CRBG.atlas_allcell_N,1);
                            cmap0=jet(double(max(cell_atlasL(:))));cmap1=cmap0(randperm(size(cmap0,1)),:);
                            
                            if flag.save_imsplit~=0
                                imFs = labeloverlaySplit(flag.save_imsplit,data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                            else
                                imFs = labeloverlay(data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                            end

                            imFs=imFs(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+imsize_orig(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+imsize_orig(2),:);
                            if flag.imzp==1
                                imFs=imFs(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(imFs,1)-size_zpe(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(imFs,2)-size_zpe(2),:);
                            end
                            if data1{nn,1}.info.pixel_size~=0.464
                                imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                            end
                            if flag.save_imsplit~=0
                                imwriteSplit(uint8(imFs), [filepath_result0 'images' filesep imsavefilename(1:end-4) '_GT.jpg'],flag.save_imsplit);
                            else
                                imwrite(uint8(imFs), [filepath_result0 'images' filesep imsavefilename(1:end-4) '_GT.jpg']);
                            end

                            clear cell_atlasL imFs cmap0 cmap1;
                        end
                    end

                    if isfield(data1{nn,1},[foldername.result_yolo{1} '_M' ])
                        if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '_yolo.jpg'],'file')
                            Ybbox=data1{1, 1}.([foldername.result_yolo{1} '_M' ]).bbox;
                            cmap0=jet(size(Ybbox,1));s=rng(0,'twister');cmap1=cmap0(randperm(size(Ybbox,1)),:);
                            if flag.save_imsplit~=0
                                imFs = insertShapeSplit(flag.save_imsplit,data1{nn,1}.im0gray, 'Rectangle', Ybbox,'Color', 255*cmap1,'LineWidth',4);
                            else
                                imFs = insertShape(data1{nn,1}.im0gray, 'Rectangle', Ybbox,'Color', 255*cmap1,'LineWidth',4);
                            end
                            %imFs=imFs(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+imsize_orig(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+imsize_orig(2),:);
                            if flag.imzp==1
                                imFs=imFs(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(imFs,1)-size_zpe(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(imFs,2)-size_zpe(2),:);
                            end
                            if data1{nn,1}.info.pixel_size~=0.464
                                imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                            end
                            if flag.save_imsplit~=0
                                imwriteSplit(uint8(imFs), [filepath_result0 'images' filesep imsavefilename(1:end-4) '_yolo.jpg'],flag.save_imsplit);
                            else
                                imwrite(uint8(imFs), [filepath_result0 'images' filesep imsavefilename(1:end-4) '_yolo.jpg']);
                            end

                            clear imFs cmap0 cmap1 Ybbox;
                        end
                    end
                    if isfield(data1{nn,1},[foldername.result_UnetOneCell_M{end}])
                        if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '_unet.jpg'],'file')
                            cell_atlasL=getAtlasEdge(data1{nn,1}.(foldername.result_UnetOneCell_M{1}).atlas_allcell_N,1);
                            cmap0=jet(double(max(cell_atlasL(:))));s=rng(0,'twister');cmap1=cmap0(randperm(size(cmap0,1)),:);

                            if flag.save_imsplit~=0
                                imFs = labeloverlaySplit(flag.save_imsplit,data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                            else
                                imFs = labeloverlay(data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                            end
                            %imFs=imFs(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+imsize_orig(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+imsize_orig(2),:);
                            if flag.imzp==1
                                imFs=imFs(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(imFs,1)-size_zpe(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(imFs,2)-size_zpe(2),:);
                            end

                            if data1{nn,1}.info.pixel_size~=0.464
                                imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                            end
                            if flag.save_imsplit~=0
                                imwriteSplit(uint8(imFs), [filepath_result0 'images' filesep imsavefilename(1:end-4) '_unet.jpg'],flag.save_imsplit);
                            else
                                imwrite(uint8(imFs), [filepath_result0 'images' filesep imsavefilename(1:end-4) '_unet.jpg']);
                            end

                            clear cell_atlasL imFs cmap0 cmap1;
                        end
                        if isfield(data1{nn,1}.(foldername.result_UnetOneCell_M{1}),'atlas_allcellcore_N')
                            if ~exist([filepath_result0 'images' filesep imsavefilename(1:end-4) '_CellCore.jpg'],'file')

                                cell_atlasL=getAtlasEdge(data1{nn,1}.(foldername.result_UnetOneCell_M{1}).atlas_allcellcore_N,1);
                                cmap0=jet(double(max(cell_atlasL(:))));s=rng(0,'twister');cmap1=cmap0(randperm(size(cmap0,1)),:);

                                if flag.save_imsplit~=0
                                    imFs = labeloverlaySplit(flag.save_imsplit,data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                                else
                                    imFs = labeloverlay(data1{nn,1}.im0gray, cell_atlasL,'Colormap',cmap1,'Transparency',0); clear cell_atlasL;
                                end
                                %imFs=imFs(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+imsize_orig(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+imsize_orig(2),:);
                                if flag.imzp==1
                                    imFs=imFs(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(imFs,1)-size_zpe(1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(imFs,2)-size_zpe(2),:);
                                end

                                if data1{nn,1}.info.pixel_size~=0.464
                                    imFs=imresize(imFs,size(data1{nn,1}.im0gray_orig));
                                end
                                if flag.save_imsplit~=0
                                    imwriteSplit(uint8(imFs), [filepath_result0 'images' filesep imsavefilename(1:end-4) '_CellCore.jpg'],flag.save_imsplit);
                                else
                                    imwrite(uint8(imFs), [filepath_result0 'images' filesep imsavefilename(1:end-4) '_CellCore.jpg']);
                                end

                                clear cell_atlasL imFs cmap0 cmap1;
                            end
                        end
                    end

                    % save xls tables
                    filepathG_temp=[filepath_result0 'table' filesep];if ~exist(filepathG_temp,'dir');mkdir(filepathG_temp);end
                    if isempty(flag.load_cocoC50{1})~=1
                        select_data0={[foldername.result_UnetOneCell_M{end}],'masks_CRBG'};
                        for sa=1:length(select_data0)
                            if isfield(data1{nn,1},select_data0{sa})
                                if isfield(data1{nn,1}.(select_data0{sa}),'cocoP')==1
                                    %save_file=[dinfo1{nn,1}.filename_image(1:end-4) '__' select_data0{sa} '__' flag.result_ver flag.regp_ver '__C50_at' flag.atlas_ver '.json'];
                                    save_file=[imsavefilename(1:end-4) '__YUC50_' flag.regp_ver '.json'];
                                    cocotemp=data1{nn,1}.(select_data0{sa}).cocoP;
                                    table_00=struct2table(data1{nn,1}.(select_data0{sa}).cocoP.annotations);
                                    if istablefield(table_00,'score')==0;
                                        score=ones(size(table_00,1),1);
                                        table_00=addvars(table_00,score,'before','image_id');
                                    end
                                    [table_01]=tableResChang(table_00,size_zpe,data1{nn,1}.info.pixel_size,flag);
                                    if data1{nn,1}.info.pixel_size~=0.464
                                        cocotemp.info.Brain_Area=cocotemp.info.Brain_Area*(0.464/data1{nn,1}.info.pixel_size).^2;
                                    end
                                    cocotemp.annotations=table2struct(table_00);
                         
                                    if isfield(DataSetInfo,'UserID')==0;DataSetInfo.UserID='unknow';end
                                    table_info{1,1}='User:';table_info{1,2}=DataSetInfo.UserID;

                                    table_info{2,1}='Filename:';
                                    if isfield(data1{nn, 1}.info,'filename_orig');table_info{2,2}=data1{nn, 1}.info.filename_orig;
                                    else;table_info{2,2}=data1{nn, 1}.info.filename_image;end
                                    table_info{3,1}='Filename_temp:';table_info{3,2}=data1{nn, 1}.info.filename_image;

                                    table_info{4,1}='Slice thickness (um):';table_info{4,2}=data1{nn, 1}.info.thk*1000;
                                    table_info{5,1}='pixel size (um):';table_info{5,2}=data1{nn, 1}.info.pixel_size;
                                    table_info{6,1}='image size:';table_info{6,2}=mat2str(data1{nn, 1}.info.imOrig_size);
                                    table_info{7,1}='adjzp image size:';table_info{7,2}=mat2str(size(data1{nn, 1}.im0));
                                    table_info{8,1}='zp pixels:';table_info{8,2}=mat2str(setp.size_zpe);

                                    table_info{9,1}='species:';if isfield(data1{nn, 1}.info,'species');table_info{9,2}=data1{nn, 1}.info.species;else;table_info{9,2}='';end
                                    table_info{10,1}='anatomy:';if isfield(data1{nn, 1}.info,'anatomy');table_info{10,2}=data1{nn, 1}.info.species;else;table_info{10,2}='';end
                                    table_info{11,1}='treatment:';if isfield(data1{nn, 1}.info,'treatment');table_info{11,2}=data1{nn, 1}.info.species;else;table_info{11,2}='';end
                                    table_info{12,1}='image preprocessing fun:';table_info{12,2}=flag.imadj_function;
                                    table_info{13,1}='others:';if isfield(data1{nn, 1}.info,'others');table_info{13,2}=data1{nn, 1}.info.species;else;table_info{13,2}='';end

                               
                                    save_file=[imsavefilename(1:end-4) '__YUC50_' flag.regp_ver '.xls'];
                                    [table_01,table_info]=xlstablenameConvert(table_01,table_info);

                                    if flag.save_imsplit==0
                                         writetableSplit(1,imsize_orig,table_01,table_info,[filepathG_temp save_file],'WriteMode','overwritesheet','Sheet','Sheet1');

                                    else
                                       % imsize_orig=data1{nn,1}.info.imOrig_size
                                        writetableSplit(flag.save_imsplit,imsize_orig,table_01,table_info,[filepathG_temp save_file],'WriteMode','overwritesheet','Sheet','Sheet1');
                                    end



                                end
                            end
                        end
                    end
                end
                % save brain_atlas
                filepathG_temp=[dinfo1{nn,1}.filepath_image 'results' filesep 'brain_atlas' filesep];
                
                if flag.Low_res~=-1
                    if data1{nn,1}.info.load_atlas_nii==1 || flag.update_atlas~=0
                        if ~exist(filepathG_temp,'dir');mkdir(filepathG_temp);end
                        filemat_brainatlas=[filepathG_temp imsavefilename(1:end-4) '_brain_atlas_' flag.atlas_ver '.mat'];
                        fileNii_brainatlas=[filepathG_temp imsavefilename(1:end-4) '__L20_brain_atlas_' flag.atlas_ver '.nii'];
                        fileXls_brainatlas=[filepathG_temp imsavefilename(1:end-4) '_brain_atlas_' flag.atlas_ver '.xls'];
                        if ~exist(filemat_brainatlas,'file')
                            atlas_brain=data1{nn,1}.atlas_brain;atlas_table=data1{nn,1}.atlas_table;
                            save(filemat_brainatlas,'atlas_brain','atlas_table','-v7.3');clear atlas_brain atlas_table

                            atlas_brainLow=imresize3D(data1{nn,1}.atlas_brain,size(data1{nn,1}.atlas_brain)/20,'atlas');
                            nii = make_nii(flip(rot90(atlas_brainLow)));save_nii(nii,fileNii_brainatlas);
                            writetable(data1{nn,1}.atlas_table,fileXls_brainatlas);
                            if exist([dinfo1{nn,1}.filepath_image filesep 'brain_atlas' filesep dinfo1{nn,1}.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver '.jpg'],'file')
                                copyfile([dinfo1{nn,1}.filepath_image filesep 'brain_atlas' filesep dinfo1{nn,1}.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver '.jpg'],...
                                    [filepathG_temp filesep dinfo1{nn,1}.filename_image(1:end-4) '_brain_atlas_' flag.atlas_ver '.jpg']);
                            end
                        end
                    end
                end
            end
            %% section-B2 for exchange data between computers - not use, move to zip_to_move
            for SectionB2=1
                if flag.Low_res~=-1
                    if flag.data2exchange==1
                        % copy update for exchange data between PC
                        filepath_result_imagesN2=regexprep(dinfo1{nn,1}.filepath_image,folder_result00,flag.ex_folder_result02);

                        if ~exist(filepath_result_imagesN2,'dir');mkdir(filepath_result_imagesN2);end
                        % copy cocoJson
                        filepath_source0=[dinfo1{nn,1}.filepath_image 'cocoJson' filesep];
                        files_in_source=dir(filepath_source0);files_in_source=files_in_source(~ismember({files_in_source.name},{'.','..'}));files_in_source={files_in_source.name}';
                        keyW1={'regp11s'};keyN1={''};[~,file_temp]=getkeyword(files_in_source,keyW1,keyN1);
                        filepath_cocoN2=[filepath_result_imagesN2 'cocoJson' filesep];
                        if ~exist(filepath_cocoN2,'dir');mkdir(filepath_cocoN2);end
                        for kk=1:length(file_temp)
                            if ~exist([filepath_cocoN2 file_temp{kk}],'file');copyfile([filepath_source0 file_temp{kk}],[filepath_cocoN2 file_temp{kk}]);end
                        end

                        % copy mat_temp
                        filepath_source0=[dinfo1{nn,1}.filepath_image 'mat_temp' filesep];
                        files_in_source=dir(filepath_source0);files_in_source=files_in_source(~ismember({files_in_source.name},{'.','..'}));files_in_source={files_in_source.name}';
                        keyW1={'regp11s'};keyN1={''};[~,file_temp]=getkeyword(files_in_source,keyW1,keyN1);
                        filepath_mat=[filepath_result_imagesN2 'mat_temp' filesep];

                        for kk=1:length(file_temp)
                            if ~exist([filepath_cocoN2 file_temp{kk}],'file');copyfile([filepath_source0 file_temp{kk}],[filepath_mat file_temp{kk}]);end
                        end
                        % copy atlas
                        filepath_source0=[dinfo1{nn,1}.filepath_image 'brain_atlas' filesep];
                        files_in_source=dir(filepath_source0);files_in_source=files_in_source(~ismember({files_in_source.name},{'.','..'}));files_in_source={files_in_source.name}';
                        keyW1={''};keyN1={''};[~,file_temp]=getkeyword(files_in_source,keyW1,keyN1);
                        filepath_brain_atlas=[filepath_result_imagesN2 'brain_atlas' filesep];
                        if ~exist(filepath_brain_atlas,'dir');mkdir(filepath_brain_atlas);end
                        for kk=1:length(file_temp)
                            if exist([filepath_source0 file_temp{kk}],'file')
                                if ~exist([filepath_brain_atlas file_temp{kk}],'file');copyfile([filepath_source0 file_temp{kk}],[filepath_brain_atlas file_temp{kk}]);end
                            end
                        end

                    end
                end
            end
            %% Section B3 copy data for web_server, old version code in Main_data_preparation__v84mg_results_update SectionA2 - not use, move to zip_to_move
            for SectionB3=1
                if flag.data2webserver==1
                    %filepath_result_images0=[dinfo1{nn,1}.filepath_image];
                    flag.web_folder_result01='I:\DLweb_v2\'; %'DLresults_v2';
                    folder_result00=DataSetInfo.file_path0;
                    filepath_web=regexprep(dinfo1{nn,1}.filepath_image,folder_result00,folder_result01); % new folder, same in web-server
                    if ~exist(filepath_web,'dir');mkdir(filepath_web);end
                    if exist([dinfo1{nn,1}.filepath_image dinfo1{nn,1}.filename_image],'file');if ~exist([filepath_web dinfo1{nn,1}.filename_image],'file');copyfile([dinfo1{nn,1}.filepath_image dinfo1{nn,1}.filename_image],[filepath_web dinfo1{nn,1}.filename_image]);end;end
                    filepath_web_images=[filepath_web 'results' filesep];
                    copyfile([dinfo1{nn,1}.filepath_image 'results'],filepath_web_images);
                end
            end

            %% section-B4 copy selected cocofile to the output dir into zip file
            for SectionB4=1
                if flag.data2zip==1
                    path_result01=[DataSetInfo.file_path_opt  DataSetInfo.UserID filesep DataSetInfo.project_name filesep DataSetInfo.type_of_image filesep 'cocoJson__V04regp11s' filesep];
                    if ~exist(path_result01,'dir');mkdir(path_result01);end
                    select_data0={'ChImJroi_DChecked_512x512__train_M','ArStImJroi_20210812_512x512__train_M','Yolo512_Unet_256x256__result__UNET_ML','CRBG_UnetOneCell_256x256__result__UNET_ML','masks_CRBG'};

         
                    rmovefield={'ROI_name','category_id2_name','category_id1','category_id1_name','category_id2','category_id3','category_id4','category_id4_name','N_segmentation','N_bbox','NC','NC_cdist','NC_cdist2MaxSACHr',...
                        'N_MeanIntensity','N_StdIntensity','MeanIntensity','MinIntensity','MaxIntensity','StdIntensity','MedianIntensity','FM_BREN_bbox1p2','distC_median','distC_N','distC_median','distE_median','distC_mean',...
                        'distC_slr','distE_mean','distE_std','distE_slr','distC_std'};
                    for ns=1:length(select_data0)
                        clear cocotemp tableds category_id3_name

                        filename_coco=[dinfo1{nn,1}.filename_image(1:end-4) '__' select_data0{ns} '__' flag.result_ver flag.result_ver '.json'];
                        filename_cocoS=[dinfo1{nn,1}.filename_image(1:end-4) '__' select_data0{ns} '__' flag.result_ver flag.result_ver 's.json'];
                        if exist([dinfo1{nn,1}.filepath_coco filesep filename_coco],'file')
                            cocotemp=CocoApi([dinfo1{nn,1}.filepath_coco filesep filename_coco]);
                            anntable=struct2table(cocotemp.data.annotations);
                            for rr=1:length(rmovefield)
                                en=find(strcmp(anntable.Properties.VariableNames,rmovefield{rr})==1);
                                if isempty(en)~=1
                                    anntable = removevars(anntable,rmovefield{rr});
                                end
                            end
                            cocotemp.data.annotations=table2struct(anntable)';
                           
                        end


                    end

                 end


                if flag.Low_res~=-1
                    im_size=size(data1{nn,1}.im0);
                    if isfield(data1{nn,1},'Yolo512_Unet_256x256__result__UNET_ML')==1
                        if isfield(data1{nn,1}.Yolo512_Unet_256x256__result__UNET_ML,'atlas_allcell_N')==1
                            data1{nn,1}.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N=imresize(data1{nn,1}.Yolo512_Unet_256x256__result__UNET_ML.atlas_allcell_N,[im_size(1) im_size(2)],'Method','nearest');
                        end
                    end
                    %end
                end
            end
        end
    end
 
end


