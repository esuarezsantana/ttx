function [out] = conv(t,filt,varargin)
%TENSOR/CONV Tensor convolution.
%    C = CONV(T, B) performs the N-dimensional convolution of
%    tensor object T and filter B. B can be either a tensor or a
%    scalar.
%
%    C = CONV(T, B, 'shape') controls the size of the answer C:
%      'full'   - (default) returns the full N-D convolution
%      'same'   - returns the central part of the convolution that
%                 is the same size as A.
%      'valid'  - returns only the part of the result that can be
%                 computed without assuming zero-padded arrays.  The
%                 size of the result is max(size(A)-size(B)+1,0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/conv.m
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
%   Copyright (C) 2002 Eduardo Suarez-Santana
%                      http://e.suarezsantana.com/
%

%if one of them is a scalar, then run through the other. Otherwise,
%check if tensor dimensions are equal and convolve.

% Check number of inputs
if nargin > 3
  error('too many input arguments');
  return;
end
if nargin < 2
  error('not enough input arguments');
  return
end

% Get string input
if nargin == 3
  if isstr(varargin{1})
    switch lower(varargin{1})
     case {'full','same','valid'}
      output_size = lower(varargin{1});
     otherwise
      error('unknown size option');
      return;
    end
  else
    error('third argument must be a string');
    return
  end
else
  output_size = 'full';
end

%the filter can also be a tensor object
% Check the filter

switch (class(filt))
 case 'tensor'
  filt_fsz = fieldsize(filt);
  filt_fd  = fielddim(filt);
  filt_tsz = tensorsize(filt);
  filt_td  = tensordim(filt);
  filt     = double(filt);
 case 'double'
  filt_fsz = size(filt);
  filt_fd  = ndims(filt);
  %check for column
  if (filt_fd==2 & filt_fsz(2)==1)
    filt_fd = 1;
  end
  filt_tsz = 1;
  filt_td  = 0;
 otherwise
  error('input FILT must be tensor or double');
end

% Get tensor data
data_fsz = fieldsize(t);
data_fd  = fielddim(t);
data_tsz = tensorsize(t);
data_td  = tensordim(t);
data     = double(t);

max_fd = max(data_fd,filt_fd);

%check which convolution to do
switch filt_td
 case 0
  switch data_td
   case 0
    %this is a normal convolution
    out = tensor(convn(data,filt,output_size),data_fd);
   otherwise
    % reshape for looping
    data = reshape(data,[data_fsz prod(data_tsz)]);
    subs = repmat({':'},[1 length(data_fsz)+1]);
    subs{end} = 1;
    % get output size
    output1 = convn(data(subs{:}),filt,output_size);
    output_fsz = size(output1);
    output2 = zeros([output_fsz prod(data_tsz)-1]);
    subs_output = repmat({':'},[1 length(output_fsz)+1]);
    % iterate
    for x = 2:prod(data_tsz)
      subs{end} = x;
      subs_output{end} = x-1;
      output2(subs_output{:}) = convn(data(subs{:}),filt,output_size);
    end
    out = tensor(reshape(cat(max_fd+1,output1,output2), ...
                         [output_fsz data_tsz]),max_fd);
  end
 otherwise
  switch data_td
   case 0
    % reshape for looping
    filt = reshape(filt,[filt_fsz prod(filt_tsz)]);
    subs = repmat({':'},[1 length(filt_fsz)+1]);
    subs{end} = 1;
    % get output size
    output1 = convn(data,filt(subs{:}),output_size);
    output_fsz = size(output1);
    output2 = zeros([output_fsz prod(filt_tsz)-1]);
    subs_output = repmat({':'},[1 length(output_fsz)+1]);
    % iterate
    for x = 2:prod(filt_tsz)
      subs{end} = x;
      subs_output{end} = x-1;
      output2(subs_output{:}) = convn(data,filt(subs{:}),output_size);
    end
    out = tensor(reshape(cat(max_fd+1,output1,output2), ...
                         [output_fsz filt_tsz]),max_fd);
   otherwise
    %convolution one 2 one component
    if ~isequal(data_tsz,filt_tsz)
      error('Don''t know how to assign components to convolve.');
    end
    tsz=data_tsz; %easier to read
    data = reshape(data,[data_fsz prod(tsz)]);
    dsubs = repmat({':'},[1 length(data_fsz)+1]);
    dsubs{end} = 1;
    filt = reshape(filt,[filt_fsz prod(tsz)]);
    fsubs = repmat({':'},[1 length(filt_fsz)+1]);
    fsubs{end} = 1;
    % get output size
    output1=convn(data(dsubs{:}),filt(fsubs{:}),output_size);
    output_fsz = size(output1);
    output2 = zeros([output_fsz prod(tsz)-1]);
    subs_output = repmat({':'},[1 length(output_fsz)+1]);
    % iterate
    for x = 2:prod(tsz)
      dsubs{end} = x;
      fsubs{end} = x;
      subs_output{end} = x-1;
      output2(subs_output{:}) = convn(data(dsubs{:}), ...
                                      filt(fsubs{:}),output_size);
    end
    out = tensor(reshape(cat(max_fd+1,output1,output2), ...
                         [output_fsz tsz]),max_fd);
  end
end

% vim: ts=2:sw=2:et
