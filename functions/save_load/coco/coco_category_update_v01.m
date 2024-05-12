function cocostruct=coco_category_update_v01(cocostruct,data1,varargin)
%    (R7) cocoObj=coco_category_update_v01(cocostruct,data1,varargin)
%        update coco category for atlas on category_id2, category_id2_name, category_id4, category_id4_name 
%{
         input:
             cocostruct.annotations
             data1.atlas_brain
                  .atlas_table
         output:
             cocoObj.data.annotations  <= from cocoApi, with new category
             cocoObj.data.info.atlas_table
%}
if isempty(varargin)~=1
    options.case=varargin{1};
else
    options.case='atlas';
end
cocostruct.categories=data1.categories;
switch options.case
    case 'atlas'
        cocostruct.categories=data1.categories;
        bbox=[reshape([cocostruct.annotations(:).bbox],4,length(cocostruct.annotations))]';

        if isfield(data1,'atlas_brain')==1;

            
            bw0=false(size(data1.atlas_brain));bw0(data1.atlas_brain~=0)=true;
            cocostruct.info.Brain_Area=sum(bw0(:))*(data1.info.pixel_size).^2;
            cocostruct.categories=data1.categories;
            bbox_center=fix([bbox(:,1)+bbox(:,3)/2 bbox(:,2)+bbox(:,4)/2]);%x,y
            ixe=find(bbox_center(:,1)>size(data1.atlas_brain,2));
            if isempty(ixe)~=1;bbox_center(ixe,1)=size(data1.atlas_brain,2);end
            iye=find(bbox_center(:,2)>size(data1.atlas_brain,1));
            if isempty(iye)~=1;bbox_center(iye,2)=size(data1.atlas_brain,1);end
            ixl=find(bbox_center(:,1)<1);
            if isempty(ixl)~=1;bbox_center(ixl,1)=1;end
            iyl=find(bbox_center(:,2)<1);
            if isempty(iyl)~=1;bbox_center(iyl,2)=1;end
            
           % ia0=unique(data1.atlas_brain);
            ind = sub2ind(size(data1.atlas_brain),bbox_center(:,2),bbox_center(:,1));%y,x
            num_at=data1.atlas_brain(ind);
            id_at=unique(data1.atlas_brain);%unique(num_at);
            index_at=zeros(length(id_at),1);
            %data1.atlas_table(:,5:6)=repmat({nan},size(data1.atlas_table,1),2);
            ccc=data1.atlas_table.id; %(:,2);
            for aa=1:length(id_at)
             
                bw0=false(size(data1.atlas_brain));
                bw0(data1.atlas_brain==id_at(aa))=true;
                
                index_at(aa) = find([ccc] == id_at(aa));
                %data1.atlas_table.are{index_at(aa),6}=sum(bw0(:))*(data1.info.pixel_size).^2;  
                %idna=find(num_at==id_at(aa));
                in=find(strcmpi({cocostruct.categories.name},data1.atlas_table.atlas_name{index_at(aa)})==1);
                %data1.atlas_table{index_at(aa),1}
                if strcmpi(data1.atlas_table{index_at(aa),1},'brain')==1
                    if isempty(in)==1
                        in=find(strcmpi({cocostruct.categories.name},'microglia')==1);
                    end
                end
                %category_id2c(idna,:)=cocostruct.categories(in).id;
                if isempty(in)~=1
                    category_id2(num_at==id_at(aa),:)=cocostruct.categories(in).id;
                    data1.atlas_table.coco_id{index_at(aa)}=cocostruct.categories(in).id;
                    idd=find(num_at==id_at(aa));
                    category_id2_name(idd,:)=repmat(data1.atlas_table.atlas_name(index_at(aa)),[length(idd),1]);
                end
            end
