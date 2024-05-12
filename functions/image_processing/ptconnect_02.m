function bw0=ptconnect_02(p1,p2,bwsize,varargin)
% (I6) bw0=ptconnect_02(p1,p2,bwsize,varargin)
%     get bwmap between two set of points (p1, p2) in the size of bwsize
%{
      input: 
          p1=[y11,x11;y12,x12;y13,x13;...];  % ex: p1=[1 53; 5 82;10 55];
          p2=[y21,x21;y22,x22;y23,x23;...]   % ex: p2=[45 66; 55 88;44 22]
          bwsize=[256, 256]
          varargin{1}=1
      output:
          bw0: line between p1(ii) to p2(ii), if varargin{1}=0 or empty
               line between p1(ii) to p2(jj), if varargin{1}=1
%}
% History:
% created by Chao-Hsiung Hsu, before 2020/08/28
% Howard University, Washington DC

if isempty(varargin)==1
    c_all_flag=0;
else
    c_all_flag=varargin{1};
end

if c_all_flag==0
    bw0=false(bwsize);
    for jj=1:size(p1,1)
        clear xpi ypi xp yp yp1 xp1
        bw0(p1(jj,1),p1(jj,2))=1;
        bw0(p2(jj,1),p2(jj,2))=1;
        xpi=[p2(jj,2) p1(jj,2)];ypi=[p2(jj,1) p1(jj,1)];
        xp=min(xpi):max(xpi);yp=min(ypi):max(ypi);
        if p1(jj,2)-p2(jj,2)==0 && p1(jj,1)-p2(jj,1)==0
        elseif p1(jj,2)-p2(jj,2)==0 && p1(jj,1)-p2(jj,1)~=0
            bw0(yp,p1(jj,2))=1;
        elseif p1(jj,2)-p2(jj,2)~=0 && p1(jj,1)-p2(jj,1)==0
            bw0(p1(jj,1),xp)=1;
        else
            for ii=1:length(xp)
                yp1(ii)=round((p1(jj,1)-p2(jj,1))/(p1(jj,2)-p2(jj,2)).*(xp(ii)-p1(jj,2))+p1(jj,1));
                bw0(yp1(ii),xp(ii))=1;
            end
            for ii=1:length(yp);
                xp1(ii)=round((yp(ii)-p1(jj,1)).*(p1(jj,2)-p2(jj,2))./(p1(jj,1)-p2(jj,1))+p1(jj,2));
                bw0(yp(ii),xp1(ii))=1;
            end
        end
    end
else
    bw0=false(bwsize);
    for kk=1:size(p2,1)
        for jj=1:size(p1,1)
            clear xpi ypi xp yp yp1 xp1
            bw0(p1(jj,1),p1(jj,2))=1;
            bw0(p2(kk,1),p2(kk,2))=1;
            xpi=[p2(kk,2) p1(jj,2)];ypi=[p2(kk,1) p1(jj,1)];
            xp=min(xpi):max(xpi);yp=min(ypi):max(ypi);
            if p1(jj,2)-p2(kk,2)==0 && p1(jj,1)-p2(kk,1)==0
            elseif p1(jj,2)-p2(kk,2)==0 && p1(jj,1)-p2(kk,1)~=0
                bw0(yp,p1(jj,2))=1;
            elseif p1(jj,2)-p2(kk,2)~=0 && p1(jj,1)-p2(kk,1)==0
                bw0(p1(jj,1),xp)=1;
            else
                for ii=1:length(xp)
                    yp1(ii)=round((p1(jj,1)-p2(kk,1))/(p1(jj,2)-p2(kk,2)).*(xp(ii)-p1(jj,2))+p1(jj,1));
                    bw0(yp1(ii),xp(ii))=1;
                end
                for ii=1:length(yp);
                    xp1(ii)=round((yp(ii)-p1(jj,1)).*(p1(jj,2)-p2(kk,2))./(p1(jj,1)-p2(kk,1))+p1(jj,2));
                    bw0(yp(ii),xp1(ii))=1;
                end
            end
        end
    end
    
end







%figure(13);imagesc(bw0);axis image