function writetableSplit(spnum,im0size,T,table_info,filename,varargin);
[fpath,fname,fext]=fileparts(filename);

imssize=fix([im0size(1:2)]/spnum);
position=T.bbox;
if istablefield(T,'N_bbox')
    positionN=T.N_bbox;
else
    positionN=T.S_bbox;
end

x0=position(:,1);
y0=position(:,2);
x1=x0+position(:,3);
y1=y0+position(:,4);

x0N=positionN(:,1);
y0N=positionN(:,2);
x1N=x0N+positionN(:,3);
y1N=y0N+positionN(:,4);

%figure(444);imshow(im1)
for ii=1:spnum
    for jj=1:spnum

        if ii==1 && jj==1
            i1=find(y0>=imssize(1)*(ii-1)+1 & y0<=ii*imssize(1) & x0>=imssize(2)*(jj-1)+1 & x0<=jj*imssize(2));
            positionSplit=position(i1,:);

            %i1N=find(y0N>=imssize(1)*(ii-1)+1 & y0N<=ii*imssize(1) & x0N>=imssize(2)*(jj-1)+1 & x0N<=jj*imssize(2));
            positionSplitN=positionN(i1,:);

        elseif ii==1 && jj~=1
            clear positionSplit positionSplitN
            i1=find(y0>=imssize(1)*(ii-1)+1 & y0<=ii*imssize(1) & x1>=imssize(2)*(jj-1)+1 & x0<=jj*imssize(2));
            positionSplit=position(i1,:);
            positionSplit(:,1)=positionSplit(:,1)-imssize(2)*(jj-1);
            positionSplit(:,2)=positionSplit(:,2)-imssize(1)*(ii-1);

            %i1N=find(y0N>=imssize(1)*(ii-1)+1 & y0N<=ii*imssize(1) & x1N>=imssize(2)*(jj-1)+1 & x0N<=jj*imssize(2));
            positionSplitN=positionN(i1,:);
            positionSplitN(:,1)=positionSplitN(:,1)-imssize(2)*(jj-1);
            positionSplitN(:,2)=positionSplitN(:,2)-imssize(1)*(ii-1);

        elseif ii~=1 && jj==1
            clear positionSplit positionSplitN
            i1=find(y1>=imssize(1)*(ii-1)+1 & y0<=ii*imssize(1) & x0>=imssize(2)*(jj-1)+1 & x0<=jj*imssize(2));
            positionSplit=position(i1,:);
            positionSplit(:,1)=positionSplit(:,1)-imssize(2)*(jj-1);
            positionSplit(:,2)=positionSplit(:,2)-imssize(1)*(ii-1);

            %i1N=find(y1N>=imssize(1)*(ii-1)+1 & y0N<=ii*imssize(1) & x0N>=imssize(2)*(jj-1)+1 & x0N<=jj*imssize(2));
            positionSplitN=positionN(i1,:);
            positionSplitN(:,1)=positionSplitN(:,1)-imssize(2)*(jj-1);
            positionSplitN(:,2)=positionSplitN(:,2)-imssize(1)*(ii-1);

        elseif ii~=1 && jj~=1
            clear positionSplit positionSplitN
            i1=find(y1>=imssize(1)*(ii-1)+1 & y0<=ii*imssize(1) & x1>=imssize(2)*(jj-1)+1 & x0<=jj*imssize(2));
            positionSplit=position(i1,:);
            positionSplit(:,1)=positionSplit(:,1)-imssize(2)*(jj-1);
            positionSplit(:,2)=positionSplit(:,2)-imssize(1)*(ii-1);

            %i1N=find(y1N>=imssize(1)*(ii-1)+1 & y0N<=ii*imssize(1) & x1N>=imssize(2)*(jj-1)+1 & x0N<=jj*imssize(2));
            positionSplitN=positionN(i1,:);
            positionSplitN(:,1)=positionSplitN(:,1)-imssize(2)*(jj-1);
            positionSplitN(:,2)=positionSplitN(:,2)-imssize(1)*(ii-1);
        end
        Tb1=T(i1,:);
        %bbox0=positionSplit;
        bbox0=mat2cell(positionSplit,ones(length(positionSplit),1),4);
        N_bbox0=mat2cell(positionSplitN,ones(length(positionSplitN),1),4);
        % bboxtestsp=bboxtest(i1,:);
        % label=Tb1.C50;disp.th_FM0=0;
        % disp.type_name_C50={'R','H','B','A','RD','HR'};
        % disp.cmap_label1={[255 0 0],[255 0 0],[255 0 0],[255 0 0],[255 0 0],[255 0 0],[255 0 0]};
        % disp.box_ratio1=[1 1 1 1 1 1 1]*1.4;disp.Low_res=-1;disp.opacity1=0.5;
        % ims1=imread(['E:\HU\DLdata_v3\Burke\projecTb1\IHC\UN6\UN6 slide 1\results\images\UN6 slide 1.jpg']);
        % [imboxlabel,indLable]=insertLabelbox2image_v2(ims1,positionSplit,label,disp);
        % figure(1);imshow(imboxlabel)
        % [imboxlabel,indLable]=insertLabelbox2image_v2(ims1,bboxtestsp,label,disp);
        % figure(2);imshow(imboxlabel)


        Tb1=renamevars_chh(Tb1,'bbox','Ntemp');
        bbox=cellfun(@mat2str,bbox0,'UniformOutput',false);Tb1= addvars(Tb1,bbox,'after','Ntemp');
        Tb1=removevars(Tb1,'Ntemp');

        if istablefield(Tb1,'N_bbox')
            %N_bbox0=mat2cell(Tb1.N_bbox,ones(length(Tb1.N_bbox),1),4);
            Tb1=renamevars_chh(Tb1,'N_bbox','Ntemp');
            S_bbox=cellfun(@mat2str,N_bbox0,'UniformOutput',false);
            Tb1= addvars(Tb1,S_bbox,'after','Ntemp');Tb1=removevars(Tb1,'Ntemp');

        else
            %N_bbox0=mat2cell(Tb1.S_bbox,ones(length(Tb1.S_bbox),1),4);
            Tb1=renamevars_chh(Tb1,'S_bbox','Ntemp');
            S_bbox=cellfun(@mat2str,N_bbox0,'UniformOutput',false);
            Tb1= addvars(Tb1,S_bbox,'after','Ntemp');Tb1=removevars(Tb1,'Ntemp');
        end


       
        if ii==1 && jj==1
            writetable(Tb1,filename,varargin{:});
            writecell(table_info,filename,'WriteMode','overwritesheet','Sheet','info');

        else
            writetable(Tb1,[fpath filesep fname '_s' num2str((ii-1)*spnum+jj) fext],varargin{:});
            writecell(table_info,[fpath filesep fname '_s' num2str((ii-1)*spnum+jj) fext],'WriteMode','overwritesheet','Sheet','info');

        end

    end
end