%             ibk=find(strcmpi(data1.atlas_table(:,1),'background')==1);
%             
%             ibk0=find(strcmpi({data1.categories.name},'background')==1);
%             data1.atlas_table{ibk,5}=data1.categories(ibk0).id;
%             data1.atlas_table{ibk,6}=sum(abs(1-bw0(:)))*(data1.info.pixel_size).^2; 
            
            %atlas_table = cell2table(data1.atlas_table,'VariableNames',...
            %                         {'Atlas' 'id' 'RGB' 'RGBnum' 'coco_id' 'area'});
            
            atlas_table=data1.atlas_table;
            cocostruct.info.atlas_table=table2struct(atlas_table)';
            
        end
        cocotemp=struct2table(cocostruct.annotations);
        if isfield(cocostruct.annotations,'category_id2')==1
            cocotemp = removevars(cocotemp,{'category_id2'});
        end
        if isfield(cocostruct.annotations,'category_id2_name')==1
            cocotemp = removevars(cocotemp,{'category_id2_name'});
        end
        if isfield(cocostruct.annotations,'category_id1_name')==1
            cocotemp = addvars(cocotemp,category_id2,'After','category_id1_name');
            cocotemp = addvars(cocotemp,category_id2_name,'After','category_id2');
        else
            try
                cocotemp = addvars(cocotemp,category_id2,'After','id_chh');
                cocotemp = addvars(cocotemp,category_id2_name,'After','category_id2');
            catch
                try
                    cocotemp = addvars(cocotemp,category_id2,'After','id_masknii');
                    cocotemp = addvars(cocotemp,category_id2_name,'After','category_id2');
                catch
                    cocotemp = addvars(cocotemp,category_id2,'After','id');
                    cocotemp = addvars(cocotemp,category_id2_name,'After','category_id2');
                end
            end
        end
        
        if isfield(cocostruct.annotations,'category_id4_name')==1
            if isfield(cocostruct.annotations,'category_id3_name')==1
                name_id2=[cocotemp.category_id2_name(:)];
                name_id3={cocostruct.annotations(:).category_id3_name}';
                sn1 = strfind(name_id3,'__');
                name_id3n=cellfun(@(c,n)c(n:end),name_id3,sn1,'uni',false);
                category_id4_name=cellfun(@(x,y)[x y],name_id2,name_id3n,'uni',false);
                u_category_id4_name=unique(category_id4_name);
                category_id4=zeros(length(category_id4_name),1);
                for nn=1:length(u_category_id4_name)
                    in=find(strcmpi({cocostruct.categories.name},u_category_id4_name{nn})==1);
                    idnn=find(strcmpi(category_id4_name,u_category_id4_name{nn})==1);
                    category_id4(idnn,:)=cocostruct.categories(in).id;
                end
                cocotemp = removevars(cocotemp,{'category_id4_name'});
                if isfield(cocostruct.annotations,'category_id4')==1
                    cocotemp = removevars(cocotemp,{'category_id4'});
                end
                cocotemp = addvars(cocotemp,category_id4,'After','category_id3_name');
                cocotemp = addvars(cocotemp,category_id4_name,'After','category_id4');
            end
        
            
        end
        cocostruct=rmfield(cocostruct,'annotations');
        
        cocostruct.annotations=table2struct(cocotemp)';
        %cocoObj=CocoApi(cocostruct);
%     case 'cat_one'
%         annotations=struct2table(cocostruct.annotations);
%         annotations.category_id=repmat(cocostruct.categories(1).id,length(annotations.category_id),1);
%         
%         cocostruct.annotations=table2struct(annotations)';
%     otherwise
%         annotations=struct2table(cocostruct.annotations);
%         annotations.category_id=repmat(cocostruct.categories(1).id,length(annotations.category_id),1);
%         cocostruct.annotations=table2struct(annotations)';

end
annotations=struct2table(cocostruct.annotations);
annotations.category_id=repmat(uint64(20210255000),length(annotations.category_id),1);
cocostruct.annotations=table2struct(annotations)';
