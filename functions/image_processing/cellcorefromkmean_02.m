function [bw_core,bw_peri,kn]=cellcorefromkmean_02(ims1,bwt,kn,csizeth)
% seperate bwt into core and peri from the intensity kmean of ims1
rng(6,'twister');
% history: 
% Created by Chao-Hsiung Hsu, 2020/09/12
% Email: hsuchaohsiung@gmail.com

bw_core=false(size(bwt));
tt=0;
if sum(bwt(:))>csizeth
    while sum(bw_core(:))<=csizeth && kn >1
        [sort_kmean_idx_res bwkmean kmean_cs]=kmeans_no_zeros(ims1.*bwt,kn);
        if tt==0
        %figure(9002);imagesc_bw(ims1,[0 255],'gray',255,bwkmean,{'b','c','y','g'},-1,-1);axis image;axis off
        end

        bw_core0=bwkmean{kn};cc=bwconncomp(bw_core0,4); %sum(bw_core(:))
        if cc.NumObjects>1;numPixels = cellfun(@numel,cc.PixelIdxList);[~,id_cc]=max(numPixels);
            bw_core(cc.PixelIdxList{id_cc})=true;if sum(bw_core(:))<=csizeth;bw_core=false(size(bwt));end
        else;bw_core=bw_core0;end;kn=kn-1;
        tt=tt+1;
    end
else
%     if sum(bwt(:))>csizeth
%         [sort_kmean_idx_res bwkmean kmean_cs]=kmeans_no_zeros(ims1.*bwt,2);%figure(1);imagesc(bwkmean{2})
%         bw_core0=bwkmean{2};cc=bwconncomp(bw_core0,4);
%         if cc.NumObjects>1;numPixels = cellfun(@numel,cc.PixelIdxList);[~,id_cc]=max(numPixels);
%             bw_core(cc.PixelIdxList{id_cc})=true;else;bw_core=bw_core0;end
%     else
%         bw_core=bwt;
%     end
    bw_core=bwt;
end

kn=kn+1;
bw_peri=bwt;bw_peri(bw_core==true)=false;%figure(2);imagesc_bw(ims1abs,[0 255],'gray',255,{bw_core,bw_peri},{'g','r','b','c'},-1,4);axis image;
%bw_cell=uint8(bw_core);bw_cell(bw_peri==1)=2;