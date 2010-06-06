function [c] = ctranspose(a)
%TENSOR/CTRANSPOSE Implement a' for tensor objects.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/ctranspose.m
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

if (isempty(a.datasize))
  c = tensor;
  return;
end

[aM,aS,aR] = matrixop(a);
ctsize = tensorsize(a);
totalfieldelems = prod(ctsize);

for ii = 1:totalfieldelems
  eval([aS{ii} '=' aR{ii} ';']);
end

cM = aM';

eval(['c = ' strexchange(char(cM)) ';']);

%rearrange array
ctdim = tensordim(a);
cfdim = rawfielddim(a);
cfsize = rawfieldsize(a);
totaldim = ctdim + cfdim;

switch ctdim
  case 0
  case 1 %it will now turn into two
    switch cfdim
      case 0
        c = reshape(c,[1 ctsize]);
      case 1
        c = reshape(c,[cfsize 1 ctsize]);
      otherwise
        c = reshape(c,[cfsize(1:2) 1 ctsize cfsize(3:end)]);
        c = ipermute(c,[1 2 totaldim:totaldim+1 3:totaldim-1]);
    end
  case 2
    switch cfdim
      case 0
      case 1
        c = reshape(c,[cfsize ctsize(2) ctsize(1)]);
      case 2
        c = reshape(c,[cfsize(1) ctsize(2) cfsize(2) ctsize(1)]);
        c = ipermute(c,[1 3 2 4]);
      otherwise
        c = reshape(c, ...
          [cfsize(1) ctsize(2) cfsize(2) ctsize(1) cfsize(3:end)]);
        c = ipermute(c,[1 totaldim-1 2 totaldim 3:totaldim-2]);
    end
  otherwise
    error('Internal Error');
end

c = tensor(c,cfdim);

% vim: ts=2:sw=2:et
