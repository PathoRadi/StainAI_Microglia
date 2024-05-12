function [fnum,fname]=getkeyword_02(dinfo,keyW1,keyN1,varargin)
% (St1) [fnum fname]=getkeyword_02(dinfo,keyW1,keyN1,varargin)
%     find number or name with keyW1{}, or without keyN1{} in dinfo{ff}.filename_image or {cell}
%{
    Input:
        dinfo = {'CR1 slide 10.tif','N25 slide 10.tif','CR1 slide 7.tif' }
            or = dinfo{}.filename_image;
        keyW1 = {'CR1', 'slide 10.'}  % wanted keywords
        keyN1 = {'N25'}  % unwanted keywords
        varargin{1} = 1  % => keep the wanted keyword of the same length only
    Output:
        fnum = 1
        fname = 'CR1 slide 10'
%}
% History:
% created by Chao-Hsiung Hsu, before 2020/08/28
% Howard University, Washington DC

if isempty(varargin)~=1
    fkeyext=1;
    kend_check=varargin{1};
else
    fkeyext=0;
end

if iscell(dinfo)==1
    if isfield(dinfo{1},'filename_image')==1
        for ff=1:length(dinfo)
            if isempty(dinfo{ff})~=1
                filenameC{ff,1}=dinfo{ff}.filename_image;%(1:end-4);
            end
        end
    else
        filenameC=dinfo;
    end
end

for kw=1:length(keyW1)
    if isempty(keyW1{kw})~=1
        if kw==1
            w=find(cellfun(@isempty,strfind(filenameC,keyW1{1}))==0);
        else
            w0=find(cellfun(@isempty,strfind(filenameC,keyW1{kw}))==0);
            
            
            w=intersect(w,w0);
        end
        
        if fkeyext~=0
            if kend_check(kw)~=0
                etn0=strfind(filenameC,keyW1{kw});
                kc0=cellfun(@(c,n)c(n:end),filenameC,etn0,'uni',false);
                w1=find(cellfun(@length,kc0)==length(keyW1{kw}));
                w=intersect(w,w1);
            end
        end
    else
        w=1:length(dinfo);
    end
    
end

for kn=1:length(keyN1)
    if kn==1
        n=find(cellfun(@isempty,strfind(filenameC,keyN1{1}))==0);
    else
        n0=find(cellfun(@isempty,strfind(filenameC,keyN1{kn}))==0);
        n=intersect(n,n0);
    end
end

fnum=sort(setdiff(w,n))';
fname0t=filenameC(fnum);
if isempty(fname0t)~=1
    for ff=1:length(fname0t)
        fname{ff}=fname0t{ff}(1:end-4);
    end
else
    fname={''};
end