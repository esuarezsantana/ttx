function [a,b,wscalar,empty] = binaryop(a,b)
%BINARYOP converts one input to tensor field.
%    [A,B,ISSCALAR,EMPTY] = BINARYOP(A,B) checks either A
%    or B are double and converts it to tensor if consistent. It
%    tries to fit double array to the same size of tensor or to the
%    tensor size the tensor object. It returns A and B as tensor
%    objects or as scalars, and in such case ISSCALAR points either
%    A (1) or B (2). Moreover, it returns whether one of them is
%    empty in EMPTY.
%
%    Note:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/private/binaryop.m
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

wscalar = 0; % boolean to see whether is an scalar
empty = 0;
if (isa(a,'tensor'))
  if (isempty(a.datasize))
    a = [];
    b = [];
    wscalar = [];
    empty = 1;
    return;
  end
  if (isa(b,'tensor'))
    if (isempty(b.datasize))
      a = [];
      b = [];
      wscalar = [];
      empty = 1;
      return;
    end
    [a,b] = SameSize(a,b);
    return;
  else
    if (isempty(b))
      a = [];
      b = [];
      wscalar = [];
      empty = 1;
      return;
    end

    [sizeb,dimb,isok,bnew] = arraysize(b);

    if (isok == 0)
      b = bnew;
      clear bnew;
    end

    if (dimb == 0)
      wscalar = 2;
      return;
    end
    sizea  = a.datasize;
    tsizea = tensorsize(a);
    dima   = fielddim(a)+tensordim(a);
    if (dimb == dima & isequal(sizeb,sizea))
      b = tensor(b,a.dimension);
      return;
    elseif (dimb==tensordim(a) & isequal(sizeb,tsizea))
      b = tensor(b,0);
      [a,b] = SameSize(a,b);
      return;
    else
      error('Total or tensor dimensions must coincide.');
    end
  end

  % to avoid lack of memory, it's better to repeat the code. %'
else % b must be at least a tensor
  if isempty(a)
    a = [];
    b = [];
    wscalar = [];
    empty = 1;
    return;
  end

  [sizea,dima,isok,anew] = arraysize(a);
  if (isok ==0)
    a = anew;
    clear anew;
  end

  if (dima == 0)
    wscalar = 1;
    return;
  end
  sizeb = b.datasize;
  tsizeb = tensorsize(b);
  dimb = fielddim(b)+tensordim(b);
  if (dimb == dima & isequal(sizea,sizeb))
    a = tensor(a,b.dimension);
    return;
  elseif (dima==tensordim(b) & isequal(sizea,tsizeb))
    a = tensor(a,0);
    [a,b] = SameSize(a,b);
    return;
  else
    error('Total or tensor dimensions must coincide.');
  end
end


%-----------------------------------------------------------------------
% Subfunction SameSize
%-----------------------------------------------------------------------
function [c,d] = SameSize (c,d)

ctdim = tensordim(c);
dtdim = tensordim(d);
ctsiz = tensorsize(c);
dtsiz = tensorsize(d);
cfdim = fielddim(c);
dfdim = fielddim(d);
cfsiz = fieldsize(c);
dfsiz = fieldsize(d);

if (cfdim==0 & dfdim~=0)
  c.data = repmat(c.data(:).',[prod(dfsiz) 1]);
  if (dfdim==1 & dtdim>1)
    c.data = reshape(c.data,[dfsiz dtsiz]);
  elseif (dfdim>1 & dtdim==0)
    c.data = reshape(c.data,dfsiz);
  elseif (dfdim>1 & dtdim>0)
    %c.data=reshape(c.data,[dfsiz dtsiz]);
    %Fails in this case [1] -> [3 3] * [10 10] -> [3]
    c.data = reshape(c.data,[dfsiz ctsiz]);
  end
  c.dimension(1) = d.dimension(1);
  %c.datasize=d.datasize;
  %Fails in the case before
  c.datasize = [dfsiz ctsiz];

elseif (cfdim~=0 & dfdim==0)
  d.data = repmat(d.data(:).',[prod(cfsiz) 1]);
  if (cfdim==1 & ctdim>1)
    d.data = reshape(d.data,[cfsiz ctsiz]);
  elseif (cfdim>1 & ctdim==0)
    d.data = reshape(d.data,cfsiz);
  elseif (cfdim>1 & ctdim>0)
    d.data = reshape(d.data,[cfsiz ctsiz]);
  end
  d.dimension(1) = c.dimension(1);
  d.datasize = c.datasize;

elseif (cfdim == dfdim)
  if (ctdim==0 & dtdim~=0)
    c.data = repmat(c.data(:),[1 prod(dtsiz)]);
    c.data = reshape(c.data,[dfsiz dtsiz]);
    c.datasize = d.datasize;
    c.dimension(2) = d.dimension(2);
  elseif (ctdim~=0 & dtdim==0)
    d.data = repmat(d.data(:),[1 prod(ctsiz)]);
    d.data = reshape(d.data,[cfsiz ctsiz]);
    d.datasize = c.datasize;
    d.dimension(2) = c.dimension(2);
  end

end

% vim: ts=2:sw=2:et
