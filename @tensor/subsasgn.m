function [Tf] = subsasgn(Tf,S,in)
%TENSOR/SUBSASGN Subscripted assigment of a tensor field.
%
%    Examples:
%
%        a=tensor(randn([10 10 2 2]),2);
%        a{4}=tensor(zeros([10 10]))
%        a{1,:}=tensor(ones([10 10 2]),2)
%        a{2}=-7;
%        a(1)=eye(2);
%        a(2:end,[3 4])=zeros(2);
%        a([2 3 4],[1 3])=tensor(randn([3 2 2 2]),2);
%        a{1}(end)=3;
%        a.name='hello'
%
%    See also SUBSREF, TENSOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/subsasgn.m
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

switch length(S)
  case 1
    switch (S.type)
      case '{}'
        in=tensor(in,0);
        fdim_out  = rawfielddim(Tf);
        fdim_in   = rawfielddim(in);
        fsize_out = rawfieldsize(Tf);
        fsize_in  = rawfieldsize(in);
        tdim_out  = tensordim(Tf);
        tdim_in   = tensordim(in);
        tsize_out = tensorsize(Tf);
        tsize_in  = tensorsize(in);

        t_subs = S.subs;
        f_subs = repmat({':'},[1 fdim_out]);
        lts = length(t_subs);

        for ii = 1:lts
          if (isempty(t_subs{ii}))
            Tf = tensor;
            return;
          end
        end

        switch lts
          case tdim_out % local indexing
            subs = cat(2,f_subs,t_subs);
            switch fdim_in
              case fdim_out
                % one to all copy
                Tf.data(subs{:}) = in.data;
              case 0
                % one to all copy
                % fdim_out~=0
                for ii = 1:lts;
                  if (ischar(t_subs{ii}) & isequal(t_subs{ii},':'))
                    subsetsize(1,ii)=tdim_out(ii);
                  else
                    subsetsize(1,ii)=length(t_subs{ii});
                  end
                end
                in.data = repmat(in.data(:).', ...
                  [prod(fsize_out) prod(subsetsize)]);
                in.data = reshape(in.data,[fsize_out subsetsize]);
                Tf.data(subs{:}) = in.data;
              otherwise
                error('Invalid number of field dimensions.');
            end

          case 1        %global indexing and zerodim tensor
            %only vector argument is allowed in S.subs
            Tf.data = reshape(Tf.data, ...
              [prod(fsize_out) prod(tsize_out)]);
            in.data = reshape(in.data, ...
              [prod(fsize_in) prod(tsize_in)]);
            switch (fdim_in)
              case fdim_out
                Tf.data(:,t_subs{1}) = in.data;
              case 0
                in.data = repmat(in.data,[prod(fsize_in) 1]);
                Tf.data(:,t_subs{1}) = in.data;
              otherwise
                ('Invalid number of field dimensions.');
            end
            Tf.data = reshape(Tf.data,[fsize_out tsize_out]);
          otherwise
            error('Invalid number of tensor subscripts');
        end

      case '()'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This is the Matlab array () selection chart for ASSIGNMENT
        %
        %  array dim = 1
        %
        %    one argument    INPUT                     OUTPUT
        %
        %       empty       scalar,[]                 same
        %
        %       nonempty    []                        selection as ind
        %                                             (reduces!)
        %
        %       nonempty    scalar, same prod(size)   selection as ind
        %
        %    more arguments
        %
        %       makes expansion !?!
        %
        %  array dim > 1
        %
        %    one argument
        %
        %       empty       scalar,[]                 same
        %
        %       nonempty    []                        row, (ind reduced)
        %
        %       nonempty    scalar, same prod(size)   selection as ind
        %
        %    number of arguments as field size
        %
        %       each one is treated as a vector, selection as sub
        %
        %    other number of arguments
        %
        %       expansion/others as one
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        in = tensor(in,0);
        fdim_out  = rawfielddim(Tf);
        fdim_in   = rawfielddim(in);
        fsize_out = rawfieldsize(Tf);
        fsize_in  = rawfieldsize(in);
        tdim_out  = tensordim(Tf);
        tdim_in   = tensordim(in);
        tsize_out = tensorsize(Tf);
        tsize_in  = tensorsize(in);

        f_subs = S.subs;
        t_subs = repmat({':'},[1 tdim_out]);
        lfs    = length(S.subs);
        subs   = cat(2,f_subs,t_subs);

        for ii = 1:lfs
          if (isempty(f_subs{ii}))
            %Tf=tensor;
            %just not to modify it.
            return;
          end
        end

        if (fdim_in==0 & fdim_out==lfs) % one to all copy
          % fdim_out~=0
          for ii = 1:lfs
            if (ischar(f_subs{ii}) & isequal(f_subs{ii},':'))
              subsetsize(1,ii)=fsize_out(ii);
            else
              subsetsize(1,ii)=length(f_subs{ii});
            end
          end
          in.data = repmat(in.data(:).',[prod(subsetsize) 1]);
          if ( tdim_out ~= 0 )
            in.data = reshape(in.data,[subsetsize tsize_out]);
          elseif (length(subsetsize)~=1) %dim of subsetsize can be 1
            in.data = reshape(in.data,subsetsize);
          end
          Tf.data(subs{:}) = in.data;

        elseif ((fdim_out == lfs) & (fdim_in <= fdim_out))
          % One to one copy
          Tf.data(subs{:}) = in.data;

        elseif (lfs==1)  % sparse assignment; only vector allowed
          if (ischar(f_subs{1}) & f_subs{1}==':')
            subindex = [1:prod(fsize_out)].';
            rsize = [prod(fsize_out) 1];
          else
            subindex = f_subs{1};
            rsize = length(subindex);
          end
          Tf.data = reshape(Tf.data, ...
            [prod(fsize_out) prod(tsize_out)]);
          switch fdim_in
            case 1
              if (prod(fsize_in)~=rsize(1))
                error('Different number of elements');
              end
              in.data = reshape(in.data, ...
                [prod(fsize_in) prod(tsize_in)]);
            case 0
              in.data = repmat(in.data(:).',[rsize(1) 1]);
            otherwise
              error('Invalid assignment.');
          end
          Tf.data(subindex,:) = in.data;
          Tf.data = reshape(Tf.data, [fsize_out tsize_out]);
        else
          error('Invalid assignment');
        end

      case '.'
        switch S.subs
          case 'name'
            Tf.name = in;
          case 'longdisplay'
            Tf.longdisplay = in;
          case 'sample'
            Tf.sample = in;
          otherwise
            error('No such field defined.');
        end
      otherwise
        error('Invalid subsassignment');
    end

  case 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     {}()
    if (isequal(S(1).type,'.') & isequal(S(1).subs,'mem'))
      switch S(2).subs
        case 'storeasuint16'
          Tf.mem.storeasuint16 = in;
        case 'tmpbackup_not_allowed'
          Tf.mem.tmpbackup_not_allowed = in;
        case 'filename'
          Tf.mem.filename = in;
        otherwise
          error('No such field defined.');
      end
      return;
    end

    if (~isequal(S(1).type,'{}') | ~isequal(S(2).type,'()'))
      error('Invalid subsassignment');
    end
    aux = subsasgn(Tf,S(1),in);
    Tf  = subsasgn(Tf,S(2),subsref(aux,S(2))); %wonderful!!!
  otherwise
    error('Invalid subsassignment');
end

% vim: ts=2:sw=2:et
