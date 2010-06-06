function [f_sum] = fsum (Tf)
%TENSOR/FMAX maximum of field of the tensor field.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/fsum.m
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
%   Copyright (C) 2002 Eduardo Suarez-Santana
%                      http://e.suarezsantana.com/
%

Tf.data = reshape(Tf.data,[prod(fieldsize(Tf)) ...
  tensorsize(Tf)]);

f_sum = sum(Tf.data);
fsize = size(f_sum);
f_sum = reshape(f_sum,[fsize(2:end) 1]);

% vim: ts=2:sw=2:et
