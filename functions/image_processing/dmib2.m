function [imaget,bline_mask]=dmib2(imagt,row,col,varargin);
% montage 3d image into 2d image

% created by Chao-Hsiung Hsu before 4/8/2020
% at National Taiwan University, Taiwan
% modified by Chao-Hsiung Hsu at 6/6/2020
% at Department of Radiology, Howard University
%
%

    
imclass=class(imagt);
if isempty(varargin)==1
    bline=0;
else
    bline=varargin{1};
end


sizimagt=size(imagt);

if length(sizimagt)>3
    imagt=reshape(imagt,sizimagt(1)*sizimagt(2),sizimagt(3),sizimagt(4));
    sizimagt=size(imagt);
elseif length(sizimagt)==2
    imagt0=imagt;clear imagt
    imagt(1,:,:)=reshape(imagt0,1,sizimagt(1),sizimagt(2));
    sizimagt=size(imagt);
end
    
if bline==0
    eval(['imaget=' imclass '(false(row*(sizimagt(2)),col*(sizimagt(3))));']);
    for jj=1:row
        for ii=1:col
            nn=ii+(jj-1)*col;
            if nn <= sizimagt(1)
                imaget(sizimagt(2)*(jj-1)+1:sizimagt(2)*jj,sizimagt(3)*(ii-1)+1:sizimagt(3)*ii)=squeeze(imagt(nn,:,:));
%                 if isempty(find(imaget==782))~=1
%                     figure(1111);
%                     imagesc(squeeze(imagt(nn,:,:)));axis image
%                     
%                 end
            end
        end
    end
    %figure(1112);imagesc(imaget);
    
    bline_mask=false(size(imaget));
else
    eval(['imaget=' imclass '(false(row*(sizimagt(2))+bline*(row-1),col*(sizimagt(3))+bline*(col-1)));']);
    
    bline_mask=false(size(imaget));
    
    for jj=1:row
        for ii=1:col
            nn=ii+(jj-1)*col;
            if nn <= sizimagt(1)
                imaget(sizimagt(2)*(jj-1)+1+(jj-1)*bline:sizimagt(2)*jj+(jj-1)*bline,sizimagt(3)*(ii-1)+1+(ii-1)*bline:sizimagt(3)*ii+(ii-1)*bline)=imagt(nn,:,:);
                %   figure(1);imagesc(imaget);axis image
            end
        end
        if jj~=row
            bline_mask(sizimagt(2)*jj+(jj-1)*bline+1:sizimagt(2)*jj+(jj-1)*bline+bline,:)=true;
        end
    end
    for ii=1:col-1
        bline_mask(:,sizimagt(3)*ii+(ii-1)*bline+1:sizimagt(3)*ii+(ii-1)*bline+bline)=true;
    end
end
%imagesc(plpe*col,plro*row,abs(imaget),clim);colormap(gray);axis image;axis off

%set(gca,'XTick',[0.1 1.6 3.2 ]*10)
%set(gca,'XTickLabel',{'0mm';'16mm';'32mm'})
%set(gca,'YTick',[0.1 6.4/4 6.4/2 3*6.4/4 6.4]*10)
%set(gca,'YTickLabel',{'0mm';'16mm';'32mm';'48mm';'64mm'})
%set(gca,'FontSize',8)



