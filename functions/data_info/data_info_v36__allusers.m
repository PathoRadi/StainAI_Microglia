function dinfo=data_info_v36__allusers(filepath0, DataSetInfo)
ff=1;
%filetype='jpg';
for ss=1:length(DataSetInfo.sample_ID)
    fname0=dir([filepath0 DataSetInfo.sample_ID{ss} filesep]);
    fname0=fname0(~ismember({fname0.name},{'.','..'}));

    for si=1:length(fname0)
        if fname0(si).isdir==0
            %filetype=
            [~,name,filetype] = fileparts(fname0(si).name);filetype=filetype(2:end);
            if strcmpi(filetype,'tiff')==1;filetype='tif';end;
            if strcmpi(filetype,'jpeg')==1;filetype='jpg';end;
  
            %if strcmpi(fname0(si).name(end-2:end),filetype)==1   %%%% need change
                fnameNew=[DataSetInfo.sample_ID{ss} ' slide ' num2str(si)];
                if ~exist([filepath0  DataSetInfo.sample_ID{ss} filesep fnameNew],'dir')
                    mkdir([filepath0  DataSetInfo.sample_ID{ss} filesep fnameNew])
                    copyfile([filepath0 DataSetInfo.sample_ID{ss} filesep fname0(si).name],[filepath0  DataSetInfo.sample_ID{ss} filesep fnameNew filesep fnameNew '.' filetype])
                    delete([filepath0 DataSetInfo.sample_ID{ss} filesep fname0(si).name]);
                    dinfo{ff,1}.filepath_image=[filepath0  DataSetInfo.sample_ID{ss} filesep fnameNew filesep];
                    dinfo{ff,1}.filename_image=[fnameNew '.' filetype];
                    dinfo{ff,1}.filename_orig=fname0(si).name;
                    %dinfo{ff,1}.pixel_size=0.464; %um  %%%% need change
                    dinfo{ff,1}.pixel_size=DataSetInfo.im_pixel_size;
                 
                    dinfo{ff,1}.imblk_sizeth=100000;
                    dinfo{ff,1}.box_source='from_threshold'; % or 'from_Allen'
                    dinfo{ff,1}.datatype='';   % opt_hx or 'opt_ctrl'
                    dinfo{ff,1}.folder_mat='matlab_rule_base_mask'; % save .mat and masks in this folder
                    dinfo{ff,1}.atlas_filename=[dinfo{ff}.filename_image(1:end-4) '.nii'];
                    dinfo{ff,1}.folderTag_result.yolo5={'noGt_im','YOLO_conf_50_100';'noGt_imShift','YOLO_conf_50_100'}; % source - model
                    dinfo{ff,1}.folderTag_result.UnetAllCell={'test_image';'UNET_512'};
                    dinfo{ff,1}.folderTag_result.UnetOneCell={'Yolo512_Unet','netC4b1'};
                    dinfo{ff,1}.folderTag_train.UnetOneCell={'URBG_UnetOneCell';'Yolo512_UnetOneCell';'Yolo1024_Unet_UnetOneCell'};
                    dinfo{ff,1}.folderTag_train.maskrcnn={'URBG_im'; 'URBG_imShift'};
                    %dinfo{ff,1}.folderTag_train.imJ2maskrcnn={'Children_wEdge'};
                    dinfo{ff,1}.folderTag_test.yolo2unet={'Yolo512_Unet';'Yolo1024_Unet'};
                    dinfo{ff,1}.folderTag_test.maskrcnn={'noGt_im';'noGt_imShift'};
                    dinfo{ff,1}.foldername_coco={'cocoJson'};
                    dinfo{ff,1}.imId=uint64(ff*1000);
                    %dinfo{ff,1}.bwk_case=DataSetInfo.bwk_case;  %'method_003';

                    xlsrename{1,1}='name_orig';xlsrename{1,2}='name_new';xlsrename{1,3}='filepath_image';
                    xlsrename{1+ff,1} = dinfo{ff,1}.filename_orig;
                    xlsrename{1+ff,2} = dinfo{ff,1}.filename_image;
                    xlsrename{1+ff,3} = dinfo{ff,1}.filepath_image;
                    ff=ff+1;
                end
           % end
   

        end

    end
