function [unet_result]=load_unet_train_png_v2(data_info,varargin)
filepath_info=data_info.file_info;
size_box2=data_info.train_imsize;
if isempty(varargin)~=1
    result_yolo=varargin{1};
    unet_result.score=zeros(length(filepath_info),1);
    xc=fix((result_yolo.bbox(:,1)+result_yolo.bbox(:,3)/2));
    yc=fix((result_yolo.bbox(:,2)+result_yolo.bbox(:,4)/2));
    xp=xc-fix(size_box2(2)/2);
    yp=yc-fix(size_box2(1)/2);
    idx=find(xp<1);if isempty(idx)~=1;xp(idx)=1;end
    idy=find(yp<1);if isempty(idy)~=1;yp(idy)=1;end
end


unet_result.bbmaskU=false([length(filepath_info) size_box2]);
unet_result.bboxU=zeros(length(filepath_info),4);
tt1=1;
for mm=1:length(filepath_info)
    filename=filepath_info(mm).file_name; 
    if isfield(filepath_info(mm),'file_name_mask')
        filename_mask=filepath_info(mm).file_name_mask; %filename=filepath_info(mm).file_name_mask;
        filepath_mask=filepath_info(mm).file_path_mask;
    else
        filename_mask='';
    end
    if isempty(filename)~=1
       
        %size_bw0=size(bw0);
     
        sn1=strfind(filename,'_n');
        sn2=strfind(filename,'_');
        ind=str2double(filename(sn1(1)+2:sn2(2)-1));

        sn3=strfind(filename,'_y');
        sn4=strfind(filename,'_x');
        sn5=strfind(filename,'.png');
        
        yi=str2double(filename(sn3(1)+2:sn4(1)-1));
        xi=str2double(filename(sn4(1)+2:sn5(1)-1));
        if isempty(filename_mask)~=1
            if exist([filepath_mask filesep filename_mask],'file')~=0
                bw0=imread([filepath_mask filesep filename_mask]);
            end
        end
        if isempty(varargin)~=1
            id_score=intersect(find(xp==xi),find(yp==yi));
            if isempty(id_score)~=1
                if length(id_score)>1
                    indx=find(id_score==ind);
                    if isempty(indx)~=1
                        id_score=ind;
                    else
                        if id_score~=ind
                            fprint(['wrong index for score: ' num2str(ind) '(' num2str(mm) ')'])
                        end
                    end
                end
              %  if mm==25113
              %      mm %825 N25 slide 11_n32602_y16040_x13749.png
              %  end
                
                unet_result.score(ind)=result_yolo.score(id_score);
                unet_result.ind_yolo(ind)=id_score;
                if id_score~=ind
                    fprint(['wrong index for score: ' num2str(ind) '(' num2str(mm) ')'])
                end
            else
                unet_result.error_file{tt1,1}=mm;
                unet_result.error_file{tt1,2}=filename;
                tt1=tt1+1;
            end
        end
        unet_result.bboxU(ind,:)=[xi,yi,size_box2];
        
        if isempty(filename_mask)~=1
            if exist([filepath_mask filesep filename_mask],'file')~=0
                unet_result.score(ind)=1;
                bw0(bw0~=0)=1;
                if isempty(filename_mask)~=1
                    unet_result.bbmaskU(ind,:,:)=logical(bw0);
                end
            end
        end
        
    end
    
end

if sum(unet_result.bbmaskU(:))==0
    unet_result=rmfield(unet_result,'bbmaskU');
end