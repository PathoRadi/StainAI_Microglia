function [status,cmdout]=R_predicC50_v01(DataSetInfo,env)
% DataSetInfo.C50_case='train'; or 'prediction'
% env.C50_Model_filename='F:\matlab_program\IHC\R\C50\C50_v01.RData';
% env.C50_Json_train_filename{1,1}='H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\cocoJson\CR1 slide 10__ChImJroi_DChecked_512x512__train_M__V04regp11s.json';
% env.C50_Json_train_filename{2,1}='H:\HU\DLdata_v2\SC50_flagC50_flaghoykhet\project1\IHC\N25\N25 slide 10\cocoJson\N25 slide 10__ChImJroi_DChecked_512x512__train_M__V04regp11s.json';
% env.C50_Json_train_temp='F:\matlab_program\IHC\R\C50\C50_train_temp.json';
% DataSetInfo.C50_TrainLabel='category_id3_name'; %
% DataSetInfo.C50_TrainPara={'NA','NCAr','NP','NCPr','CA','MajorAxisLength','MinorAxisLength','Eccentricity','CHA','Density','Extent',...
%                              'FD','LC','LCstd','CP','CC','CHC','CHP','MaxSACH','MinSACH','CHSR','Roughness','diameterBC','rMmCHr','meanCHrd'};
% DataSetInfo.C50_Json_test_filename{1}='H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\cocoJson\CR1 slide 10__Yolo512_Unet_256x256__result__UNET_ML__V04regp11s.json';
% DataSetInfo.C50_Json_pred_filename{1}='H:\HU\DLdata_v2\Shoykhet\project1\IHC\CR1\CR1 slide 10\cocoJson\CR1 slide 10__Yolo512_Unet_256x256__result__UNET_ML__V04regp11s__C50v01t.json';

% env.C50_Rscript_train_filename='F:\matlab_program\IHC\R\C50\R_trainC50_v01.R';
% env.C50_Rscript_predict_filename='F:\matlab_program\IHC\R\C50\R_predicC50_v01.R';


