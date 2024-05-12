function DataSetInfo=data_set_info_v02(UserID,project_name,type_of_image,type_of_cell,sample_ID,image_info_file,file_path0,varargin)
% (D1) DataSetInfo=data_set_info_v02(UserID,project_name,type_of_image,type_of_cell,sample_ID,image_info_file,file_path0,varargin)
%     image information <= see (data structure), atlas information in microglia_detection_v003(DataSetInfo,env,setp,opts,varargin)
%     ex: DataSetInfo=data_set_info_v02('Shoykhet','project1','IHC','microglia',{'CR1','N25','N13','N15','N16','N17','N18','N20','N27','N29','N31','N33','N34','N36','N38','N40'},'data_info_v38','H:\HU\DLdata_v2\','I:\HU\DLdata_v2_R_v04regp11\',opts.atlas_ver);
%     set: DataSetInfo.sampleIdselect='N25'; to only process the selected sample ID, or for all sample, 
%          also controlled by opts.keywords and opts.Nkeywords;
%{
    Input:
        UserID='Shoykhet';
        project_name='project1';
        type_of_image='IHC';
        type_of_cell='microglia';
        sample_ID={'CR1','N25','N13','N15','N16','N17','N18','N20','N27','N29','N31','N33','N34','N36','N38','N40'};
        image_info_file='data_info_v38';  % detial information for each image
        file_path0='H:\HU\DLdata_v2\';
        varargin{1} = 'I:\HU\DLdata_v2_R_v04regp11\'; path of output data for exchange between PC
        varargin{2} = 'v4'; atlas version
    Output:
        DataSetInfo = (struct with fields)
                   .UserID = 'Shoykhet'
                   .project_name = 'project1'
                   .type_of_image = 'IHC'
                   .type_of_cell = 'microglia'
                   .sample_ID = {'CR1','N25','N13','N15','N16','N17','N18','N20','N27','N29','N31','N33','N34','N36','N38','N40'}
                   .image_info_file = 'data_info_v38'
                   .file_path0 = 'H:\HU\DLdata_v2\'
                   .result_path: 'I:\HU\DLdata_v2_R_v04regp11\'
                   .atlas_ver = 'v4'
                   .im_reverse = 1;  % depend on "UserID"
                   .atlas_rename: [23×3 table];  % <= brain atlas
                   .coco_category: [1×391 struct]  % from (D3) coco_category_v02 <= brain atlas
                   .sampleIdselect = ''; % if empty => program will only load all images in sample_ID
                                         % ='CR1' => only load CR1
    Functions: (D3) coco_category_v02
%}

DataSetInfo.UserID=UserID;   % 'Shoykhet', 'Artur', ...
DataSetInfo.project_name=project_name;  %'project1';
DataSetInfo.type_of_image=type_of_image;  % 'IHC' or 'MRI'
DataSetInfo.type_of_cell=type_of_cell;   % 'microglia' or 'astrocyte'
DataSetInfo.sample_ID=sample_ID;
DataSetInfo.image_info_file=image_info_file;%'data_info_v34';
DataSetInfo.file_path0=file_path0;
if isempty(varargin)==1
    DataSetInfo.result_path=file_path0;
else
    DataSetInfo.result_path=varargin{1};
    if length(varargin)==2
        DataSetInfo.atlas_ver=varargin{2};
    elseif length(varargin)==3
        DataSetInfo.atlas_ver=varargin{2};
        DataSetInfo.atlas_ver_old=varargin{3};
    end
end


%% brain atlas for coco categories
supercategory0='microglia';
%category_brainatlas={'microglia';'background';'Cortex';'Corpus_Callosum';'Hindbrain';'Substantia_Nigra';'CA2';'Pituitary_Gland';'Diancephalon';'Internal_Capsule';'Midbrain';'Dentate_Gyrus';'CA1';'CA3'};
%category_brainatlas
% atlas_name={'background';'Cortex';'External_Capsule';'Interpeduncular_Nucleus';'Substantia_Nigra';'CA2';'Pituitary_Gland';...
%     'Thalamus';'Contricofugal_Pathways';'Midbrain';'DG';'CA1';'CA3';'Pons';'Hippocampus_Subiculum';'Inferior_Colliculus';'CC';...
%     'Hippocampus';'Striatum';'Global_Pallidus';'Basal_Forebrain';'Anterior_Commisure';'Optic_tract';'brain'}; %remove Hippocampus_Fimbria
% %atlas_name=category_brainatlas;
% atlas_name_N(:,1)={'background';'COR';'EC';'IN';'SN';'CA2';'PG';...
%     'THAL';'CP';'MB';'DG';'CA1';'CA3';'Pons';'HPC_S';'IC';'CC';...
%     'HPC';'STRI';'GP';'BF';'AC';'OT';'brain'};
% atlas_namefull(:,1)={'background';'Cortex';'External_Capsule';'Interpeduncular_Nucleus';'Substantia_Nigra';'Cornu_Ammonis_2';'Pituitary_Gland';...
%     'Thalamus';'Corticofugal_Pathways';'Midbrain';'Dentate_Gyrus';'Cornu_Ammonis_1';'Cornu_Ammonis_3';'Pons';'Hippocampus_Subiculum';'Inferior_Colliculus';'Corpus_Callosum';...
%     'Hippocampus';'Striatum';'Globus_Pallidus';'Basal_Forebrain';'Anterior_Commissure';'Optic_tract';'brain'};

if isfield(DataSetInfo,'atlas_ver')==1
    atlas_ver_case{1}=DataSetInfo.atlas_ver;
end
if isfield(DataSetInfo,'atlas_ver_old')==1
    atlas_ver_case{2}=DataSetInfo.atlas_ver_old;
end

for ac=1:length(atlas_ver_case);
    switch atlas_ver_case{ac}
        case {'v2','v3'}
            atlas_name0={'background'             ,'background','background';              % 0
                'Cortex'                 ,'COR'       ,'Cortex';                  % 1
                'External_Capsule'       ,'EC'        ,'External_Capsule';        % 2
                'Interpeduncular_Nucleus','IN'        ,'Interpeduncular_Nucleus'; % 3
                'Substantia_Nigra'       ,'SN'        ,'Substantia_Nigra';        % 4
                'CA2'                    ,'CA2'       ,'Cornu_Ammonis_2';         % 5
                'Pituitary_Gland'        ,'PG'        ,'Pituitary_Gland';         % 6
                'Thalamus'               ,'THAL'      ,'Thalamus';                % 7
                'Contricofugal_Pathways' ,'CP'        ,'Corticofugal_Pathways';   % 8
                'Midbrain'               ,'MB'        ,'Midbrain';                % 9
                'DG'                     ,'DG'        ,'Dentate_Gyrus';           % 10
                'CA1'                    ,'CA1'       ,'Cornu_Ammonis_1';         % 11
                'CA3'                    ,'CA3'       ,'Cornu_Ammonis_3';         % 12
                'Pons'                   ,'Pons'      ,'Pons';                    % 13
                'Hippocampus_Subiculum'  ,'HPC_S'     ,'Hippocampus_Subiculum';   % 14
                'Inferior_Colliculus'    ,'IC'        ,'Inferior_Colliculus';     % 15
                'Hippocampus'            ,'HPC'       ,'Hippocampus';             % 16
                'Striatum'               ,'STRI'      ,'Striatum';                % 17
                'Global_Pallidus'        ,'GP'        ,'Globus_Pallidus';         % 18
                'Basal_Forebrain'        ,'BF'        ,'Basal_Forebrain';         % 19
                'Anterior_Commisure'     ,'AC'        ,'Anterior_Commissure';     % 20
                'CC'                     ,'CC'        ,'Corpus_Callosum';         % 21
                'Optic_tract'            ,'OT'        ,'Optic_tract';             % 22
                'brain'                  ,'brain'     ,'brain';};                 % 23 -> 255
        case 'v4'
            atlas_name0={'background'    ,'background','background';              % 0
                'Cortex'                 ,'COR'       ,'Cortex';                  % 1
                'External_Capsule'       ,'EC'        ,'External_Capsule';        % 2
                'Interpeduncular_Nucleus','IN'        ,'Interpeduncular_Nucleus'; % 3
                'Substantia_Nigra'       ,'SN'        ,'Substantia_Nigra';        % 4
                'CA2'                    ,'CA2'       ,'Cornu_Ammonis_2';         % 5
                'Pituitary_Gland'        ,'PG'        ,'Pituitary_Gland';         % 6
                'Thalamus'               ,'THAL'      ,'Thalamus';                % 7
                'Contricofugal_Pathways' ,'CP'        ,'Corticofugal_Pathways';   % 8
                'Midbrain'               ,'MB'        ,'Midbrain';                % 9
                'DG'                     ,'DG'        ,'Dentate_Gyrus';           % 10
                'CA1'                    ,'CA1'       ,'Cornu_Ammonis_1';         % 11
                'CA3'                    ,'CA3'       ,'Cornu_Ammonis_3';         % 12
                'Pons'                   ,'Pons'      ,'Pons';                    % 13
                'Hippocampus'            ,'HPC'       ,'Hippocampus';             % 14
                'Striatum'               ,'STRI'      ,'Striatum';                % 15
                'Global_Pallidus'        ,'GP'        ,'Globus_Pallidus';         % 16
                'Basal_Forebrain'        ,'BF'        ,'Basal_Forebrain';         % 17
                'Anterior_Commisure'     ,'AC'        ,'Anterior_Commissure';     % 18
                'CC'                     ,'CC'        ,'Corpus_Callosum';         % 19
                'Optic_tract'            ,'OT'        ,'Optic_tract';             % 20
                'ChP'                    ,'ChP'       ,'Choroid_Plexus';          % 21
                'brain'                  ,'brain'     ,'brain';};                 % > 255
        case 'v5'
            atlas_name0={'background'    ,'background','background'              ,0;              % 0
                'COR'                    ,'CTX'       ,'Cortex'                  ,1;                  % 1
                'External_Capsule'       ,'EC'        ,'External_Capsule'        ,2;        % 2
                'Interpeduncular_Nucleus','IN'        ,'Interpeduncular_Nucleus' ,3; % 3
                'Substantia_Nigra'       ,'SN'        ,'Substantia_Nigra'        ,4;        % 4
                'CA2'                    ,'CA2'       ,'Cornu_Ammonis_2'         ,5;         % 5
                'Pituitary_Gland'        ,'PG'        ,'Pituitary_Gland'         ,6;         % 6
                'Thalamus'               ,'THAL'      ,'Thalamus'                ,7;                % 7
                'Contricofugal_Pathways' ,'CP'        ,'Corticofugal_Pathways'   ,8;   % 8
                'Midbrain'               ,'MB'        ,'Midbrain'                ,9;                % 9
                'DG'                     ,'DG'        ,'Dentate_Gyrus'           ,10;           % 10
                'CA1'                    ,'CA1'       ,'Cornu_Ammonis_1'         ,11;         % 11
                'CA3'                    ,'CA3'       ,'Cornu_Ammonis_3'         ,12;         % 12
                'Pons'                   ,'Pons'      ,'Pons'                    ,13;                    % 13
                'Hippocampus'            ,'HPC'       ,'Hippocampus'             ,14;             % 14
                'Striatum'               ,'STRI'      ,'Striatum'                ,15;                % 15
                'Global_Pallidus'        ,'GP'        ,'Globus_Pallidus'         ,16;         % 16
                'Basal_Forebrain'        ,'BF'        ,'Basal_Forebrain'         ,17;         % 17
                'Anterior_Commisure'     ,'AC'        ,'Anterior_Commissure'     ,18;     % 18
                'CC'                     ,'CC'        ,'Corpus_Callosum'         ,19;         % 19
                'Optic_tract'            ,'OT'        ,'Optic_tract'             ,20;             % 20
                'ChP'                    ,'ChP'       ,'Choroid_Plexus'          ,21;          % 21
                'RT'                     ,'RT'        ,'Reticular_nucleus_of_the_thalamus',22;  %22
                'und'                    ,'und'       ,'undefined_region'        ,254;         % > 254
                'brain'                  ,'brain'     ,'brain'                   ,255;};                 % > 255
        case 'v6'
            atlas_name0={'background'    ,'background','background'              ,0;              % 0
                'COR'                    ,'CTX'       ,'Cortex'                  ,1;                  % 1
                'External_Capsule'       ,'EC'        ,'External_Capsule'        ,2;        % 2
                'Interpeduncular_Nucleus','IN'        ,'Interpeduncular_Nucleus' ,3; % 3
                'Substantia_Nigra'       ,'SN'        ,'Substantia_Nigra'        ,4;        % 4
                'CA2'                    ,'CA2'       ,'Cornu_Ammonis_2'         ,5;         % 5
                'Pituitary_Gland'        ,'PG'        ,'Pituitary_Gland'         ,6;         % 6
                'Thalamus'               ,'THAL'      ,'Thalamus'                ,7;                % 7
                'Contricofugal_Pathways' ,'CP'        ,'Corticofugal_Pathways'   ,8;   % 8
                'Midbrain'               ,'MB'        ,'Midbrain'                ,9;                % 9
                'DG'                     ,'DG'        ,'Dentate_Gyrus'           ,10;           % 10
                'CA1'                    ,'CA1'       ,'Cornu_Ammonis_1'         ,11;         % 11
                'CA3'                    ,'CA3'       ,'Cornu_Ammonis_3'         ,12;         % 12
                'Pons'                   ,'Pons'      ,'Pons'                    ,13;                    % 13
                'Hippocampus'            ,'HPC'       ,'Hippocampus'             ,14;          % 14
                'Striatum'               ,'STRI'      ,'Striatum'                ,15;          % 15
                'Global_Pallidus'        ,'GP'        ,'Globus_Pallidus'         ,16;          % 16
                'Basal_Forebrain'        ,'BF'        ,'Basal_Forebrain'         ,17;          % 17
                'Anterior_Commisure'     ,'AC'        ,'Anterior_Commissure'     ,18;          % 18
                'CC'                     ,'CC'        ,'Corpus_Callosum'         ,19;          % 19
                'Optic_tract'            ,'OT'        ,'Optic_tract'             ,20;          % 20
                'ChP'                    ,'ChP'       ,'Choroid_Plexus'          ,21;          % 21
                'RT'                     ,'RT'        ,'Reticular_nucleus_of_the_thalamus',22;  %22
                'Ctx1'                   ,'Ctx1'      ,'Cortex_Layer_1'          ,23;
                'Ctx2'                   ,'Ctx2'      ,'Cortex_Layer_2'          ,24;
                'Ctx3'                   ,'Ctx3'      ,'Cortex_Layer_3'          ,25;
                'Ctx4'                   ,'Ctx4'      ,'Cortex_Layer_4'          ,26;
                'Ctx5'                   ,'Ctx5'      ,'Cortex_Layer_5'          ,27;
                'Ctx6'                   ,'Ctx6'      ,'Cortex_Layer_6'          ,28;
                'und'                    ,'und'       ,'undefined_region'        ,254;         % > 254
                'brain'                  ,'brain'     ,'brain'                   ,255;};                 % > 255

        case 'v7' %(update form v6)
            atlas_name0={'background'    ,'background','background'              ,0;              % 0
                'COR'                    ,'CTX'       ,'Cortex'                  ,1;                  % 1
                'External_Capsule'       ,'EC'        ,'External_Capsule'        ,2;        % 2
                'Interpeduncular_Nucleus','IN'        ,'Interpeduncular_Nucleus' ,3; % 3
                'Substantia_Nigra'       ,'SN'        ,'Substantia_Nigra'        ,4;        % 4
                'CA2'                    ,'CA2'       ,'Cornu_Ammonis_2'         ,5;         % 5
                'Pituitary_Gland'        ,'PG'        ,'Pituitary_Gland'         ,6;         % 6
                'Thalamus'               ,'THAL'      ,'Thalamus'                ,7;                % 7
                'Contricofugal_Pathways' ,'CP'        ,'Corticofugal_Pathways'   ,8;   % 8
                'Midbrain'               ,'MB'        ,'Midbrain'                ,9;                % 9
                'DG'                     ,'DG'        ,'Dentate_Gyrus'           ,10;           % 10
                'CA1'                    ,'CA1'       ,'Cornu_Ammonis_1'         ,11;         % 11
                'CA3'                    ,'CA3'       ,'Cornu_Ammonis_3'         ,12;         % 12
                'Pons'                   ,'Pons'      ,'Pons'                    ,13;                    % 13
                'Hippocampus'            ,'HPC'       ,'Hippocampus'             ,14;          % 14
                'Striatum'               ,'STRI'      ,'Striatum'                ,15;          % 15
                'Global_Pallidus'        ,'GP'        ,'Globus_Pallidus'         ,16;          % 16
                'Basal_Forebrain'        ,'BF'        ,'Basal_Forebrain'         ,17;          % 17
                'Anterior_Commisure'     ,'AC'        ,'Anterior_Commissure'     ,18;          % 18
                'CC'                     ,'CC'        ,'Corpus_Callosum'         ,19;          % 19
                'Optic_tract'            ,'OT'        ,'Optic_tract'             ,20;          % 20
                'ChP'                    ,'ChP'       ,'Choroid_Plexus'          ,21;          % 21
                'RT'                     ,'RT'        ,'Reticular_nucleus_of_the_thalamus',22;  %22
                'Ctx1'                   ,'Ctx1'      ,'Cortex_Layer_1'          ,23;
                'Ctx2'                   ,'Ctx2'      ,'Cortex_Layer_2'          ,24;
                'Ctx3'                   ,'Ctx3'      ,'Cortex_Layer_3'          ,25;
                'Ctx4'                   ,'Ctx4'      ,'Cortex_Layer_4'          ,26;
                'Ctx5'                   ,'Ctx5'      ,'Cortex_Layer_5'          ,27;
                'Ctx6'                   ,'Ctx6'      ,'Cortex_Layer_6'          ,28;
                'CA1_SO'                 ,'CA1_SO'    ,'CA1_Stratum_Oriens'      ,29;
                'CA1_SP'                 ,'CA1_SP'    ,'CA1_Stratum_Pyramidale'  ,30;
                'CA1_SR'                 ,'CA1_SR'    ,'CA1_Stratum_Radiatum'    ,31;
                'CA2_SO'                 ,'CA2_SO'    ,'CA2_Stratum_Oriens'      ,32;
                'CA2_SP'                 ,'CA2_SP'    ,'CA2_Stratum_Pyramidale'  ,33;
                'CA2_SR'                 ,'CA2_SR'    ,'CA2_Stratum_Radiatum'    ,34;
                'CA3_SO'                 ,'CA3_SO'    ,'CA3_Stratum_Oriens'      ,35;
                'CA3_SP'                 ,'CA3_SP'    ,'CA3_Stratum_Pyramidale'  ,36;
                'CA3_SR'                 ,'CA3_SR'    ,'CA3_Stratum_Radiatum'    ,37;
                'SLM'                    ,'SLM'       ,'Stratum_Lacunosum_Moleculare'   ,38;
                'DG_ML'                  ,'DG_ML'     ,'DG_Molecular_Layer'      ,39;
                'DG_GL'                  ,'DG_GL'     ,'DG_Granule_Cell_Layer,'  ,40;
                'DG_H'                   ,'DG_H'      ,'DG_Hilus'                ,41;
                % SP                                    Stratum pyramidale;
                % SL                                    Stratum_Lucidum
                'und'                    ,'und'       ,'undefined_region'        ,254;         % > 254
                'brain'                  ,'brain'     ,'brain'                   ,255;};       % > 255

        case {'v8'}  %(update form v5)
            atlas_name0={'background'    ,'background','background'              ,0;              % 0
                'COR'                    ,'CTX'       ,'Cortex'                  ,1;                  % 1
                'External_Capsule'       ,'EC'        ,'External_Capsule'        ,2;        % 2
                'Interpeduncular_Nucleus','IN'        ,'Interpeduncular_Nucleus' ,3; % 3
                'Substantia_Nigra'       ,'SN'        ,'Substantia_Nigra'        ,4;        % 4
                'CA2'                    ,'CA2'       ,'Cornu_Ammonis_2'         ,5;         % 5
                'Pituitary_Gland'        ,'PG'        ,'Pituitary_Gland'         ,6;         % 6
                'Thalamus'               ,'THAL'      ,'Thalamus'                ,7;                % 7
                'Contricofugal_Pathways' ,'CP'        ,'Corticofugal_Pathways'   ,8;   % 8
                'Midbrain'               ,'MB'        ,'Midbrain'                ,9;                % 9
                'DG'                     ,'DG'        ,'Dentate_Gyrus'           ,10;           % 10
                'CA1'                    ,'CA1'       ,'Cornu_Ammonis_1'         ,11;         % 11
                'CA3'                    ,'CA3'       ,'Cornu_Ammonis_3'         ,12;         % 12
                'Pons'                   ,'Pons'      ,'Pons'                    ,13;                    % 13
                'Hippocampus'            ,'HPC'       ,'Hippocampus'             ,14;          % 14
                'Striatum'               ,'STRI'      ,'Striatum'                ,15;          % 15
                'Global_Pallidus'        ,'GP'        ,'Globus_Pallidus'         ,16;          % 16
                'Basal_Forebrain'        ,'BF'        ,'Basal_Forebrain'         ,17;          % 17
                'Anterior_Commisure'     ,'AC'        ,'Anterior_Commissure'     ,18;          % 18
                'CC'                     ,'CC'        ,'Corpus_Callosum'         ,19;          % 19
                'Optic_tract'            ,'OT'        ,'Optic_tract'             ,20;          % 20
                'ChP'                    ,'ChP'       ,'Choroid_Plexus'          ,21;          % 21
                'RT'                     ,'RT'        ,'Reticular_nucleus_of_the_thalamus',22;  %22
                'Ctx1'                   ,'Ctx1'      ,'Cortex_Layer_1'          ,23;
                'Ctx2'                   ,'Ctx2'      ,'Cortex_Layer_2'          ,24;
                'Ctx3'                   ,'Ctx3'      ,'Cortex_Layer_3'          ,25;
                'Ctx4'                   ,'Ctx4'      ,'Cortex_Layer_4'          ,26;
                'Ctx5'                   ,'Ctx5'      ,'Cortex_Layer_5'          ,27;
                'Ctx6'                   ,'Ctx6'      ,'Cortex_Layer_6'          ,28;
                'CA1_Or'                 ,'CA1_Or'    ,'CA1_Stratum_Oriens'      ,29;
                'CA1_Py'                 ,'CA1_Py'    ,'CA1_Stratum_Pyramidale'  ,30;
                'CA1_Rad'                ,'CA1_Rad'   ,'CA1_Stratum_Radiatum'    ,31;
                'CA2_Or'                 ,'CA2_Or'    ,'CA2_Stratum_Oriens'      ,32;
                'CA2_Py'                 ,'CA2_Py'    ,'CA2_Stratum_Pyramidale'  ,33;
                'CA2_Rad'                ,'CA2_Rad'   ,'CA2_Stratum_Radiatum'    ,34;
                'CA3_Or'                 ,'CA3_Or'    ,'CA3_Stratum_Oriens'      ,35;
                'CA3_Py'                 ,'CA3_Py'    ,'CA3_Stratum_Pyramidale'  ,36;
                'CA3_Rad'                ,'CA3_Rad'   ,'CA3_Stratum_Radiatum'    ,37;
                'CA3_SLu'                ,'CA3_SLu'   ,'CA3_stratum_lucidum'     ,38;
                'LMol'                   ,'LMol'      ,'Stratum_Lacunosum_Moleculare'   ,39;
                'MoDG'                   ,'MoDG'      ,'DG_Molecular_Layer'      ,40;
                'GrDG'                   ,'GrDG'      ,'DG_Granule_Cell_Layer,'  ,41;
                'PoDG'                   ,'PoDG'      ,'DG_Hilus'                ,42;
                'dhc'                    ,'dhc'       ,'dorsal_HPC_commissure'   ,43;
                % SP                                    Stratum pyramidale;
                % SL                                    Stratum_Lucidum
                'und'                    ,'und'       ,'undefined_region'        ,254;         % > 254
                'brain'                  ,'brain'     ,'brain'                   ,255;};       % > 255

        case {'v9'}  %(update form v8)
            atlas_name0={'background'    ,'background','background'              ,0;              % 0
                'COR'                    ,'CTX'       ,'Cortex'                  ,1;                  % 1
                'External_Capsule'       ,'EC'        ,'External_Capsule'        ,2;        % 2
                'Interpeduncular_Nucleus','IN'        ,'Interpeduncular_Nucleus' ,3; % 3
                'Substantia_Nigra'       ,'SN'        ,'Substantia_Nigra'        ,4;        % 4
                'CA2'                    ,'CA2'       ,'Cornu_Ammonis_2'         ,5;         % 5
                'Pituitary_Gland'        ,'PG'        ,'Pituitary_Gland'         ,6;         % 6
                'Thalamus'               ,'THAL'      ,'Thalamus'                ,7;                % 7
                'Contricofugal_Pathways' ,'CP'        ,'Corticofugal_Pathways'   ,8;   % 8
                'Midbrain'               ,'MB'        ,'Midbrain'                ,9;                % 9
                'DG'                     ,'DG'        ,'Dentate_Gyrus'           ,10;           % 10
                'CA1'                    ,'CA1'       ,'Cornu_Ammonis_1'         ,11;         % 11
                'CA3'                    ,'CA3'       ,'Cornu_Ammonis_3'         ,12;         % 12
                'Pons'                   ,'Pons'      ,'Pons'                    ,13;                    % 13
                'Hippocampus'            ,'HPC'       ,'Hippocampus'             ,14;          % 14
                'Striatum'               ,'STRI'      ,'Striatum'                ,15;          % 15
                'Global_Pallidus'        ,'GP'        ,'Globus_Pallidus'         ,16;          % 16
                'Basal_Forebrain'        ,'BF'        ,'Basal_Forebrain'         ,17;          % 17
                'Anterior_Commisure'     ,'AC'        ,'Anterior_Commissure'     ,18;          % 18
                'CC'                     ,'CC'        ,'Corpus_Callosum'         ,19;          % 19
                'Optic_tract'            ,'OT'        ,'Optic_tract'             ,20;          % 20
                'ChP'                    ,'ChP'       ,'Choroid_Plexus'          ,21;          % 21
                'RT'                     ,'RT'        ,'Reticular_nucleus_of_the_thalamus',22;  %22
                'Ctx1'                   ,'Ctx1'      ,'Cortex_Layer_1'          ,23;
                'Ctx23'                  ,'Ctx23'     ,'Cortex_Layer_23'         ,24;
                'Ctx4'                   ,'Ctx4'      ,'Cortex_Layer_4'          ,25;
                'Ctx5'                   ,'Ctx5'      ,'Cortex_Layer_5'          ,26;
                'Ctx6'                   ,'Ctx6'      ,'Cortex_Layer_6'          ,27;
                'CA1_Or'                 ,'CA1_Or'    ,'CA1_Stratum_Oriens'      ,28;
                'CA1_Py'                 ,'CA1_Py'    ,'CA1_Stratum_Pyramidale'  ,29;
                'CA1_Rad'                ,'CA1_Rad'   ,'CA1_Stratum_Radiatum'    ,30;
                'CA2_Or'                 ,'CA2_Or'    ,'CA2_Stratum_Oriens'      ,31;
                'CA2_Py'                 ,'CA2_Py'    ,'CA2_Stratum_Pyramidale'  ,32;
                'CA2_Rad'                ,'CA2_Rad'   ,'CA2_Stratum_Radiatum'    ,33;
                'CA3_Or'                 ,'CA3_Or'    ,'CA3_Stratum_Oriens'      ,34;
                'CA3_Py'                 ,'CA3_Py'    ,'CA3_Stratum_Pyramidale'  ,35;
                'CA3_Rad'                ,'CA3_Rad'   ,'CA3_Stratum_Radiatum'    ,36;
                'CA3_SLu'                ,'CA3_SLu'   ,'CA3_stratum_lucidum'     ,37;
                'LMol'                   ,'LMol'      ,'Stratum_Lacunosum_Moleculare'   ,38;
                'MoDG'                   ,'MoDG'      ,'DG_Molecular_Layer'      ,39;
                'GrDG'                   ,'GrDG'      ,'DG_Granule_Cell_Layer,'  ,40;
                'PoDG'                   ,'PoDG'      ,'DG_Hilus'                ,41;
                'dhc'                    ,'dhc'       ,'dorsal_HPC_commissure'   ,42;
                % SP                                    Stratum pyramidale;
                % SL                                    Stratum_Lucidum
                'und'                    ,'und'       ,'undefined_region'        ,254;         % > 254
                'brain'                  ,'brain'     ,'brain'                   ,255;};       % > 255

        case {'v10','v11'}  %(update form v8)
            atlas_name0={'background'    ,'background','background'              ,0;              % 0
                'COR'                    ,'CTX'       ,'Cortex'                  ,1;                  % 1
                'External_Capsule'       ,'EC'        ,'External_Capsule'        ,2;        % 2
                'Interpeduncular_Nucleus','IN'        ,'Interpeduncular_Nucleus' ,3; % 3
                'Substantia_Nigra'       ,'SN'        ,'Substantia_Nigra'        ,4;        % 4
                'CA2'                    ,'CA2'       ,'Cornu_Ammonis_2'         ,5;         % 5
                'Pituitary_Gland'        ,'PG'        ,'Pituitary_Gland'         ,6;         % 6
                'Thalamus'               ,'THAL'      ,'Thalamus'                ,7;                % 7
                'Contricofugal_Pathways' ,'CP'        ,'Corticofugal_Pathways'   ,8;   % 8
                'Midbrain'               ,'MB'        ,'Midbrain'                ,9;                % 9
                'DG'                     ,'DG'        ,'Dentate_Gyrus'           ,10;           % 10
                'CA1'                    ,'CA1'       ,'Cornu_Ammonis_1'         ,11;         % 11
                'CA3'                    ,'CA3'       ,'Cornu_Ammonis_3'         ,12;         % 12
                'Pons'                   ,'Pons'      ,'Pons'                    ,13;                    % 13
                'Hippocampus'            ,'HPC'       ,'Hippocampus'             ,14;          % 14
                'Striatum'               ,'STRI'      ,'Striatum'                ,15;          % 15
                'Global_Pallidus'        ,'GP'        ,'Globus_Pallidus'         ,16;          % 16
                'Basal_Forebrain'        ,'BF'        ,'Basal_Forebrain'         ,17;          % 17
                'Anterior_Commisure'     ,'AC'        ,'Anterior_Commissure'     ,18;          % 18
                'CC'                     ,'CC'        ,'Corpus_Callosum'         ,19;          % 19
                'Optic_tract'            ,'OT'        ,'Optic_tract'             ,20;          % 20
                'ChP'                    ,'ChP'       ,'Choroid_Plexus'          ,21;          % 21
                'RT'                     ,'RT'        ,'Reticular_nucleus_of_the_thalamus',22;  %22
                'VPL_VPM'                ,'VPL_VPM'   ,'Ventral posterolateral(posteromedial) nucleus',23;  %23
                'Ctx1'                   ,'Ctx1'      ,'Cortex_Layer_1'          ,24;
                'Ctx23'                  ,'Ctx23'     ,'Cortex_Layer_23'         ,25;
                'Ctx4'                   ,'Ctx4'      ,'Cortex_Layer_4'          ,26;
                'Ctx5'                   ,'Ctx5'      ,'Cortex_Layer_5'          ,27;
                'Ctx6'                   ,'Ctx6'      ,'Cortex_Layer_6'          ,28;
                'CA1_Or'                 ,'CA1_Or'    ,'CA1_Stratum_Oriens'      ,29;
                'CA1_Py'                 ,'CA1_Py'    ,'CA1_Stratum_Pyramidale'  ,30;
                'CA1_Rad'                ,'CA1_Rad'   ,'CA1_Stratum_Radiatum'    ,31;
                'CA2_Or'                 ,'CA2_Or'    ,'CA2_Stratum_Oriens'      ,32;
                'CA2_Py'                 ,'CA2_Py'    ,'CA2_Stratum_Pyramidale'  ,33;
                'CA2_Rad'                ,'CA2_Rad'   ,'CA2_Stratum_Radiatum'    ,34;
                'CA3_Or'                 ,'CA3_Or'    ,'CA3_Stratum_Oriens'      ,35;
                'CA3_Py'                 ,'CA3_Py'    ,'CA3_Stratum_Pyramidale'  ,36;
                'CA3_Rad'                ,'CA3_Rad'   ,'CA3_Stratum_Radiatum'    ,37;
                'CA3_SLu'                ,'CA3_SLu'   ,'CA3_stratum_lucidum'     ,38;
                'LMol'                   ,'LMol'      ,'Stratum_Lacunosum_Moleculare' ,39;
                'MoDG'                   ,'MoDG'      ,'DG_Molecular_Layer'      ,40;
                'GrDG'                   ,'GrDG'      ,'DG_Granule_Cell_Layer,'  ,41;
                'PoDG'                   ,'PoDG'      ,'DG_Hilus'                ,42;
                % SP                                    Stratum pyramidale;
                % SL                                    Stratum_Lucidum
                'und'                    ,'und'       ,'undefined_region'        ,254;         % > 254
                'brain'                  ,'brain'     ,'brain'                   ,255;};       % > 255



        case {'v12'}  %(update form v11, set up new name for next version)
             atlas_name0={'background'   ,'background','background'              ,0;             
                'COR'                    ,'CTX'       ,'Cortex'                  ,1;                 
                'External_Capsule'       ,'EC'        ,'External_Capsule'        ,2;       
                'Hippocampus'            ,'HPF'       ,'Hippocampal Formation'   ,3;          
                'CPU'                    ,'CPU'       ,'Caudate Putamen'         ,4;        
                'Global_Pallidus'        ,'GPVP'      ,'Globus Pallidus and Ventral Pallidum'         ,5;         
                'Basal_Forebrain'        ,'BF'        ,'Basal_Forebrain'         ,6;         
                'Thalamus'               ,'THAL'      ,'Thalamus'                ,7;                
                'Pons'                   ,'PONS'      ,'Pons'                    ,8;                    
                'ChP'                    ,'CHP'       ,'Choroid_Plexus'          ,9;          
                'Anterior_Commisure'     ,'AC'        ,'Anterior_Commissure'     ,10;          
                'IC'                     ,'IC'        ,'Internal_Capsule'        ,11; 
                'CC'                     ,'CC'        ,'Corpus_Callosum'         ,12;          
                'CG'                     ,'CG'        ,'Cingulum'                ,13;          
                'SEPT'                   ,'SEPT'      ,'Septal Region'           ,14;       
                'SC'                     ,'SC'        ,'Subicular Complex'       ,15;        
                'Midbrain'               ,'MB'        ,'Midbrain'                ,16;                
                'SN'                     ,'SN'        ,'Substantia_Nigra'        ,17;       
                'PG'                     ,'PG'        ,'Pituitary_Gland'         ,18;         
                'CFT'                    ,'CFT'       ,'Corticofugal Tract'      ,19;   
                'DG'                     ,'DG'        ,'Dentate_Gyrus'           ,20;           
                'CA1'                    ,'CA1'       ,'Cornu_Ammonis_1'         ,21;         % 11
                'CA3'                    ,'CA3'       ,'Cornu_Ammonis_3'         ,22;         % 12
                'RT'                     ,'RT'        ,'Reticular_nucleus_of_the_thalamus',23;  %22
                'Striatum'               ,'STRI'      ,'Striatum'                ,24;          % 15
                'VPL_VPM'                ,'VPMVPL'    ,'Ventral posterolateral(posteromedial) nucleus',25;  %23
                'Ctx1'                   ,'S1_L1'     ,'Cortex_Layer_1'          ,26;
                'Ctx23'                  ,'S1_L2L3'   ,'Cortex_Layer_23'         ,27;
                'Ctx4'                   ,'S1_L4'      ,'Cortex_Layer_4'         ,28;
                'Ctx5'                   ,'S1_L5'      ,'Cortex_Layer_5'         ,29;
                'Ctx6'                   ,'S1_L6'      ,'Cortex_Layer_6'         ,30;
                'CA1_Or'                 ,'CA1_Or'    ,'CA1_Stratum_Oriens'      ,31;
                'CA1_Py'                 ,'CA1_Py'    ,'CA1_Stratum_Pyramidale'  ,32;
                'CA1_Rad'                ,'CA1_Rad'   ,'CA1_Stratum_Radiatum'    ,33;
                'CA2_Or'                 ,'CA2_Or'    ,'CA2_Stratum_Oriens'      ,34;
                'CA2_Py'                 ,'CA2_Py'    ,'CA2_Stratum_Pyramidale'  ,35;
                'CA2_Rad'                ,'CA2_Rad'   ,'CA2_Stratum_Radiatum'    ,36;
                'CA3_Or'                 ,'CA3_Or'    ,'CA3_Stratum_Oriens'      ,37;
                'CA3_Py'                 ,'CA3_Py'    ,'CA3_Stratum_Pyramidale'  ,38;
                'CA3_Rad'                ,'CA3_Rad'   ,'CA3_Stratum_Radiatum'    ,39;
                'CA3_SLu'                ,'CA3_SLu'   ,'CA3_stratum_lucidum'     ,40;
                'LMol'                   ,'LMOL'      ,'Stratum_Lacunosum_Moleculare' ,41;
                'MoDG'                   ,'MoDG'      ,'DG_Molecular_Layer'      ,42;
                'GrDG'                   ,'GrDG'      ,'DG_Granule_Cell_Layer,'  ,43;
                'PoDG'                   ,'PoDG'      ,'DG_Hilus'                ,44;
                % SP                                    Stratum pyramidale;
                % SL                                    Stratum_Lucidum
                'und'                    ,'und'       ,'undefined_region'        ,254;         % > 254
                'brain'                  ,'brain'     ,'brain'                   ,255;};       % > 255


        otherwise
            atlas_name0={'background'   ,'background','background'              ,0;              % 0
                'brain'        ,'brain'     ,'brain'                   ,255;};       % > 255

    end


    if ac==1
        try
            DataSetInfo.atlas_rename=cell2table(atlas_name0,'VariableNames',{'atlas_name', 'atlas_name_N','atlas_namefull','id'});
        catch
            DataSetInfo.atlas_rename=cell2table(atlas_name0,'VariableNames',{'atlas_name', 'atlas_name_N','atlas_namefull'});
        end
    else
        try
            DataSetInfo.atlas_rename_old=cell2table(atlas_name0,'VariableNames',{'atlas_name', 'atlas_name_N','atlas_namefull','id'});
        catch
            DataSetInfo.atlas_rename_old=cell2table(atlas_name0,'VariableNames',{'atlas_name', 'atlas_name_N','atlas_namefull'});
        end
    end
end
% atlas_name={'background';'Cortex';'External_Capsule';'Interpeduncular_Nucleus';'Substantia_Nigra';'CA2';'Pituitary_Gland';...
%             'Thalamus';'Contricofugal_Pathways';'Midbrain';'DG';'CA1';'CA3';'Pons';'Hippocampus_Subiculum';'Inferior_Colliculus';...
%             'Hippocampus';'Striatum';'Global_Pallidus';'Basal_Forebrain';'Anterior_Commisure';'CC';'Optic_tract';'brain'}; %remove Hippocampus_Fimbria
% %atlas_name=category_brainatlas;
% atlas_name_N(:,1)={'background';'COR';'EC';'IN';'SN';'CA2';'PG';'THAL';'CP';'MB';'DG';'CA1';'CA3';'Pons';'HPC_S';'IC';...
%                    'HPC';'STRI';'GP';'BF';'AC';'CC';'OT';'brain'};
%
% atlas_namefull(:,1)={'background';'Cortex';'External_Capsule';'Interpeduncular_Nucleus';'Substantia_Nigra';'Cornu_Ammonis_2';'Pituitary_Gland';...
%                      'Thalamus';'Corticofugal_Pathways';'Midbrain';'Dentate_Gyrus';'Cornu_Ammonis_1';'Cornu_Ammonis_3';'Pons';'Hippocampus_Subiculum';'Inferior_Colliculus';...
%                      'Hippocampus';'Striatum';'Globus_Pallidus';'Basal_Forebrain';'Anterior_Commissure';'Corpus_Callosum';'Optic_tract';'brain'};
%


%DataSetInfo.atlas_rename=table(atlas_name,atlas_name_N,atlas_namefull);
category_celltype={'microglia';'type1';'type2';'type3';'type4';'type5';'type6';'type7';'type8';'type9';'N';'R';'RD';'H';'HR';'A';'B';};
DataSetInfo.coco_category=coco_category_v02(supercategory0,DataSetInfo.atlas_rename.atlas_name_N,category_celltype);


% %=== for C50




