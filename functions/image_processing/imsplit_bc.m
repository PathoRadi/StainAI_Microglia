function im3d=imsplit_bc(im2d,size_box,flag_direction);
% seperate 2d image into small boxes

%size_box=[16 16]
%im2d=bw_grid;im2d(1:end,1:3)=1;
%figure(1);imagesc(im2d);axis image;
imsize=size(im2d);
drc=ceil(imsize./size_box);

imzp=zeros(drc(1)*size_box(1),drc(2)*size_box(2));
imsizezp=size(imzp);
switch flag_direction
    case 'top-left'
        imzp(1:imsize(1),1:imsize(2))=im2d;
    case 'top-right'
        imzp(1:imsize(1),imsizezp(2)-imsize(2)+1:imsizezp(2))=im2d;
    case 'down-left'
        imzp(imsizezp(1)-imsize(1)+1:imsizezp(1),1:imsize(2))=im2d;
    case 'down-right'
        imzp(imsizezp(1)-imsize(1)+1:imsizezp(1),imsizezp(2)-imsize(2)+1:imsizezp(2))=im2d;
end

for ri=1:drc(1)
    imt1=imzp(1+(ri-1)*size_box(1):size_box(1)*ri,:);
    imtr=reshape(imt1,size_box(1),size_box(2),drc(2));
    im3d(1+(ri-1)*drc(2):drc(2)*ri,:,:)=permute(imtr,[3,1,2]);
end
% bwedge=zeros(size(im3d));
% bwedge(:,1:end,1)=1;
% bwedge(:,1,1:end)=1;
% 
% bmm=dmib2(bwedge,drc(1),drc(2));
% imm=dmib2(im3d,drc(1),drc(2));
% cmap=[1,0,0];%parula(max(bwtemp(:)));
% imF1 = labeloverlay(imm,bmm,'Colormap',cmap,'Transparency',0.2);
% 
% figure(1111);imshow(imF1)