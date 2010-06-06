function [b] = resample(a,newsize,tensortype)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the tensor toolbox
%
%   Module: @tensor/resample.m
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
%   Copyright (C) 2000 Eduardo Suarez-Santana
%                      http://e.suarezsantana.com/
%

fd = fielddim(a);
td = tensordim(a);
fsize = fieldsize(a);
tsize = tensorsize(a);
resamp = makeresampler('cubic','symmetric');
T = maketform('box',fsize,ones(1,fd),newsize);

range = cell(1,fd+1);
[range{:}] = deal(':');
b = zeros([newsize tsize]);

%filtering
factor = newsize./fsize;
%separable filtering
halfkernel = cell(1,fd);
f = 0:.025:1;
hsize = 2;
for kk = 1:fd
  if factor(kk)<1
    %contravariant and covariant must be designed in the kernel
    kernel = fir2(2.*hsize,f,f<factor(kk));
    halfkernel{kk} = {hsize,kernel(hsize+1:end)};
  else
    halfkernel{kk} = 'cubic';
  end
end
resamp = makeresampler(halfkernel,'symmetric');

%downsampling
for kk = 1:prod(tsize)
  range{fd+1} = kk;
  b(range{:}) = tformarray(a.data(range{:}),T,resamp, ...
    [1:fd],[1:fd],newsize,[],[]);
end

%make contravariant
if (nargin>2)
  if (isequal(tensortype,'ct') & td==1)
    for ii = 1:tsize
      range{fd+1} = ii;
      b(range{:}) = b(range{:}).*(newsize(ii)./fsize(ii));
    end
  end
end

b = tensor(b,fd);

% vim: ts=2:sw=2:et
