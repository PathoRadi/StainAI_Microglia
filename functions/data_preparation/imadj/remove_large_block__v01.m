function data1=remove_large_block__v01(data1) 
% reverse black and white, remove large black block 
% input:  data1.im0 <= RGB color image
% output: data1.im0 RBMimage remove black blocks
%         data1.im0gray => reverse gray scale image
%         data1.imbackground => bw map with the cell


clear numPixelsR numPixelsRsort CC
im0r=double(data1.im0(:,:,1));im0g=double(data1.im0(:,:,2));im0b=double(data1.im0(:,:,3));% %figure(1002);imagesc(data1.im0)
bw0=false(size(im0r));bw0(im0r<=15)=true;bw0(im0g<=15)=true;bw0(im0b<=15)=true;% figure(1);imagesc(bw0)
clear numPixelsR numPixelsRsort CC
if data1.info.imblk_sizeth>0
    CC = bwconncomp(bw0);numPixels = cellfun(@numel,CC.PixelIdxList);numPixelsR(:,1)=numPixels;numPixelsR(:,2)=1:length(numPixels);numPixelsRsort=sortrows(numPixelsR,-1);clear bw0
    if isfield(data1.info,'imblk')==0
        data1.info.imblk=length(find(numPixelsRsort(:,1)>data1.info.imblk_sizeth));
    end
    %bw0=false(size(im0r));bw0(CC.PixelIdxList{1})=1;
    for ii=1:data1.info.imblk;im0r(CC.PixelIdxList{numPixelsRsort(ii,2)})=255;im0g(CC.PixelIdxList{numPixelsRsort(ii,2)})=255;im0b(CC.PixelIdxList{numPixelsRsort(ii,2)})=255;end
end;%figure(111);imshow(data1.im0)

data1.im0(:,:,1)=uint8(im0r);data1.im0(:,:,2)=uint8(im0g);data1.im0(:,:,3)=uint8(im0b);clear im0r im0g im0b CC
%figure(10111);imshow(data1.im0);

if ~isfield(data1,'imbackground')
    im0gray = 255-rgb2gray(data1.im0);
    %figure(10111);imshow(im0gray);set(gcf,'color','w');
    bw001=false(size(im0gray));bw001(im0gray>50)=true;bw002=bw001;
  %   figure(101111);imshow(bw001);
    tic;
    for cs=1:6
        bw001cs=circshift(bw001,10);bw002(bw001cs==1)=1;bw001cs=circshift(bw001,-10);bw002(bw001cs==1)=1;
        bw001cs=circshift(bw001,10,2);bw002(bw001cs==1)=1;bw001cs=circshift(bw001,-10,2);bw002(bw001cs==1)=1;
        bw001=bw002;
    end
    toc
    %figure(10112);imshow(bw002);
    tic;
    parf.fill_orient = 'y';parf.fill_range = [1 -25000];parf.fill_connectivity=4;
    bw003=BW_Fill_Holes_v02(bw002, parf);
    %figure(10112);imshow(bw003);
    toc
    tic;
    parf.fill_orient = 'y';parf.fill_range = [1 800000];parf.fill_connectivity=4;bw003=BW_Fill_Holes_v02(bw003, parf);
    %figure(10112);imshow(bw003);
    toc
    tic;
    se=strel('disk',20);bw003=imopen(bw003,se);
    [~, bw003]=BW_Edge_Modified_v09(bw003, 10);[~, bw003]=BW_Edge_Modified_v09(bw003, -10);

    %                                 clear numPixelsR numPixelsRsort CC
    %                                 CC = bwconncomp(bw003);numPixels = cellfun(@numel,CC.PixelIdxList);numPixelsR(:,1)=numPixels;numPixelsR(:,2)=1:length(numPixels);numPixelsRsort=sortrows(numPixelsR,-1);clear bw0

    %parf.fill_orient = 'y';parf.fill_range = [1 -10000];parf.fill_connectivity=4;bw003=BW_Fill_Holes_v02(bw003, parf);
    [~, bw003]=BW_Edge_Modified_v09(bw003, 5);


  %  figure(10113);imshow(imbackground);axis image

    %                                bw004=roipoly;
    %                                bw003(bw004==1)=0;
    %
    %                                 cmap=[1,0,0];%parula(max(bwtemp(:)));
    %                                 imF1 = labeloverlay(im0gray,bw003,'Colormap',cmap,'Transparency',0.85);
    %                                 %figure(10113);imshow(imF1);axis image

    %cmap=[1,0,0];%parula(max(bwtemp(:)));
    %imF1 = labeloverlay(im0gray,bw003,'Colormap',cmap,'Transparency',0.85);
    %imwrite(imF1, [data1.info.filepath_image data1.info.filename_image(1:end-4) '_grayM.jpg']);

    %toc
    %return

    imbackground=bw003;
    data1.imbackground=imbackground;
    %bw002=getAtlasEdge(bw001,10);
    %data1.imbackground=roipoly;%figure(1);imagesc(data1.imbackground);
end
data1.im0gray = 255-rgb2gray(data1.im0);

