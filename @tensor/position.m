function [pos] = position(Tf,initial_pos)
%TENSOR/POSITION Index of field samples.
%   P = POSITION(T) returns a tensor objects the same field size than T
%   that contains the index position of every field sample in T.
%
%   P = POSITION(T, ORIGIN) works the same, but assuming that T indexes
%   start at ORIGIN.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/position.m
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

Tf = tensor(Tf);

if isempty(Tf)
  pos = tensor;
end

fd = fielddim(Tf);

if nargin<2
  initial_pos = ones(fd,1);
end

switch fd
 case 0
  pos = tensor(1,1);
 case 1
  pos = tensor([0+initial_pos(1):fieldsize(Tf)+initial_pos(1)-1].',1);
 otherwise
  out = cell(1,fd);
  fsize = fieldsize(Tf);
  for ii = 1:fd
    range{ii} = 0+initial_pos(ii):fsize(ii)+initial_pos(ii)-1;
  end
  [out{:}] = ndgrid(range{:});
  pos = cat(fd+1,out{:});
  pos = tensor(pos,fd);
end

% vim: ts=2:sw=2:et
