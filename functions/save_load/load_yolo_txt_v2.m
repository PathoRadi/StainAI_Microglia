function result_yolo=load_yolo_txt_v2(filepath_load_yolo,imsize0, train_imsize, size_im4d, pixshift,dinfo ,varargin)
%filepath_load_yolo=['F:\Expdata\HU_William\IHC\brain_optical_im\cell_in_bbox3\results_yolo' filesep dinfo{ff}.imat_name filesep num2str(train_imsize(1)) 'x' num2str(train_imsize(2))];
% pixshift: y - x
% box_im0_yolo: x, y, width, height
filename0=dir(filepath_load_yolo);
filename0=filename0(~ismember({filename0.name},{'.','..'}));
filename_yolo={filename0.name}';

% tt=1;clear filename_yolo
% for mm=1:length(filename0)
%     if strcmp(filename0(mm).name,'.')==1 || strcmp(filename0(mm).name,'..')==1;else;
%         filename_yolo{tt,1}=filename0(mm).name;tt=tt+1;
%     end
% end
if isempty(varargin)~=1
    yolo_class_name=varargin{1};
end

box_ims_yolo=cell(size_im4d(1),1);
box_im0_yolo=cell(size_im4d(1),1);
label_yolo=cell(size_im4d(1),1);
yolo_predict=cell(size_im4d(1),1);
yolo_allc=cell(size_im4d(1),1);
yolo_class=cell(size_im4d(1),1);
if isempty(filename_yolo)~=1
    for mm=1:length(filename_yolo)
        sn0=findstr(filename_yolo{mm},dinfo.filename_image(1:end-4));
        name_temp=filename_yolo{mm}(sn0+length(dinfo.filename_image(1:end-4)):end);
        
        sn=findstr(name_temp,'_');
        if length(sn)==1
            sn=findstr(name_temp,'_n');
            if isempty(sn)==1
                sn(1)=findstr(name_temp,'_s');
            end
            sn(2)=findstr(name_temp,'.txt');
            ind_ex=str2num(name_temp(sn(1)+2:sn(2)-1));
        else
            try
            ind_ex=str2num(name_temp(sn(1)+1:sn(2)-1));
            catch
                mm
            end
        end

        

        A = readmatrix([filepath_load_yolo filename_yolo{mm}]);
        if isnan(A)==1
            id=fopen([filepath_load_yolo filename_yolo{mm}],'r');
            tline = fgets(id);
            if isempty(tline)~=1
                A=str2num(tline);
            end;fclose(id);
        end
        if isempty(A)~=1

            if isnan(A)~=1
                box_temp=fix([A(:,2)*train_imsize(2)-A(:,4)*train_imsize(2)/2 A(:,3)*train_imsize(1)-A(:,5)*train_imsize(2)/2 A(:,4)*train_imsize(2) A(:,5)*train_imsize(1)]);
                indx0=find(box_temp(:,1)==0);if isempty(indx0)~=1;box_temp(indx0,1)=1;end
                indx0=find(box_temp(:,2)==0);if isempty(indx0)~=1;box_temp(indx0,2)=1;end
                box_ims_yolo{ind_ex,1}=box_temp;

                drc=ceil(imsize0./train_imsize);
                if imsize0(1)==train_imsize(1) && imsize0(2)==train_imsize(2)
                    box_im0_yolo{ind_ex,1}=box_temp;
                else
                    if mod(ind_ex,drc(2))==0
                        box_im0_yolo{ind_ex,1}(:,:)=fix([(ind_ex-(ind_ex/drc(2)-1)*drc(2)-1)*train_imsize(2)+box_temp(:,1)-pixshift(2)...
                            (ind_ex/drc(2)-1)*train_imsize(1)+box_temp(:,2)-pixshift(1)...
                            A(:,4)*train_imsize(2) A(:,5)*train_imsize(1)]);
                    else
                        box_im0_yolo{ind_ex,1}(:,:)=fix([(ind_ex-fix(ind_ex/drc(2))*drc(2)-1)*train_imsize(2)+box_temp(:,1)-pixshift(2)...
                            fix(ind_ex/drc(2))*train_imsize(1)+box_temp(:,2)-pixshift(1)...
                            A(:,4)*train_imsize(2) A(:,5)*train_imsize(1)]);
                    end
                end

                if size(A,2)>5
                    yolo_allc{ind_ex,1}(:,:)=[box_im0_yolo{ind_ex,1}(:,:) A(:,6)];
                else
                    yolo_allc{ind_ex,1}(:,:)=[box_im0_yolo{ind_ex,1}(:,:) A(:,5)];
                end

                if pixshift(2)~=0
                    idxn=find(box_im0_yolo{ind_ex,1}(:,1)<1);
                    if isempty(idxn)~=1
                        box_im0_yolo{ind_ex,1}(:,1)=imsize0(2)-abs(box_im0_yolo{ind_ex,1}(:,1));
                    end

                    idxn=find(box_im0_yolo{ind_ex,1}(:,1)>imsize0(2));
                    if isempty(idxn)~=1
                        box_im0_yolo{ind_ex,1}(:,1)=abs(box_im0_yolo{ind_ex,1}(:,1)-imsize0(2));
                    end
                end

                if pixshift(1)~=0
                    idxn2=find(box_im0_yolo{ind_ex,1}(:,2)<1);
                    if isempty(idxn2)~=1
                        box_im0_yolo{ind_ex,1}(:,2)=imsize0(1)-abs(box_im0_yolo{ind_ex,1}(:,2));
                    end

                    idxn2=find(box_im0_yolo{ind_ex,1}(:,2)>imsize0(1));
                    if isempty(idxn2)~=1
                        box_im0_yolo{ind_ex,1}(:,2)=abs(box_im0_yolo{ind_ex,1}(:,2)-imsize0(1));
                    end
                end

            end
            yolo_class{ind_ex,1}=repmat({''},size(A,1),1);
            if isempty(varargin)~=1
                for ci=1:length(yolo_class_name)
                    try
                        ic=find(A(:,1)==ci-1);
                    catch
                        ic=1
                    end
                    if isempty(ic)~=1;
                        yolo_class{ind_ex,1}(ic)=repmat(yolo_class_name(ci),length(ic),1);
                    end
                end
            end




            for ii=1:size(box_ims_yolo{ind_ex,1},1)
                if size(A,2)>5
                    label_yolo{ind_ex,1}{ii,1} = [num2str(A(ii,6),'%0.2f')];
                    yolo_predict{ind_ex,1}(ii,1) = A(ii,6);
                else
                    label_yolo{ind_ex,1}{ii,1} = 0;
                    yolo_predict{ind_ex,1}(ii,1) = 0;
                end
            end

        end
        
    end
end
result_yolo.bbox=cell2mat(box_im0_yolo);
result_yolo.bbox_ims=box_ims_yolo;
result_yolo.label=label_yolo;
iex=find(cellfun(@isempty,yolo_class)==0);
result_yolo.yolo_class0=yolo_class;
result_yolo.yolo_class=vertcat (yolo_class{iex});
result_yolo.score=cell2mat(yolo_predict);
result_yolo.score_ims=yolo_predict;

%, box_ims_yolo, label_yolo, yolo_predict, yolo_allc




