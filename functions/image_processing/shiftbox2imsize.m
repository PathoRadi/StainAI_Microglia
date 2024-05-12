function [bboxS,corrd_on_image,corrd_on_smallbox]=shiftbox2imsize(bbox,imsize,varargin)
% (I7) [bboxS,corrd_on_image,corrd_on_smallbox]=shiftbox2imsize(bbox,imsize)
%     shift x, y in  bbox (x,y,rx,ry) into range of imsize; rx, ry size of box
%     ex: bbox:[-5 254, 256, 256] in 2560x2526 => bboxS: [1, 254, 256, 256];
%{
      input:
          bbox:  box position of masks: [x,y,mpara.box_size(1) mpara.box_size(2)] 
          imsize: image size
          varargin{1}=[256,256]; % fixed size of box on the small image
      output:
          bboxS: new coordinates
          corrd_on_image: (y,y+ry,x,x+rx),the corrdinate on large image with size of imsize, 
                          if y+ry>imsize(1) => imsize(1); if x+rx>imsize(2) => imsize(2);
          corrd_on_smallbox: (y,ry-yd,x,rx-xd),the corrdinate on image in box with the size of 
%}

% History:
% created by Chao-Hsiung Hsu, before 2020/08/28
% Howard University, Washington DC

% bbox:x,y,xL,yL
% smallbox: y1:yend,x1:xend
%                     y1:                   yend,        x1:   xend
corrd_on_image=[bbox(:,2),  bbox(:,2)+bbox(:,4)-1, bbox(:,1),  bbox(:,1)+bbox(:,3)-1];
if isempty(varargin)~=1
   box_imsize=varargin{1};
   corrd_on_smallbox(:,1)=ones(1,size(bbox,1));
   corrd_on_smallbox(:,2)=ones(1,size(bbox,1))*box_imsize(1);
   corrd_on_smallbox(:,3)=ones(1,size(bbox,1));
   corrd_on_smallbox(:,4)=ones(1,size(bbox,1))*box_imsize(2);
else
    corrd_on_smallbox(:,1)=ones(1,size(bbox,1));
    corrd_on_smallbox(:,2)=bbox(:,4);
    corrd_on_smallbox(:,3)=ones(1,size(bbox,1));
    corrd_on_smallbox(:,4)=bbox(:,3);
end



bboxS=bbox;
idb0=find(bbox(:,1)<1); %x
if isempty(idb0)~=1;
    bboxS(idb0,1)=1;%x
    corrd_on_image(idb0,3)=corrd_on_image(idb0,3)+abs(bbox(idb0,1))+1;
    corrd_on_smallbox(idb0,3)=1+abs(bbox(idb0,1))+1;
end

idb0=find(bbox(:,2)<1);
if isempty(idb0)~=1;
    bboxS(idb0,2)=1;%y
    corrd_on_image(idb0,1)=1;
    corrd_on_smallbox(idb0,1)=1+abs(bbox(idb0,2))+1;
end
idb0=find(corrd_on_image(:,2)>imsize(1));
if isempty(idb0)~=1;
    corrd_on_smallbox(idb0,2)=bbox(idb0,4)-(corrd_on_image(idb0,2)-imsize(1));
    corrd_on_image(idb0,2)=imsize(1);
end
idb0=find(corrd_on_image(:,4)>imsize(2));
if isempty(idb0)~=1;
    corrd_on_smallbox(idb0,4)=bbox(idb0,3)-(corrd_on_image(idb0,4)-imsize(2));
    corrd_on_image(idb0,4)=imsize(2);
end