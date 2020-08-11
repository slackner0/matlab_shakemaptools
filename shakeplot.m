function [ map ] = shakeplot(sm_i, outpath, varargin)

  % ------------------------------------------------------------------------
  % VARIABLE INPUTS (varargin)
  %    - 'sizeratio'
  %    - 'zoom'
  %    - 'posleg' Legend position
  %    - 'fname'
  %    - 'deltax' extra space when saving figure if colorbar is cut off
  %    - 'legendoff'
  %    - 'colorbaroff'
  %    - 'deltay'
  %    - 'fault'
  %    - 'location'
  path = '/Users/slackner/Google Drive/Research/Projects/EarthquakesSurface/Data/Built/';
  load([path 'kick_them.mat']);
  load([path 'ShakeMap_Grid_PGALand.mat']);
  load([path 'ShakeMapLand_VarShake_PGA.mat']);
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
  
  if ~isfield(param,'sizeratio')
    resize=1;
  else
    resize=param.sizeratio;
  end
  
  adjustgrid=120./res_event(sm_i);

  for j=1:length(sm_i)
    legoff=0;
    if isfield(param,'legendoff')
        if param.legendoff(j)==1
            legoff=1;
        end
    end

    locationoff=0;
    if isfield(param,'location')
        if param.location(j)==0
            locationoff=1;
        end
    end
  
    i = sm_i(j);
    figure
    map=PGALand.(['id' num2str(i)]);
    imagesc(map)
    caxis([0 maxval]);
    axis image;

    c=parula(5000);
    title([region{i} ' (' num2str(YMDHMS(i,2)) '/' num2str(YMDHMS(i,1)) ')'])
    colormap([1,1,1; c(700:end,:)])
    if locationoff==0
        hold on
        plot(SC_PGALand.col(i),SC_PGALand.row(i),'ko')
        plot(SCtroid_PGALand.col(i),SCtroid_PGALand.row(i),'kv')
        plot(EC_PGALand.col(i),EC_PGALand.row(i),'kd')
        if legoff==0
            leg = legend('Shaking Center','Shaking Centroid','Epicenter');
            %set(leg, 'location', 'southeast');
        end
    end
    if isfield(param,'colorbaroff')
        if param.colorbaroff(j)==1
        else
            c=colorbar;
            ylabel(c,'PGA in %g')
        end
    else
        c=colorbar;
        ylabel(c,'PGA in %g')
    end
    
    truesize(gcf, adjustgrid(j)*size(map)/resize)
    if isfield(param,'zoom')
      axis(param.zoom(j,:))
    end

    if isfield(param,'posleg')
      set(leg,'position',param.posleg(j,:), 'FontSize', 13)
    end
    
    %Draw Fault
    if isfield(param,'fault')
        fault=param.fault{j};
        if size(fault,1)>0 && size(fault,2)==2
            x_fault=(fault(:,2)-ulxmap(i))./xdim(i);
            y_fault=(ulymap(i)-fault(:,1))./ydim(i);
            hold on
            plot(x_fault, y_fault, 'm')
            if legoff==0
                if locationoff==0
                    legend('Shaking Center','Shaking Centroid','Epicenter', 'Fault');
                else
                    legend('Fault');
                end
            end       
        end
    end

    %Adjust axis to show coordinates
    xl = xlim*xdim(i)+ulxmap(i);
    yl = ulymap(i)-ylim*ydim(i);
    if max(xl)-min(xl)<2
        xrangemin=ceil(2*min(xl))/2;
        xrangemax=floor(2*max(xl))/2;
        xrange = [xrangemin:0.5:xrangemax];
    else
        xrangemin=ceil(min(xl));
        xrangemax=floor(max(xl));
        xrange = [xrangemin:1:xrangemax];
    end
    if max(yl)-min(yl)>=2
        yrangemin=ceil(min(yl));
        yrangemax=floor(max(yl));
        yrange = [yrangemax:-1:yrangemin];
    else
        yrangemin=ceil(2*min(yl))/2;
        yrangemax=floor(2*max(yl))/2;
        yrange = [yrangemax:-0.5:yrangemin];
    end 
    set(gca, 'xtick', (xrange-ulxmap(i))/xdim(i));
    set(gca,'xticklabel',xrange);
    set(gca, 'ytick', (-yrange+ulymap(i))/ydim(i));
    set(gca,'yticklabel',yrange);

    %% Saving
    if isfield(param,'deltax')
        deltax=param.deltax(j);
    else
        deltax=0;
    end
    if isfield(param,'deltay')
        deltay=param.deltay(j);
    else
        deltay=0;
    end
    set(gcf,'paperunits','points');
    temp=get(gcf,'position');
    temp(3)=temp(3)+deltax;
    set(gcf, 'position', temp);
    sizeim=get(gcf,'paperposition');
    sizeim=sizeim(3:4);
    
    set(gcf, 'PaperSize', [sizeim(1)-deltax/4 , sizeim(2)+deltay], 'paperposition', [0 0 sizeim(1)-deltax/4 , sizeim(2)+deltay]);

    if isfield(param,'fname')
      name=param.fname{j};
    else
      name=[region{i} num2str(YMDHMS(i,2)) num2str(YMDHMS(i,1)) '_' num2str(i)];
    end

    print(gcf,[outpath name], '-dpdf')
  end

end
