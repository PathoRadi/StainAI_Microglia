function mpara=parameters_Get_cell_mask_optical_v14(dinfo)
% (P2) mpara_getmask=parameters_Get_cell_mask_optical_v14(dinfo);
%     thresholds for rule base mask, see: Heuristic Rules_Parameters.pptx .xlsx 
%{       
    input: dinfo{} from (D2) data_info_v38
    output:
        mpara{ff,1}= (struct with fields)
        mpara{ff,1}.box_source=dinfo{ff,1}.box_source;
        mpara{ff,1}.rm_celltype=dinfo{ff,1}.datatype;
        mpara{ff,1}.rm_threshold_list=10:10:255;
        mpara{ff,1}.pixel_size=dinfo{ff,1}.pixel_size;
        mpara{ff,1}.segmentation_function='rm_non_center_bw05';
               ...
%}


%{
for ff=[1 3 4 5 6];
    mpara{ff,1}.box_source=dinfo{ff,1}.box_source;
    mpara{ff,1}.rm_celltype=dinfo{ff,1}.datatype;
    mpara{ff,1}.rm_threshold_list=10:10:255;
    mpara{ff,1}.pixel_size=0.464;
    switch mpara{ff,1}.box_source
        case 'from_threshold'
            mpara{ff,1}.segmentation_function='rm_non_center_bw03';
            mpara{ff,1}.rm_select_case='center-size';
            mpara{ff,1}.rm_core_max_ratio=0.8;  % in bwrmjudgment_01.m
            mpara{ff,1}.rm_rcmean_ratio=[0.98 0.96];
            mpara{ff,1}.rm_brmean_ratio=[0.75 0.35];
            mpara{ff,1}.rm_edge_dist_th=[3 5];
            mpara{ff,1}.rm_dist_th=[33 52 40];
            mpara{ff,1}.rm_rcvis_ratio=[0.7 0.3 0.45 0.6 3];
            mpara{ff,1}.rm_min_size=[250 100];
            mpara{ff,1}.rm_num=7;                % in rm_non_center_bw03.m
            mpara{ff,1}.rm_core_min_size=[200 30];
            mpara{ff,1}.rm_core_max_size=1200;
            mpara{ff,1}.rm_line_increase=5;
            mpara{ff,1}.rm_line_increase_bridge=10;
            mpara{ff,1}.rm_crext_ratio=[0.9 1.1];
            mpara{ff,1}.rm_crext_increase=10;
            mpara{ff,1}.rm_cent_th=20;
            mpara{ff,1}.rm_corconpix_ratio=0.25;
            mpara{ff,1}.rm_size_th=[50 2000]; % in get_vis_max_bw.m
            mpara{ff,1}.cc_num=4;
            mpara{ff,1}.cc_conn=8;
            mpara{ff,1}.cc_kn=[5 4 3 3 3];
            mpara{ff,1}.cc_bridge_th_ratio=[0.8 0.8 0.6 0.9 0.8];
            mpara{ff,1}.cc_dist_th=[5 3 6 6 3];
            mpara{ff,1}.cc_ext_pixels=[3 2 1 2 2];
            mpara{ff,1}.cc_minconectpixels=[25 16 13 9 5];
            
        case 'Allen'
            mpara{ff,1}.rm_stdist=40;
    end
    
    mpara{ff,1}.ctypepar.CHSR=[1.35  1.93];
    mpara{ff,1}.ctypepar.CC=[0.0035 0.0145];
    mpara{ff,1}.ctypepar.CHA=1915;
    mpara{ff,1}.ctypepar.CHC2=0.85;
    mpara{ff,1}.ctypepar.CHC4=0.8;
    mpara{ff,1}.ctypepar.MSACH1=58;
    mpara{ff,1}.ctypepar.MSACH3=70;
end
%}

