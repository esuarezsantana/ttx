function display(Tf)
%TENSOR/DISPLAY Command window display of a tensor field.
%    This is the specific class function that is run when an output is
%    requested (no semi-colon).
%
%    Note: setting the field '.longdisplay' to 1, it shows all the
%    properties of the object.
%
%    Examples:
%
%        m = tensor(rand([3 4 5]),3)
%        m.longdisplay=1
%
%    See also TENSOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/display.m
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

%convert into text
sfield = num2str(rawfieldsize(Tf));
stensor = num2str(tensorsize(Tf));
if isa(Tf.data,'uint8')
  datatype = 'uint8';
elseif (isa(Tf.data,'double'))
  datatype = 'double';
else
  datatype = 'no numeric';
end

%display
if (Tf.longdisplay == 0)
  disp(' ');
  disp([inputname(1),' =']);
  disp(' ');
  disp(['     [',sfield '] -> [' stensor ']']);
  disp([' ']);
else
  nfield = num2str(fielddim(Tf));
  ntensor = num2str(tensordim(Tf));
  %  sampling=num2str(Tf.sample);
  disp(' ');
  disp([inputname(1),' =']);
  disp(['             name: ',Tf.name]);
  disp(['             kind: (',nfield,',',ntensor,')']);
  disp(['       field size: ',sfield]);
  %removed in 2.0
  %  disp(['    sampling rate: ',sampling]);
  disp(['      tensor size: ',stensor]);
  disp(['        data type: ',datatype]);
  disp(['   backup allowed: ',yesornot(~Tf.mem.tmpbackup_not_allowed)]);
  if (~Tf.mem.tmpbackup_not_allowed)
    disp(['   save as uint16: ',yesornot(Tf.mem.storeasuint16)]);
    disp(['         filename: ''',Tf.mem.filename '''']);
  end
  disp(['   tensor version: ',Tf.version]);
  disp(' ');
end


%-----------------------------------------------------------------------
% Subfunction yesornot
%-----------------------------------------------------------------------
function yn = yesornot(flag)

if (flag)
  yn = 'Yes';
else
  yn = 'No';
end

% vim: ts=2:sw=2:et
