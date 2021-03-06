function [c] = applybin(a,b,f,varargin)
%TENSOR/APPLYBIN Apply random binary function to tensors.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/applybin.m
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
%   Copyright (C) 2000 Anders Brun
%

cfsize = fieldsize(a);
cfdim  = fielddim(a);

[aM,aS,aR] = matrixop(a);
[bM,bS,bR] = matrixop(b);

% arrange each field layer as a vector
% makes it easier to reshape later
atsize = tensorsize(a);
for ii = 1:prod(atsize)
  eval([aS{ii} '=' aR{ii} '; ' aS{ii} '=' aS{ii} '(:);']);
end
btsize = tensorsize(b);
for ii = 1:prod(btsize)
  eval([bS{ii} '=' bR{ii} '; ' bS{ii} '=' bS{ii} '(:);']);
end

cM = feval(f,aM,bM,varargin{:});

eval(['c = ' strexchange(char(cM)) ';']);
c = reshape(c,[cfsize size(cM)]);
c = tensor(c,cfdim);

% vim: ts=2:sw=2:et
