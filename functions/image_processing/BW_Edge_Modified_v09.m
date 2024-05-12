function [bw_edgef, bw_modified]=BW_Edge_Modified_v09(bw0, line_num, varargin)
% (I2) [bw_edgef, bw_modified]=BW_Edge_Modified_v09(bw0, line_num, varargin)
%      Use circshift to get the edge of bwmap
%{
      input: bw0: 3d or 2d bwmap
          line_num: the thickness of edge lines around bw0, >0: lines outside, <0: line inside the bwmap
          varargin = '3d', 'z', 'y', 'x' to control the direction of edge
      output:
          bw_edgef: edge of bw0 with thickness of line_num
              line_num>0 => increase area of bwmap
              line_num<0 => decrease area of bwmap
          bw_modified: bwmap with edge if line_num>0
              bwmap without edge if line_num<0
%}

% History:
%     2019/5/22 add 2d input for bw0
%     2019/8/29 remove the loop for 2d image in 3d array to accelerate the code 
%               remove "ext_shape" case
%
% Author
%     Chao-Hsiung Hsu, 2019/4/29
%     Molecular Imaging Laboratory, Department of Radiology, College of Medicine, Howard University
%     Email: hsuchaohsiung@gmail.com

dataclass=class(bw0);
switch dataclass
    case {'uint8','logical'}
        bw0=int8(bw0);
    case 'uint16'
        bw0=int16(bw0);
end
if isempty(varargin)==true
    im_orient='3d';
    flag_3dedge=1;
else
    im_orient=varargin{1};
    flag_3dedge=0;
end
if length(size(bw0))==2
    bw0t=bw0;clear bw0;input_bwmap_dim='2d';
    bw0(1,:,:)=bw0t;im_orient='y';clear bw0t;
    flag_3dedge=0;
else
    input_bwmap_dim='3d';
end

switch im_orient
    case {'z','cor','coronal'}
        bw0=permute(bw0,[3,1,2]);
        flag_3dedge=0;
    case {'x','sag','sagittal'}
        bw0=permute(bw0,[2,3,1]);
        flag_3dedge=0;
    case {'y','axial','2d'}
        flag_3dedge=0;
    case '3d'
        flag_3dedge=1;
end
if flag_3dedge==0
    bw_edgef=false(size(bw0));
    %bw_edgef_2d=false(size(bw0));
    %bw_modified=false(size(bw0));
    bw_modified=bw0;tt=1;
    while sum(bw_modified(:))<=numel(bw_modified) && tt<=abs(line_num)
       if  line_num==0
           bw_edgef=false(size(bw0));
           bw_modified=bw0;
       else
           bw_edge_source_N1=circshift(bw_modified,1,2);bw_edge_source_N1(:,1,:)=0;
           bwlt=zeros(size(bw_modified));bwlt(:,:,1)=bw_edge_source_N1(:,:,1)+bw_modified(:,:,1);
           bw_edge_source_N1(bwlt==1)=0;
           edge0=abs(bw_edge_source_N1-bw_modified);
           %figure(1);imagesc(squeeze(edge0(1,:,:)));axis image
         %  bw1=squeeze(bw_edge_source_N1(25,:,:));
         %  bw2=squeeze(bw_modified(25,:,:));
           
           bw_edge_source_N1=circshift(bw_modified,-1,2);bw_edge_source_N1(:,end,:)=0;
           bwlt=zeros(size(bw_modified));bwlt(:,:,end)=bw_edge_source_N1(:,:,end)+bw_modified(:,:,end);bw_edge_source_N1(bwlt==1)=0;
           edge0=edge0+abs(bw_edge_source_N1-bw_modified);
          %  figure(1);imagesc(squeeze(edge0(1,:,:)));axis image
           bw_edge_source_N1=circshift(bw_modified,-1,3);bw_edge_source_N1(:,:,end)=0;
           bwlt=zeros(size(bw_modified));bwlt(:,end,:)=bw_edge_source_N1(:,end,:)+bw_modified(:,end,:);bw_edge_source_N1(bwlt==1)=0;
           edge0=edge0+abs(bw_edge_source_N1-bw_modified);
         %  figure(1);imagesc(squeeze(bw_edge_source_N1(1,:,:)));axis image
           bw_edge_source_N1=circshift(bw_modified,1,3);bw_edge_source_N1(:,:,1)=0;
           bwlt=zeros(size(bw_modified));bwlt(:,1,:)=bw_edge_source_N1(:,1,:)+bw_modified(:,1,:);bw_edge_source_N1(bwlt==1)=0;
           edge0=edge0+abs(bw_edge_source_N1-bw_modified);
           clear bwlt bw_edge_source_N1
       end
      % dn=25
       bw_edge=false(size(edge0));bw_edge(edge0~=false)=true;