end
try
    xlswrite([filepath0 DataSetInfo.renamefile],xlsrename)
catch
    if exist([filepath0 DataSetInfo.renamefile],'file')
        rename=readtable([filepath0 DataSetInfo.renamefile]);

        for ff=1:size(rename,1)
            sn=strfind(rename.filepath_image{ff},filesep);
            %dinfo{ff,1}.filepath_image=rename.filepath_image{ff};
            dinfo{ff,1}.filepath_image=[filepath0 rename.filepath_image{ff}(sn(end-2)+1:sn(end))];

            dinfo{ff,1}.filename_image=rename.name_new{ff};
            dinfo{ff,1}.filename_orig=rename.name_orig{ff};
            dinfo{ff,1}.pixel_size=DataSetInfo.im_pixel_size;

            dinfo{ff,1}.imblk_sizeth=100000;
            dinfo{ff,1}.box_source='from_threshold'; % or 'from_Allen'
            dinfo{ff,1}.datatype='';   % or 'opt_ctrl'
            dinfo{ff,1}.folder_mat='matlab_rule_base_mask'; % save .mat and masks in this folder
            dinfo{ff,1}.atlas_filename=[dinfo{ff}.filename_image(1:end-4) '.nii'];
            dinfo{ff,1}.folderTag_result.yolo5={'noGt_im','YOLO_conf_50_100';'noGt_imShift','YOLO_conf_50_100'}; % source - model
            dinfo{ff,1}.folderTag_result.UnetAllCell={'test_image';'UNET_512'};
            dinfo{ff,1}.folderTag_result.UnetOneCell={'Yolo512_Unet','UNET'};
            dinfo{ff,1}.folderTag_train.UnetOneCell={'URBG_UnetOneCell';'Yolo512_UnetOneCell';'Yolo1024_Unet_UnetOneCell'};
            dinfo{ff,1}.folderTag_train.maskrcnn={'noGt_im'; 'noGt_imShift'};
            %dinfo{ff,1}.folderTag_train.imJ2maskrcnn={'Children_wEdge'};
            dinfo{ff,1}.folderTag_test.yolo2unet={'Yolo512_Unet';'Yolo1024_Unet'};
            dinfo{ff,1}.folderTag_test.maskrcnn={'noGt_im';'noGt_imShift'};
            dinfo{ff,1}.foldername_coco={'cocoJson'};
            dinfo{ff,1}.imId=uint64(ff*1000);
            %dinfo{ff,1}.bwk_case='method_003';

        end
    else
        dinfo{ff,1}.filepath_image=[filepath0 rename.filepath_image{ff}(sn(end-2)+1:sn(end))];
        dinfo{ff,1}.filename_image;



    end
end


% dgroups(1,:)={'ctrl','Control',{'ct1'}};   %%%% need change
% dgroups(2,:)={'TBI1','TBI 1Hit',{'tb1'}};  %%%% need change

dgroups(1,:)={'UM1','unknow',{'UM1'}};   %%%% need change
%dgroups(2,:)={'TBI1','TBI 1Hit',{'tb1'}};  %%%% need change

for ff=1:length(dinfo)
    if isfield(DataSetInfo,'thk')
        dinfo{ff,1}.thk=DataSetInfo.thk; 
    else
        dinfo{ff,1}.thk=0.04;  %0.04; %mm
    end
    for dg=1:size(dgroups,1)
        for gn=1:length(dgroups{dg,3})
            keywords=dgroups{dg,3}(gn);
            fnum1=getkeyword_02({dinfo{ff}.filename_image},keywords,{''});
            if isempty(fnum1)~=1
                dinfo{ff,1}.exp_condition=dgroups(dg,1:2);
            else
                dinfo{ff,1}.exp_condition={'unknow','unknow',{'unknow'}};
            end
        end

    end
end