for ff=1:size(dinfo,1) %[2 7:13];  %ff=2
    %mpara{ff,1}.filepath_output=[dinfo{ff,1}.filepath_boxatlas filesep dinfo{ff,1}.filefolder_boxatlas{1}] ; %dinfo{ff,1}.filepath_output;
    %mpara{ff,1}.filename_image=dinfo{ff,1}.filename_image;
    mpara{ff,1}.box_source=dinfo{ff,1}.box_source;
    mpara{ff,1}.rm_celltype=dinfo{ff,1}.datatype;
    mpara{ff,1}.rm_threshold_list=10:10:255;
    mpara{ff,1}.pixel_size=dinfo{ff,1}.pixel_size;
    switch mpara{ff,1}.box_source
        %case {'from_threshold','from_threshold2'}
        case 'from_Allen'
            mpara{ff,1}.rm_stdist=40;
        otherwise
            mpara{ff,1}.segmentation_function='rm_non_center_bw05';
            mpara{ff,1}.rm_select_case='center-size';
            mpara{ff,1}.rm_core_max_ratio=0.8;  % in bwrmjudgment_01.m
            mpara{ff,1}.rm_rcmean_ratio=[0.95 0.75];
            mpara{ff,1}.rm_brmean_ratio=[0.6 0.35];
            mpara{ff,1}.rm_edge_dist_th=[5 10];
            mpara{ff,1}.rm_dist_th=[38 50 40];
            mpara{ff,1}.rm_rcvis_ratio=[0.85 0.25 0.45 0.6 3];
            mpara{ff,1}.rm_min_size=[250 100];
            mpara{ff,1}.rm_num=20;                % in rm_non_center_bw03.m
            mpara{ff,1}.rm_num_stop_core_mean_ratio=0.4;
            mpara{ff,1}.rm_num_stop_mean_min=125;
            mpara{ff,1}.rm_core_min_size=[200 60];
            mpara{ff,1}.rm_core_max_size=500;
            mpara{ff,1}.rm_line_increase=5;
            mpara{ff,1}.rm_line_increase_bridge=10;
            mpara{ff,1}.rm_crext_ratio=[0.9 1.1];
            mpara{ff,1}.rm_crext_increase=10;
            mpara{ff,1}.rm_cent_th=40;
            mpara{ff,1}.rm_corconpix_ratio=0.1;
            mpara{ff,1}.rm_size_th=[50 5000]; % in get_vis_max_bw.m
            
%             mpara{ff,1}.cc_num=5;
%             mpara{ff,1}.cc_conn=8;
%             mpara{ff,1}.cc_kn=[5 4 3 3 3];
%             mpara{ff,1}.cc_bridge_th_ratio=[0.8 0.8 0.6 0.9 0.8];
%             mpara{ff,1}.cc_dist_th=[5 3 6 6 5];
%             mpara{ff,1}.cc_ext_pixels=[3 2 1 2 3];
%             mpara{ff,1}.cc_minconectpixels=[25 16 13 9 9];

            
            mpara{ff,1}.cc_num=4;
            mpara{ff,1}.cc_conn=8;
            mpara{ff,1}.cc_kn=[5 4 3 3];
            mpara{ff,1}.cc_bridge_th_ratio=[0.8 0.8 0.6 0.9];
            mpara{ff,1}.cc_dist_th=[5 3 6 6];
            mpara{ff,1}.cc_ext_pixels=[3 2 1 2];
            mpara{ff,1}.cc_minconectpixels=[25 16 13 9];


    end
    
    mpara{ff,1}.ctypepar.CHSR=[1.35  1.93];
    mpara{ff,1}.ctypepar.CC=[0.0035 0.0145];
    mpara{ff,1}.ctypepar.CHA=1915;
    mpara{ff,1}.ctypepar.CHC2=0.85;
    mpara{ff,1}.ctypepar.CHC4=0.8;
    mpara{ff,1}.ctypepar.MSACH1=58;
    mpara{ff,1}.ctypepar.MSACH3=70;
end
