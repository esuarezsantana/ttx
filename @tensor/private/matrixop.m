function [asym,name,range] = matrixop(a)
%TFMATRIXOPERATION Symbolic matrix translation.
%    [MAT,ELEM,RANG] = MATRIXOP translates the double data to
%    symbolic data. It returns the names of the symbolic objects as the
%    cell ELEM which builds the symbolic matrix MAT. Each symbolic
%    object is assigned to a subset of the double data. These subsets
%    are stored as another cell in RANG.
%
%    Examples:
%
%        a = tensor(rand([100 125 2 3],2))
%
%            a =
%                 field size: 100  125
%                tensor size: 2  3
%
%        [mat,elem,rang] = matrixop(a)
%
%        mat =
%
%            [ a_1_1, a_1_2, a_1_3]
%            [ a_2_1, a_2_2, a_2_3]
%
%
%        elem =
%
%          Columns 1 through 4
%
%            'a_1_1'    'a_1_2'    'a_1_3'    'a_2_1'
%
%          Columns 5 through 6
%
%            'a_2_2'    'a_2_3'
%
%
%        rang =
%
%          Columns 1 through 2
%
%            'a.data(:,:,1,1)'    'a.data(:,:,1,2)'
%
%          Columns 3 through 4
%
%            'a.data(:,:,1,3)'    'a.data(:,:,2,1)'
%
%          Columns 5 through 6
%
%            'a.data(:,:,2,2)'    'a.data(:,:,2,3)'
%
%    See also ...
%
%    References: ...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/private/matrixop.m
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

if (~isa(a,'tensor'))
  error('Data must be tensor');
end

td = tensordim(a);
if (td>2)
  error('Too many tensor dimensions');
end

ts    = tensorsize(a);
fd    = fielddim(a);
aname = inputname(1);
name  = cell(1,prod(ts));
range = name;
eval(['syms ' aname ';']);
colon = [aname '.data('];
if (fd~=0)
  for ii = 1:fd
    colon = [colon ':,'];
  end
end

switch td
  case 0
    eval(['syms ' aname '_;']);
    eval(['asym = ' aname '_;']);
    name{1} = [aname '_'];
    if (fd==0)
      range{1} = [colon(1:end-1)];
    else
      range{1} = [colon(1:end-1) ')'];
    end

  case 1
    for ii = 1:ts(1)
      nameij = [aname '_' num2str(ii)];
      eval(['syms ' nameij ';']);
      eval(['asym(ii,1) = ' nameij ';']);
      name{ii} = nameij;
      range{ii} = [colon num2str(ii) ')'];
    end

  case 2
    kk = 0;
    for ii = 1:ts(1)
      for jj = 1:ts(2)
        kk = kk+1;
        nameij = [aname '_' num2str(ii) '_' num2str(jj)];
        eval(['syms ' nameij ';']);
        eval(['asym(ii,jj) = ' nameij ';']);
        name{kk} = nameij;
        range{kk} = [colon num2str(ii) ',' num2str(jj) ')'];
      end
    end

  otherwise
    error('Internal error!');
end

% vim: ts=2:sw=2:et
