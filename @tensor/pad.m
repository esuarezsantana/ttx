function [TT] = pad(T,varargin)
%TENSOR/PAD Tensor field padding.
%   TPADDED = PAD(T, EDGE) pads mirroring the tensor field T as
%   indicated in matrix EDGE. EDGE can accept the next formats:
%   1. a single number, the same padding is assumed everywhere.
%   2. a column vector, the same padding is assumed at the
%   beginning and at the end of each dimension.
%   3. a fielddim(T)x2 matrix, the first row is the beginning
%   padding and the second is the end one.
%
%   TPADDED = PAD(T, EDGE, METHOD) performs the padding as
%   indicated in method, 'mirror' or 'repeat', that is, mirroring
%   or repeating the border values.
%
%   TPADDED = PAD(T, EDGE, PADTENSOR) performs the padding filling
%   the padded area with PADTENSOR.
%
%   Examples:
%
%       ...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/pad.m
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
%   Copyright (C) 2000 Juan Ruiz-Alzola
%
%   Copyright (C) 2001 Eduardo Suarez-Santana
%                      http://e.suarezsantana.com/
%

msg = nargchk(2,3,nargin);
if ~isempty(msg)
  error('msg');
end

fdim = fielddim(T);
[edge_size, method, padtensor] = ParseInputs(fdim,nargin,varargin{:});
fsize = fieldsize(T);
subsc = cell([1 fdim]);

switch method
  case 'mirror'
    for dd = 1:fdim
      subsc{dd} = [edge_size(dd,1)+1:-1:2,  1:fsize(dd) ...
        fsize(dd)-1:-1:fsize(dd)-edge_size(dd,2)];
    end
    S.type = '()';
    S.subs = subsc;
    TT = subsref(T,S);

  case 'repeat'
    for dd = 1:fdim
      subsc{dd} = [ones(1,edge_size(dd,1)),  1:fsize(dd) ...
        fsize(dd).*ones(1,edge_size(dd,2))];
    end
    S.type = '()';
    S.subs = subsc;
    TT = subsref(T,S);

  case 'fill'
    sizeTT = fieldsize(T)+sum(edge_size,2).';
    TT = repmat(padtensor,sizeTT);
    for dd = 1:fdim
      subsc{dd} = [1:fsize(dd)]+edge_size(dd,1);
    end
    S.type = '()';
    S.subs = subsc;
    TT = subsasgn(TT,S,T);
end


%-----------------------------------------------------------------------
% Subfunction ParseInputs
%-----------------------------------------------------------------------
function [edge_size, method, padtensor] = ...
  ParseInputs(fdim,narg,varargin);

switch narg
  case 2
    method = 'mirror';
    padtensor = [];
  case 3
    if isstr(varargin{2})
      if (isequal(varargin{2},'mirror') | ...
          isequal(varargin{2},'repeat'))
        method = varargin{2};
        padtensor = [];
      else
        error('Invalid padding method.');
      end
    else
      method = 'fill';
      if isempty(varargin{2});
        error('Padding tensor must be no empty');
      else
        padtensor = varargin{2};
      end
    end
  otherwise
    error('Internal error! Check source.');
end

e_size = varargin{1};
[r_ed, c_ed] = size(varargin{1});
switch (r_ed.*c_ed)
  case (2.*fdim)
    edge_size = e_size;
  case fdim
    edge_size = [e_size e_size];
  case 1
    edge_size = repmat(e_size,[fdim 2]);
  otherwise
    error('Invalid edge padding matrix.');
end

padtensor = tensor(padtensor,0);
if ~issingle(padtensor)
  error('Padding vector must be a single tensor.');
end

% vim: ts=2:sw=2:et
