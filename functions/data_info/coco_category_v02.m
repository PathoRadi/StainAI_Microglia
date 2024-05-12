function coco_category=coco_category_v02(varargin)
% (D3) coco_category=coco_category_v02(supercategory0,category_brainatlas,category_celltype)
%    create category and category_id for coco 
%{
    Input:
        supercategory0 = 'microglia';
        category_brainatlas = {'background','COR','EC',...}
        category_celltype={'R','H','B','A','RD','HR',...}
    Output:
        coco_category.supercategory
                     .id
                     .name
%}
if isempty(varargin)==1
    % old version
    supercategory0='microglia';
    category_brainatlas={'brain';'background';'Cortex';'Corpus_Callosum';'Hindbrain';'Substantia_Nigra';'CA2';'Pituitary_Gland';'Diancephalon';'Internal_Capsule';'Midbrain';'Dentate_Gyrus';'CA1';'CA3'};
    category_celltype={'microglia';'type1';'type2';'type3';'type4';'type5';'type6';'type7';'type8';'type9';'N';'R';'RD';'H';'HR';'A';'B';};
    %                           0       1       2       3       4       5       6       7       8       9   10  11  12   13  14  15  16
else
    supercategory0=varargin{1};
    category_brainatlas=varargin{2};
    category_celltype=varargin{3};
end
supercategory= cell(length(category_brainatlas)*length(category_celltype), 1);supercategory(:) ={supercategory0};

id=uint64(zeros(length(category_brainatlas)*length(category_celltype), 1));
%name2=cell(length(category_brainatlas)*length(category_celltype), 1);
name=cell(length(category_brainatlas)*length(category_celltype), 1);
for ii=1:length(category_celltype)
    for jj=1:length(category_brainatlas)
        switch category_brainatlas{jj}
            case 'background'
                id(jj+(ii-1)*length(category_brainatlas),1)=2021*10000000+(ii-1);
            case 'brain'
                id(jj+(ii-1)*length(category_brainatlas),1)=2021*10000000+(ii-1)+1000*255;
            otherwise
                id(jj+(ii-1)*length(category_brainatlas),1)=2021*10000000+(ii-1)+1000*(jj-1);
        end

  
        %name2{jj+(ii-1)*length(category_brainatlas),1}=[category_brainatlas{jj}];
        if ii==1
            name{jj+(ii-1)*length(category_brainatlas),1}=[category_brainatlas{jj}];
        else
            switch category_brainatlas{jj}
                case 'brain'
                    name{jj+(ii-1)*length(category_brainatlas),1}=[category_celltype{ii}];
                otherwise
                    name{jj+(ii-1)*length(category_brainatlas),1}=[category_brainatlas{jj} '__' category_celltype{ii}];
            end
        end
    end
end
id=uint64(id);
coco_category=table2struct(table(supercategory,id,name))';