switch DataSetInfo.C50_case
    case {'train','training'}
        for ii=1:length(env.C50_Json_train_filename)
            cocotemp=CocoApi(env.C50_Json_train_filename{ii});
            cocoStructure{ii}=cocotemp.data;
            table_temp=struct2table(cocoStructure{ii}.annotations);
            tablename=table_temp.Properties.VariableNames;
            %if length(tablename)==34
            if ii==1;%length(tablename)==34
                tablename0=tablename;
            else
                [t,ia]=setdiff(tablename,tablename0);
                table_temp= removevars(table_temp,tablename{ia});
                tablename=table_temp.Properties.VariableNames;
                cocoStructure{ii}.annotations=table2struct(table_temp)';
                %cocostring=gason(cocoStructure{ii});
                %fid = fopen(env.C50_Json_train_filename{ii}, 'w');
                %if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
                %tablename0=tablename;
            end
            clear cocotemp
            % get traing label and feature parameters
            idlabel=find(strcmpi(tablename0,DataSetInfo.C50_TrainLabel)==1);
            [~,ia]=intersect(tablename0,DataSetInfo.C50_TrainPara,'stable');
            coltrain=[idlabel;ia];
        end
        % merge selected training json file
        cocostruct=cocoMerge_v01(cocoStructure);
        cocostring=gason(cocostruct);
        fid = fopen(env.C50_Json_train_temp, 'w');
        if fid == -1, error('Cannot create JSON file');end;fwrite(fid, cocostring, 'char');fclose(fid);
        str_coltrain=mat2str(coltrain);str_coltrain=regexprep(str_coltrain,';',',');

        % create R script for training
        fileID = fopen(env.C50_Rscript_train_filename,'w');
        Rl = '# Need installing following packages';fprintf(fileID,'%s\n',Rl); %
        Rl = 'library(jsonlite)';fprintf(fileID,'%s\n',Rl);
        Rl = 'library(caret)';fprintf(fileID,'%s\n',Rl);
        Rl = 'library(C50)';fprintf(fileID,'%s\n',Rl);
        Rl = ['# train C50 model'];fprintf(fileID,'%s\n',Rl); %
        Rl = ['# data retrieval'];fprintf(fileID,'%s\n',Rl);  %
        jsonf=regexprep(env.C50_Json_train_temp,'\','/');
        Rl = ['gs1df <- fromJSON("' jsonf '")'];fprintf(fileID,'%s\n',Rl);
        Rl = ['gs1df <- gs1df$annotations'];fprintf(fileID,'%s\n',Rl);
        Rl = ['# select corresponding columns'];fprintf(fileID,'%s\n',Rl);  %
        Rl = ['gs1df <- gs1df[,c(' str_coltrain(2:end-1) ')]'];fprintf(fileID,'%s\n',Rl);
        Rl = ['gs1df$' DataSetInfo.C50_TrainLabel ' <- as.factor(gs1df$' DataSetInfo.C50_TrainLabel ')'];fprintf(fileID,'%s\n',Rl);
        Rl = ['model_gsdf <- C5.0(' DataSetInfo.C50_TrainLabel ' ~., data=gs1df, trials = 100)'];fprintf(fileID,'%s\n',Rl);

        C50_Model_filename=regexprep(env.C50_Model_filename ,'\','/');
        Rl = ['save(model_gsdf,file="' C50_Model_filename '")'];fprintf(fileID,'%s\n',Rl);
        fclose(fileID);

        % Run Rscript by system command
        [status,cmdout]=RunRcode(env.C50_Rscript_train_filename,env.path_R);

    case {'predict','prediction'}    % predict by C50
        % check selected parameters
        cocotemp=CocoApi(DataSetInfo.C50_Json_test_filename{1});
        cocoStruct=cocotemp.data;
        table_temp=struct2table(cocoStruct.annotations);
        tablename=table_temp.Properties.VariableNames;

        idlabel=find(strcmpi(tablename,DataSetInfo.C50_TrainLabel)==1);
        [~,ia]=intersect(tablename,DataSetInfo.C50_TrainPara,'stable');
        coltrain=[idlabel;ia];
        str_coltrain=mat2str(coltrain);str_coltrain=regexprep(str_coltrain,';',',');

        % create R script for prediction
        C50_Json_test_filename=regexprep(DataSetInfo.C50_Json_test_filename{1},'\','/');
        C50_Json_pred_filename=regexprep(DataSetInfo.C50_Json_pred_filename{1},'\','/');
        C50_Model_filename=regexprep(env.C50_Model_filename ,'\','/');


        
        fileID = fopen(env.C50_Rscript_predict_filename,'w');
        Rl = '# Need installing following packages';fprintf(fileID,'%s\n',Rl); %
        Rl = 'library(jsonlite)';fprintf(fileID,'%s\n',Rl);
        Rl = 'library(caret)';fprintf(fileID,'%s\n',Rl);
        Rl = 'library(C50)';fprintf(fileID,'%s\n',Rl);

        Rl = ['if (file.exists("' C50_Model_filename '")) {'];fprintf(fileID,'%s\n',Rl);
        Rl = ['  model_gsdf<-get(load("' C50_Model_filename '"))'];fprintf(fileID,'%s\n',Rl);
        Rl = ['} else {'];fprintf(fileID,'%s\n',Rl);
        Rl = ['# train C50 model'];fprintf(fileID,'%s\n',Rl);
        Rl = ['}'];fprintf(fileID,'%s\n',Rl);

        Rl = ['test1df <- fromJSON("' C50_Json_test_filename '")'];fprintf(fileID,'%s\n',Rl);
        Rl = ['test1df <- test1df$annotations'];fprintf(fileID,'%s\n',Rl);
        Rl = ['test1df <- test1df[,c(' str_coltrain(2:end-1) ')]'];fprintf(fileID,'%s\n',Rl);
        Rl = ['test1df_results <- predict(object=model_gsdf, newdata=test1df, type="class")'];fprintf(fileID,'%s\n',Rl);
        Rl = ['# write to Json files'];fprintf(fileID,'%s\n',Rl); %
        Rl = ['cr1df <- fromJSON("' C50_Json_test_filename '")'];fprintf(fileID,'%s\n',Rl);
        Rl = ['cr1df$annotations$C50 <- test1df_results'];fprintf(fileID,'%s\n',Rl);
        Rl = ['write(toJSON(cr1df), "' C50_Json_pred_filename '")'];fprintf(fileID,'%s\n',Rl);
        fclose(fileID);

        % Run Rscript by RunRcode with system command
        [status,cmdout]=RunRcode(env.C50_Rscript_predict_filename,env.path_R);

end

