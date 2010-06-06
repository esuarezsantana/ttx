function show(tn,varargin)
%TENSOR/SHOW Show a tensor content.
%
%    Warning!!: the horizontal axis is taken for the first
%    component (x,i) and the vertical axis is taken for the second
%    (y,j). Origin is set to left bottom corner.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the tensor toolbox
%
%   Module: @tensor/show.m
%
%   tensor toolbox is free software: you can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation, either version 3 of the
%   License, or any later version.
%
%   tensor toolbox is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with tensor toolbox.  If not, see
%   <http://www.gnu.org/licenses/>.
%
%   Copyright (C) 2000 C.-F. Westin
%
%   Copyright (C) 2001 Eduardo Suarez-Santana
%
%   Copyright (C) 2010 Eduardo Suarez-Santana
%                      http://e.suarezsantana.com/
%

tdim = tensordim(tn);
tsiz = tensorsize(tn);
fdim = fielddim(tn);
fsiz = fieldsize(tn);

if (tdim>2)
  error('Only available for vector-scalar tensors');
end

switch fdim

  case 1 % 1-d field
    switch tdim

      case 0
        if isreal(tn.data)
          plot_1_1(tn);
        else
          plot_1_1c(tn,varargin{:});
        end

      case 1
        switch tsiz(1)
          case 2
            plot_1_2(tn);
          case 3
            plot_1_3(tn);
          otherwise
            error('Only scalar or vector 1-D available');
        end

    end

  case 2 % 2-d field
    switch tdim

      case 0
        if isreal(tn.data)
          plot_2_1(tn,varargin{:});
        else
          plot_2_1c(tn,varargin{:})
        end

      case 1
        if (tsiz~=2)
          error('Only available for displacement fields');
        end
        if isempty(varargin)
          plot_2_2(tn);
        elseif isequal(varargin{1},'mesh')
          plot_2_2m(tn);
        elseif isequal(varargin{1},'mesh+')
          tn = tn+position(tn);
          plot_2_2m(tn);
        elseif isequal(varargin{1},'meshsp')
          plot_2_2ms(tn,varargin{2:end});
        else
          error('Invalid argument');
        end

      case 2
        if isequal(tsiz,[2 2])
          plot_2_2x2(tn);
        elseif isequal(tsiz,[3 3])
          plot_2_3x3(tn,varargin{:});
        else
          error('Only available for 2x2 and 3x3 tensors');
        end

      otherwise
        error('Only available for vector-scalar tensors');
    end

  case 3
    % 3-d field
    switch tdim

      case 0 % only available as medical data
        plot_3_1(tn,varargin{:});

      case 1 % assume tensorsize=[3]

        [smode,direction,slices,delta] = parse_3_3(fsiz,varargin{:});
        switch smode % show mode
          case 'quiver'
            plot_3_3(tn,direction,slices,delta);
          case {'mesh2','mesh2+'}
            if isequal(smode,'mesh2+')
              tn = tn+position(tn);
            end
            plot_3_3m(tn,direction,slices,delta);
        end

      case 2
        plot_3_3x3(tn,varargin{:});

      otherwise
        error('Only available for scalar and vector data');
    end

  otherwise
    error('Only available for 1,2 and 3 dimension fields');
end


%-----------------------------------------------------------------------
% Subfunction plot_1_1
%-----------------------------------------------------------------------
function plot_1_1(tn)

plot(tn.data);
view(2);
zoom on;


%-----------------------------------------------------------------------
% Subfunction plot_1_1c
%-----------------------------------------------------------------------
function plot_1_1c(tn,varargin);

fsize = fieldsize(tn);
if isempty(varargin)
  aux = tn.data;
  plot3(1:fsize(1),real(aux),imag(aux));
elseif isequal(varargin{1},'shift')
  aux = fftshift(tn.data);
  plot3(1:fsize(1),real(aux),imag(aux));
  title('Complex shifted');
else
  error('No such mode');
end
cameratoolbar('setmode','orbit');
cameratoolbar('SetCoordSys' ,'z')
view(3); axis vis3d
box;


%-----------------------------------------------------------------------
% Subfunction plot_1_2
%-----------------------------------------------------------------------
function plot_1_2(tn)

