function [data1, flag]=loadimage_and_getBackground_v07(data1,flag,setp,dispfig,varargin)
% (Dp1) [data1, flag]=loadimage_and_getBackground_v03(data1,flag,size_zpe,dispfig,varargin)
%     load and pre-processing images depend on the dataset, 
%     control by flag.DataSetInfo.UserID, flag.tif_select, flag.imadj, flag.im_reverse
%                flag.remove_background, flag.Low_res, flag.imzp   
%                data1.info.datatype, data1.info.imblk_sizeth
%{
    Input:
        
        data1.info.filepath_image='F:\Expdata\HU_William\IHC\data2\CR1\CR1 slide 10\'; 
        data1.info.filename_image='CR1 slide 10.tif';
        data1.info.folder_mat = 'matlab_rule_base_mask'  % folder for save .mat
        data1.info.datatype='opt_ctrl';   % {'opt_ctrl','opt_hx','astrocytes'}  
                                          % {'iba_ctrl','iba_hx'} for iba1 not finished
        data1.info.imblk_sizeth=100000;
        flag.imadj_function='adaptthreshold__v01';  
                         % pre-process modulate function in "~\IHC_v2\functions\imadj_functions"
                         % 'none': no preprocess 
                         % 'remove_large_block__v01': remove large black block for large image
                         % 'adaptthreshold__v01': (adaptthreshold -> imadj)x2

        flag.Low_res=-1; % or 10,20, load reduced reso image by 10x, or 20x
                         % or = -1 to load original size image                       
        flag.im_reverse = 1;        % = 1, white -> black
        flag.imzp = 1               % = 1, zero padding by setp.size_zpe
        size_zpe=[256 256], zeropadding of image
        dispfig=1;   %=1 to display images 
        varargin{1} = filepath_old0; % path of old data, not used in this version
    Output:
        data1.im0           % image in original color after processing
        data1.im0gray       % grayscale image         
        data1.imbackground  % brain-backgroud mask
        data1.info.imblk    % the number of removed blocks
        data1.im0orig       % original image w/o image processing
        data1.info.im0_size % image size after processing
        data1.info.Area     % area of regions include cells
    save files: 
        (1) the mask of brain region: imbackground
            [data1.info.filepath_image data1.info.folder_mat filesep data1.info.filename_image(1:end-4) '_background.mat']
            ex: 'H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\matlab_rule_base_mask\CR1 slide 10_background.mat'
%}
size_zpe=setp.size_zpe;
if isempty(varargin)~=1
    filepath_old0=varargin{1};
else
    filepath_old0='';
end

if isfield(data1.info,'filename_orig')
    imsavefilename=data1.info.filename_orig;
else
    imsavefilename=data1.info.filename_image;
end

setp.save_imsplit=flag.save_imsplit;
%figure(1);imagesc(data1.im0);axis image
tiff_info = imfinfo([data1.info.filepath_image data1.info.filename_image]);

if flag.Low_res==-1
    switch flag.operate_mode
        case 'load_results'
            [~,name1,ext1]=fileparts(data1.info.filename_image);
            data1.im0=imread([data1.info.filepath_image 'results' filesep 'images' filesep name1 '.jpg']);
            data1.im0orig=imread([data1.info.filepath_image data1.info.filename_image]);
            data1.info.imOrig_size=size(data1.im0orig);

            if flag.keep_imorig~=1
                data1=rmfield(data1,'im0orig');

            end
        case 'processing'
            try
                data1.im0=imread([data1.info.filepath_image data1.info.filename_image]);
            catch
                copyfile([data1.info.filepath_image data1.info.filename_image], [data1.info.filepath_image data1.info.filename_image(1:end-4) '_CMYK.jpg']);
                filename1 = [data1.info.filepath_image data1.info.filename_image];
                magickCommand = ['"' 'C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick' '" convert "' filename1 '" -colorspace "sRGB" "' filename1 '"'];
                system(magickCommand);
                data1.im0=imread([data1.info.filepath_image data1.info.filename_image]);
            end

            data1.info.imOrig_size=size(data1.im0);
            if flag.keep_imorig==1
                data1.im0orig=data1.im0;
            end
    end
    data1.info.imOrig_size=size(data1.im0);
