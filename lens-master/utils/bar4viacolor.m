function [hh,ScalingDataColorImg,ScaleColorDataClim,colorbarh] = bar4viacolor(varargin)
% bar4viacolor - 4-D bar graph : bar3 with another dimension via bar color. 
% Two color schemes are available: The jet colormap and another that, like
% bar3, is a column group scheme whose groups colors vary mainly by saturation
%  (see BarColorType below)
%
% function bar4viacolor(varargin)
% function [hh,ScalingDataColorImg,ScaleColorDataClim,colorbarh] = bar4viacolor(varargin)
%
% This function is a add-on hack on bar3 and so I've left the bar3
%   documentation below.  W/r to the bar3 documentation below, bar4 uses a
%   Z sized matrix to specifiy the 4D color dimension. There are some
%   options that are appropriate with the new facility but, as it so
%   happpens, bar3 uses its own argument parsing function.  So rather than
%   hack that too, I extended the bar3 Z argument to be a struture s.t.
%   one of the fields is Z and the rest the new 4D parameters. This "Z"
%   structure goes in the first or second argument, just like Bar3, and all
%   other Bar3 args stay the same.
%
% Because color is used as another dimension, an obligatory colorbar is
%   automatically be displayed showing the range of colors.
% 
% The Z structure consists of these fields:
%   {.Z, .ColorScaleData, .ScalingOption, .BarColorType}
%   (Note that ScalingOption and BarColorType have defaults and those fields
%       do not have to be in the structure for their defaults to take
%       effect)
%
%   Z - 3D data just like bar3 where each element yields a bar.
%
%   ColorScaleData - Same size as Z.  Defines the 4D data.
%   Note, negative values will yield bars with red edges.  New if this
%   argument is left out or empty than it will default to the Z data which
%   then causes the bars to be Z colored.
%
%   ScalingOption - {'a'} | 's' | 'c' | Clim - This controls how the
%   Scaling Data is mapped to the colors:
%       'a' - autoscaling - if all ScalingData is between 0 and 1 nothing is
%           done but otherwise the data is mapped to the entire color range.
%       's' - scaled - The ScalingData is mapped to the entire color range
%           (like imagesc)
%       'c' - clipped - ScalingData between 0 and 1 is scaled to the entire
%          color range.  Data outside that is mapped to the first and last
%          colors respectively (i.e. as if ScalingData was clipped to 0,1)
%       Clim - [minvalue, maxvalue] - ScalingData in the range of minvalue
%         to maxvalue is mapped to the first and last colors respectively
%         (i.e. as if ScalingData was clipped to Clim like imagesc w/
%         clim)
%
%   BarColorType - 'c' | {'s'} - controls the color scheme used to color
%     the bars.  
%   The default 's' option colors each bar by indexing into the jet
%     colormap just like, say, an indexed image using imagesc
%   The 'c' option is, like bar3, is a column group color scheme.
%   Specifically, all the bars of a column are the same hue but vary by
%   saturation, and to a lesser degree intensity, of each bar is varied to
%   reflect the ColorScaleData.
%   WARNING: *** concerning the use of 'c' options with figures containing
%       multiple subplots/colorbars see *** below
%
%   Additional output args: ScalingDataColorImg,ScaleColorDataClim,colorbarh.
%   Only appropriate for the BarColorType=='c' option.
%   ScalingDataColorImg - shows the range of colors available to this
%    histogram. A RGB image with row being the hue used for the
%    respective column of the histogram and the columns being 
%    the breakdown thereof.
%   ScaleColorDataClim - is the ScalingDataClim implied or specified (and
%   so is the appropriate item to specify the range of X labels for
%   ScalingDataColorImg as per the image function)
%       image(ScaleColorDataClim,1:size(ScalingDataColorImg,1),ScalingDataColorImg);
%  colorbarh - handle to colorbar.  For the 'c' option resizing this might
%    be desirable but the colorbar won't auto resize or move nicely if you do
%
% Example:
%
%     figure; 
%     Z = reshape(1:6*7,6,7); % 3D values, i.e. bar heights, increase in column order
%     ScalingData= reshape(-20:21,7,6)'; % 4D values, i.e. bar colors, increase in row order
%     bar4viacolor(struct('Z',Z,'ColorScaleData',ScalingData, ...
%       'ScalingOption',[-17,17],'BarColorType','c'));
% 
%   Here the Z data is just 1:42 reshaped to a 6,7 array and the
%   ScalingData is a likewise sized array from -20:21 but whos sequence is
%   in row major order.
%   The construction of Z is such that each column will have bar
%   heights greater than the previous column and the construction of
%   ScalingData, along with the specification of  BarColorType == 'c', will
%   independly produce increasing saturation within each row. The negative
%   ScalingData values (the first 20 boxes in row major order) yield red
%   edged light bars.  The Clim clipping value means that the ScalingData
%   outside of -17,17 is as if it were -17,17.
%
%   Here's the 's' color scheme w/ the same data
%      figure;
%      bar4viacolor(struct('Z',Z,'ColorScaleData',ScalingData, ...
%        'ScalingOption',[-17,17],'BarColorType','s'));
%   Now the bar color are completely independent and correspond to the jet
%       colormap
%
%   Here's a 3d color version.
%   bar4viacolor(struct('Z',Z,'ScalingOption','s'))
%
%   Andrew Diamond
%   EnVision Systems LLC
%
%   WARNING: *** : Having color as a 4th dimension makes a colorbar obligatory.
%   Unfortunately, colorbars seeem to be funny (in a black humor way)
%   things.  The 'c' option requires the use of absolute vs indexed
%   colors but colormaps don't have that in mind.  I hacked into the colorbar
%   information to make the color bar an RGB image of the colors used but
%   it doesn't seem to be 100% proper.  In particular, the use of this type
%   of colorbar seems to interfere with standard colobars in the same figure
%   (through the use of subplots).  So, if you are making a figure with
%   multiple colorbars where any are not from bar4viacolor with the 'c'
%   option, don't use the 'c' option.  But, if all you have is a figure
%   with one plot or all subplots use the 'c' option then I think its OK.
%   At one point just making the colorbar an RGB image caused the fonts to
%   go nuts (like a memory overwrite of some sort).  Also, it would be nice
%   to have a wider colorbar with the 'c' option but if you alter a
%   colorbar's position (width) it stops being completely automatic and
%   part of that is a fixed width for a narrow colobar.  If anyone wants to
%   fix this go right ahead.  Please.  I just wanted an RGB colorbar but
%   instead I got the bloody Spanish Inquisition.  The histogram code was
%   trivial!
% -----------------------
%   BAR3(Y,Z) draws the columns of the M-by-N matrix Z as vertical 3-D
%   bars.  The vector Y must be monotonically increasing or
%   decreasing.
%
%   BAR3(Z) uses the default value of Y=1:M.  For vector inputs,
%   BAR3(Y,Z) or BAR3(Z) draws LENGTH(Z) bars.  The colors are set by
%   the colormap.
%
%   BAR3(Y,Z,WIDTH) or BAR3(Z,WIDTH) specifies the width of the
%   bars. Values of WIDTH > 1, produce overlapped bars.  The default
%   value is WIDTH=0.8
%
%   BAR3(...,'detached') produces the default detached bar chart.
%   BAR3(...,'grouped') produces a grouped bar chart.
%   BAR3(...,'stacked') produces a stacked bar chart.
%   BAR3(...,LINESPEC) uses the line color specified (one of 'rgbymckw').
%
%   BAR3(AX,...) plots into AX instead of GCA.
%
%   H = BAR(...) returns a vector of surface handles in H.
%
%   Example:
%       subplot(1,2,1), bar3(peaks(5))
%       subplot(1,2,2), bar3(rand(5),'stacked')
%
%   See also BAR, BARH, and BAR3H.

