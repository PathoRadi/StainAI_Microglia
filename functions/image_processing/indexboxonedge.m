function [id_boxcenter,id_boxedge,bw_edge]=indexboxonedge(edgelinewidth,im0gray,train_imsize,box_yolo5,method)
drc=ceil(size(im0gray)./train_imsize);
bw_edge=false(size(im0gray));
bw_edge_4d=imsplit4d(bw_edge,[train_imsize]);
bw_edge_4d(:,1:edgelinewidth,:)=1;
bw_edge_4d(:,train_imsize(1)-edgelinewidth+1:train_imsize(1),:)=1;
bw_edge_4d(:,:,1:edgelinewidth)=1;
bw_edge_4d(:,:,train_imsize(2)-edgelinewidth+1:train_imsize(2))=1;
bw_edge=dmib2(bw_edge_4d,drc(1),drc(2));
bw_edge(1:edgelinewidth,:)=0;bw_edge(end-edgelinewidth+1:end,:)=0;bw_edge(:,1:edgelinewidth)=0;bw_edge(:,end-edgelinewidth+1:end)=0;
%figure(404);imagesc(bw_edge);axis image
[y x]=find(bw_edge==1);
ind_edgeline = sub2ind(size(bw_edge), y, x);
%[yI,xI] = ind2sub(size(bw_edge),ind_edgeline);
%figure(1);imagesc(im0gray);axis image

if isempty(box_yolo5)~=1
    switch method
        case 'vertex'
            ind_boxyolo1 = sub2ind(size(bw_edge), box_yolo5(:,2), box_yolo5(:,1));
            [~,iax1,ibx1] = intersect(ind_boxyolo1,ind_edgeline);
            ind_boxyolo2 = sub2ind(size(bw_edge), box_yolo5(:,2)+box_yolo5(:,4), box_yolo5(:,1)+box_yolo5(:,3));
            [~,iax2,ibx2] = intersect(ind_boxyolo2,ind_edgeline);
            id_boxedge=union(iax1,iax2);
            id_boxcenter=[setdiff([1:size(box_yolo5,1)],id_boxedge)]';
        case 'line'
            wmax=max(box_yolo5(:,3));
            hmax=max(box_yolo5(:,4));
            tt=0; % (y1,x1) ---->  (y1,x2)
            clear id_boxedge
            %while tt<=wmax
            for ww=1:wmax
                xp=box_yolo5(:,1)+tt;
                idex=find(tt>box_yolo5(:,3));
                if isempty(idex)~=1
                    xp(idex)=box_yolo5(idex,3);
                end
                ind_boxyolo1 = sub2ind(size(bw_edge), box_yolo5(:,2), xp);
                [~,iax1,ibx1] = intersect(ind_boxyolo1,ind_edgeline);
                if tt==0
                    id_boxedge=iax1;
                else
                    id_boxedge=union(id_boxedge,iax1);
                end
                tt=tt+1;
            end

            tt=0; % (y1,x1) ---->  (y2,x1)
            for ww=1:hmax
                yp=box_yolo5(:,2)+tt;
                idex=find(tt>box_yolo5(:,4));
                if isempty(idex)~=1
                    yp(idex)=box_yolo5(idex,4);
                end
                ind_boxyolo1 = sub2ind(size(bw_edge), yp, box_yolo5(:,1));
                [~,iax1,ibx1] = intersect(ind_boxyolo1,ind_edgeline);
                id_boxedge=union(id_boxedge,iax1);
                tt=tt+1;
            end

            %         imF1 = insertObjectAnnotation(im0gray, 'rectangle', box_yolo5(id_boxedge,:), {''},'color',{'yellow'},'LineWidth',5);
            %         imF1 = labeloverlay(imF1,bw_edge(1:size(imF1,1),1:size(imF1,2)),'Colormap',[1 0 0],'Transparency',0.7);
            %         figure(406);imshow(imF1);
            %
            %  imF1 = insertObjectAnnotation(im0gray, 'rectangle', box_yolo5, {''},'color',{'yellow'},'LineWidth',5);
            %         imF1 = labeloverlay(imF1,bw_edge(1:size(imF1,1),1:size(imF1,2)),'Colormap',[1 0 0],'Transparency',0.7);
            %         figure(405);imshow(imF1);



            %         imF2 = insertObjectAnnotation(im0gray, 'rectangle', box_yolo5(id_boxedge2,:), {''},'color',{'yellow'},'LineWidth',5);
            %         imF2 = labeloverlay(imF2,bw_edge(1:size(imF1,1),1:size(imF1,2)),'Colormap',[1 0 0],'Transparency',0.7);
            %         figure(406);imshow(imF2(3553-50:3553+200,22031-50:22031+200,:));

            % tt=0; % (y2,x1) ---->  (y2,x2)
            % for ww=1:wmax
            %     xp=box_yolo5(:,1)+tt;
            %     idex=find(tt>box_yolo5(:,3));
            %     if isempty(idex)~=1
            %         xp(idex)=box_yolo5(idex,3);
            %     end
            %     ind_boxyolo1 = sub2ind(size(bw_edge), box_yolo5(:,2)+box_yolo5(:,4), xp);
            %     [~,iax1,ibx1] = intersect(ind_boxyolo1,ind_edgeline);
            %     id_boxedge=union(id_boxedge,iax1);
            %     tt=tt+1;
            % end
            % 
            % 
            % tt=0; % (y1,x2) ---->  (y2,x2)
            % for ww=1:hmax
            %     yp=box_yolo5(:,2)+tt;
            %     idex=find(tt>box_yolo5(:,4));
            %     if isempty(idex)~=1
            %         yp(idex)=box_yolo5(idex,4);
            %     end
            %     ind_boxyolo1 = sub2ind(size(bw_edge), yp, box_yolo5(:,1)+box_yolo5(:,3));
            %     [~,iax1,ibx1] = intersect(ind_boxyolo1,ind_edgeline);
            %     id_boxedge=union(id_boxedge,iax1);
            %     tt=tt+1;
            % end

            id_boxcenter=[setdiff([1:size(box_yolo5,1)],id_boxedge)]';


    end
else
    id_boxcenter='';
    id_boxedge='';
    bw_edge='';
end