else
    filepath_lowres=[data1.info.filepath_image 'results' filesep 'images' filesep];
    filename_lowres=[data1.info.filename_image(1:end-4) '__L' num2str(flag.Low_res) 'x.jpg']; % image after zp
    if exist([filepath_lowres filename_lowres],'file');
        data1.im0=imread([filepath_lowres filename_lowres]);flag.remove_background=0;
       % figure(2);imshow(data1.im0)
    else
        flag.Low_res=-1;
        data1.im0=imread([data1.info.filepath_image data1.info.filename_image]);
    end
end


% if only one channel => RGB channel in .im0
if size(data1.im0,3)~=3
    im0=data1.im0;data1=rmfield(data1,'im0');
    switch size(im0,3);
        case 4
            im0=im2uint8(squeeze(im0(:,:,1)));
            data1.im0(:,:,1)=im0;
            data1.im0(:,:,2)=im0;
            data1.im0(:,:,3)=im0;
            data1.im0orig=data1.im0;
    end
end
figure(1);imshow(data1.im0)

% if flag.im_reverse==1
%     data1.im0gray = 255-rgb2gray(data1.im0);
% else
%     data1.im0gray = rgb2gray(data1.im0);
% end
% figure(1);imshow(uint8(data1.imbackground).*data1.im0gray)
filepath_mat=[data1.info.filepath_image data1.info.folder_mat];if ~exist(filepath_mat, 'dir');mkdir(filepath_mat);end
%filename_background_mat=[data1.info.filename_image(1:end-4) '_background.mat'];
if isempty(strfind(data1.info.filepath_image,'Shoykhet'))==0
    switch data1.info.filename_image
        case 'N34 slide 11.tif'
            filename_background_mat=[data1.info.filename_image(1:end-4) '_background_m.mat'];
        otherwise
            filename_background_mat=[data1.info.filename_image(1:end-4) '_background.mat'];
    end
else
    filename_background_mat=[data1.info.filename_image(1:end-4) '_background_m.mat'];
end


if exist([filepath_mat filesep filename_background_mat],'file')
    ppim=load([filepath_mat filesep filename_background_mat]);
    
    data1.imbackground=ppim.imbackground;
    
    % imF1 = labeloverlay(data1.im0,ppim.imbackground,'Colormap',[1 0 0],'Transparency',0.5);
    % figure(1);imagesc(data1.im0gray);axis image
    % bwm=roipoly;
    % imbackground=ppim.imbackground;
    % imbackground(bwm==1)=0;
    % save([filepath_mat filesep filename_background_mat],'imbackground');


    if flag.Low_res==-1
        if ~exist([data1.info.filepath_image 'results' filesep 'images' filesep imsavefilename(1:end-4) '_grayOrig.jpg'],'file')
            if ~exist([data1.info.filepath_image filesep 'results' filesep 'images' filesep], 'dir');mkdir([data1.info.filepath_image filesep 'results' filesep 'images' filesep]);end
            if flag.im_reverse==1
                im0=255-rgb2gray(data1.im0);
            else
                im0=rgb2gray(data1.im0);
            end
            if flag.save_imsplit~=0
                imwriteSplit(im0,[data1.info.filepath_image filesep 'results' filesep 'images' filesep imsavefilename(1:end-4) '_grayOrig.jpg'],flag.save_imsplit);
            else
                imwrite(im0,[data1.info.filepath_image filesep 'results' filesep 'images' filesep imsavefilename(1:end-4) '_grayOrig.jpg']);
            end
            clear im0
        end

    else

        data1.info.im0_size=size(data1.imbackground);
        data1.info.Area=sum(double(data1.imbackground(:))).*data1.info.pixel_size.*data1.info.pixel_size;

    end
    %ppim=rmfield(ppim,'adj_im0gray');
    if ~isfield(ppim,'adj_im0gray')  % if the adjust image exist
       % if size(ppim.adj_im0gray,1)<size(ppim.imbackground,1)
            flag.Low_res=-1;
            data1.im0=imread([data1.info.filepath_image data1.info.filename_image]);
            data1.imbackground=ppim.imbackground;
            switch flag.imadj_function
                case {'remove_large_block__v01','none','reverse_bw'}; % for no image adjust
                    try
                        eval(['data1=' flag.imadj_function '(data1,setp);']);
                    catch
                        eval(['data1=' flag.imadj_function '(data1);']);
                    end
                    imbackground=ppim.imbackground;adj_im0gray=data1.im0gray.*uint8(imbackground);
                    data1.im0gray=data1.im0gray.*uint8(imbackground);
                    save([filepath_mat filesep filename_background_mat],'imbackground','adj_im0gray');
                otherwise
                    try
                        eval(['data1=' flag.imadj_function '(data1,setp);']);
                    catch
                        eval(['data1=' flag.imadj_function '(data1);']);
                    end
                    imbackground=data1.imbackground;adj_im0gray=data1.im0gray;
                    if ~exist([filepath_mat filesep filename_background_mat],'file')
                        save([filepath_mat filesep filename_background_mat],'imbackground','adj_im0gray');
                    end
            end
       % else
