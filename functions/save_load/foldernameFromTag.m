function foldername=foldernameFromTag(data1,setp,varargin);
% load_manual_imageJroi
if isempty(varargin)~=1
    idd=varargin{1};
else
    idd.load_ch=1;
end
ts=1;sh=1;
for ch=1:length(idd.load_ch)
    if isfield(data1.info,'folderTag_manual_imJroi')==1
        foldername.imageJroi{ch,1}=folderTag2foldername(data1.info.folderTag_manual_imJroi(idd.load_ch(ch)), setp.train_imsize{1}, '');
        foldername.train_manual{ts, sh}{ch,1}=folderTag2foldername(data1.info.folderTag_manual_imJroi(idd.load_ch(ch)), setp.train_imsize{1}, 'train');
    end
end
% load_yolo5
for ts=1:length(setp.train_imsize);
    if size(data1.im0gray,1)<=setp.train_imsize{ts}(1) && size(data1.im0gray,2)<=setp.train_imsize{ts}(2);shn=1;
        foldername.train_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_train.maskrcnn(sh), setp.train_imsize{ts}, 'train');
        foldername.result_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_result.yolo5(sh,:), setp.train_imsize{ts}, 'result');
        foldername.test_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_test.maskrcnn(sh), setp.train_imsize{ts}, 'test');

    else
        for sh=1:size(data1.info.folderTag_train.maskrcnn,1)
            foldername.train_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_train.maskrcnn(sh,:), setp.train_imsize{ts}, 'train');
        end
        for sh=1:size(data1.info.folderTag_result.yolo5,1)
            foldername.result_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_result.yolo5(sh,:), setp.train_imsize{ts}, 'result');
        end
        for sh=1:size(data1.info.folderTag_test.maskrcnn,1)
            foldername.test_yolo{ts, sh}=folderTag2foldername(data1.info.folderTag_test.maskrcnn(sh,:), setp.train_imsize{ts}, 'test');
        end

    end
end
% Load Unet
ms=1;
for ii=1:size(data1.info.folderTag_result.UnetOneCell,1)
    if size(data1.info.folderTag_result.UnetOneCell,1)==2
        if ii==1 % get folder name
            foldername.train_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_train.UnetOneCell(ii,:), setp.size_box2, 'train');
            foldername.result_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_result.UnetOneCell(ii,:), setp.size_box2, 'result');
        else
            foldername.train_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_test.yolo2unet(1,:), setp.size_box2, 'test');
            foldername.result_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_result.UnetOneCell(ii,:), setp.size_box2, 'result');
        end
    else
        % assign test => foldername.train_UnetOneCell
        foldername.train_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_test.yolo2unet(1,:), setp.size_box2, 'test');
        foldername.result_UnetOneCell{ii,1}=folderTag2foldername(data1.info.folderTag_result.UnetOneCell(ii,:), setp.size_box2, 'result');
    end
    foldername.result_UnetOneCell_M{ii,ms}=[foldername.result_UnetOneCell{ii} '_ML'];
end
% Load load_MaskRCNN
ts=1;sh=1;
if isfield(data1.info.folderTag_result,'MaskRCNN')==1;sh=1;ts=1;
    foldername.result_MaskRCNN{ts, sh}=folderTag2foldername(data1.info.folderTag_result.MaskRCNN(sh,:), setp.train_imsize{ts}, 'result');
end
% Load load_yolact
if isfield(data1.info.folderTag_result,'yolact')==1;sh=1;ts=1;
    foldername.result_yolact{ts, sh}=folderTag2foldername(data1.info.folderTag_result.yolact(sh,:), setp.train_imsize{ts}, 'result');
end