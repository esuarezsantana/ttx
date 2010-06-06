function [c] = fieldsum(varargin)
%TENSOR/FIELDSUM Sum of the field components.
%    Y = FIELDSUM(X) sums the elements of the field, returning them
%    as a tensor.
%
%    Y = FIELDSUM(X,N) sums the elements of the field only in the
%    Nth component of the tensor.
%
%    Example:
%
%        tn1=tensor(rand([10 10 2 2]),2);
%        tn2=fieldsum(tn1(5:10,15:20));
%
%    See also TENSOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/fieldsum.m
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
    fd = fielddim(varargin{1});
    if (fd==0)
      c = varargin{1};
      return;
    else
      sumdim = [1:fd];
    end
    c = varargin{1}.data;
    for ii = sumdim
      c = sum(c,ii);
    end
    switch (tensordim(varargin{1}))
      case {0,1}
        c = tensor(squeeze(c),0);
      otherwise
        c = reshape(c,tensorsize(varargin{1}));
        c = tensor(c,0);
    end
  case 2
    if (isempty(varargin{1}.datasize))
      c = tensor;
      return;
    end
    fd = fielddim(varargin{1});
    if (varargin{2}>fd)
      error('Not a valid field dimension.');
    elseif (fd==0)
      c = varargin{1};
      return;
    else
      sumdim = varargin{2};
    end
    c = varargin{1}.data;
    for ii = sumdim
      c = sum(c,ii);
    end
    c = tensor(c,fd);
  otherwise
    error('Too many input arguments.');
end

% vim: ts=2:sw=2:et
