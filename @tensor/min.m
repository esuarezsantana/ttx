function [c] = min (varargin)
%TENSOR/MIN Implement min for tensor objects.
% 1 arg -> operates on tensor
% 2 arg -> operates on field

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/min.m
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
%   Copyright (C) 2000 Eduardo Suarez-Santana
%                      http://e.suarezsantana.com/
%

switch nargin
 case 0
  error('Not enough input arguments.');
 case 1
  if (isempty(varargin{1}.datasize))
    c = tensor;
    return;
  end

  varargin{1}.data = reshape(varargin{1}.data, ...
    [prod(rawfieldsize(varargin{1})) prod(tensorsize(varargin{1}))]);
  c = min(varargin{1}.data,[],2);
  if (rawfielddim(varargin{1})<1)
    c = reshape(c,rawfieldsize(varargin{1}));
  end
  c = tensor(c,rawfielddim(varargin{1}));

 case 2
  [varargin{1},varargin{2},wscalar,empty] = ...
      binaryop(varargin{1},varargin{2});
  if (empty==1);
    c = tensor;
    return;
  end

  switch wscalar
   case 0
    c = min(varargin{1}.data,varargin{2}.data);
    %a.dimension(1),b.dimension(2) are equal or one of them is zero.
    c = tensor(c, ...
      max(rawfielddim(varargin{1}),rawfielddim(varargin{2})));
   case 1
    c = min(varargin{1},varargin{2}.data);
    c = tensor(c, rawfielddim(varargin{2}));
   case 2
    c = min(varargin{1}.data,varargin{2});
    c = tensor(c,rawfielddim(varargin{1}));
   otherwise
    error('Internal error!! Check source.');
  end
 otherwise
  error('Too few input arguments.');
end

% vim: ts=2:sw=2:et
