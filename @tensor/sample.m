function [def] = sample(ref,pos,method,fill)
%TENSOR/SAMPLE Samples the tensor field at positions.
%
%    Examples:
%
%        a=tensor(rand([10 2 2]),1);
%        b=sample(a,position(a)+.5);
%        c=tensor(zeros([19 2 2]),1);
%        c(1:2:end)=a; c(2:2:end)=b(1:end-1);
%
%    See also TENSOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/sample.m
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

if (isempty(ref) | isempty(pos))
  def = tensor;
  return;
end

ref_fd = fielddim(ref);
ref_td = tensordim(ref);
ref_fs = fieldsize(ref);
ref_ts = tensorsize(ref);
pos_fd = fielddim(pos);
pos_td = tensordim(pos);
pos_fs = fieldsize(pos);
pos_ts = tensorsize(pos);

if ~isequal(ref_fd,pos_ts,pos_fd)
  error('Invalid positions');
end

if (nargin==2 | isempty(method))
  method = '*linear';
end

ncoords  = prod(pos_ts);)
pos_cell = cell(1,ncoords);
ntelems  = prod(ref_ts);

refsize  = [ref_fs prod(ref_ts)];
ref.data = reshape(ref.data,refsize);
possize  = [pos_fs ncoords];
def      = zeros(possize);
pos.data = reshape(pos.data,[prod(pos_fs) ncoords]);

for count = 1:ncoords
  pos_cell{count} = reshape(pos.data(:,count),[pos_fs 1]);
end

def  = zeros([pos_fs ntelems]);
subs = repmat({':'},[1 ref_fd+1]);

switch ref_fd
  %case 0 impossible
  case 1
    for count = 1:ntelems
      subs{end} = count;
      def(subs{:}) = interp1(ref.data(subs{:}),pos_cell{:},method);
    end

  otherwise
    for count = 1:ntelems
      subs{end} = count;
      def(subs{:}) = interpn(ref.data(subs{:}),pos_cell{:},method);
    end
end

def = reshape(def,[pos_fs ref_ts]);

if nargin>3
  out = find(isnan(def));
  def(out) = fill;
end

def = tensor(def,ref_fd);

% vim: ts=2:sw=2:et