%   Mark W. Reichelt 8-24-93
%   Revised by CMT 10-19-94, WSun 8-9-95
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.30.6.5 $  $Date: 2005/04/28 19:55:59 $
ScalingDataColorImg=[];ScaleColorDataClim=[];colorbarh=[];
error(nargchk(1,inf,nargin,'struct'));
nin = length(varargin);
zeroscale=[]; %
% all saturation values (beteen 0 an 1) get raised to this power.  Maximum
% intensity colors, at least on my monitor, look totally saturated after
% about 70% saturation.  This pushed that a bit but it comes at the expense
% of more unsaturated looking low values.
% Should probably devise a color map by analytic formuala that lowers
% intensity significantly only for > 90% saturation which would then make
% high saturated values easier to discriminate
% Then I added the non linear intensity mangling to do the same thing so
% the need for this parameter has gone away.
SaturationPower = 1;
iZStruct=0;
for ivarargin = 1:min(2,length(varargin)) % The Z structure will be the 1st or second arg
    argi = varargin{ivarargin};
    if(isstruct(argi)) % first element in mag which is bars size and second is phase which is color adj
        iZStruct=ivarargin;
        defaultParams = struct('Z',[], 'ColorScaleData',[], 'ScalingOption','a', 'BarColorType','s');
        argi = mergedefaultparams(argi, defaultParams);
        if(isempty(argi.ColorScaleData))
            argi.ColorScaleData = argi.Z;
        end
        if( length(size(argi.Z))~= 2 ||  length(size(argi.Z))~= length(size(argi.ColorScaleData)) || isempty(argi.Z))
            error('Z and ColorScale Data must be the same sized non empty 2d matrices');
        end
        ScaleColorData = argi.ColorScaleData;
        ScaleColorDataRaw = ScaleColorData; 
        varargin{ivarargin} = argi.Z; % bar3 machinery will not see the bar4 Z structure stuff.
        
        if(~ischar(argi.ScalingOption) && ~(isnumeric(argi.ScalingOption) && all(size(argi.ScalingOption(:))==[2,1]))) % scaling info for color
            error('scaling data type should be a of type character A)uto, S)caling, C)lipping or a 2x1 clim')
        end
        if(isnumeric(argi.ScalingOption))
            ScaleColorDataClim = argi.ScalingOption;
            if(ScaleColorDataClim(1) >= ScaleColorDataClim(2))
                error('ScaleColorData clim(2) > clim(1)');
            else
                ScaleColorData = min(1,max(0,(ScaleColorData - ScaleColorDataClim(1)) ./ diff(ScaleColorDataClim)));
                zeroscale = (0 - ScaleColorDataClim(1)) ./ diff(ScaleColorDataClim);
            end
        else
            scalestr = argi.ScalingOption;
            minScaleColorData = min(ScaleColorData(:));
            maxScaleColorData = max(ScaleColorData(:));
            switch(lower(scalestr(1)))
                case 'a'
                    if(maxScaleColorData > 1 || minScaleColorData < 0)
                        ScaleColorData = (ScaleColorData - minScaleColorData) ./ (maxScaleColorData -minScaleColorData);
                        ScaleColorDataClim=[minScaleColorData,maxScaleColorData];
                        zeroscale = (0 - minScaleColorData) ./ (maxScaleColorData -minScaleColorData);
                    else
                        ScaleColorDataClim=[0,1];
                    end
                case 's'
                    ScaleColorData = (ScaleColorData - minScaleColorData) ./ (maxScaleColorData -minScaleColorData);
                    ScaleColorDataClim=[minScaleColorData,maxScaleColorData];
                    zeroscale = (0 - minScaleColorData) ./ (maxScaleColorData -minScaleColorData);
                case 'c'
                    ScaleColorData = min(1,max(0,ScaleColorData));
                    ScaleColorDataClim=[0,1];
                otherwise
                    error('scaling data type should be a of type character A)uto, S)caling, C)lipping')
            end
        end
        sepcolorsstr = argi.BarColorType;
        switch(lower(sepcolorsstr(1)))
            case 'c'
                colgroupcolors=1;
            case 's'
                colgroupcolors=0;
            otherwise
                error('bar4 BarColorType, colgroupcolors, must be ''c'' for column group colors or ''n'' otherwise');
        end
        break;
    end
