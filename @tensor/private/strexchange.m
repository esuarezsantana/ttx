function [b] = strexchange (a)
%STREXCHANGE String of an operation from a symbolic char casting.
%    STR = STREXCHANGE (SCHAR) performs the casting of SCHAR, which is a
%    string obtained from a char casting of a symbolic operation.
%    Symbolic operations can be casted to char, returning an expression
%    which can not be evaluated from Matlab. This function turns it to
%    an evaluable form.
%
%    Examples:
%
%        syms x y z s
%        s=[x + y.^2,y]
%
%            s =
%
%                [ x+y^2,     y]
%
%        char(s)
%
%            ans =
%
%                array([[x+y^2,y]])
%
%        strexchange(ans)
%
%            ans =
%
%                [x+y.^2,y]
%
%    See also ...
%
%    References: ...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/private/strexchange.m
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

la = length(a);
b = '[';
level = 0;

if length(a) >= 7
  if (a(1:7) == 'array([')
    range = [8 2];
    %modification for matlab version 7
  elseif (a(1:8) == 'matrix([')
    range = [9 2];
    % fin modificacion
  else
    range = [1 0];
  end
else
  range = [1 0];
end

for ii = range(1):la-range(2)
  switch a(ii)
    case '*'
      b = [b '.*'];
    case '/'
      b = [b './'];
    case '^'
      b = [b '.^'];
    case '['
      level = level+1;
      %      b=[b '['];
    case ']'
      level = level-1;
      %      b=[b ']'];
    case ','
      switch level
        case 0
          b = [b ';'];
        case 1
          b = [b ','];
        otherwise
          error('Internal error!');
      end
    otherwise
      b = [b a(ii)];
  end
end
b = [b ']'];

% vim: ts=2:sw=2:et
