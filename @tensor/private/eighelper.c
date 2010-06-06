/***********************************************************************
 *
 *  This file comes with the ttx tensor toolbox
 *
 *  Module: @tensor/private/eighelper.c
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
 *  Copyright (C) 2001 Einer Heiberg
 *
 */

/* Helper function to eig.m */

/* OBS should be compiled with: */
/* mex eighelper.c */

#include <math.h>
#include <float.h>
#include "mex.h"

void calceig(double *eigenvalue_real_ptr,
      double *eigenvalue_imag_ptr,
      double *eigenvector_real_ptr,
      double *eigenvector_imag_ptr,
      double *ndarray_real_ptr,
      double *ndarray_imag_ptr,
      int tensorloop,
      int tensorsize,
      int numtensors)
{
   double  *tensor_real_ptr;
   double  *tensor_imag_ptr;
   double  *temp_eigenvalue_real_ptr;
   double  *temp_eigenvalue_imag_ptr;
   double  *temp_eigenvector_real_ptr;
   double  *temp_eigenvector_imag_ptr;

   int      loop;
   int      pos;

   mxArray *tensor_mxptr;
   mxArray *lhs1_mxptr;
   mxArray *lhs2_mxptr[2];

   /* create matlab representation of tensor */
   if (ndarray_imag_ptr==NULL)
   {
      /* create real matrix */
      tensor_mxptr = mxCreateDoubleMatrix(
            tensorsize, tensorsize, mxREAL);

      tensor_real_ptr = mxGetPr(tensor_mxptr);
   }

   else
   {
      /* create complex matrix */
      tensor_mxptr = mxCreateDoubleMatrix(
            tensorsize, tensorsize, mxCOMPLEX);

      tensor_real_ptr = mxGetPr(tensor_mxptr);
      tensor_imag_ptr = mxGetPi(tensor_mxptr);
   }

   /* copy tensor */
   pos = tensorloop;
   for (loop=0; loop<(tensorsize*tensorsize); loop++)
   {
      tensor_real_ptr[loop] = ndarray_real_ptr[pos];
      pos = pos + numtensors;
   }

   if (ndarray_imag_ptr!=NULL)
   {
      /* copy also imaginary part */
      pos = tensorloop;

      for (loop=0; loop<(tensorsize*tensorsize); loop++)
      {
         tensor_imag_ptr[loop] = ndarray_imag_ptr[pos];
         pos = pos + numtensors;
      }
   }

   if (eigenvector_real_ptr==NULL)
   {
      /* just calculate eigenvalues */
      /* call matlab to calc eigenvalues */
      mexCallMATLAB(1, &lhs1_mxptr, 1, &tensor_mxptr, "eig");

      /* store the eigenvalues */
      /* get pointers to result */
      temp_eigenvalue_real_ptr = mxGetPr(lhs1_mxptr);
      pos = tensorloop;

      for (loop=0 ; loop<tensorsize ; loop++)
      {
         eigenvalue_real_ptr[pos] = temp_eigenvalue_real_ptr[loop];
         pos = pos+numtensors;
      }

      if (mxIsComplex(lhs1_mxptr))
      {
         /* copy also imaginary part */
         /* get pointers to result */
         temp_eigenvalue_imag_ptr = mxGetPi(lhs1_mxptr);
         pos = tensorloop;

         for (loop=0 ; loop<tensorsize ; loop++)
         {
            eigenvalue_imag_ptr[pos] = temp_eigenvalue_imag_ptr[loop];
            pos = pos+numtensors;
         }
      }
   }

   else
   {
      /* calculate both eigenvalue and eigenvectors */
      /* call matlab to calc eigenvalues */
      mexCallMATLAB(2, lhs2_mxptr, 1, &tensor_mxptr, "eig");

      /* store eigenvalues */
      pos = tensorloop;
      /* get pointers to result */
      temp_eigenvalue_real_ptr = mxGetPr(lhs2_mxptr[1]);

      for (loop=0;
            loop<(tensorsize*tensorsize);
            loop=loop+tensorsize+1)
      {
         /* note that eigenvalues are stored
          * in the diagonal elements */
         eigenvalue_real_ptr[pos] = temp_eigenvalue_real_ptr[loop];
         pos = pos+numtensors;
      }

      if (mxIsComplex(lhs2_mxptr[1]))
      {
         /* copy also imaginary part */
         pos = tensorloop;
         /* get pointers to result */
         temp_eigenvalue_imag_ptr = mxGetPi(lhs2_mxptr[1]);

         for (loop=0;
               loop<(tensorsize*tensorsize);
               loop=loop+tensorsize+1)
         {
            /* note that eigenvalues are stored
             * in the diagonal elements */
            eigenvalue_imag_ptr[pos] = temp_eigenvalue_imag_ptr[loop];
            pos = pos+numtensors;
         }
      }
      /* store eigenvectors */
      pos = tensorloop;
      /* get pointers to result */
      temp_eigenvector_real_ptr = mxGetPr(lhs2_mxptr[0]);

      for (loop=0;loop<(tensorsize*tensorsize);loop++)
      {
         eigenvector_real_ptr[pos] = temp_eigenvector_real_ptr[loop];
         pos = pos+numtensors;
      }

      if (mxIsComplex(lhs2_mxptr[0]))
      {
         /* copy also imaginary part */
         pos = tensorloop;
         /* get pointers to result */
         temp_eigenvector_imag_ptr = mxGetPi(lhs2_mxptr[0]);

         for (loop=0;loop<(tensorsize*tensorsize);loop++)
         {
            eigenvector_imag_ptr[pos] = temp_eigenvector_imag_ptr[loop];
            pos = pos+numtensors;
         }
      }
   }
}


