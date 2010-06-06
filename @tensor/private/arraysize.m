function [varargout] = arraysize(data)
%ARRAYSIZE Real size and dimension.
%    [TSIZE,TDIMS] = ARRAYSIZE(MATRIX) gives us the size and number of
%    dimensions of the arrays, including 1-d arrays (vectors).
%
%    [TSIZE, TDIMS, ISOK, MATRIX] = ARRAYSIZE (MATRIX) also checks and
%    turns into double MATRIX. ISOK returns whether a cast has been
%    done.
%
%    Example:
%
%        a=[3 5 7]; [s,d,ok,a]=arraysize(a)
%
%            s =
%
%                 3
%
%            d =
%
%                 1
%
%
%            ok =
%
%                 1
%
%            a =
%
%                 3 5 7
%
%    See also TENSOR, ...
%
%    References: ...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/private/arraysize.m
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

if (nargout == 4)
  varargout{4} = [];
  isok = 1;
  %check for double matrix
  if (~isnumeric(data))
    error('Data must be a numeric array.');
  end
  if (issparse(data))
    varargout{4} = full(data);
    isok = 0;
  end
  if (isa(data,'uint8'))
    varargout{4} = double(data)./255;
    isok = 0;
  end
  varargout{3} = isok;
elseif (nargout ~= 2)
  error('Invalid number of output arguments');
end

%compute dimensions
sizein = size(data);
tdims  = ndims(data);
tsize  = sizein;
if (tdims == 2 )
  if (isempty(data))
    % oops. it's empty %'
    tsize = 0;
    tdims = 0;
  elseif (sizein == [1 1])
    tsize = 1;
    tdims = 0;
  elseif (sizein(2) == 1)
    % ndims==1
    tsize = sizein(1);
    tdims = 1;
  end
end

varargout{1} = tsize;
varargout{2} = tdims;

% vim: ts=2:sw=2:et