fsize = fieldsize(tn);
quiver3(1:fsize(1), zeros(1,fsize), zeros(1,fsize), ...
  zeros(1,fsize), tn.data(:,1).', tn.data(:,2).');
hold on;
plot3([0 fsize(1)+1],[0 0],[0 0],'k');
hold off;
cameratoolbar('setmode','orbit');
cameratoolbar('SetCoordSys' ,'z')
view(3); axis vis3d
box;


%-----------------------------------------------------------------------
% Subfunction plot_1_3
%-----------------------------------------------------------------------
function plot_1_3(tn)

fsize = fieldsize(tn);
quiver3(1:fsize(1), zeros(1,fsize), zeros(1,fsize), ...
  tn.data(:,1).', tn.data(:,2).', tn.data(:,3).');
hold on;
plot3([0 fsize(1)+1],[0 0],[0 0],'k');
hold off;
cameratoolbar('setmode','orbit');
cameratoolbar('SetCoordSys' ,'z')
view(3); axis vis3d
box;


%-----------------------------------------------------------------------
% Subfunction plot_2_1
%-----------------------------------------------------------------------
function plot_2_1(tn,varargin)

if isempty(varargin)
  smode = 'n';
else
  smode = varargin{1};
end

if isequal(smode,'mesh')
  colormap('jet');
  mesh(tn.data.');
  axis tight; box;
  cameratoolbar('setmode','orbit');
  cameratoolbar('SetCoordSys' ,'z')
  view(3); axis vis3d
  return;
end

colormap('gray');
switch smode
  case 'n'
    imagesc(tn.data.');
  case 'a','s','c'
    imagesc(flipdim(tn.data.',2));
  otherwise
    error('Invalid graphics mode');
end
axis xy; axis image; box;
cameratoolbar('setmode','nomode');
view(2);
zoom on;


%-----------------------------------------------------------------------
% Subfunction plot_2_1c
%-----------------------------------------------------------------------
function plot_2_1c(tn,varargin)

if isempty(varargin)
  aux = tn.data.';
elseif isequal(varargin{1},'shift')
  aux = fftshift(tn.data.');
end

iA = floor((angle(aux)+pi).*128./pi);
vA = abs(aux);
fA = ind2rgb(iA,hsv(256)).*repmat(vA./max(vA(:)),[1 1 3]);
imagesc(fA);

if (~isempty(varargin) & isequal(varargin{1},'shift'))
  title('Complex shifted');
end

colormap('gray');
axis xy; axis image; box;
cameratoolbar('setmode','nomode');
view(2);
zoom on;


%-----------------------------------------------------------------------
% Subfunction plot_2_2
%-----------------------------------------------------------------------
function plot_2_2(tn)

fsize = fieldsize(tn);
% size of arrow head relative to the length of the vector
alpha = 0.33;
% width of the base of the arrow head relative to the length
beta  = 0.33;
[x,y] = ndgrid(1:fsize(1),1:fsize(2));
x = x(:).';
y = y(:).';
u = reshape(tn.data(:,:,1),[1 prod(fsize)]);
v = reshape(tn.data(:,:,2),[1 prod(fsize)]);
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];
plot(uu(:),vv(:));
hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
  x+u-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
  y+v-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
hold on;
plot(hu(:),hv(:));
hold off;
axis xy; axis equal;
axis([0 fsize(1)+1 0 fsize(2)+1]);
box;


%-----------------------------------------------------------------------
% Subfunction plot_2_2m
%-----------------------------------------------------------------------
function plot_2_2m(tn)

fsize = fieldsize(tn);
X = double(tn.data(:,:,1));
Y = double(tn.data(:,:,2));
Z = zeros(size(X));
newplot;
surface(X,Y,Z,'FaceColor','none','EdgeColor',[0 0 0]);
axis xy; axis equal;
axis([0 fsize(1)+1 0 fsize(2)+1]);


%-----------------------------------------------------------------------
% Subfunction plot_2_2ms
%-----------------------------------------------------------------------
function plot_2_2ms(tn,varargin)

fsize = fieldsize(tn);
tn = double(tn);
if isempty(varargin)
  sp = 1;
else
  sp = varargin{1};
end
newplot;
ih = ishold();
for ii=1:sp:fsize(1);
  lx = tn(ii,:,1);
  ly = tn(ii,:,2);
  h  = line(lx(:),ly(:),zeros(fsize(2),1));
  set(h,'color',[0 0 0]);
end
if ~(mod(fsize(1),sp))
  lx = tn(fsize(1),:,1);
  ly = tn(fsize(1),:,2);
  h  = line(lx(:),ly(:),zeros(fsize(2),1));
  set(h,'color',[0 0 0]);
end
for ii = 1:sp:fsize(2);
  lx = tn(:,ii,1);
  ly = tn(:,ii,2);
  h  = line(lx(:),ly(:),zeros(fsize(1),1));
  set(h,'color',[0 0 0]);
end
if ~(mod(fsize(2),sp))
  lx = tn(:,fsize(2),1);
  ly = tn(:,fsize(2),2);
  h  = line(lx(:),ly(:),zeros(fsize(1),1));
  set(h,'color',[0 0 0]);
end
if ~ih
  hold off
end
axis xy; axis equal;
axis([0 fsize(1)+1 0 fsize(2)+1]);


%-----------------------------------------------------------------------
% Subfunction plot_2_2x2
%-----------------------------------------------------------------------
function plot_2_2x2(tn)

fsize = fieldsize(tn);
tsize = tensorsize(tn);
T = reshape(tn.data,prod(fsize),prod(tsize));
[X,Y] = ndgrid(1:fsize(1),1:fsize(2));
newplot;
ih = ishold();
hold on;
for kk=1:length(X(:))
  if ~isequal(T(kk,:),[0 0 0 0])
    drawEllipse([X(kk) Y(kk)],T(kk,:),1);
  end
end
if ~ih
  hold off
end


%-----------------------------------------------------------------------
% Subfunction plot_2_3x3
%-----------------------------------------------------------------------
function plot_2_3x3(tn,varargin)

fsize=fieldsize(tn);
if isempty(varargin)
  hax = newplot;
  for ii = 1:fsize(1)
    for jj = 1:fsize(2)
      [V,D] = eig(squeeze(tn.data(ii,jj,:,:)));
      d = diag(D);
      N = 20;
      [x,y,z] = sphere(N);
      x = x.*d(1);
      y = y.*d(2);
      z = z.*d(3);
      [dd,maxi] = max(d);
      xyz = cat(3,x,y,z);
      xyz = reshape(xyz,(N+1).*(N+1),3);
      xyzp = xyz*(V.');
      xyzp = xyzp+repmat([ii jj 0],[(N+1).^2 1]);
      xyzp = reshape(xyzp,N+1,N+1,3);
      h = surface(xyzp(:,:,1),xyzp(:,:,2),xyzp(:,:,3), ...
        reshape(xyz(:,maxi),[N+1 N+1]),'Parent',hax);
      set(h,'EdgeColor','none');
      set(h,'FaceColor',[0 0 1]);
      set(h,'backfacelighting','lit');
      material metal
    end
  end
elseif isequal(varargin{1},'wheel')
  for ii = 1:fsize(1)
    for jj = 1:fsize(2)
      [V,D] = eig(squeeze(tn.data(ii,jj,:,:)));
      d = diag(D);
      [dd,maxi] = max(d);
      dcircle = d;
      dcircle(maxi) = [];
      Vcircle = V;
      Vcircle(:,maxi) = [];
      N = 12;
      theta = ((0:N-1)/N*2*pi).';
      x = dcircle(1).*cos(theta);
      y = dcircle(2).*sin(theta);
      xyzp = [x y]*(Vcircle.')+repmat([ii jj 0],[N 1]);
      h = patch(xyzp(:,1),xyzp(:,2),xyzp(:,3),'b');
      set(h,'EdgeColor','none','FaceColor','blue');
      material shiny
      linexyz = [-d(maxi).*V(:,maxi) d(maxi).*V(:,maxi)].' + ...
        [ii jj 0; ii jj 0];
      h = line(linexyz(:,1),linexyz(:,2),linexyz(:,3));
      set(h,'Color','red');
    end
  end
end
axis vis3d;
daspect([1 1 1]);
box;
light
lighting gouraud;


%-----------------------------------------------------------------------
% Subfunction plot_3_1
%-----------------------------------------------------------------------
function plot_3_1(tn,varargin)

fsize = fieldsize(tn);
narg  = nargin;
if isempty(varargin)
  narg=narg+1;
  varargin{1}='n';
elseif ~isstr(varargin{1})
  varargin={'n',varargin{1:end}};
  narg=narg+1;
end

switch narg
  case 2
    slice = [];
    grayrange = [fmin(tn) fmax(tn)];
  case 3
    slice = varargin{2};
    grayrange = [0 256];
  case 4
    slice = varargin{2};
    grayrange = varargin{3};
  otherwise
    error('Too many input arguments');
end

if isequal(varargin{1},'n') % n for normal
  if isempty(slice)
    slice = 1:fsize(3);
  end
  colormap('gray');
  h = imagesc(tn.data(:,:,slice(1)).',grayrange);
  set(gcf,'DoubleBuffer','on');
  axis xy; axis image; box;
  cameratoolbar('setmode','nomode');
  view(2);
  lensl = length(slice);
  if lensl>1
    for ii = 1:lensl
      drawnow;
      set(h,'cdata',squeeze(tn.data(:,:,slice(ii))).');
    end
  end
elseif isequal(varargin{1},'a') % a for axial
  if isempty(slice)
    slice = 1:fsize(3);
  end
  colormap('gray');
  h = imagesc(flipdim(squeeze(tn.data(:,:,slice(1))).',2),grayrange);
  set(gcf,'DoubleBuffer','on');
  axis xy; axis image; box;
  cameratoolbar('setmode','nomode');
  view(2);
  lensl = length(slice);
  if lensl>1
    for ii = 1:lensl
      drawnow;
      set(h,'cdata',flipdim(squeeze(tn.data(:,:,slice(ii))).',2))
    end
  end
elseif isequal(varargin{1},'s') % s for saggital
  if isempty(slice)
    slice = 1:fsize(1);
  end
  colormap('gray');
  h = imagesc(flipdim(squeeze(tn.data(slice(1),:,:)).',2),grayrange);
  set(gcf,'DoubleBuffer','on');
  axis xy; axis image; box;
  cameratoolbar('setmode','nomode');
  view(2);
  %zoom on;
  lensl = length(slice);
  if lensl>1
    for ii = 1:lensl
      drawnow;
      set(h,'cdata',flipdim(squeeze(tn.data(slice(ii),:,:)).',2))
    end
  end
elseif isequal(varargin{1},'c') % c for coronal
  if isempty(slice)
    slice = 1:fsize(2);
  end
  colormap('gray');
  h = imagesc(flipdim(squeeze(tn.data(:,slice(1),:)).',2),grayrange);
  set(gcf,'DoubleBuffer','on');
  axis xy; axis image; box;
  cameratoolbar('setmode','nomode');
  view(2);
  lensl = length(slice);
  if lensl>1
    for ii=1:lensl
      drawnow;
      set(h,'cdata',flipdim(squeeze(tn.data(:,slice(ii),:)).',2))
    end
  end
else
  error('Invalid graphics mode');
end
title(['slice: ' num2str(slice(end))]);


%-----------------------------------------------------------------------
% Subfunction plot_3_3
%-----------------------------------------------------------------------
function plot_3_3(tn,direction,slices,delta)

fsize = fieldsize(tn);
switch direction
  case {'n','a'}
    % size of arrow head relative to the length of the vector
    alpha = 0.33;
    % width of the base of the arrow head relative to the length
    beta  = 0.33;
    v1 = 1:delta:fsize(1);
    v2 = 1:delta:fsize(2);
    [x,y] = ndgrid(v1,v2);
    slicesize = size(x);
    z = repmat(slices(1), slicesize);
    cla;
    surface(x,y,z,'FaceColor','none','EdgeColor',[0 0 0]);
    u = reshape(tn.data(v1,v2,slices(1),1),[prod(slicesize) 1]);
    v = reshape(tn.data(v1,v2,slices(1),2),[prod(slicesize) 1]);
    w = reshape(tn.data(v1,v2,slices(1),3),[prod(slicesize) 1]);
    hold on
    quiver3(x(:),y(:),z(:),u,v,w,0);
    hold off
    cameratoolbar('setmode','orbit');
    cameratoolbar('SetCoordSys' ,'z')
    view(3); axis vis3d
    axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
    daspect([1 1 1]);
    box on;
    lensl = length(slices);
    if lensl>1
      for ii = 1:delta:lensl
        drawnow;
        z = repmat(slices(ii), slicesize);
        cla;
        surface(x,y,z,'FaceColor','none','EdgeColor',[0 0 0]);
        u = reshape(tn.data(v1,v2,slices(ii),1),[prod(slicesize) 1]);
        v = reshape(tn.data(v1,v2,slices(ii),2),[prod(slicesize) 1]);
        w = reshape(tn.data(v1,v2,slices(ii),3),[prod(slicesize) 1]);
        hold on
        quiver3(x(:),y(:),z(:),u,v,w,0);
        hold off
        axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
      end
    end

  case 'c'
    % size of arrow head relative to the length of the vector
    alpha = 0.33;
    % width of the base of the arrow head relative to the length
    beta  = 0.33;
    v1=1:delta:fsize(1);
    v3=1:delta:fsize(3);
    [x,z]=ndgrid(v1,v3);
    slicesize=size(x);
    y=repmat(slices(1), slicesize);
    cla;
    surface(x,y,z,'FaceColor','none','EdgeColor',[0 0 0]);
    u=reshape(tn.data(v1,slices(1),v3,1),[prod(slicesize) 1]);
    v=reshape(tn.data(v1,slices(1),v3,2),[prod(slicesize) 1]);
    w=reshape(tn.data(v1,slices(1),v3,3),[prod(slicesize) 1]);
    hold on
    quiver3(x(:),y(:),z(:),u,v,w,0);
    hold off
    cameratoolbar('setmode','orbit');
    cameratoolbar('SetCoordSys' ,'z')
    view(3); axis vis3d
    axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
    daspect([1 1 1]);
    box on;
    lensl=length(slices);
    if lensl>1
      for ii=1:delta:lensl
        drawnow;
        y=repmat(slices(ii), slicesize);
        cla;
        surface(x,y,z,'FaceColor','none','EdgeColor',[0 0 0]);
        u=reshape(tn.data(v1,slices(ii),v3,1),[prod(slicesize) 1]);
        v=reshape(tn.data(v1,slices(ii),v3,2),[prod(slicesize) 1]);
        w=reshape(tn.data(v1,slices(ii),v3,3),[prod(slicesize) 1]);
        hold on
        quiver3(x(:),y(:),z(:),u,v,w,0);
        hold off
        axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
      end
    end
  case 's'
    % size of arrow head relative to the length of the vector
    alpha = 0.33;
    % width of the base of the arrow head relative to the length
    beta  = 0.33;
    v2=1:delta:fsize(2);
    v3=1:delta:fsize(3);
    [y z]=ndgrid(v2,v3);
    slicesize=size(y);
    x=repmat(slices(1), slicesize);
    cla;
    surface(x,y,z,'FaceColor','none','EdgeColor',[0 0 0]);
    u=reshape(tn.data(slices(1),v2,v3,1),[prod(slicesize) 1]);
    v=reshape(tn.data(slices(1),v2,v3,2),[prod(slicesize) 1]);
    w=reshape(tn.data(slices(1),v2,v3,3),[prod(slicesize) 1]);
    hold on
    quiver3(x(:),y(:),z(:),u,v,w,0);
    hold off
    cameratoolbar('setmode','orbit');
    cameratoolbar('SetCoordSys' ,'z')
    view(3); axis vis3d
    axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
    daspect([1 1 1]);
    box on;
    lensl=length(slices);
    if lensl>1
      for ii=1:delta:lensl
        drawnow;
        x=repmat(slices(ii), slicesize);
        cla;
        surface(x,y,z,'FaceColor','none','EdgeColor',[0 0 0]);
        u=reshape(tn.data(slices(ii),v2,v3,1),[prod(slicesize) 1]);
        v=reshape(tn.data(slices(ii),v2,v3,2),[prod(slicesize) 1]);
        w=reshape(tn.data(slices(ii),v2,v3,3),[prod(slicesize) 1]);
        hold on
        quiver3(x(:),y(:),z(:),u,v,w,0);
        hold off
        axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
      end
    end
end


%-----------------------------------------------------------------------
% Subfunction plot_3_3m
%-----------------------------------------------------------------------
function plot_3_3m(tn,direction,slices,delta)

fsize=fieldsize(tn);
switch direction
  case {'n','a'}
    X = double(tn.data(:,:,slices(1),1));
    Y = double(tn.data(:,:,slices(1),2));
    Z = double(tn.data(:,:,slices(1),3));
    newplot;
    surface(X,Y,Z,'FaceColor','none','EdgeColor',[0 0 0]);
    cameratoolbar('setmode','orbit');
    cameratoolbar('SetCoordSys' ,'z')
    axis vis3d
    axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
    daspect([1 1 1]);
    box on;
    lensl = length(slices);
    if (lensl>1)
      for ii = 1:delta:lensl
        drawnow;
        X = double(tn.data(:,:,slices(ii),1));
        Y = double(tn.data(:,:,slices(ii),2));
        Z = double(tn.data(:,:,slices(ii),3));
        cla;
        surface(X,Y,Z,'FaceColor','none','EdgeColor',[0 0 0]);
        axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
      end
    end
  case 'c'
    X = squeeze(double(tn.data(:,slices(1),:,1)));
    Y = squeeze(double(tn.data(:,slices(1),:,2)));
    Z = squeeze(double(tn.data(:,slices(1),:,3)));
    newplot;
    surface(X,Y,Z,'FaceColor','none','EdgeColor',[0 0 0]);
    cameratoolbar('setmode','orbit');
    cameratoolbar('SetCoordSys' ,'z')
    view(3); axis vis3d
    axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
    daspect([1 1 1]);
    box on;
    lensl = length(slices);
    if (lensl>1)
      for ii = 1:delta:lensl
        drawnow;
        X = squeeze(double(tn.data(:,slices(ii),:,1)));
        Y = squeeze(double(tn.data(:,slices(ii),:,2)));
        Z = squeeze(double(tn.data(:,slices(ii),:,3)));
        cla;
        surface(X,Y,Z,'FaceColor','none','EdgeColor',[0 0 0]);
        axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
      end
    end
  case 's'
    X = squeeze(double(tn.data(slices(1),:,:,1)));
    Y = squeeze(double(tn.data(slices(1),:,:,2)));
    Z = squeeze(double(tn.data(slices(1),:,:,3)));
    newplot;
    surface(X,Y,Z,'FaceColor','none','EdgeColor',[0 0 0]);
    cameratoolbar('setmode','orbit');
    cameratoolbar('SetCoordSys' ,'z')
    view(3); axis vis3d
    axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
    daspect([1 1 1]);
    box on;
    lensl = length(slices);
    if (lensl>1)
      for ii = 1:delta:lensl
        drawnow;
        X = squeeze(double(tn.data(slices(ii),:,:,1)));
        Y = squeeze(double(tn.data(slices(ii),:,:,2)));
        Z = squeeze(double(tn.data(slices(ii),:,:,3)));
        cla;
        surface(X,Y,Z,'FaceColor','none','EdgeColor',[0 0 0]);
        axis([0 fsize(1)+1 0 fsize(2)+1 0 fsize(3)+1]);
      end
    end
end


%-----------------------------------------------------------------------
% Subfunction plot_3_3x3
%-----------------------------------------------------------------------
function plot_3_3x3(tn,varargin)

fsize = fieldsize(tn);
if isempty(varargin)
  hax = newplot;
  for ii = 1:fsize(1)
    for jj = 1:fsize(2)
      for kk = 1:fsize(3)
        [V,D] = eig(squeeze(tn.data(ii,jj,kk,:,:)));
        d = diag(D);
        N = 20;
        [x,y,z] = sphere(N);
        x = x.*d(1);
        y = y.*d(2);
        z = z.*d(3);
        [dd,maxi] = max(d);
        xyz = cat(3,x,y,z);
        xyz = reshape(xyz,(N+1).*(N+1),3);
        xyzp = xyz*(V.');
        xyzp = xyzp+repmat([ii jj kk],[(N+1).^2 1]);
        xyzp = reshape(xyzp,N+1,N+1,3);
        h=surface(xyzp(:,:,1),xyzp(:,:,2),xyzp(:,:,3), ...
          reshape(xyz(:,maxi),[N+1 N+1]),'Parent',hax);
        set(h,'EdgeColor','none');
        set(h,'FaceColor',[0 0 1]);
        set(h,'backfacelighting','lit');
        material metal
      end
    end
  end
end
axis vis3d;
daspect([1 1 1]);
box;
light
lighting gouraud;


%-----------------------------------------------------------------------
% Subfunction parse_3_3
%-----------------------------------------------------------------------
function [smode,direction,slices,delta] = parse_3_3(fsiz,varargin)

if isempty(varargin)
  direction = 'n';
  smode     = 'quiver';
  slices    = 1:fsiz(3);
  delta     = 1;
else
  % string parsing
  lenvar = length(varargin);
  ii = 1;
  while (ii<=lenvar & ~isstr(varargin{ii}))
    ii = ii+1;
  end
  if (ii>lenvar)
    direction = 'n';
    smode     = 'quiver';
  else
    switch varargin{ii}
      case {'n','a','c','s'}
        direction = varargin{ii};
        ii = ii+1;
        while (ii<=lenvar & ~isstr(varargin{ii}))
          ii = ii+1;
        end
        if ii>lenvar
          smode = 'quiver';
        else
          smode = varargin{ii};
        end
      case {'mesh3','mesh3+','quiver3'}
        smode = varargin{ii};
        % not implemented
      case {'quiver','mesh2','mesh2+'}
        direction = 'n';
        smode = varargin{ii};
      otherwise
        error('Invalid string argument');
    end
  end
  % numeric parsing
  ii = 1;
  while (ii<=lenvar & isstr(varargin{ii}))
    ii = ii+1;
  end
  if (ii>lenvar)
    switch direction
      case {'n','s'}
        slices = 1:fsiz(3);
      case 'a'
        slices = 1:fsiz(2);
      case 'c'
        slices = 1:fsiz(1);
      otherwise
        error('Internal error');
    end
    delta = 1;
  else
    slices = varargin{ii};
    ii = ii+1;
    while (ii<=lenvar & isstr(varargin{ii}))
      ii = ii+1;
    end
    if (ii>lenvar)
      delta = 1;
    else
      delta = varargin{ii};
    end
  end
end


%-----------------------------------------------------------------------
% Subfunction drawEllipse
%-----------------------------------------------------------------------
function [h] = drawEllipse(x,D,s,n)

% resolution is given by n,
n = 20;

D = reshape(D,[2 2]);

% get eigen system
[U S V]=svd(D);
lam1 = S(1,1);
lam2 = S(2,2);
e1 = s*U(:,1)*lam1;
e2 = s*U(:,2)*lam2;

% construct ellipsoide
[X,Y] = ellipse(lam1,lam2,n);

% rotate ellipsoide
R = [e1';e2'];
XX= [X(:) Y(:)]*R;
XSize = size(X);
X = reshape(XX(:,1), XSize);
Y = reshape(XX(:,2), XSize);

h = plot(X+x(1),Y+x(2));

if 0
  % color stuff, doesn't work yet
  C=ones([XSize(1) XSize(2) 3]);
  C(:,:,1)=c(1);
  C(:,:,2)=c(2);
  C(:,:,3)=c(3);
  h = plot(X,Y,C);
end


%-----------------------------------------------------------------------
% Subfunction ellipse
%-----------------------------------------------------------------------
function [X,Y] = ellipse(a,b,n)

phi = linspace(-pi,pi,n);
X = sqrt(a)*cos(phi);
Y = sqrt(b)*sin(phi);

[alpha,r] = cart2pol(X,Y);
[X,Y] = pol2cart(alpha,(r));

% vim: ts=2:sw=2:et
