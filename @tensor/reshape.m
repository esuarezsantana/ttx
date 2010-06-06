function [t] = reshape(t,f_shape,varargin)
%TENSOR/RESHAPE Reshape dimensions of a tensor object.
%
% the following syntax is used:
%    out = reshape(tnsr,field_shape,tensor_shape)
%
% if you do not want to change either the field or tensor
% dimensions, simply input an empty vector in the appropriate
% place. Also, if you only input one reshape vector, the default is
% to reshape only the field dimensions
%
%    out = reshape(tnsr,field_shape,[])   %only changes the field
%                                          dimensions of TNSR
% NOTE: can also be done by:
%    out = reshape(tnsr,field_shape)
%
%    out = reshape(tnsr,[],tensor_shape)  %only changes the tensor
%                                          dimensions of TNSR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/reshape.m
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
%   Copyright (C) 2001 Dan Fox, C.-F. Westin
%

% check number of inputs
if ((nargin<2) | (nargin>3))
  error('Must have either 2 or 3 arguments');
  return;
end

if nargin == 3;
  t_shape = varargin{1};
end

% get info on tensor input
f_dim   = fielddim(t);
t_dim   = tensordim(t);
f_sz    = fieldsize(t);
t_sz    = tensorsize(t);
f_lmnts = prod(f_sz);
t_lmnts = prod(t_sz);

% check for empty inputs
if isempty(f_shape)
  f_shape = f_sz
end
if (nargin == 2 | isempty(t_shape))
  t_shape = t_sz
end

% check for appropriate values within each shape vector
if (prod(f_shape) ~= f_lmnts | prod(t_shape) ~= t_lmnts)
  error('number of elements must not change');
  return;
end

% make full_shape
full_shape = [f_shape t_shape];

% reshape
t.data = reshape(t.data,full_shape);

% update
t.dimension = [length(f_shape) length(t_shape)];
t.datasize = size(t.data);

% vim: ts=2:sw=2:et
