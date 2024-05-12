function atlas_allcell_NLF=getAtlasEdge(atlas_allcell_N,linewidth,varargin)
% get edge line of the atlas (uint format)
% also check getAtlasEdge2.m
%
check_diff=0; 
if isempty(varargin)==1
    flag_disp_time=1;
else
    flag_disp_time=varargin{1};
    if length(varargin)==2
       check_diff=varargin{2}; 
    end
end

atlas_allcell_N0=atlas_allcell_N;
atlas_allcell_NLF=atlas_allcell_N*0;
for ll=1:linewidth
    if flag_disp_time==1
       % tic;
    end
    atlas_allcell_NLd1=(atlas_allcell_N-circshift(atlas_allcell_N,1,1));
    atlas_allcell_NLd2=(atlas_allcell_N-circshift(atlas_allcell_N,-1,1));
    atlas_allcell_NLd1(atlas_allcell_NLd2~=0)=atlas_allcell_NLd2(atlas_allcell_NLd2~=0);
    atlas_allcell_NLd2=(atlas_allcell_N-circshift(atlas_allcell_N,1,2));
    atlas_allcell_NLd1(atlas_allcell_NLd2~=0)=atlas_allcell_NLd2(atlas_allcell_NLd2~=0);
    atlas_allcell_NLd2=(atlas_allcell_N-circshift(atlas_allcell_N,-1,2));
    atlas_allcell_NLd1(atlas_allcell_NLd2~=0)=atlas_allcell_NLd2(atlas_allcell_NLd2~=0);
    atlas_allcell_NLF(atlas_allcell_NLd1~=0)=atlas_allcell_N0(atlas_allcell_NLd1~=0);
    atlas_allcell_N(atlas_allcell_NLF~=0)=0;
    if flag_disp_time==1
       % toc;
       % ll;
    end
end
if check_diff==1
    q0=unique(atlas_allcell_N);
    qf=unique(atlas_allcell_NLF);
    if length(q0)~=length(qf)
        dq=setdiff(q0,qf);
        for qq=1:length(dq)
            bwt0=zeros(size(atlas_allcell_N));
            bwt0(atlas_allcell_N==dq(qq))=1;
            bwtL=BW_Edge_Modified_v09(bwt0, -linewidth);
            if sum(bwtL(:))~=0
                atlas_allcell_NLF(bwtL==1)=dq(qq);
            else
                atlas_allcell_NLF(bwt0==1)=dq(qq);
            end
        end
    end
end
