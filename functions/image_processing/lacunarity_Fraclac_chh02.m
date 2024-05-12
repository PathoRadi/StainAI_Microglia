function [fracL,bw1]=lacunarity_Fraclac_chh02(bw0,mpara)
% Lacunarity, fractal dimension with the method from Fraclac (imageJ plugin) 

% bw0: 2d logical mask
% Output 0 when no calaulation

% mpara.case_sampling='power_series';
% mpara.set_im_dimmension='greater';
% mpara.set_max_box_ratio=0.45;
% mpara.num_grid=12;
%
% Chaohsiung Hsu 2021/3/21 Howard University

flag_cal=1;
fracL.case_sampling=mpara.case_sampling;
fracL.set_im_dimmension=mpara.set_im_dimmension;
fracL.set_max_box_ratio=mpara.set_max_box_ratio;

if mpara.flag_bbox==1
    stats0i=regionprops(bw0,'BoundingBox');
    bbox0i=ceil(stats0i.BoundingBox);
    bw1=bw0(bbox0i(2):bbox0i(2)+bbox0i(4)-1,bbox0i(1):bbox0i(1)+bbox0i(3)-1);
else
    bw1=bw0;
end
fracL.size_image=size(bw1);
fracL.num_grid=mpara.num_grid;

switch fracL.set_im_dimmension
    case 'greater'
        [fracL.size_cal]=max(size(bw1));
    otherwise
        [fracL.size_cal]=min(size(bw1));
end

switch fracL.case_sampling
    case 'power_of_2' % 2 4 8 16 32 64 128 256
        p = ceil(log(fracL.size_cal)/log(2));
        nn=1:p;
        cb=2.^nn;
        fracL.size_sampling=cb(cb<=mpara.set_max_box_ratio*fracL.size_cal);
        %frac.size_sampling=[2 4 16];
        
        if isempty(fracL.size_sampling)==1
            flag_cal=0;
        else
            switch mpara.startpoint
                case 'rand'
                    fracL.starting_point= randi(max(fracL.size_sampling),[fracL.num_grid,2]);
                    fracL.starting_point(1,:)=[0,0];
                case 'fixed'
                    ng=ceil((fracL.num_grid).^0.5)+1;
                    [xp,yp]=meshgrid(1:max(fracL.size_sampling)/ng:max(fracL.size_sampling)-max(fracL.size_sampling)/ng,...
                                     1:max(fracL.size_sampling)/ng:max(fracL.size_sampling)-max(fracL.size_sampling)/ng);
                    starting_point0(:,1)= round(xp(:))-1;
                    starting_point0(:,2)= round(yp(:))-1;
                    if size(starting_point0,1)>=fracL.num_grid;
                        fracL.starting_point=starting_point0(1:fracL.num_grid,:);
                    else
                        clear starting_point0
                        [xp,yp]=meshgrid(1:1:max(fracL.size_sampling),...
                            1:1:max(fracL.size_sampling));
                        starting_point0(:,1)= round(xp(:))-1;
                        starting_point0(:,2)= round(yp(:))-1;
                        if size(starting_point0,1)>=fracL.num_grid;
                            fracL.starting_point=starting_point0(1:fracL.num_grid,:);
                        else
                            fracL.starting_point=starting_point0;
                        end
                    end
            end
        end
        
        %randperm(max(frac.size_sampling),12)
    case 'power_series' % 2 4 16 64 256
        p = ceil(log(fracL.size_cal)/log(2));
        
        nn=1:p;
        nns=(nn-1)*2;nns(1)=1;
        cb=2.^nns;
        fracL.size_sampling=cb(cb<=mpara.set_max_box_ratio*fracL.size_cal);
        if isempty(fracL.size_sampling)==1
            flag_cal=0;
        else
            switch mpara.startpoint
                case 'rand'
                    fracL.starting_point= randi(max(fracL.size_sampling),[fracL.num_grid,2]);
                    fracL.starting_point(1,:)=[0,0];
                case 'fixed'
                    ng=ceil((fracL.num_grid).^0.5)+1;
                    [xp,yp]=meshgrid(1:max(fracL.size_sampling)/ng:max(fracL.size_sampling)-max(fracL.size_sampling)/ng,...
                        1:max(fracL.size_sampling)/ng:max(fracL.size_sampling)-max(fracL.size_sampling)/ng);
                    starting_point0(:,1)= round(xp(:))-1;
                    starting_point0(:,2)= round(yp(:))-1;
                    if size(starting_point0,1)>=fracL.num_grid;
                        fracL.starting_point=starting_point0(1:fracL.num_grid,:);
                    else
                        clear starting_point0
                        [xp,yp]=meshgrid(1:1:max(fracL.size_sampling),...
                            1:1:max(fracL.size_sampling));
                        starting_point0(:,1)= round(xp(:))-1;
                        starting_point0(:,2)= round(yp(:))-1;
                        if size(starting_point0,1)>=fracL.num_grid;
                            fracL.starting_point=starting_point0(1:fracL.num_grid,:);
                        else
                            fracL.starting_point=starting_point0;
                        end
                    end
            end
        end
        
end