%             for r=1:3
%                 im0r=data1.im0(:,:,r);
%                 if flag.im_reverse==1
%                     im0r(data1.imbackground==0)=255;
%                 else
%                     im0r(data1.imbackground==0)=0;
%                 end
%                 im0(:,:,r)=im0r;
%             end
%             data1.im0=uint8(im0);
       % end
        %data1.im0gray=ppim.adj_im0gray;
    else
        if flag.Low_res==-1
            data1.im0gray=ppim.adj_im0gray;
            data1.info.Area=sum(double(data1.imbackground(:))).*data1.info.pixel_size.*data1.info.pixel_size;
%figure(1);imshow(data1.im0gray)
            
            switch flag.imadj_function
                case {'remove_large_block__v01','none','reverse_bw'}; % for no image adjust
                    try
                        eval(['data1=' flag.imadj_function '(data1,setp);']);
                    catch
                        eval(['data1=' flag.imadj_function '(data1);']);
                    end


                    imbackground=ppim.imbackground;adj_im0gray=data1.im0gray.*uint8(imbackground);
                    data1.im0gray=data1.im0gray.*uint8(imbackground);
                    save([filepath_mat filesep filename_background_mat],'imbackground','adj_im0gray','-v7.3');
                otherwise
                    if isfield(ppim,'imbackground')~=1 || isfield(ppim,'adj_im0gray')~=1
                        try
                            eval(['data1=' flag.imadj_function '(data1,setp);']);
                        catch
                            eval(['data1=' flag.imadj_function '(data1);']);
                        end
                        imbackground=data1.imbackground;adj_im0gray=data1.im0gray;
                        if ~exist([filepath_mat filesep filename_background_mat],'file')
                            save([filepath_mat filesep filename_background_mat],'imbackground','adj_im0gray','-v7.3');
                        end
                    end
            end


        else
            adj_im0gray_zp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(ppim.adj_im0gray,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(ppim.adj_im0gray,2),:)=ppim.adj_im0gray;
            data1.im0gray=imresize(adj_im0gray_zp,size(data1.im0,[1,2]));clear at0zp
            data1.info.Area=sum(double(data1.imbackground(:))).*data1.info.pixel_size.*data1.info.pixel_size;
%           imbackground_zp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(ppim.adj_im0gray,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(ppim.adj_im0gray,2),:)=data1.imbackground;
%           data1.imbackground=imresize(imbackground_zp,size(data1.im0,[1,2]),'Method','nearest');

        end
    end

else
    flag.Low_res=-1;
    switch flag.imadj_function
        case {'remove_large_block__v01','none','reverse_bw'} % for no image adjust
            try
                eval(['data1=' flag.imadj_function '(data1,setp);']);
            catch
                eval(['data1=' flag.imadj_function '(data1);']);
            end
            imbackground=data1.imbackground;
            adj_im0gray=data1.im0gray;

            if ~exist([filepath_mat filesep filename_background_mat],'file')
                save([filepath_mat filesep filename_background_mat],'imbackground','adj_im0gray','-v7.3');
            end
        otherwise
            try
                eval(['data1=' flag.imadj_function '(data1,setp);']);
            catch
                eval(['data1=' flag.imadj_function '(data1);']);
            end
            imbackground=data1.imbackground;adj_im0gray=data1.im0gray;
            if ~exist([filepath_mat filesep filename_background_mat],'file')
                save([filepath_mat filesep filename_background_mat],'imbackground','adj_im0gray','-v7.3');
            end
    end
    % try
    %     eval(['data1=' flag.imadj_function '(data1,setp);']);
    % catch
    %     eval(['data1=' flag.imadj_function '(data1);']);
    % end
    % imbackground=data1.imbackground;adj_im0gray=data1.im0gray;
    % if ~exist([filepath_mat filesep filename_background_mat],'file')
    %     save([filepath_mat filesep filename_background_mat],'imbackground','adj_im0gray');
    % end
