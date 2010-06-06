function [out] = end(t,ind,N)
%TENSOR/END 'end' indexing for tensor objects.
%    When indexing field dimensions of tensor objects, the particle
%    end refers to the last element in such dimension.
%
%    Examples:
%
%        a=tensor(rand(20),2);
%        b=a(1:2:end,1:2:end); %subsampling
%
%    See also TENSOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/end.m
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

if (N==1)
  out = prod(fieldsize(t));
elseif (N==fielddim(t))
  out = t.datasize(ind);
else
  error('Invalid number of subscripting dimensions');
end

% vim: ts=2:sw=2:et
