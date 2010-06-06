function [c] = sum(varargin)
%TENSOR/SUM Sum of the tensor components.
%    Y = SUM(X) sums the components of the tensor of the tensor.
%
%    Y = SUM(X,N) sums the components of the tensor of the tensor
%    only in the Nth component of the tensor.
%
%    Example:
%
%        tn1=tensor(rand([10 10 2 2]),2);
%        tn2=sum(tn1(5:10,15:20));
%
%    See also TENSOR
%
%    References: ...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/sum.m
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
  case 0
    error('Not enough input arguments.');
  case 1
    if (isempty(varargin{1}.datasize))
      c = tensor;
      return;
    end
    td = tensordim(varargin{1});
    if (td==0)
      c = varargin{1};
      return;
    else
      sumdim = [1:td]+fielddim(varargin{1});
    end
  case 2
    if (isempty(varargin{1}.datasize))
      c = tensor;
      return;
    end
    td = tensordim(varargin{1});
    if (td==0)
      c = varargin{1};
      return;
    elseif (varargin{2}>td)
      error('Not a valid tensor dimension.');
    else
      sumdim = varargin{2}+fielddim(varargin{1});
    end
  otherwise
    error('Too many input arguments.');
end

c = varargin{1}.data;
for ii = sumdim
  c = sum(c,ii);
end

c = tensor(c,fielddim(varargin{1}));

% vim: ts=2:sw=2:et
