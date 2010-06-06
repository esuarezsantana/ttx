function ReferenceSystem
%REFERENCE SYSTEM
%    In medicine, the reference system is based on the natural
%    system:
%                      S         where S Superior
%                      |  P            I Inferior
%                      | /
%                      |/              P Posterior
%                R-----o-----L         A Anterior
%                     /|
%                    / |               R Right
%                   A  |               L Left
%                      I
%
%    where medical images are displayed in the next reference
%    systems, independient of the scanning order:
%
%       IS/SI  A           LR/RL  S           AP/PA  S
%              |                  |                  |
%              |                  |                  |
%          R---o---L          A---o---P          R---o---L
%              |                  |                  |
%              |                  |                  |
%              P                  I                  I
%
%            axial             sagital            coronal
%
%    In 2D computation, there are also several coordinate systems:
%
%            o---j              o---i              y
%            |                  |                  |
%            |                  |                  |
%            i                  j                  o---x
%
%      slice/image/matrix        file              space
%
%    On the other hand, in medical computation there appears the
%    next 3D reference systems:
%
%              z                   k                 S
%              |                  /                  |
%              o                 o--j                o
%             / \                |                  / \
%            x   y               i                 R   A
%
%            space              matrix            medical
%
%    where 1st component:       x   i   R
%          2nd component:       y   j   A
%          3rd component:       z   k   S
%
%    In order to simplify this mess, the components of these latter
%    will be equivalent.
%
%    There must a translation between the natural computer reading
%    (i,j,k) and this new convention. In the next picture, 1 and 2
%    are slice components (i,j) and 3 is the slice order (k), in
%    relation with the RAS reference system.
%
%       S                     3                 2        2     2
%       |       2---o        /       3         /        /     /
%       |          /|   2---o        | 2  1---o    3---o     o---3
%       o---A     3 |       |        |/       |        |     |
%      /            1       |    1---o        |        |     |
%     R                     1                 3        1     1
%
%       RAS      L-R      R-L      I-S      S-I      A-P      P-A


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: ReferenceSystem.m
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

help ReferenceSystem

% vim: ts=2:sw=2:et
