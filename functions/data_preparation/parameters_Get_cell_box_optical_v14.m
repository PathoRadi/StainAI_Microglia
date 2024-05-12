function mpara=parameters_Get_cell_box_optical_v14(dinfo)
% (P1) mpara_getbox=parameters_Get_cell_box_optical_v14(dinfo);
%     thresholds to get possibile cell position, see: Heuristic Rules_Parameters.pptx .xlsx 
%{
    input: dinfo{} from (D2) data_info_v38
    output: 
        mpara{ff,1}= (struct with fields)
        mpara{ff,1}.threshold=[165 100 1500];   % [intensity-sizeS-sizeL] threshold
        mpara{ff,1}.box_size{1}=[256 256];      % size for each cell
        mpara{ff,1}.stages=[1];                 % control the step of program
        mpara{ff,1}.loop_for_get_cell_box=6;    % repeat the detection with mpara{ff,1}.thresholdn{1,1}
        mpara{ff,1}.thresholdn{1,1}=[165 100 1500;150 70 1500];
        mpara{ff,1}.thresholdn{2,1}=[70 200  256*256];  
        mpara{ff,1}.thresholdn{3,1}=[100 200 256*256];  
        mpara{ff,1}.thresholdn{4,1}=[120 300 256*256];  
        mpara{ff,1}.thresholdn{5,1}=[120 300 256*256];  
        mpara{ff,1}.thresholdn{6,1}=[110 300 256*256];  
%}

