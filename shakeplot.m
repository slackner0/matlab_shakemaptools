function [ map ] = shakeplot(sm_i, outpath, varargin)

  % ------------------------------------------------------------------------
  % VARIABLE INPUTS (varargin)
  %    - 'fwidth'
  %    - 'fheight'
  %    - 'zoom'
  %    - 'posleg'
  %    - 'fname'
  path = '/Users/slackner/Google Drive/Research/Projects/EarthquakesSurface/Data/Built/';
  load([path 'kick_them.mat']);
  load([path 'ShakeMap_Grid_PGALand.mat']);
  load([path 'ShakeMapLand_Var_PGA.mat']);
  load([path 'ShakeMap_Info.mat']);

  if mod(nargin,2)
      error('Every input parameter must have a value! \n');
  end

  param=struct();
  for i=1:((nargin-2)/2)
      name=varargin{2*i-1};
      value=varargin{2*i};
      param=setfield(param,name,value);
  end

  maxval=0;
  for j=1:length(sm_i)
    maxval=max([maxval, max(max(PGALand.(['id' num2str(sm_i(j))])))]);
  end

  for j=1:length(sm_i)
    i = sm_i(j);
    if ~isfield(param,'fwidth')
      filewidth=460;
    else
      filewidth=param.fw(i);
    end

    if ~isfield(param,'fheight')
      fileheight=350;
    else
      fileheight=param.fh(i);
    end

    figure('position', [200, 200, filewidth, fileheight])

    map=PGALand.(['id' num2str(i)]);
    imagesc(map)
    caxis([0 maxval]);
    axis image;

    c=parula(500);
    title([region{i} ' (' num2str(YMDHMS(i,2)) '/' num2str(YMDHMS(i,1)) ')'])
    colormap([1,1,1; c(70:end,:)])
    hold on
    plot(SC_PGALand.col(i),SC_PGALand.row(i),'ko')
    plot(SCtroid_PGALand.col(i),SCtroid_PGALand.row(i),'kv')
    plot(EC_PGALand.col(i),EC_PGALand.row(i),'kd')
    c=colorbar;
    ylabel(c,'PGA in %g')
    leg = legend('Shaking Center','Shaking Centroid','Epicenter');

    if isfield(param,'zoom')
      axis(param.zoom(j,:))
    end

    if isfield(param,'posleg')
      set(leg,'position',param.posleg(j,:), 'FontSize', 13)
    end

    %Adjust axis to show coordinates
    xl = xlim*xdim(i)+ulxmap(i);
    yl = ulymap(i)-ylim*ydim(i);
    xrangemin=(ceil(2*min(xl))/2);
    xrangemax=(floor(2*max(xl))/2);
    yrangemin=(ceil(2*min(yl))/2);
    yrangemax=(floor(2*max(yl))/2);
    xrange = [xrangemin:0.5:xrangemax];
    set(gca, 'xtick', (xrange-ulxmap(i))/xdim(i));
    set(gca,'xticklabel',xrange);
    yrange = [yrangemax:-0.5:yrangemin];
    set(gca, 'ytick', (-yrange+ulymap(i))/ydim(i));
    set(gca,'yticklabel',yrange);

    %% Saving
    size=[filewidth fileheight];
    set(gcf,'paperunits','points','paperposition',[0 0 size]);
    set(gcf, 'PaperSize', size);

    if isfield(param,'fname')
      name=param.fname;
    else
      name=[region{i} num2str(YMDHMS(i,2)) num2str(YMDHMS(i,1)) '_' num2str(i)];
    end

    print(gcf,[outpath name], '-dpdf')
  end

end
