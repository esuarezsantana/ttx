function [c] = mtimes(a,b)
%TENSOR/TIMES Element wise matrix multiplication.
%
%    Examples:
%
%       tn = tensor(rand(4,4,10,3,3),3);
%       ss = tensor(rand(3,3),0);
%       mm = [1 2 3; 4 5 6; 7 8 9];
%
%       out1 = 13 * tn;      %scalar and a TENSOR
%       out1 = tn * tn;      %two TENSORs with suitable dimensions
%       out2 = ss * tn;      %a singleton TENSOR and a regular TENSOR
%       out3 = mm * tn;      %a double array and a TENSOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/mtimes.m
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

atd = tensordim(a);
btd = tensordim(b);
ats = tensorsize(a);
bts = tensorsize(b);

switch atd
 case 0
 case 1
  switch btd
   case 0
   case 1
    error('Inner matrix dimensions must agree');
   case 2
    if (bts(1)~=1)
      error('Inner matrix dimensions must agree');
    end
   otherwise
    error('Not a possible matrix operation');
  end
 case 2
  switch btd
   case 0
   case {1,2}
    if (ats(2)~=bts(1))
      error('Inner matrix dimensions must agree');
    end
   otherwise
    error('Not a possible matrix operation');
  end
 otherwise
  if (btd~=0)
    error('Not a possible matrix operation');
  end
end

[aM,aS,aR] = matrixop(a);
[bM,bS,bR] = matrixop(b);
for ii = 1:prod(ats)
   eval([aS{ii} '=' aR{ii} ';']);
end
for ii = 1:prod(bts)
   eval([bS{ii} '=' bR{ii} ';']);
end

cM = aM*bM;

eval(['c = ' strexchange(char(cM)) ';']);

%rearrange array
[ctsize,ctdim] = arraysize(cM);
cfdim    = rawfielddim(a);
cfsize   = rawfieldsize(a);
totaldim = ctdim+cfdim;
switch ctdim
 case 0
 case 1
  switch cfdim
   case 0
   case 1
    c = reshape(c,[cfsize ctsize]);
   otherwise
    c = reshape(c,[cfsize(1) ctsize cfsize(2:end)]);
    c = ipermute(c,[1 totaldim 2:totaldim-1]);
  end
 case 2
  switch cfdim
   case 0
   case 1
    c = reshape(c,[cfsize ctsize]);
   case 2
    c = reshape(c,[cfsize(1) ctsize(1) cfsize(2) ctsize(2)]);
    c = ipermute(c,[1 3 2 4]);
   otherwise
    c = reshape(c, ...
      [cfsize(1) ctsize(1) cfsize(2) ctsize(2) cfsize(3:end)]);
    c = ipermute(c,[1 totaldim-1 2 totaldim 3:totaldim-2]);
  end
 otherwise
  error('Internal Error');
end

c = tensor(c,cfdim);

% vim: ts=2:sw=2:et