end
if(iZStruct==0)
    error(sprintf('%s requires a Z struct arg',mfilename));
end
[cax,args] = axescheck(varargin{:});
[msg,x,y,xx,yy,linetype,plottype,barwidth,zz] = makebars(args{:},'3');
if ~isempty(msg), error(msg); end %#ok

m = size(y,2);
% Create plot
cax = newplot(cax);
fig = ancestor(cax,'figure');

next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);
edgec = get(fig,'defaultaxesxcolor');
facec = 'flat';
h = [];
cc = ones(size(yy,1),4);

if ~isempty(linetype)
    facec = linetype;
end

nrows=size(yy,2)/4;
if(~colgroupcolors) % each bar has its own 4d color
    cmap = colormap('jet'); % scaling is w/r to saturation;
    colormap(cmap);
    for i=1:nrows % size(yy,2)/4
        for k=1:size(yy,1)/6
            cdatai = diff(ScaleColorDataClim) * ScaleColorData(k,i) + ScaleColorDataClim(1);
            if(ScaleColorDataRaw(k,i) < 0)
                edgei = [1,0,0];
            else
                edgei = edgec;
            end
            h = [h,surface('xdata',xx((k-1)*6+(1:6),:)+x(i),...
                'ydata',yy((k-1)*6+(1:6),(i-1)*4+(1:4)), ...
                'zdata',zz((k-1)*6+(1:6),(i-1)*4+(1:4)),...
                'cdata', cdatai .* cc((k-1)*6+(1:6),:), ...
                'FaceColor', facec,... %
                'EdgeColor',edgei,...
                'tag','bar3',...
                'parent',cax)];
        end
    end
