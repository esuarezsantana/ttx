function [c] = gt (a,b)
%TENSOR/GT Implement a > b for tensor objects.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/gt.m
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

[a,b,wscalar,empty] = binaryop(a,b);

if (empty==1)
  c = tensor;
  return;
end

switch wscalar
  case 0
    c = a.data>b.data;
    %rawfielddim(a),rawfielddim(b) are equal or one of them is zero.
    c = tensor(c,max(rawfielddim(a),rawfielddim(b)));
  case 1
    c = a>b.data;
    c = tensor(c,rawfielddim(b));
  case 2
    c = a.data>b;
    c = tensor(c,rawfielddim(a));
  otherwise
    error('Internal error!! Check source');
end

% vim: ts=2:sw=2:et
