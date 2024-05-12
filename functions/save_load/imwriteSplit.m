function imwriteSplit(im0,filename,spnum)
% imreadSplit
[fpath,fname,fext]=fileparts(filename);
im0size=size(im0);
imssize=fix([im0size(1:2)]/spnum);
for ii=1:spnum
    for jj=1:spnum
        if ii==spnum && jj~=spnum
            ims=im0(imssize(1)*(ii-1)+1:end,imssize(2)*(jj-1)+1:jj*imssize(2),:);
        elseif jj==spnum && ii~=spnum
            ims=im0(imssize(1)*(ii-1)+1:ii*imssize(1),imssize(2)*(jj-1)+1:end,:);
        elseif ii==spnum && jj==spnum 
            ims=im0(imssize(1)*(ii-1)+1:end,imssize(2)*(jj-1)+1:end,:);
        else
            ims=im0(imssize(1)*(ii-1)+1:ii*imssize(1),imssize(2)*(jj-1)+1:jj*imssize(2),:);
        end

        if ii==1 && jj==1
            imwrite(ims,filename);
        else
            imwrite(ims,[fpath filesep fname '_s' num2str((ii-1)*spnum+jj) fext]);
        end
    end
end


    % 
    % if flag.save_imsplit==1
    %             imwriteSplit(im0,[data1.info.filepath_image filesep 'results' filesep 'images' filesep data1.info.filename_image(1:end-4) '_grayOrig.jpg'],2);
    %         else
    %             imwrite(im0,[data1.info.filepath_image filesep 'results' filesep 'images' filesep data1.info.filename_image(1:end-4) '_grayOrig.jpg']);
    %         end

%  imwrite(imFs2,[pptpath filesep  data1{nn,1}.info.filename_image(1:end-4) '_Unet2.jpg']);