end

% if ~exist([data1.info.filepath_image filesep 'results' filesep 'images' filesep  imsavefilename(1:end-4) '_grayAdj.jpg'],'file');
%     if ~isdir([data1.info.filepath_image filesep 'results' filesep 'images' filesep]);mkdir([data1.info.filepath_image filesep 'results' filesep 'images' filesep]);end
%     % save images in original size in results folder
%     %if size(data1.im0gray,1)~= data1.info.imOrig_size(1) || size(data1.im0gray,2)~= data1.info.imOrig_size(2)
%     if flag.save_imsplit~=0
%        imwriteSplit(data1.im0gray,[data1.info.filepath_image filesep 'results' filesep 'images' filesep  imsavefilename(1:end-4) '_grayAdj.jpg'],flag.save_imsplit)
% 
%     else
%        imwrite(data1.im0gray,[data1.info.filepath_image filesep 'results' filesep 'images' filesep  imsavefilename(1:end-4) '_grayAdj.jpg'])
%     end    
%     %end
% end

% adjust image resolution
if flag.Low_res==-1
    if data1.info.pixel_size~=0.464
        %data1.info.pixel_size=0.464/1.5
        data1.im0=imresize(data1.im0,round(size(data1.im0,[1,2])/(0.464/data1.info.pixel_size)));
        data1.im0gray_orig=data1.im0gray;
        data1.im0gray=imresize(data1.im0gray,round(size(data1.im0gray,[1,2])/(0.464/data1.info.pixel_size)));
        data1.imbackground=imresize(data1.imbackground,round(size(data1.imbackground,[1,2])/(0.464/data1.info.pixel_size)));
        %im0=imresize(data1.im0,round(size(data1.im0,[1,2])*(0.464/data1.info.pixel_size)));
        %figure(1);imshow(im0(1000:1000+511,1000:1000+511))
        %figure(2);imshow(im0(1000:1000+256,1000:1000+256))
    end
    data1.info.im0_size=size(data1.imbackground);
    data1.info.Area=sum(double(data1.imbackground(:))).*data1.info.pixel_size.*data1.info.pixel_size;
end
%figure(1);imshow(data1.im0)

%     % if flag.imzp==1 % move to im_zeropadding_v02
%     %     imbackgroundzp=uint8(false(size(data1.imbackground,1)+size_zpe(1),size(data1.imbackground,2)+size_zpe(2),size(data1.imbackground,3)));
%     %     imbackgroundzp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.imbackground,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.imbackground,2),:)=data1.imbackground;clear data1.imbackground
%     %     im_size=size1.im0);
%     %     data1.info.im0_size=size(imbackgroundzp);
%     %     data1.info.Area=sum(double(imbackgroundzp(:))).*data1.info.pixel_size.*data1.info.pixel_size;
%     %     data1.imbackground=imresize(imbackgroundzp,[im_size(1) im_size(2)],'Method','nearest');(data
%     % else
%     % not do zeropadding for low resolution data
%     %imbackgroundzp=data1.imbackground;
%     %data1.info.im0_size=size(imbackgroundzp);
%     %data1.info.Area=sum(double(imbackgroundzp(:))).*data1.info.pixel_size.*data1.info.pixel_size;
%     % end
% else
%     %if flag.imzp==1
%     %    imbackgroundzp=uint8(false(size(data1.imbackground,1)+size_zpe(1),size(data1.imbackground,2)+size_zpe(2),size(data1.imbackground,3)));
%     %    imbackgroundzp(ceil(size_zpe(1)/2)+1:ceil(size_zpe(1)/2)+size(data1.imbackground,1),ceil(size_zpe(2)/2)+1:ceil(size_zpe(2)/2)+size(data1.imbackground,2),:)=data1.imbackground;clear data1.imbackground
%     %else
%     %   imbackgroundzp=data1.imbackground;
%     %end
%     %data1.info.im0_size=size(imbackground);
%     %data1.info.Area=sum(double(imbackground(:))).*data1.info.pixel_size.*data1.info.pixel_size;
% 
% end
