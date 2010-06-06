function [data] = uint8 (Tf)
%TENSOR/UINT8 Uint8 casting of the tensor object data.
%
%    Casted is performed from double (0,1) to uint8 (0,255)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/uint8.m
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

if (isa(Tf.data,'uint8'))
  data = Tf.data;
else
  [s,t,isok,data] = arraysize(Tf.data);
  if (isok==1)
    data = uint8(Tf.data);
  else
    data = uint8(data);
  end
end

% vim: ts=2:sw=2:et
