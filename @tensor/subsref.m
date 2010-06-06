function [out] = subsref(Tf,S)
%TENSOR/SUBSREF Subscripted reference of a tensor field.
%
%    Examples:
%
%        a=tensor(randn([10 10 2 2]),2);
%        a{[]}, a{1,[]}, a{1,2}, a{4}, a{:,2} %'end' not allowed for {}
%        b=1:9; b=reshape(b,[3 3]);
%        a([]), a(1,[]), a([1 3 4],5:end), a(:,2), a(b), a(:)
%        a{4}(b)
%        a.name
%
%     See also TENSOR/SUBSASGN, TENSOR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This file comes with the ttx tensor toolbox
%
%   Module: @tensor/subsref.m
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
%   Copyright (C) 2001 Dan Fox, C.-F. Westin
%

switch length(S)
  case 1
    switch S.type
      case '{}'

        fdim   = fielddim(Tf);
        tdim   = tensordim(Tf);
        t_subs = S.subs;
        f_subs = repmat({':'},[1 fdim]);
        lts    = length(t_subs);

        for ii = 1:lts
          if (isempty(t_subs{ii}))
            out = tensor;
            return;
          end
        end

        switch lts
          %read text at end of file
          case tdim
            subs = cat(2,f_subs,t_subs);
            out  = tensor(Tf.data(subs{:}),fdim);
          case 1
            if (isempty(f_subs{1}))
              out = tensor;
            elseif (isempty(Tf.dimension)) %empty tensor
              error('Not allowed to subsref an empty tensor');
            else
              fsize = rawfieldsize(Tf); tsize=tensorsize(Tf);
              [isize,idims] = arraysize(t_subs{:});
              indexs  = reshape(t_subs{:},[1 prod(isize)]);
              Tf.data = reshape(Tf.data,[prod(fsize) prod(tsize)]);
              out = tensor( ...
                reshape(Tf.data(:,indexs),[fsize isize]),fdim);
            end
          otherwise
            error('dimension mismatch');
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%()
      case '()'
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % This is the Matlab array () selection chart:
        %  array dim = 1
        %    one argument
        %       empty     -> empty
        %       column    -> shape as array, selection as ind
        %       row       -> shape as array, selection as ind
        %       another   -> shape as reference, selection as ind
        %       colon     -> column shape, all selection
        %    more arguments
        %       makes no sense
        %  array dim > 1
        %    one argument
        %       empty     -> empty
        %       column    -> column shape, selection as ind
        %       row       -> row shape, selection as ind
        %       another   -> shape as reference, selection as ind
        %       colon     -> column shape, all selection
        %    number of arguments as field size
        %       each one is treated as a vector, selection as sub
        %    other number of arguments
        %       make no sense
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fdim   = fielddim(Tf);
        tdim   = tensordim(Tf);
        f_subs = S.subs;
        t_subs = repmat({':'},[1 tdim]);
        lfs    = length(f_subs);
        for ii = 1:lfs
          if (isempty(f_subs{ii}))
            out = tensor;
            return;
          end
        end

        switch lfs

          case fdim
            %add necessary colons
            subs = cat(2,f_subs,t_subs);
            out  = tensor(Tf.data(subs{:}),fdim);

            %and what about if the field size is [ ... 1 1 1 ]?
            out_fsize = fieldsize(out);
            out_fdim  = fielddim(out);
            while (out_fsize(end)==1 & length(out_fsize)>1 )
              %this would be bad if we had to do it many times
              out_fsize = out_fsize(1:end-1);
              out_fdim  = out_fdim-1;
            end
            if isequal(out_fsize,1)
              out.datasize     = tensorsize(out);
              out.dimension(1) = 0;
            else
              out.datasize     = [out_fsize tensorsize(out)];
              out.dimension(1) = out_fdim;
            end
            %add 1 just in case
            out.data=reshape(out.data,[out.datasize 1]);

          case 1
            if (isempty(f_subs{1})) % to allow a([])
              out = tensor;
            elseif (isempty(Tf.dimension))
              %we don't allow subsref empty tensors. Same as Matlab
              error('Not allowed to subsref an empty tensor');
            elseif (ischar(f_subs{1}) & isequal(f_subs{1},':'))
              tsize = tensorsize(Tf);
              fsize = rawfieldsize(Tf);
              if (isequal(fsize,1));
                out = tensor(reshape(Tf.data,[tsize 1]),0);
              else
                out = tensor(reshape(Tf.data,[prod(fsize) tsize]),1);
              end
            else
              fsize = rawfieldsize(Tf);
              tsize = tensorsize(Tf);
              [isize,idims] = arraysize(f_subs{:});  %i for index
              indexs  = reshape(f_subs{:},[1 prod(isize)]);
              Tf.data = reshape(Tf.data,[prod(fsize) prod(tsize)]);
              if (idims==0)
                out = tensor(reshape(Tf.data(indexs,:),[tsize 1]),0);
              else
                out = tensor( ...
                  reshape(Tf.data(indexs,:),[isize tsize]),idims);
              end
            end

          otherwise
            error('Invalid number of subscripting elements.');
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% .
      case '.'
        lenstruct = length(S);
        % NOTE: all are now referenced
        % in lower case (non-case specificity)
        switch lower(S.subs)
          % data members
          case 'data'
            %empty? allowed for inheritance to work
            out = Tf.data;
          case 'name'
            out = Tf.name;
          case 'longdisplay'
            out = Tf.longdisplay;
          case 'dimension'
            out = Tf.dimension;
          case 'version'
            out = Tf.version;
          otherwise
            error('No such field defined.');
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      otherwise
        error('Subscripting error.');
    end

  case 2
    if (isequal(S(1).type,'.') & isequal(S(1).subs,'mem'))
      switch S(2).subs
        case 'storeasuint16'
          out = Tf.mem.storeasuint16;
        case 'tmpbackup_not_allowed'
          out = Tf.mem.tmpbackup_not_allowed;
        case 'filename'
          out = Tf.mem.filename;
        case 'already_on_disk'
          out = Tf.mem.already_on_disk;
        otherwise
          error('No such field defined.');
      end
      return;
    end

    if (~isequal(S(1).type,'{}') | ~isequal(S(2).type,'()'))
      error('Invalid subsassignment');
    end
    out = subsref(Tf,S(1));
    out = subsref(out,S(2));

  otherwise
    error('Too many subscrits');
end

% vim: ts=2:sw=2:et