else % scaling data via saturation w/r to each column having the same hue
    cmap = colormap('hsv'); % scaling is w/r to saturation;
    orangedivider =find(cmap(:,1) == 1 & cmap(:,2) < 0.7 & cmap(:,3) ==0 );
    orangedivider = orangedivider(end);
    cmap = cmap([orangedivider:end],:); % chuck orange red start so end bars isn't too much just like start bars
    colormap(cmap);
    cmapScalingT = [1,1;size(yy,2)/4,1]\[0.5+0.001;size(cmap,1)+0.5-0.001];
    % hsvbasecolori = rgb2hsv(basecolori);
    for i=1:size(yy,2)/4 % each column (same hue)
        basecolori = cmap(round([i,1]*cmapScalingT),:);
        hsvbasecolori = rgb2hsv(basecolori);
        for k=1:size(yy,1)/6 % each row
            if(ScaleColorDataRaw(k,i) < 0)
                edgei = [1,0,0];
            else
                edgei = edgec;
            end
            hsvbasecolori(2) = ScaleColorData(k,i) .^ SaturationPower;
            hsvbasecolori(3) = SatToDecIntensity(hsvbasecolori(2));
            colori = hsv2rgb(hsvbasecolori);
            h = [h,surface('xdata',xx((k-1)*6+(1:6),:)+x(i),...
                'ydata',yy((k-1)*6+(1:6),(i-1)*4+(1:4)), ...
                'zdata',zz((k-1)*6+(1:6),(i-1)*4+(1:4)),...
                'cdata',i .* cc((k-1)*6+(1:6),:), ...
                'FaceColor', colori,... %
                'EdgeColor', edgei,... % edgec,...
                'tag','bar3',...
                'parent',cax)];
        end
    end
end

if length(h)==1
    set(cax,'clim',[1 2]);
end

if ~hold_state,
    % Set ticks if less than 16 integers
    if all(all(floor(y)==y)) && (size(y,1)<16)
        set(cax,'ytick',y(:,1));
    end

    xTickAmount = sort(unique(x(1,:)));
    if length(xTickAmount)<2
        set(cax,'xtick',[]);
    elseif length(xTickAmount)<=16
        set(cax,'xtick',xTickAmount);
    end  %otherwise, will use xtickmode auto, which is fine

    hold(cax,'off'), view(cax,3), grid(cax,'on')
    set(cax,...
        'NextPlot',next,...
        'ydir','reverse');
    if plottype==0,
        set(cax,'xlim',[1-barwidth/m/2 max(x)+barwidth/m/2])
    else
        set(cax,'xlim',[1-barwidth/2 max(x)+barwidth/2])
    end

    dx = diff(get(cax,'xlim'));
    dy = size(y,1)+1;
    if plottype==2,
        set(cax,'PlotBoxAspectRatio',[dx dy (sqrt(5)-1)/2*dy])
    else
        set(cax,'PlotBoxAspectRatio',[dx dy (sqrt(5)-1)/2*dy])
    end
