function [c] = catt(varargin)
%TENSOR/CATT Concatenate tensor elements of tensor objects.
%    B = CATT(DIM,A1,A2,A3,...) works as the cat operation for
%    multidimensional arrays on the tensor of the tensor object.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/catt.m
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

    fsize = fieldsize(a);
    if (~isequal(fsize,fieldsize(b)))
      error('Tensor dimensions must coincide.');
    end

    atdim = tensordim(a);
    btdim = tensordim(b);
    afdim = fielddim(a);
    bfdim = fielddim(b);

    %so we have at least a 2-by-2 matrix
    ntdim = max([atdim,btdim,catdim,2]);

    asize = [fsize ones(1,ntdim)];
    bsize = asize;
    asize(afdim+1:afdim+atdim) = tensorsize(a);
    bsize(bfdim+1:bfdim+btdim) = tensorsize(b);

    if (ntdim>1)
      atest = asize([1:afdim+catdim-1 afdim+catdim+1:end]);
      btest = bsize([1:bfdim+catdim-1 bfdim+catdim+1:end]);
      if ~isequal(atest,btest)
        error('Arguments dimensions are not consistent.');
      end
    end

    a.data = reshape(a.data,[prod(asize(1:afdim+catdim)) ...
      prod(asize(afdim+catdim+1:end))]);
    b.data = reshape(b.data,[prod(bsize(1:bfdim+catdim)) ...
      prod(bsize(bfdim+catdim+1:end))]);
    c.data = [a.data; b.data];

    ctsiz = [asize(afdim+1:afdim+catdim-1) asize(afdim+catdim)+ ...
      bsize(bfdim+catdim) asize(afdim+catdim+1:afdim+ntdim)];

    c.data = reshape(c.data,[fsize ctsiz]);

    c = tensor(c.data,afdim);

  otherwise
    c = varargin{2};
    for ii = 3:nargin
      c = catt(varargin{1},c,varargin{ii});
    end
end

% vim: ts=2:sw=2:et
