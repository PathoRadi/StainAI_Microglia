function [sort_kmean_idx_res bwkmean kmean_cs]=kmeans_no_zeros(im1,cnum,varargin);
% (I3) [sort_kmean_idx_res bwkmean kmean_cs]=kmeans_no_zeros(im1,cnum,varargin);
%     get  kmean results without zero value in im1, and sorted from small to large
%{
    Input:
        im1: grayscale image
        cnum: number of cluster (k)
        varargin{1}=1  => remove im1=0;
        varargin{1}=2  => remove im1=-9878949;  % for some old data only, can be removed
    Output:
        sort_kmean_idx_res: sorted kmean atlas
        bwkmean{}: sorted kmean mask 
        kmean_cs: sorted kmean center 
%}
% History:
% created by Chao-Hsiung Hsu, before 2020/08/28
% Howard University, Washington DC

if isempty(varargin) == 1
    flag=1;
else
    flag=2;
end
imsize=size(im1);
if flag==1
    idx2=find(im1~=0);
    [kmean_idx,kmean_c] = kmeans(im1(idx2),cnum,'Distance','city','emptyaction','drop','Replicates',5);  %
else
     idx2=find(im1~=-9878949);
     [kmean_idx,kmean_c] = kmeans(im1(idx2),cnum,'distance','sqEuclidean', 'Replicates',3);  %
end
    kmean_c(:,2)=1:length(kmean_c(:,1));
    kmean_cs=sortrows(kmean_c,1);
    kmean_idx2=zeros(imsize(1),imsize(2));
    kmean_idx2(idx2)=kmean_idx;
    kmean_idx_res=reshape(kmean_idx2,imsize(1),imsize(2));
    sort_kmean_idx_res=zeros(imsize(1),imsize(2));
    for kmii=1:length(kmean_c(:,1));
        sort_kmean_idx_res(find(kmean_idx_res==kmean_cs(kmii,2)))=kmii;
    end
    
    for kmii=1:length(kmean_c(:,1));
        bwkmean{kmii}=zeros(imsize(1),imsize(2));
        bwkmean{kmii}(find(sort_kmean_idx_res==kmii))=1;
    end
    
    

