function [unet_result]=load_unet_result_png_v3(filepath,train_num,size_box2,varargin)
filename0=dir(filepath);
if isempty(varargin)~=1
    result_yolo=varargin{1};
    %unet_result.score=zeros(length(filepath_info),1);
    xc=fix((result_yolo.bbox(:,1)+result_yolo.bbox(:,3)/2));
    yc=fix((result_yolo.bbox(:,2)+result_yolo.bbox(:,4)/2));
    xp=xc-fix(size_box2(2)/2);
    yp=yc-fix(size_box2(1)/2);
    idx=find(xp<1);if isempty(idx)~=1;xp(idx)=1;end
    idy=find(yp<1);if isempty(idy)~=1;yp(idy)=1;end
end


tt=1;
for mm=1:length(filename0)
    if strcmp(filename0(mm).name,'.')==1 || strcmp(filename0(mm).name,'..')==1;else;
        if isempty(strfind(filename0(mm).name,'.png'))~=1
            filename{tt,1}=filename0(mm).name;tt=tt+1;
        end
    end
end


%filename={filename0(3:end).name}';

bw0=imread([filepath filesep filename{1}]);
size_bw0=size(bw0);
unet_result.bbmaskU=false([train_num size_bw0]);
unet_result.bboxU=zeros(train_num,4);
tt1=1;
for mm=1:length(filename)
    sn1=strfind(filename{mm},'_n');
    sn2=strfind(filename{mm},'_');
    ind=str2double(filename{mm}(sn1(1)+2:sn2(2)-1));
    sn3=strfind(filename{mm},'_y');
    sn4=strfind(filename{mm},'_x');
    sn5=strfind(filename{mm},'__result');
    yi=str2double(filename{mm}(sn3(1)+2:sn4(1)-1));
    try
        xi=str2double(filename{mm}(sn4(1)+2:sn5(1)-1));
    catch
        sn5=strfind(filename{mm},'.png');
        xi=str2double(filename{mm}(sn4(1)+2:sn5(1)-1));
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
                        fprintf(['wrong index for score: ' num2str(ind) '(' num2str(mm) ')'])
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
    
    bw0=imread([filepath filesep filename{mm}]);
    unet_result.bboxU(ind,:)=[xi,yi,size_bw0];
    bw0(bw0~=0)=1;
    unet_result.bbmaskU(ind,:,:)=logical(bw0);
end



