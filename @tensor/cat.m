function [c] = cat(varargin)
%TENSOR/CAT Concatenate fields of tensor objects.
%    B = CAT(DIM,A1,A2,A3,...) works as the cat operation for
%    multidimensional arrays on the field of the tensor object.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/cat.m
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

switch nargin
  case {0,1,2}
    error('Too few input arguments.');
  case 3
    catdim = varargin{1};
    if (~isa(catdim,'double') | ...
        size(catdim)~=[1 1]   | ...
        floor(catdim)~=catdim | ...
        catdim<1)
      error('Concatenation dimension must be a natural number.');
    end
    a = tensor(varargin{2});
    b = tensor(varargin{3});
    if (isempty(a))
      c = b;
      return;
    elseif (isempty(b))
      c = a;
      return;
    end

    tsize = tensorsize(a);
    if (~isequal(tsize,tensorsize(b)))
      error('Tensor dimensions must coincide.');
    end

    afdim = rawfielddim(a);
    bfdim = rawfielddim(b);

    %so we have at least a 2-by-2 matrix
    nfdim = max([afdim,bfdim,catdim,2]);

    asize = [ones(1,nfdim) tsize];
    bsize = asize;
    asize(1:afdim) = rawfieldsize(a);
    bsize(1:bfdim) = rawfieldsize(b);

    if (nfdim>1)
      atest = asize([1:catdim-1 catdim+1:end]);
      btest = bsize([1:catdim-1 catdim+1:end]);
      if ~isequal(atest,btest)
        error('Arguments dimensions are not consistent.');
      end
    end

    a.data = reshape(a.data,[prod(asize(1:catdim)) ...
      prod(asize(catdim+1:end))]);
    b.data = reshape(b.data,[prod(bsize(1:catdim)) ...
      prod(bsize(catdim+1:end))]);
    c.data = [a.data; b.data];

    cfdim = [asize(1:catdim-1) asize(catdim)+bsize(catdim) ...
      asize(catdim+1:nfdim)];
    c.data = reshape(c.data,[cfdim tsize]);

    if (nfdim==2 & size(c.data,2)==1)
      dimension = 1;
      if (tensordim(a)==0)
        c.data = c.data(:);
      else
        c.data = reshape(c.data,[size(c.data,1) tsize]);
      end
    else
      dimension = nfdim;
      if (tensordim(a)==0)
        c.data = reshape(c.data,cfdim);
      end
    end

    c = tensor(c.data,dimension);

  otherwise
    c = varargin{2};
    for ii = 3:nargin
      c = cat(varargin{1},c,varargin{ii});
    end
end

% vim: ts=2:sw=2:et
