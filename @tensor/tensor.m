function [Tf] = tensor(varargin)
%TENSOR/TENSOR Tensor Field class constructor.
%    Y = TENSOR creates an empty tensor class object.
%
%    Y = TENSOR(X) returns X if X is already a tensor.
%
%    Y = TENSOR(X) converts a Matlab data X array into a tensor
%    object. It sets rank 0.
%
%    Y = TENSOR(X,N) sets the number of field dimensions of Y to N.
%    X must be a Matlab data array. It returns X if X is already a
%    tensor.
%
%    WARNING: Reference System is always a mess. So that, the next
%    convention will be applied:
%
%      Space             Matrix            Medical
%        z                  k                 S
%        |                 /                  |
%        o                o--j                o
%       / \               |                  / \
%      x   y              i                 R   A
%
%    where 1st component:       x   i   R
%          2nd component:       y   j   A
%          3rd component:       z   k   S
%
%    This way, image representation and data reading becomes a bit
%    more complex, but operations simplify greatly.
%
%    Examples:
%
%        Tf1 = tensor; % empty tensor
%        Tf2 = tensor(rand(100)); % 100x100 scalar field
%        %Volume 100x125x80 of 3-d vectors
%        Tf3 = tensor(randn([100 125 80 3]),3);
%        %Image 100x125 of 2-d vectors
%        Tf4 = tensor(randn([100 125 2]),2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/tensor.m
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

%        tensor/TENSOR
%          char[] name
%          char[] version
%           uint8 longdisplay
%           uint8 mem.storeasuint16
%           uint8    .tmpbackup_not_allowed
%           uint8    .already_on_disk
%          char[]    .filename
%       double[2] dimensions %field+tensor dimensions
%        double[] data
%        double[] datasize

[data,isok,dimension,ntensor,datasize,already] = ...
  ParseInputs(varargin{:});

if ( already )
  Tf = varargin{1};
  return;
end

if (isempty(dimension))
  rawfieldsize = [];

elseif ( dimension == 0 )
  rawfieldsize = 1;

else
  rawfieldsize = datasize(1:dimension);
  if ( prod(rawfieldsize) == 1 )   % just the tensor
    if (ntensor == 0)
      tensorsize = 1;
      varargin{1} = squeeze(varargin{1});
    else
      tensorsize = datasize((dimension+1):end);
      if (ntensor == 1)
        newsize = [tensorsize 1];
      else
        newsize = tensorsize;
      end
      if (isok == 1)
        varargin{1} = reshape(varargin{1},newsize);
      elseif (isok == 0)
        data = reshape(data,newsize);
      else
        error('Internal error. Check source!');
      end
    end
    datasize     = datasize(dimension+1:end);
    rawfieldsize = 1;
    dimension    = 0;
  end
end

Tf.name        = 'no labeled';
Tf.longdisplay = 0;
Tf.datasize    = datasize;

if (isok==1)
  Tf.data = varargin{1};
else
  Tf.data = data;
end

Tf.mem.storeasuint16         = 0;
Tf.mem.tmpbackup_not_allowed = 0;
Tf.mem.filename              = '';
Tf.mem.currently_on_disk     = 0;

Tf.version='1.7';

%let's compute the tensor dimension
datadim = length(Tf.datasize);
if (datadim==0)
  Tf.dimension = [];
elseif (datadim==1 & isequal(Tf.datasize,[1 1]))
  Tf.dimension = [dimension 0];
else
  Tf.dimension = [dimension datadim-dimension];
end

Tf = class(Tf,'tensor');


%-----------------------------------------------------------------------
% Subfunction ParseInputs
%-----------------------------------------------------------------------
function [data,isok,dimension,ntensor,datasize,already] = ...
  ParseInputs(varargin)

switch nargin
  case 0 %empty object
    data      = [];
    dimension = [];
    ntensor   = [];
    datasize  = [];
    already   = 0;
    isok      = 0;
    return;

  case 1
    %check and convert to a numerical array
    if isa(varargin{1},'tensor') %return the same tensor
      already   = 1;
      data      = [];
      dimension = 0;
      ntensor   = 0;
      datasize  = 0;
      isok      = 1;
      return;
    elseif (isempty(varargin{1}))
      data      = [];
      dimension = [];
      ntensor   = [];
      datasize  = [];
      already   = 0;
      isok      = 0;
      return;
    else
      already = 0;
      %get the predefined dimensions
      [datasize,totaldimensions,isok,data] = arraysize(varargin{1});
      dimension = totaldimensions;
      ntensor   = 0;
    end

  case 2
    if isa(varargin{1},'tensor') %return the same tensor
      already   = 1;
      data      = [];
      dimension = 0;
      ntensor   = 0;
      datasize  = 0;
      isok      = 1;
      return;
    end

    already   = 0;
    dimension = varargin{2};

    %check input data and convert to a numerical array
    if (~isa(dimension,'double') | ...
        size(dimension)~=[1 1]   | ...
        floor(dimension)~=dimension)
      error('Number of field dimensions must be an integer number.');
    end

    matlab_dims = ndims(varargin{1});
    [datasize,totaldimensions,isok,data] = arraysize(varargin{1});

    if (totaldimensions == 0 & datasize == 0)
      data      = [];
      dimension = [];
      ntensor   = [];
      datasize  = [];
      already   = 0;
      isok      = 0;
      return;
    end

    if (dimension < 0) % we allow: >> a = tensor(rand([20 20]),3);
      % same as   >> a = tensor(rand([20 20 1]),3);
      %if (dimension < 0 | dimension > matlab_dims)
      error('Wrong number of field dimensions.');
    end
    dimension = min(dimension,totaldimensions);
    ntensor   = totaldimensions-dimension;

  otherwise
    error('Invalid number of arguments.');
end

% vim: ts=2:sw=2:et