%         figure(1);imagesc(squeeze(bw_edge(1,:,:)));axis image
       clear edge0;
       bw_edgef(bw_edge==true)=true;
%        bwdis=bw0+uint8(bw_edgef_2d);
%        figure(2);imagesc(squeeze(bwdis(dn,:,:)));axis image
       
       if  line_num>0
           bw_edgef(bw0==true)=false;
           bw_modified(bw_edgef==true)=true; %figure(1);imagesc(squeeze(bw_modified))
       elseif line_num<0
           bw_edgef(bw0==false)=false;
           bw_modified(bw_edgef==true)=false;
       end
       %figure(1);imagesc(bw_edgef_2d)
       tt=tt+1;
    end
    bw_edgef=bw_edgef;
    bw_modified=bw_modified;
end
switch im_orient
    case {'z','cor','coronal'}
        bw_edgef=ipermute(bw_edgef,[3,1,2]);
        bw_modified=ipermute(bw_modified,[3,1,2]);
    case {'x','sag','sagittal'}
        bw_edgef=ipermute(bw_edgef,[2,3,1]);
        bw_modified=ipermute(bw_modified,[2,3,1]);
end

if flag_3dedge==1
    bw_modified=bw0;
    bw_edgef=false(size(bw0));
    tt=1;
    if line_num==0
        bw_edgef=zeros(size(bw0));
        bw_modified=bw0;
    else
        while sum(bw_modified(:))<numel(bw_modified) && tt<=abs(line_num)
            bw_edge_source_C1=circshift(bw_modified,1,2);   %bw_edge_source_R1
            bwlt=zeros(size(bw_modified));bwlt(:,1,:)=bw_edge_source_C1(:,1,:)+bw_modified(:,1,:);bw_edge_source_C1(bwlt==1)=0;
            edge0=abs(bw_edge_source_C1-bw_modified);
            bw_edge_source_C1=circshift(bw_modified,-1,2);  %bw_edge_source_L1
            bwlt=0*bwlt;bwlt(:,end,:)=bw_edge_source_C1(:,end,:)+bw_modified(:,end,:);bw_edge_source_C1(bwlt==1)=0;
            edge0=edge0+abs(bw_edge_source_C1-bw_modified);
            bw_edge_source_C1=circshift(bw_modified,-1,1);  %bw_edge_source_U1
            bwlt=0*bwlt;bwlt(end,:,:)=bw_edge_source_C1(end,:,:)+bw_modified(end,:,:);bw_edge_source_C1(bwlt==1)=0;
            edge0=edge0+abs(bw_edge_source_C1-bw_modified);
            bw_edge_source_C1=circshift(bw_modified,1,1); %bw_edge_source_D1
            bwlt=0*bwlt;bwlt(1,:,:)=bw_edge_source_C1(1,:,:)+bw_modified(1,:,:);bw_edge_source_C1(bwlt==1)=0;
            edge0=edge0+abs(bw_edge_source_C1-bw_modified);
            bw_edge_source_C1=circshift(bw_modified,-1,3); %bw_edge_source_F1
            bwlt=0*bwlt;bwlt(:,:,end)=bw_edge_source_C1(:,:,end)+bw_modified(:,:,end);bw_edge_source_C1(bwlt==1)=0;
            edge0=edge0+abs(bw_edge_source_C1-bw_modified);
            bw_edge_source_C1=circshift(bw_modified,1,3); %bw_edge_source_B1
            bwlt=0*bwlt;bwlt(:,:,1)=bw_edge_source_C1(:,:,1)+bw_modified(:,:,1);bw_edge_source_C1(bwlt==1)=0;
            edge0=edge0+abs(bw_edge_source_C1-bw_modified);
            %edge0=tempR+tempL+tempU+tempD+tempF+tempB;
            bw_edge=false(size(edge0));bw_edge(edge0~=false)=true;
            bw_edgef(bw_edge==true)=true;
            
            if line_num>0
                bw_edgef(bw0==true)=false;
                bw_modified(bw_edgef==true)=true;
            elseif line_num<0
                bw_edgef(bw0==false)=false;
                bw_modified(bw_edgef==true)=false;
            end
            tt=tt+1;
        end
        bw_modified=bw_modified;
    end
    
end

switch input_bwmap_dim
    case '2d'
        bw_edgef=squeeze(bw_edgef);
        bw_modified=squeeze(bw_modified);
end


eval(['bw_edgef=' dataclass '(bw_edgef);']);
eval(['bw_modified=' dataclass '(bw_modified);']);


