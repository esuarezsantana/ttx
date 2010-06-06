function [c] = norm(varargin)
%TENSOR/NORM Norm of a tensor object.
%    N = NORM(TF,P) returns the norm of each tensor in a new tensor
%    according to the measure space P:
%
%    'max','Inf','inf'       p=Infinite (maximum value)
%    'min','-Inf','-inf'     p=-Infinite (mimimum value)
%    'quad','fro'            p=2
%    positive number p
%
%    N = NORM(TF) computes the quadratic norm.
%
%    See also TENSOR, NORM.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/norm.m
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

[pmeasure,empty] = ParseInputs(varargin{:});
%tn remains as varargin{1};
if (empty==1)
  c = tensor;
  return;
end

switch pmeasure
  case Inf
    %compute the maximum
    varargin{1}.data = reshape(varargin{1}.data, ...
      [prod(rawfieldsize(varargin{1})) prod(tensorsize(varargin{1}))]);
    c.data = max(varargin{1}.data,[],2);
    if (rawfielddim(varargin{1})>1)
      c.data = reshape(c.data,rawfieldsize(varargin{1}));
    end
    c = tensor(c.data,rawfielddim(varargin{1}));

  case -Inf
    %compute the minimum
    varargin{1}.data = reshape(varargin{1}.data, ...
      [prod(rawfieldsize(varargin{1})) prod(tensorsize(varargin{1}))]);
    c.data = min(varargin{1}.data,[],2);
    if (rawfielddim(varargin{1})>1)
      c.data = reshape(c.data,rawfieldsize(varargin{1}));
    end
    c = tensor(c.data,rawfielddim(varargin{1}));

  otherwise
    %compute the absolute value
    c.data = reshape(varargin{1}.data, ...
      [prod(rawfieldsize(varargin{1})) prod(tensorsize(varargin{1}))]);
    c.data = abs(c.data);
    c.data = c.data.^pmeasure;
    c.data = sum(c.data,2);
    c.data = c.data.^(1./pmeasure);
    if (rawfielddim(varargin{1})>1)
      c.data = reshape(c.data,rawfieldsize(varargin{1}));
    end
    c = tensor(c.data,rawfielddim(varargin{1}));
end


%-----------------------------------------------------------------------
% Subfunction ParseInputs
%-----------------------------------------------------------------------
function [pmeasure,empty]=ParseInputs(varargin)

empty = 0;
switch nargin
  case 0
    error('Not enough input arguments.');
  case 1
    if (~isa(varargin{1},'tensor'))
      error('First argument must be a tensor object');
    end
    if (isempty(varargin{1}.datasize))
      empty = 1;
    end
    pmeasure = 2;

  case 2
    if (~isa(varargin{1},'tensor'))
      error('First argument must be a tensor object');
    end
    if (isempty(varargin{1}.datasize))
      empty    = 1;
      pmeasure = [];
      return;
    end

    switch varargin{2}
      case {'quad','fro'}
        pmeasure = 2;
      case {'max','Inf','inf'}
        pmeasure = Inf;
      case {'min','-Inf','-inf'}
        pmeasure = -Inf;
      otherwise
        p = varargin{2};
        if (~isnumeric(p) | ~isequal(size(p),[1 1]) | p<=0)
          error('P-Measure must be a positive number');
        end
        pmeasure = p;
    end
  otherwise
    error('Too few input arguments.');
end

% vim: ts=2:sw=2:et
