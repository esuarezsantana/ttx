function [out] = squeeze(Tf)
%TENSOR/SQUEEZE Remove singleton dimensions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/squeeze.m
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

for ii = 1:fielddim(Tf)
  if (Tf.datasize(ii) == 1)
    Tf.dimension(1) = Tf.dimension(1) - 1;
  end
end

Tf.data = squeeze(Tf.data);
Tf.datasize = size(Tf.data);
out = Tf;

% vim: ts=2:sw=2:et