% zero padding image for starting point
if flag_cal==1
    [size_max]=max(size(bw1));
    size_bwzp=[size_max*4 size_max*4];
    
    bwzp=zeros(size_bwzp);
    bwzp(fix((size_bwzp(1)-size(bw1,1))/2)+1:fix((size_bwzp(1)-size(bw1,1))/2)+size(bw1,1),...
        fix((size_bwzp(2)-size(bw1,2))/2)+1:fix((size_bwzp(2)-size(bw1,2))/2)+size(bw1,2))=bw1;
    y0=fix((size_bwzp(1)-size(bw1,1))/2)+1;
    x0=fix((size_bwzp(2)-size(bw1,2))/2)+1;
    
    for gg=1:size(fracL.starting_point,1)
        x1=x0-fracL.starting_point(gg,1);
        y1=y0-fracL.starting_point(gg,2);
        bw_grid=bwzp(y1:y0+size(bw1,1)-1,x1:x0+size(bw1,2)-1);
        %   figure(123);subplot(2,3,gg);imagesc(bw_grid);axis image
        for nn=1:length(fracL.size_sampling)
            fracL.en(gg,nn)=fracL.size_sampling(nn)/fracL.size_cal;
            bw14d=imsplit_bc(bw_grid,[fracL.size_sampling(nn),fracL.size_sampling(nn)],'top-left');
            m=sum(bw14d,[2 3]);
            idex=find(m~=0);
            fracL.F__num_cbox_foreground(gg,nn)=length(idex);
            fracL.Fu__mean_pixel_in_F(gg,nn)=mean(m(idex));
            fracL.Fsigma__std_pixel_in_F(gg,nn)=std(m(idex),1); %std1
            %         fracL.Omega__num_cbox(gg,nn)=length(m);
            %         fracL.OmegaU__mean_pixel_in_Omega(gg,nn)=mean(m);
            %         fracL.OmegaSigma__std_pixel_in_Omega(gg,nn)=std(m,1);
        end
        [b, ~] = regress(log(fracL.F__num_cbox_foreground(gg,:))', [ones(length(fracL.F__num_cbox_foreground(gg,:)), 1), log(fracL.en(gg,:))']);
        fracL.F__logSlope__DBcounts(gg,1)=b(2);
        %[b, ~] = regress(log(fracL.Omega__num_cbox(gg,:))', [ones(length(fracL.Omega__num_cbox(gg,:)), 1), log(fracL.en(gg,:))'], 0.05);fracL.Omega__logSlope(gg,1)=b(2);
        [b, ~] = regress(log(fracL.Fu__mean_pixel_in_F(gg,:))', [ones(length(fracL.Fu__mean_pixel_in_F(gg,:)), 1), log(fracL.en(gg,:))'], 0.05);fracL.Fu__logSlope(gg,1)=b(2);
        [b, ~] = regress(log(fracL.Fsigma__std_pixel_in_F(gg,:))', [ones(length(fracL.Fsigma__std_pixel_in_F(gg,:)), 1), log(fracL.en(gg,:))'], 0.05);fracL.Fsigma__logSlope(gg,1)=b(2);
        fracL.Flambda__FsigmaDFu(gg,:)=(fracL.Fsigma__std_pixel_in_F(gg,:)./fracL.Fu__mean_pixel_in_F(gg,:)).^2+1;
        [b, ~] = regress(log(fracL.Flambda__FsigmaDFu(gg,:))', [ones(length(fracL.Flambda__FsigmaDFu(gg,:)), 1), log(fracL.en(gg,:))'], 0.05);fracL.Flambda__logSlope(gg,1)=b(2);
        %[b, ~] = regress(log(fracL.OmegaU__mean_pixel_in_Omega(gg,:))', [ones(length(fracL.OmegaU__mean_pixel_in_Omega(gg,:)), 1), log(fracL.en(gg,:))'], 0.05);fracL.Omegau__logSlope(gg,1)=b(2);
        %[b, ~] = regress(log(fracL.OmegaSigma__std_pixel_in_Omega(gg,:))', [ones(length(fracL.OmegaSigma__std_pixel_in_Omega(gg,:)), 1), log(fracL.en(gg,:))'], 0.05);fracL.OmegaSigma__logSlope(gg,1)=b(2);
        %fracL.OmegaLambda__OmegaSigmaDOmegaU(gg,:)=(fracL.OmegaSigma__std_pixel_in_Omega(gg,:)./fracL.OmegaU__mean_pixel_in_Omega(gg,:)).^2+1;
        %[b, ~] = regress(log(fracL.OmegaLambda__OmegaSigmaDOmegaU(gg,:))', [ones(length(fracL.OmegaLambda__OmegaSigmaDOmegaU(gg,:)), 1), log(fracL.en(gg,:))'], 0.05);fracL.OmegaLambda__logSlope(gg,1)=b(2);
        fracL.LacunarityGRID(gg,:)=((fracL.Fsigma__std_pixel_in_F(gg,:)./fracL.Fu__mean_pixel_in_F(gg,:)).^2);
    end
    fracL.Lacunarity=mean(fracL.LacunarityGRID(:));
    fracL.Lacunarity_std=std(fracL.LacunarityGRID(:),1);
    
    
    
else
    fracL.Lacunarity=0;
    fracL.Lacunarity_std=0;
end