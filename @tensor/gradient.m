function [grad] = gradient(tn)
%TENSOR/GRADIENT Gradient of a tensor.
%    G = GRADIENT(T) computes the gradient of the tensor field
%    object T. Note that gradient have different meanings for
%    different tensor objects, despite the operation is always the
%    same.
%
%    Example:
%
%        gradient(tensor);
%
%        a=tensor(rand([10 10 2 3 4]));
%        gradient(a);
%
%    See also TENSOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/gradient.m
%
%   ttx tensor toolbox is free software: you can redistribute it and/or
%   modify it under the terms of the GNU General Public License as
%   published by the Free Software Foundation, either version 3 of the
%   License, or any later version.
%
%   ttx tensor toolbox is distributed in the hope that it will be
%   useful, but WITHOUT ANY WARRANTY; without even the implied warranty
%   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with ttx tensor toolbox.  If not, see
%   <http://www.gnu.org/licenses/>.
%
%   Copyright (C) 2001 Eduardo Suarez-Santana
%                      http://e.suarezsantana.com/
%

fd = fielddim(tn);
fs = fieldsize(tn);
td = tensordim(tn);
ts = tensorsize(tn);

if isempty(tn.datasize)
  grad = tensor;
  return;
end

switch fd
  case 0
    switch td
      case 0
        grad = 0;
      case 1
        grad = zeros(ts,1);
      otherwise
        grad = zeros(ts);
    end

  case 1
    tn.data = reshape(tn.data,[fs prod(ts)]);
    grad        = zeros([fs prod(ts)]);
    grad(1,:)   = tn.data(2,:)-tn.data(1,:);
    grad(end,:) = tn.data(end,:)-tn.data(end-1,:);
    if fs > 2
      grad(2:end-1,:) = (tn.data(3:end,:)-tn.data(1:end-2,:))./2;
    end
    grad = reshape(grad,tn.datasize);

  otherwise
    rangef = cell(1,fd);
    [rangef{:}] = deal(':');

    switch td
      case 0
        grad = zeros([fs, fd]);

        for ii = 1:fd
          rangef0 = rangef;
          rangef1 = rangef;
          rangef2 = rangef;

          %extremal points
          rangef0{ii} = 1;
          rangef1{ii} = 2;
          grad(rangef0{:},ii) = (tn.data(rangef1{:})- ...
            tn.data(rangef0{:}));
          rangef0{ii} = fs(ii)-1;
          rangef1{ii} = fs(ii);
          grad(rangef1{:},ii) = (tn.data(rangef1{:})- ...
            tn.data(rangef0{:}));

          %interior points
          rangef0{ii} = 3:fs(ii);
          rangef1{ii} = 1:(fs(ii)-2);
          rangef2{ii} = 2:(fs(ii)-1);
          grad(rangef2{:},ii) = (tn.data(rangef0{:})- ...
            tn.data(rangef1{:}))./2;
        end

      otherwise
        ranget = cell(1,td);
        [ranget{:}] = deal(':');
        grad = zeros([fs, tensorsize(tn), fd]);

        for ii = 1:fd
          rangef0 = rangef;
          rangef1 = rangef;
          rangef2 = rangef;

          %extremal points
          rangef0{ii} = 1;
          rangef1{ii} = 2;
          grad(rangef0{:},ranget{:},ii) = ...
            (tn.data(rangef1{:},ranget{:}) - ...
            tn.data(rangef0{:},ranget{:}));
          rangef0{ii} = fs(ii)-1;
          rangef1{ii} = fs(ii);
          grad(rangef1{:},ranget{:},ii) = ...
            (tn.data(rangef1{:},ranget{:}) - ...
            tn.data(rangef0{:},ranget{:}));
          %interior points
          rangef0{ii} = 3:fs(ii);
          rangef1{ii} = 1:(fs(ii)-2);
          rangef2{ii} = 2:(fs(ii)-1);
          grad(rangef2{:},ranget{:},ii) = ...
            (tn.data(rangef0{:},ranget{:}) - ...
            tn.data(rangef1{:},ranget{:}))./2;
        end
    end
end

grad = tensor(grad,fd);

% vim: ts=2:sw=2:et