ff=1; %CR1 slide 10 
mpara{ff,1}.threshold=[165 100 1500];                % [intensity-sizeS-sizeL]
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[165 100 1500;150 70 1500];
mpara{ff,1}.thresholdn{2,1}=[70 200 256*256];  
mpara{ff,1}.thresholdn{3,1}=[100 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{6,1}=[110 300 256*256];  
% 
ff=2; %N25 slide 10
mpara{ff,1}.threshold=[165 100 1500];  % [intensity-sizeS-sizeL]
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[70 150 1500];
mpara{ff,1}.thresholdn{2,1}=[100 150 256*256];
mpara{ff,1}.thresholdn{3,1}=[120 200 256*256];
mpara{ff,1}.thresholdn{4,1}=[120 200 256*256];
mpara{ff,1}.thresholdn{5,1}=[120 200 256*256];
mpara{ff,1}.thresholdn{6,1}=[115 200 256*256];
 
ff=3; %CR1 slide 7
mpara{ff,1}.threshold=[165 100 1500];                % [intensity-sizeS-sizeL]
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[165 100 1500;150 70 1500];
mpara{ff,1}.thresholdn{2,1}=[70 200 256*256];  
mpara{ff,1}.thresholdn{3,1}=[100 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{6,1}=[110 300 256*256];

% 
ff=4; %CR1 slide 8
mpara{ff,1}.threshold=[165 100 1500];                % [intensity-sizeS-sizeL]
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[165 100 1500;150 70 1500];
mpara{ff,1}.thresholdn{2,1}=[70 200 256*256];  
mpara{ff,1}.thresholdn{3,1}=[100 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{6,1}=[110 300 256*256];

% 
ff=5; %CR1 slide 9
mpara{ff,1}.threshold=[165 100 1500];                % [intensity-sizeS-sizeL]
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[165 100 1500;150 70 1500];
mpara{ff,1}.thresholdn{2,1}=[70 200 256*256];  
mpara{ff,1}.thresholdn{3,1}=[100 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{6,1}=[110 300 256*256];

% 
ff=6; %CR1 slide 11
mpara{ff,1}.threshold=[165 100 1500];                % [intensity-sizeS-sizeL]
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[165 100 1500;150 70 1500];
mpara{ff,1}.thresholdn{2,1}=[70 200 256*256];  
mpara{ff,1}.thresholdn{3,1}=[100 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 300 256*256];  
mpara{ff,1}.thresholdn{6,1}=[110 300 256*256];

% 
ff=7; %N29 slide 10
mpara{ff,1}.threshold=[165 100 1500];  % [intensity-sizeS-sizeL]
mpara{ff,1}.flag_rmbg=1;
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=9;
mpara{ff,1}.thresholdn{1,1}=[70 150 1500];  
mpara{ff,1}.thresholdn{2,1}=[100 150 256*256];  
mpara{ff,1}.thresholdn{3,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 200 256*256]; 
mpara{ff,1}.thresholdn{6,1}=[115 200 256*256]; 
mpara{ff,1}.thresholdn{7,1}=[180 300 256*256]; %
mpara{ff,1}.thresholdn{8,1}=[200 300 256*256]; %
mpara{ff,1}.thresholdn{9,1}=[240 300 256*256];
% mpara{ff,1}.thresholdn{10,1}=[200 200 256*256]; 
% 
ff=8; %N31 slide 10
mpara{ff,1}.threshold=[165 100 1500];  % [intensity-sizeS-sizeL]
mpara{ff,1}.flag_rmbg=1;
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[70 150 1500];  
mpara{ff,1}.thresholdn{2,1}=[100 150 256*256];  
mpara{ff,1}.thresholdn{3,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 200 256*256]; 
mpara{ff,1}.thresholdn{6,1}=[115 200 256*256];

% 
ff=9; %N33 slide 10
mpara{ff,1}.threshold=[165 100 1500];  % [intensity-sizeS-sizeL]
mpara{ff,1}.flag_rmbg=1;
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[70 150 1500];  
mpara{ff,1}.thresholdn{2,1}=[100 150 256*256];  
mpara{ff,1}.thresholdn{3,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 200 256*256]; 
mpara{ff,1}.thresholdn{6,1}=[200 200 256*256]; 
% 
ff=10; %N34 slide 10
mpara{ff,1}.threshold=[165 100 1500];  % [intensity-sizeS-sizeL]
mpara{ff,1}.flag_rmbg=1;
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[70 150 1500];  
mpara{ff,1}.thresholdn{2,1}=[100 150 256*256];  
mpara{ff,1}.thresholdn{3,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 200 256*256]; 
mpara{ff,1}.thresholdn{6,1}=[115 200 256*256]; 
% 
ff=11; %N36 slide 10
mpara{ff,1}.threshold=[165 100 1500];  % [intensity-sizeS-sizeL]
mpara{ff,1}.flag_rmbg=1;
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[70 150 1500];  
mpara{ff,1}.thresholdn{2,1}=[100 150 256*256];  
mpara{ff,1}.thresholdn{3,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 200 256*256]; 
mpara{ff,1}.thresholdn{6,1}=[115 200 256*256]; 
% 
ff=12; %N38 slide 10
mpara{ff,1}.threshold=[165 100 1500];  % [intensity-sizeS-sizeL]
mpara{ff,1}.flag_rmbg=1;
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[70 150 1500];  
mpara{ff,1}.thresholdn{2,1}=[100 150 256*256];  
mpara{ff,1}.thresholdn{3,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 200 256*256]; 
mpara{ff,1}.thresholdn{6,1}=[115 200 256*256]; 
% 
ff=13; %N40 slide 10
mpara{ff,1}.threshold=[165 100 1500];  % [intensity-sizeS-sizeL]
mpara{ff,1}.flag_rmbg=1;
mpara{ff,1}.box_size{1}=[256 256];
mpara{ff,1}.stages=[1];
mpara{ff,1}.loop_for_get_cell_box=6;
mpara{ff,1}.thresholdn{1,1}=[70 150 1500];  
mpara{ff,1}.thresholdn{2,1}=[100 150 256*256];  
mpara{ff,1}.thresholdn{3,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{4,1}=[120 200 256*256];  
mpara{ff,1}.thresholdn{5,1}=[120 200 256*256]; 
mpara{ff,1}.thresholdn{6,1}=[115 200 256*256]; 

for ff=14:size(dinfo,1)
    mpara{ff,1}.threshold=[165 100 1500];  % [intensity-sizeS-sizeL]
    mpara{ff,1}.flag_rmbg=1;
    mpara{ff,1}.box_size{1}=[256 256];
    mpara{ff,1}.stages=[1];
    mpara{ff,1}.loop_for_get_cell_box=6;
    mpara{ff,1}.thresholdn{1,1}=[70 150 1500];
    mpara{ff,1}.thresholdn{2,1}=[100 150 256*256];
    mpara{ff,1}.thresholdn{3,1}=[120 200 256*256];
    mpara{ff,1}.thresholdn{4,1}=[120 200 256*256];
    mpara{ff,1}.thresholdn{5,1}=[120 200 256*256];
    mpara{ff,1}.thresholdn{6,1}=[115 200 256*256];
end