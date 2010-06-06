function [TT] = unpad(T,edge)
%TENSOR/UNPAD Tensor field padding.
%   TPADDED = UNPAD(T, EDGE) unpads the tensor field T as
%   indicated in matrix EDGE. EDGE can accept the next formats:
%   1. a single number, the same padding is assumed everywhere.
%   2. a column vector, the same padding is assumed at the
%   beginning and at the end of each dimension.
%   3. a fielddim(T)x2 matrix, the first row is the beginning
%   padding and the second is the end one.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/unpad.m
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
%   Copyright (C) 2000 Juan Ruiz-Alzola
%
%   Copyright (C) 2001 Eduardo Suarez-Santana
%                      http://e.suarezsantana.com/
%

msg = nargchk(2,2,nargin);
if ~isempty(msg)
  error('msg');
end

fdim = fielddim(T);
edge_size = ParseInputs(fdim,edge);
fsize = fieldsize(T);
subsc = cell([1 fdim]);

for dd = 1:fdim
  subsc{dd} = [edge_size(dd,1)+1:fsize(dd)-edge_size(dd,2)];
end

S.type = '()';
S.subs = subsc;
TT = subsref(T,S);


%-----------------------------------------------------------------------
% Subfunction ParseInputs
%-----------------------------------------------------------------------
function [edge_size] = ParseInputs(fdim,edge)

[r_ed, c_ed] = size(edge);
switch (r_ed.*c_ed)
  case (2.*fdim)
    edge_size = edge;
  case fdim
    edge_size = [edge edge];
  case 1
    edge_size = repmat(edge,[fdim 2]);
  otherwise
    error('Invalid edge padding matrix.');
end

% vim: ts=2:sw=2:et
