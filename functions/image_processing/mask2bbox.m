function bbox=mask2bbox(bwmask)
bbox=zeros(size(bwmask,1),4);

byxy=sum(sum(bwmask,3),2);
ind_ex=find(byxy~=0);
bwmask=bwmask(ind_ex,:,:);


by1=sum(bwmask,3);
by1C=mat2cell(by1,ones(size(by1,1),1),size(by1,2));
ind_by1C = cellfun(@(c) find(c ~= 0), by1C, 'uniform', false);
ind_by1= cell2mat(cellfun(@(c) [c(1) c(end)], ind_by1C, 'uniform', false));
if size(bwmask,1)>1
    bx1=squeeze(sum(bwmask,2));
    bx1C=mat2cell(bx1,ones(size(bx1,1),1),size(bx1,2));
    ind_bx1C = cellfun(@(c) find(c ~= 0), bx1C, 'uniform', false);
    ind_bx1= cell2mat(cellfun(@(c) [c(1) c(end)], ind_bx1C, 'uniform', false));
    
    bbox(ind_ex,:)=[ind_bx1(:,1) ind_by1(:,1) ind_bx1(:,2)-ind_bx1(:,1)+2 ind_by1(:,2)-ind_by1(:,1)+2];
else
    bw0=squeeze(bwmask);
    bx=sum(bw0,1);x=find(bx~=0);
    by=sum(bw0,2);y=find(by~=0);
    bbox=[x(1) y(1) x(end) y(end)];
    


    
end

