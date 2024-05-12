function imsplit=imsplit4d(imp,train_imsize)
% reshape 2d image RGB(gray) in to 4d(3d) matrix 



imsize=size(imp);
if length(imsize)==2
    if length(train_imsize)==2
        drc=ceil(imsize./train_imsize);
    else
        fprintf('length of train_imsize should equal to size of image')
    end
elseif length(imsize)==3
    if length(train_imsize)==3
        drc=ceil(imsize./[train_imsize]);
    else
        drc=ceil(imsize./[train_imsize 3]);
        %fprintf('length of train_imsize should equal to size of image')
    end
else
    fprintf('only for 2d or 3d matrix')
end


imclass=class(imp);
if length(imsize)==2
    eval(['imzp=' imclass '(false(drc(1)*train_imsize(1),drc(2)*train_imsize(2)));']);
    %imzp(1:imsize(1),1:imsize(2))=imp;
    imzp(1:imsize(1),1:imsize(2))=imp;
    eval(['imtr=' imclass '(false(train_imsize(1),train_imsize(2),drc(2)));']);
    eval(['imtrc=' imclass '(false(drc(2)*drc(1),train_imsize(1),train_imsize(2)));']);
    for ri=1:drc(1)
        imt1=imzp(1+(ri-1)*train_imsize(1):train_imsize(1)*ri,:);
        imtr=reshape(imt1,train_imsize(1),train_imsize(2),drc(2));
        imsplit(1+(ri-1)*drc(2):drc(2)*ri,:,:)=permute(imtr,[3,1,2]);
    end
    %imm=dmib2(imtrc,drc(1),drc(2));
    %figure(1111);imagesc(imm)
    
elseif length(imsize)==3
    eval(['imzp=' imclass '(false(drc(1)*train_imsize(1),drc(2)*train_imsize(2),imsize(3)));']);
    imzp(1:imsize(1),1:imsize(2),:)=imp;
    eval(['imtr=' imclass '(false(train_imsize(1),train_imsize(2),imsize(3),drc(2)));']);
    eval(['imtrc=' imclass '(false(drc(2)*drc(1),train_imsize(1),train_imsize(2),imsize(3)));']);
    
    for ri=1:drc(1)
        imt1=imzp(1+(ri-1)*train_imsize(1):train_imsize(1)*ri,:,:);
        for ii=1:imsize(3)
            imtr(:,:,ii,:)=reshape(imt1(:,:,ii),train_imsize(1),train_imsize(2),drc(2));
        end
        imsplit(1+(ri-1)*drc(2):drc(2)*ri,:,:,:)=permute(imtr,[4,1,2,3]);
    end
    %imm=dmib2rgb(imtrc,drc(1),drc(2));
    %figure(1111);imshow(imm);
end

