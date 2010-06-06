/***********************************************************************
 *
 *  This file comes with the ttx tensor toolbox
 *
 *  Module: @tensor/private/fastmldivide.c
 *
 *  ttx tensor toolbox is free software: you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or any later version.
 *
 *  ttx tensor toolbox is distributed in the hope that it will be
 *  useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 *  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with ttx tensor toolbox.  If not, see
 *  <http://www.gnu.org/licenses/>.
 *
 *  Copyright (C) 2001 Einar Heiberg
 *
 *  Copyright (C) 2001 Eduardo Suarez-Santana
 *                     http://e.suarezsantana.com/
 *
 */

#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[],
      int nrhs, const mxArray *prhs[] )
{
   /************************************* variables */

   /* Ax=b */
   /* input arguments */
   int *repeat;              /* prhs[0]; see repeat table below; */
   double *matrixsize;       /* prhs[1]; */
   double *dreturnfieldsize; /* prhs[2]; */
   double *Amatrixarray;     /* prhs[3]; */
   double *bvectorarray;     /* prhs[4]; */

   /* InputData dimensions */
   int *ireturnfieldsize;
   int matrixdim,nrows,ncols;
   int fielddim;
   int *A_size, *b_size;
   int fieldelems=1,matrixelems; /* totalfieldsize */

   /* output arguments */
   mxArray *xOutput;    /* plhs[0]; */
   double *xvectorarray;

   /* auxiliar variables */
   int i,j;       /* dummy indices */
   double *matrix;
   double *vector;
   int *moffset, *voffset;
   int *pivot;    /* pivot of the lapack function */
   int nles=1;    /* number of linear equation systems to solve */
   int status;

   /************************************** arguments parsing */

   if (nrhs==0)
   {
      printf("See tensor/mldivide.m for help.\n");
      return;
   }

   if (nrhs!=5)
   {
      printf("Error: fastmldivide requires four input arguments.\n");
      return;
   }

   /* let's suppose everything is right */
   /* at the moment, it will only work with real values */

   /* arg 0 */
   repeat = (int *)mxGetPr(prhs[0]);
   /*
      repeat 0: A and b has the same tensor field  -> move around both
      repeat 1: A is a tensor and b a tensor field -> "repeat" A
      repeat 2: A is a tensor field and b a tensor -> "repeat" b
      */

   /* arg 1 */
   matrixdim  = mxGetNumberOfElements(prhs[1]);
   /* let's assume matrixdim = 1 */

   matrixsize  = mxGetPr(prhs[1]);
   nrows       = (int)matrixsize[0];
   ncols       = nrows;
   matrixelems = nrows*ncols;
   pivot       = (int *)mxCalloc(nrows,sizeof(int));

   /* arg 2 */
   fielddim         = mxGetNumberOfElements(prhs[2]);
   dreturnfieldsize = mxGetPr(prhs[2]);
   ireturnfieldsize = (int *)mxCalloc(fielddim+1,sizeof(int));

   /* turn it into integer */
   for(i=0; i<fielddim; i++)
   {
      ireturnfieldsize[i]=(int)dreturnfieldsize[i];
      fieldelems*=ireturnfieldsize[i];
   }
   ireturnfieldsize[fielddim]=nrows; /* to create the array */

   /* arg 3 & 4 */
   Amatrixarray=mxGetPr(prhs[3]);
   bvectorarray=mxGetPr(prhs[4]);

   /* output argument */
   xOutput = mxCreateNumericArray(
         fielddim+1,ireturnfieldsize,mxDOUBLE_CLASS,mxREAL);

   xvectorarray = mxGetPr(xOutput);

   /* auxiliary variables initialization */
   matrix = (double *)mxCalloc(matrixelems,sizeof(double));
   vector = (double *)mxCalloc(nrows      ,sizeof(double));

   /********************************************** task */

   switch ((int)(repeat[0]))
   {
      case 0: /* A and b same size*/
         /* compute the matrix offsets and vector offsets */
         moffset = (int *)mxCalloc(matrixelems,sizeof(int));
         voffset = (int *)mxCalloc(nrows      ,sizeof(int));

         for(j=0; j<matrixelems; j++)
            moffset[j]=j*fieldelems;

         for(j=0; j<nrows; j++)
            voffset[j]=j*fieldelems;

         /* we run through field size */
         for(i=0; i<fieldelems; i++)
         {
            /* build the fortran matrix */
            for(j=0;j<matrixelems;j++)
               matrix[j]=Amatrixarray[moffset[j]++];

            /* build the fortran vector */
            for(j=0;j<nrows;j++)
               vector[j]=bvectorarray[voffset[j]];

            /* solve the linear equations */
            dgesv_(&nrows, &nles, matrix, &nrows,
                  pivot, vector, &nrows, &status);

            /* allocate result */
            for(j=0;j<nrows;j++)
               xvectorarray[voffset[j]++]=vector[j];
         }
         mxFree(moffset);
         mxFree(voffset);
         break;
      case 1: /* A stays quiet */
         /* compute the vector offsets */
         voffset = (int *)mxCalloc(nrows,sizeof(int));
         for(j=0; j<nrows; j++)
            voffset[j]=j*fieldelems;

         /* we run through field size */
         for(i=0; i<fieldelems; i++)
         {
            /* build the fortran matrix */
            for(j=0;j<matrixelems;j++)
               matrix[j]=Amatrixarray[j];

            /* build the fortran vector */
            for(j=0;j<nrows;j++)
               vector[j]=bvectorarray[voffset[j]];

            /* solve the linear equations */
            dgesv_(&nrows, &nles, matrix, &nrows,
                  pivot, vector, &nrows, &status);

            /* allocate result */
            for(j=0;j<nrows;j++)
               xvectorarray[voffset[j]++]=vector[j];
         }
         mxFree(voffset);
         break;

      case 2: /* b stays quiet */
         /* compute the matrix offsets and vector offsets */
         moffset = (int *)mxCalloc(matrixelems,sizeof(int));
         voffset = (int *)mxCalloc(nrows      ,sizeof(int));

         for(j=0; j<matrixelems; j++)
            moffset[j]=j*fieldelems;

         for(j=0; j<nrows; j++)
            voffset[j]=j*fieldelems;

         /* we run through field size */
         for(i=0; i<fieldelems; i++)
         {
            /* build the fortran matrix */
            for(j=0;j<matrixelems;j++)
               matrix[j]=Amatrixarray[moffset[j]++];

            /* build the fortran vector */
            for(j=0;j<nrows;j++)
               vector[j]=bvectorarray[j];

            /* solve the linear equations */
            dgesv_(&nrows, &nles, matrix, &nrows,
                  pivot, vector, &nrows, &status);

            /* allocate result */
            for(j=0;j<nrows;j++)
               xvectorarray[voffset[j]++]=vector[j];
         }
         mxFree(moffset);
         mxFree(voffset);
         break;
   }

   plhs[0] = xOutput;
   nlhs    = 1;

   mxFree(ireturnfieldsize);
   mxFree(matrix);
   mxFree(vector);
   mxFree(pivot);
}

/* vim: set ts=3 sw=3 et: */
