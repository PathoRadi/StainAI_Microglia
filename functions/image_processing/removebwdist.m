function [bw_output, bw_output_r]=removebwdist(bw_input, distth)
% keep the largest bw region, and remove the region distant > distth


bw_output=false(size(bw_input));
ccbw_existu=bwconncomp(bw_input,4);
kk=1;
bw_output_r{kk}=false(size(bw_input));
if ccbw_existu.NumObjects>1
    [mv,idM]=max(cellfun(@numel,ccbw_existu.PixelIdxList));
    bw_output(ccbw_existu.PixelIdxList{idM})=true;
    bw_output0=bw_output;
    for ci=1:ccbw_existu.NumObjects
        if ci~=idM
            bw_temp=false(size(bw_input));bw_temp(ccbw_existu.PixelIdxList{ci})=true;
            dist_ccexistu=bwdistant02(bw_output0,bw_temp);
            if dist_ccexistu.shortest_dist<=distth
                bw_output(ccbw_existu.PixelIdxList{ci})=true;
            else
                %if length(ccbw_existu.PixelIdxList{ci})/mv > 0.4
                    if length(ccbw_existu.PixelIdxList{ci})>500
                        bw_output_r{kk}=false(size(bw_input));
                        bw_output_r{kk}(ccbw_existu.PixelIdxList{ci})=true;
                        kk=kk+1;
                    end
                    %figure(1);imagesc(bw_input)
                %
            end
        end
    end
else
    bw_output=bw_input;
end

