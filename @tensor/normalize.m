function [b,maxim,minim] = normalize(a,mode,maxim,minim)
%TENSOR/NORMALIZE Implement intensity modification.
%
%    'plain'   normalizes to max value
%    'bins'    get value bins
%    'eqplain' plain + equalization
%    'eqbins'  bins + equalization
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/normalize.m
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

% there should be a prob. density funct. adjust
% for unknown maxim, minim.

%input parsing
msg = nargchk(1,4,nargin);
if ~isempty(msg)
  error(msg);
end

eps2 = 1e-10;

switch nargin
  case 1
    mode  = 'plain';
    maxim = 1;
  case 2
    if ( isequal(mode,'bins') | isequal(mode,'eqbins') ...
        | isequal(mode,'binsmax') )
      error('Number of bins needed');
    else
      maxim = 1;
    end
  case 3
    minim = 0;
end

ma = fmin(a);
Ma = fmax(a);

switch mode
  case 'plain'
    orig = ma;
    scal = (maxim-minim)./(Ma-ma);
    b    = (a-orig).*scal+minim;
  case 'eqplain'
    error('method not fully implemented');
    orig = ma;
    scal = 1./(Ma-ma);
    b    = (a-orig).*scal;
    ptsize = prod(tensorsize(b));
    b.data = reshape(b.data,[prod(rawfieldsize(b)) ptsize]);
    for ii = 1:ptsize
      b.data(:,ii)=histeq(b.data(:,ii));
    end
    b.data = reshape(b.data,[rawfieldsize(b) tensorsize(b)]);
    b = b.*maxim;
  case 'bins'
    if nargin == 4
      error('esto no tiene sentido');
    end
    orig = ma;
    scal = (maxim-eps2)./(Ma-ma);
    b = floor((a-orig).*scal);
  case 'eqbins'
    error('method not fully implemented');
    orig = ma;
    scal = 1./(Ma-ma);
    b    = (a-orig).*scal;
    ptsize = prod(tensorsize(b));
    b.data = reshape(b.data,[prod(rawfieldsize(b)) ptsize]);
    for ii = 1:ptsize
      b.data(:,ii) = histeq(b.data(:,ii));
    end
    b.data = reshape(b.data,[rawfieldsize(b) tensorsize(b)]);
    b = floor(b.*(maxim-eps2));
end

% vim: ts=2:sw=2:et