end

if nargout>0,
    hh = h;
end
if(~colgroupcolors)
    colorbar;
else
    % Either the colorbar width is fixed or it doesn't automatically resize
    % properly.  I guess I'm stuck with the default width.
    %     caxpos = get(cax,'Position');
    %     caxpos(3) = caxpos(3)- 0.0;
    %     set(cax,'Position',caxpos);
    UsedCmapMapInds= round([(1:nrows)' ,ones(nrows,1)]*cmapScalingT);
    cmaphsv = rgb2hsv(cmap(UsedCmapMapInds,:));
    cmaphsv(:,2) = 0.5 .^ SaturationPower;
    cmaphsv(:,3) = SatToDecIntensity(cmaphsv(:,2));
    showcmap = hsv2rgb(cmaphsv);
    colormap(showcmap)
    colorbarh=colorbar( 'YTick',[]);

    a=reshape(showcmap,[size(showcmap,1),1,size(showcmap,2)]);
    aI=repmat(a,[1,20,1]);
    aIhsv=rgb2hsv(aI);
    Smask = repmat(linspace(0,1,size(aIhsv,2)) .^ SaturationPower,size(aIhsv,1),1);
    aIhsv(:,:,2) = Smask;
    aIhsv(:,:,3) = SatToDecIntensity(aIhsv(:,:,2));
    ScalingDataColorImg = hsv2rgb(aIhsv);
    imageh=findobj(colorbarh,'Type','image');


    XData = [1,nrows];
    set(colorbarh, 'XLim',XData +  [-0.5, +0.5]);
    set(imageh, 'XData',XData);

    YData = ScaleColorDataClim;
    % For some odd reason I can't seem to set the limits and Xdata right.
    % I figured it should be like an image which has XData from 1:n and
    % Xlim from 0.5:n+0.5 but it doesn't seem to work.  In fact for YLim it
    % seemed to cause the tick labels on the histogram itself to go beserk.
    % So, after sacrificing a chicken and consulting my oujie bard this is
    % what I came up with.
    %  Is computer science an oxymoron or what?!
    set(colorbarh, 'YLim',YData + [0.5, -0.5]);
    set(imageh, 'YData',YData);
    set(colorbarh,'YTickMode','auto')
    set(imageh,'CData', permute(ScalingDataColorImg,[2,1,3]));
    if(0) % an image of what a colormap for this should look like.  I wish I could make a colormap out of this.
        figure; image(ScaleColorDataClim,1:size(ScalingDataColorImg,1),ScalingDataColorImg);
    end
end


function Int=SatToDecIntensity(Sat)
d=size(Sat);
Sat = Sat(:);
if(0)
    si=...
        [0,1;...
        0.125 ./ 2, 0.99999;...
        0.125, 0.9999;...
        0.25, 0.996;...
        0.5, 0.96;...
        0.75,0.92;...
        1, 0.75];

    StoImap = [si(:,1) .^ 3, si(:,1) .^ 2,si(:,1), ones(size(si,1),1)];
    StoImapT = StoImap \ si(:,2);
    Int = max(0, min(1,[Sat .^ 3, Sat .^ 2, Sat, ones(length(Sat),1)] * StoImapT));
else
    SquashPower = 0.4;
    MinInt = 0.75;
    Int = MinInt + (1 - MinInt) .* (cos(Sat .* 0.5 .* pi) .^ SquashPower);
end

Int = reshape(Int,d);

function params = mergedefaultparams(params, defaultparams)
if(isempty(params))
    params = defaultparams;
    return;
end
if(isempty(defaultparams))
    return;
end
names = fieldnames(defaultparams);
for iname=1:length(names)
    namei = names{iname};
    if(~isfield(params,namei)) % add the default 
        params=setfield(params,namei,getfield(defaultparams,namei));
    else % params has the field but if its a struct then the issue becomes recursive. 
        if(isstruct(getfield(defaultparams,namei)) & length(getfield(defaultparams,namei)) == 1 & ~isempty(getfield(params,namei))) % field name is in both so now may have to recurse.
            params=setfield(params,namei, mergedefaultparams(getfield(params,namei),getfield(defaultparams,namei)));
        end
    end
end
