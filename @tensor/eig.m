function [varargout] = eig(t)
%TENSOR/EIG Eigenvalues and eigenvectors of tensor objects.
%    EVALUE = EIG(T)  Produces a tensor that contains the different
%    eigenvalues of T. Input tensor dimensions must be square with
%    order 2. Eigenvalues are sorted from bigger to smaller.
%
%    [EVALUE, EVECTOR] = EIG(T) In addition to EVALUE, returns a
%    tensors whose columns are the eigenvectors of T, from bigger
%    to smaller eigenvalues.
%
%    Example:
%        a=tensor(rand([20 20 3 3]),2);
%        [Val, Vec]=eig(a);
%
%    See also TENSOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/eig.m
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
%   Copyright (c) 2001 Dan Fox, C.-F. Westin
%

% record info about the input tensor
f_sz  = fieldsize(t);
t_sz  = tensorsize(t);
f_dim = fielddim(t);
t_dim = tensordim(t);
width = t_sz(1);

% check for correct dimensions, etc
if ( (~all(t_sz == t_sz(1))) | (t_dim ~= 2) )
  error('Input tensor dimensions must be square with rank 2');
  return;
end

% check for correct number of input arguments
if ( nargin<1 | nargin>1 )
  error('Must supply exactly one input argument');
  return;
end

% check for correct number of output arguments
if nargout>2
  error('Must request at most 2 output arguments');
  return;
end

% run the mex file
if nargout == 1 | nargout == 0
  values = eighelper(t.data);
elseif nargout == 2
  [values vectors] = eighelper(t.data);
end

if f_dim > 0
  % sort values
  [values sort_index] = sort(values,ndims(values));
  values = flipdim(values,ndims(values));

  values_sz = size(values);
  if nargout == 2
    vectors_sz = size(vectors);
  end

  % sort vectors
  if nargout == 2
    % make appropriate index for vectors
    sort_index_new = zeros([f_sz t_sz]);
    subs = repmat({':'},[1 f_dim+t_dim]);
    for x = 1:t_sz(end-1)
      subs{f_dim+t_dim-1} = x;
      sort_index_new(subs{:}) = sort_index;
    end

    % convert to global index
    ind_basic = repmat([1:prod(values_sz)]',[vectors_sz(end) 1]);
    ind_offset = (sort_index_new(:)-1).*prod(values_sz);
    ind = ind_basic + ind_offset;

    % reshape the sorted data
    vectors = vectors(ind);
    vectors = reshape(vectors,vectors_sz);
    vectors = flipdim(vectors,ndims(vectors));
  end

  % cast to tensors
  varargout{1}=tensor(values,f_dim);
  varargout{1}.name=['eig_val: ' t.name];
  if nargout == 2
    varargout{2}=tensor(vectors,f_dim);
    varargout{2}.name=['eig_vec: ' t.name];
  end

else

  % f_dim=0
  [values sort_index] = sort(values,1);
  values = flipdim(values,1);
  sort_index = flipdim(sort_index,1);

  varargout{1} = tensor(values,0);
  varargout{1}.name=['eig_val: ' t.name];
  if nargout == 2
    varargout{2} = tensor(vectors(:,sort_index),0);
    varargout{2}.name=['eig_vec: ' t.name];
  end

end

% vim: ts=2:sw=2:et
