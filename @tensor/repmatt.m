function [TT] = repmatt(T,repsize)
%TENSOR/REPMATT Repetition of tensor field objects.
%    TT = REPMATT(T,[M N P ...]) tiles the tensor T to produce a new
%    tensor TT consisting of M-N-P-... blocks of T.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/repmatt.m
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

%it produces some trouble when using normal repmat inside @tensor,
%so i changed the name from repmat to repmatt

%first we turn fsize and repsize similar vectors
fsize  = fieldsize(T);
fdim   = fielddim(T);
lfsize = length(fsize);

repsize = repsize(:);
while (repsize(end)==1 & length(repsize)>1)
  repsize = repsize(end-1);
end
lrepsize = length(repsize);

max_s = max(lrepsize,length(fsize));
onesvec = ones(max_s,1);
fsize_  =onesvec;
fsize_(1:lfsize) = fsize;
repsize_ = onesvec;
repsize_(1:lrepsize) = repsize;

%now we initialize the data
tsize = tensorsize(T);
TT = zeros([repsize_.*fsize_; tsize(:)].');

%get the subsreferences
if fdim~=0
  f_subs = repmat({':'},[1 fdim]);
else
  if tensordim(T)~=0
    f_subs = {};
  else
    f_subs = {1};
  end
end

ff_subs = repmat({':'},[1 max_s]);

%assign the data
for ii = 1:prod(tsize)
  TT(ff_subs{:},ii) = repmat(T.data(f_subs{:},ii),repsize.');
end

TT = tensor(TT,max_s);

% vim: ts=2:sw=2:et