/* mexFunction is the main function for the MEX-file. */
/* ---------------------------------------------------*/
void mexFunction( int nlhs, mxArray *plhs[],
      int nrhs, const mxArray *prhs[] )
{
   const int *dimensions_ptr; /* dimensions */

   int        eigenvalue_dims_ptr[10];
   int        tensorsize;
   int        numtensors;
   int        numelements;
   int        pos;
   int        dims;
   int        loop;
   int        tensorloop;
   double    *ndarray_real_ptr;
   double    *ndarray_imag_ptr;
   double    *eigenvalue_real_ptr;
   double    *eigenvalue_imag_ptr;
   double    *eigenvector_real_ptr;
   double    *eigenvector_imag_ptr;

   mxArray *ndarray_mxptr;
   mxArray *eigenvalue_mxptr;
   mxArray *eigenvector_mxptr;

   /* check number of input arguments */
   if (nrhs==0)
   {
      printf("See tensor/eig.m for help.\n");
      return;
   }

   if (!(nrhs==1))
   {
      printf("Error: eighelper requires one input arguments.\n");
      return;
   }

   /* check input argument type */
   ndarray_mxptr = (mxArray *)prhs[0];
   ndarray_real_ptr = mxGetPr(ndarray_mxptr);
   if (mxIsComplex(ndarray_mxptr))
   {
      /* complex input data */
      ndarray_imag_ptr = mxGetPi(ndarray_mxptr);
   }
   else
      /* call with null pointer to mark non-complex */
      ndarray_imag_ptr = NULL;

   if (mxIsDouble(ndarray_mxptr)==0)
   {
      printf("Error: First input argument should be double.\n");
      return;
   }

   /* get number of dimensions */
   dims = mxGetNumberOfDimensions(ndarray_mxptr);   /* num of */
   dimensions_ptr = mxGetDimensions(ndarray_mxptr); /* size in each */

   /* last dim is equal to tensor size */
   tensorsize = dimensions_ptr[dims-1];

   if (dims<2)
   {
      printf("Error: First input argument should be a N-D array.\n");
      return;
   }

   if (dims>=10)
   {
      printf("Error: To many dimensions.\n");
      return;
   }

   /* find out the number of elements and tensors */
   numelements = mxGetNumberOfElements(ndarray_mxptr);
   numtensors = (numelements/(tensorsize*tensorsize));

   /* check out the number of left hand arguments */
   if (nlhs>2)
   {
      printf("To many output arguments.\n");
      return;
   }

   if (nlhs<=0)
   {
      printf("To few output arguments.\n");
      return;
   }

   if (nlhs>=1)
   {
      /* create output argument */
      for (loop=0; loop<dims; loop++)
      {
         eigenvalue_dims_ptr[loop] = dimensions_ptr[loop];
      }

      eigenvalue_dims_ptr[dims-1] = tensorsize;
      eigenvalue_mxptr = mxCreateNumericArray(
            dims-1, eigenvalue_dims_ptr, mxDOUBLE_CLASS, mxCOMPLEX);

      eigenvalue_real_ptr = mxGetPr(eigenvalue_mxptr);
      eigenvalue_imag_ptr = mxGetPi(eigenvalue_mxptr);
      plhs[0] = eigenvalue_mxptr;
      /* note, an complex array is always returned */
   }

   if (nlhs>=2)
   {
      /* create output argument */
      eigenvector_mxptr = mxCreateNumericArray(
            dims, dimensions_ptr, mxDOUBLE_CLASS, mxCOMPLEX);

      eigenvector_real_ptr = mxGetPr(eigenvector_mxptr);
      eigenvector_imag_ptr = mxGetPi(eigenvector_mxptr);
      plhs[1] = eigenvector_mxptr;
   }
   else
   {
      /* call with NULL pointer to mark that should not be saved. */
      eigenvector_real_ptr = NULL;
      /* call with NULL pointer to mark that should not be saved. */
      eigenvector_imag_ptr = NULL;
   }

   /* loop over tensors */
   for (tensorloop = 0; tensorloop<numtensors; tensorloop++)
   {
      calceig(eigenvalue_real_ptr,
            eigenvalue_imag_ptr,
            eigenvector_real_ptr,
            eigenvector_imag_ptr,
            ndarray_real_ptr,
            ndarray_imag_ptr,
            tensorloop,
            tensorsize,
            numtensors);
   }

   /* end of main function */
}

/* vim: set ts=3 sw=3 et: */
