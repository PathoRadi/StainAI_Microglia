function b1=bar_pattern(patterns,lcolor,lspacing,lwidth,varargin)
% plot bar graph with patterns lines
% varargin <= input of original "bar" matlab function
% patterns: {'\','/','*','-','|','+', ' ', 's'} (solid filled)
% lcolor: line color {[R G B]} between 0-1
% lspacing: {1}: space between lines
% lwidth:   {1}: line width

% Example 1:
% figure(1);clf
% dataBar=rand(1,5)-0.5;
% patterns={'/+\ s'};lcolor={jet(5)};lspacing={[1 1 1 1 1]};lwidth={[1 1 1 1 1]};
% b1=bar_pattern(patterns,lcolor,lspacing,lwidth,dataBar,'FaceColor',[1 1 1]);

% Example 2:
% figure(1);clf
% dataBar=rand(2,5)-0.5;
% patterns={'/+\ s','/+\ s'};
% lcolor={lines(5),lines(5)};
% lspacing={[1 1 1 1 1],[1 1 1 1 1]};lwidth={[2 2 2 2 2],[2 2 2 2 2]};
%  b1=bar_pattern(patterns,lcolor,lspacing,lwidth,dataBar,'FaceColor',[1 1 1],'BarWidth',1);

% Example 3: Apply with bar
% figure(1);clf
% dataBar=rand(3,5)-0.5;
% patterns={'/+\ x','/+\ x','/+\ s'};
% lcolor={lines(5),lines(5),lines(5)};
% lspacing={[1 1 1 1 1],[1 1 1 1 1],[1 1 1 1 1]};lwidth={[2 2 2 2 2],[2 2 2 2 2],[2 2 2 2 2]};
% b1=bar_pattern(patterns,lcolor,lspacing,lwidth,dataBar,'FaceColor',[1 1 1],'BarWidth',1,'LineWidth',2);
% b1=bar(dataBar,'FaceAlpha',0.2,'BarWidth',1,'LineWidth',2,'FaceColor','flat');hold on;
% set(gcf,'color','w');set(gca,'FontWeight','bold','LineWidth',2,'FontSize',20,'xticklabel',{'A','B','C'})
% 


% created by Chao-Hsiung Hsu, 20230320
% Department of Radiology, Howard University, Washington, DC

dataBar=varargin{1};
% remove inf, -inf data
dataBar(dataBar==inf)=0;
dataBar(dataBar==-inf)=0;

b1=bar(varargin{:});hold on
barwidth=b1(1).BarWidth;
if length(b1)==1
    dataBar=dataBar(:)';
end

% check input patterns and line color,
% using the first patterns if the size not match input data
if length(patterns{1})<size(dataBar,2)
    patterns{1}(1:size(dataBar,2))=patterns{1}(1);
    patterns0=patterns{1};clear patterns
    for gg=1:size(dataBar,1)
        patterns{gg}=patterns0;
    end
else
    if length(patterns)<size(dataBar,1)
        patterns0=patterns{1};clear patterns
        for gg=1:size(dataBar,1)
            patterns{gg}=patterns0;
        end
    end
end

if length(lspacing{1})<size(dataBar,2)
    lspacing{1}(1:size(dataBar,2))=lspacing{1}(1);
    lspacing0=lspacing{1};clear lspacing
    for gg=1:size(dataBar,1)
        lspacing{gg}=lspacing0;
    end
else
    if length(lspacing)<size(dataBar,1)
        lspacing0=lspacing{1};clear lspacing
        for gg=1:size(dataBar,1)
            lspacing{gg}=lspacing0;
        end
    end
end

if length(lwidth{1})<size(dataBar,2)
    lwidth{1}(1:size(dataBar,2))=lwidth{1}(1);
    lwidth0=lwidth{1};clear lwidth
    for gg=1:size(dataBar,1)
        lwidth{gg}=lwidth0;
    end
else
    if length(lwidth)<size(dataBar,1)
        lwidth0=lwidth{1};clear lwidth
        for gg=1:size(dataBar,1)
            lwidth{gg}=lwidth0;
        end
    end
end

if size(lcolor{1},1)<size(dataBar,2)
    lcolor{1}(1:size(dataBar,2),:)=repmat(lcolor{1}(1,:),size(dataBar,2),1);
    lcolor0=lcolor{1};clear lcolor
    for gg=1:size(dataBar,1)
        lcolor{gg}=lcolor0;
    end
else
    if length(lcolor)<size(dataBar,1)
        lcolor0=lcolor{1};clear lcolor
        for gg=1:size(dataBar,1)
            lcolor{gg}=lcolor0;
        end
    end
end

ratioyx=get(gca,'DataAspectRatio');
if length(b1)~=1
    bardistG=b1(2).XOffset-b1(1).XOffset;
else
    bardistG=1;
end


if length(b1)~=1
    for ib=1:size(dataBar,2)
        for dp=1:size(dataBar,1)
            switch patterns{dp}(ib)
                case 's'
                    b1(ib).FaceColor = 'flat';
                    b1(ib).CData(dp,:) =lcolor{dp}(ib,:);
                case '\'
                    plotSLR(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                case '/'
                    plotSRL(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                case 'x'
                    plotSLR(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                    plotSRL(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                case '-'
                    plotLR(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                case '|'
                    plotUD(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                case '+'
                    plotLR(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                    plotUD(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                case '*'
                    plotSLR(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                    plotSRL(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                    plotUD(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor{dp}(ib,:),lspacing{dp}(ib),lwidth{dp}(ib));
                case ''
                    % soild filled white color
            end
        end
    end
else % for one group
    for dp=1:size(dataBar,2)
        switch patterns{1}(dp)
            case 's'
                b1(1).FaceColor = 'flat';
                b1(1).CData(dp,:) =lcolor{1}(dp,:);
            case '\'
                plotSLR(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
            case '/'
                plotSRL(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
            case 'x'
                plotSLR(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
                plotSRL(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
            case '-'
                plotLR(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
            case '|'
                plotUD(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
            case '+'
                plotLR(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
                plotUD(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
            case '*'
                plotSLR(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
                plotSRL(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
                plotUD(b1,1,dp,ratioyx,bardistG,barwidth,lcolor{1}(dp,:),lspacing{1}(dp),lwidth{1}(dp));
            case ''
                % soild filled white color
        end
    end
end

end

function plotUD(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor,lspacing,lwidth)
y0=b1(ib).YData(dp);y1=0;
x0=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
x1=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
dx=abs(lspacing*(x1-x0)/4);
x0=x0+dx;
while x0<x1-dx/10
    plot([x0 x0],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
    x0=x0+dx;
end
end

function plotLR(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor,lspacing,lwidth)
if b1(ib).YData(dp)>0
    y0=b1(ib).YData(dp);
    x0=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    dy=abs(lspacing*(x1-x0)*ratioyx(2)/ratioyx(1)/2);y1=y0-dy;
    while y1>=0
        plot([x0 x1],[y1 y1],'-','color',lcolor,'LineWidth',lwidth);
        y1=y1-dy;
    end
elseif b1(ib).YData(dp)<0
    y0=b1(ib).YData(dp);
    x0=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    dy=abs(lspacing*(x1-x0)*ratioyx(2)/ratioyx(1)/2);y1=y0+dy;
    while y1<=0
        plot([x0 x1],[y1 y1],'-','color',lcolor,'LineWidth',lwidth);
        y1=y1+dy;
    end
end
end

function plotSRL(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor,lspacing,lwidth)
if b1(ib).YData(dp)>0
    y0=b1(ib).YData(dp);y1=y0;
    x0=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    dy=abs(bardistG*barwidth*ratioyx(2)/ratioyx(1))*lspacing/2;
    while y0>=0
        y1=y0-abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
        if y0>0
            if y1<0
                x10=x1;
                x1=interp1([y0 y1],[x0 x1],0);y1=0;
                plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
                x1=x10;
            else
                plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
            end

        end
        y0=y0-dy;
    end
    y0=b1(ib).YData(dp);
    x0=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    y1=y0-abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
    y1=y1+dy;
    while y1<=b1(ib).YData(dp)
        x0=interp1([y0+dy y1],[x0 x1],y0);
        if y1<0
            x10=x1;
            x1=interp1([y0 y1],[x0 x1],0);y1=0;
            plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
            x1=x10;
        else
            plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
        end
        y1=y1+dy;
    end

elseif b1(ib).YData(dp)<0
    y0=b1(ib).YData(dp);y1=y0;
    x0=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    dy=abs(bardistG*barwidth*ratioyx(2)/ratioyx(1))*lspacing/2;
    while y0<=0
        y1=y0+abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
        if y0<0
            if y1>0
                x10=x1;
                x1=interp1([y0 y1],[x0 x1],0);
                y1=0;
                plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
                x1=x10;
            else
                plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
            end

        end
        y0=y0+dy;
    end
    y0=b1(ib).YData(dp);
    x0=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    y0=y0-dy;
    y1=y0+abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
    while y1>=b1(ib).YData(dp)
        x00=x0;y00=y0;
        x0=interp1([y0 y1],[x0 x1],b1(ib).YData(dp));
        y0=b1(ib).YData(dp);
        if y0<=0 && y1>0
            xx=interp1([y0 y1],[x0 x1],0);
            plot([x0 xx],[y0 0],'-','color',lcolor,'LineWidth',lwidth);
        else
            plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
        end
        x0=x00;y0=y00;
        y0=y0-dy;
        y1=y0+abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
    end
end
end


function plotSLR(b1,ib,dp,ratioyx,bardistG,barwidth,lcolor,lspacing,lwidth)

if b1(ib).YData(dp)>0
    y0=b1(ib).YData(dp);y1=y0;
    x0=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    dy=abs(bardistG*barwidth*ratioyx(2)/ratioyx(1))*lspacing/2;
    while y0>=0
        y1=y0-abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
        if y0>0
            if y1<0
                x10=x1;
                x1=interp1([y0 y1],[x0 x1],0);y1=0;
                plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
                x1=x10;
            else
                plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
            end

        end
        y0=y0-dy;
    end
    y0=b1(ib).YData(dp);
    x0=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    y1=y0-abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
    y1=y1+dy;
    while y1<=b1(ib).YData(dp)
        x0=interp1([y0+dy y1],[x0 x1],y0);
        if y1<0
            x10=x1;
            x1=interp1([y0 y1],[x0 x1],0);y1=0;
            plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
            x1=x10;
        else
            plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
        end
        y1=y1+dy;
    end

elseif b1(ib).YData(dp)<0
    y0=b1(ib).YData(dp);y1=y0;
    x0=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    dy=abs(bardistG*barwidth*ratioyx(2)/ratioyx(1))*lspacing/2;
    while y0<=0
        y1=y0+abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
        if y0<0
            if y1>0
                x10=x1;
                x1=interp1([y0 y1],[x0 x1],0);
                y1=0;
                plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
                x1=x10;
            else
                plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
            end

        end
        y0=y0+dy;
    end
    y0=b1(ib).YData(dp);
    x0=b1(ib).XData(dp)+b1(ib).XOffset+bardistG*barwidth/2;
    x1=b1(ib).XData(dp)+b1(ib).XOffset-bardistG*barwidth/2;
    y0=y0-dy;
    y1=y0+abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
    while y1>=b1(ib).YData(dp)
        x00=x0;y00=y0;
        x0=interp1([y0 y1],[x0 x1],b1(ib).YData(dp));
        y0=b1(ib).YData(dp);
        if y0<=0 && y1>0
            xx=interp1([y0 y1],[x0 x1],0);
            plot([x0 xx],[y0 0],'-','color',lcolor,'LineWidth',lwidth);
        else
            plot([x0 x1],[y0 y1],'-','color',lcolor,'LineWidth',lwidth);
        end

        % plot([x0 x1],[y0 y1],'-','color',lcolor);
        x0=x00;y0=y00;
        y0=y0-dy;
        y1=y0+abs(bardistG*barwidth*ratioyx(2)/ratioyx(1));
    end
end
end
%