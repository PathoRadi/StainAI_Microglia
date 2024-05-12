function [imaget,bline_mask]=dmib2rgb(imagt,row,col,varargin)

bline_mask='';
if isempty(varargin)==1
    bline=0;
    for kk=1:3
        imagt_k=imagt(:,:,:,kk);
        imaget_k=dmib2(imagt_k,row,col);
        imaget(:,:,kk)=imaget_k;
    end
else
    if length(varargin)==1
        for kk=1:3
            imagt_k=imagt(:,:,:,kk);
            [imaget_k, bline_mask]=dmib2(imagt_k,row,col,varargin{1});
            imaget(:,:,kk)=imaget_k;

           % figure(200);imshow(bline_mask)

        end
    else
        bline_color=varargin{2};
    
        for kk=1:3
            imagt_k=imagt(:,:,:,kk);
            [imaget_k, bline_mask]=dmib2(imagt_k,row,col,varargin{1});
            imaget_k(bline_mask==1)=bline_color(kk);
            imaget(:,:,kk)=imaget_k;
        end
        
        
        
    end
end
    

    %imagesc(plpe*col,plro*row,abs(imaget),clim);colormap(gray);axis image;axis off
    
%set(gca,'XTick',[0.1 1.6 3.2 ]*10)
%set(gca,'XTickLabel',{'0mm';'16mm';'32mm'})
%set(gca,'YTick',[0.1 6.4/4 6.4/2 3*6.4/4 6.4]*10)
%set(gca,'YTickLabel',{'0mm';'16mm';'32mm';'48mm';'64mm'})
%set(gca,'FontSize',8)
    
    

