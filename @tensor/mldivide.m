function [c] = mldivide(A,b)
%TENSOR/MLDIVIDE Implement A \ b for tensor objects.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/mldivide.m
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

[A,b,wscalar,empty] = binaryop(A,b);

if (empty==1)
  c = tensor;
  return;
end

switch wscalar
  case 1
    %A is a scalar -> then no necessary inversion
    c = mdivide(A,b);
  case 2
    error('A matrix multiplication cannot return a scalar.');
  case 0
    %there are no scalars
    %if one of them is a double array, it must be a point tensor.
    A = tensor(A,0);
    b = tensor(b,0);
    %let's solve for A square matrix!
    btdim = tensordim(b);
    Atdim = tensordim(A);
    Atsiz = tensorsize(A);
    btsiz = tensorsize(b);

    %check tensor dimensions and size
    if (btdim==0)
      %let's assume A is a scalar field
      c = ldivide(A,b);
      return;
      %error('b must be a vector field');
    end
    if (~isequal([btsiz btsiz],Atsiz))
      error('A must be a square matrix field');
    end

    Afdim = fielddim(A);
    bfdim = fielddim(b);
    if (Afdim == 0 & bfdim == 0)
      c = tensor(A.data\b.data,0);
      return;
    elseif (Afdim == 0)
      %1 means repeat A
      c = fastmldivide(1,btsiz,fieldsize(b),A.data,b.data);
      c = tensor(c,bfdim);
    elseif (bfdim==0)
      %2 means repeat b
      c = fastmldivide(2,btsiz,fieldsize(A),A.data,b.data);
      c = tensor(c,Afdim);
    else
      if ~isequal(fieldsize(A),fieldsize(b))
        error('Field sizes must be equal');
      end
      % 0 means no repeat
      c = fastmldivide(0,btsiz,fieldsize(A),A.data,b.data);
      c = tensor(c,Afdim);
    end
  otherwise
    error('Internal error! Check source');
end

% vim: ts=2:sw=2:et
