// $Revision: 1.1.8.2 $
// Copyright 1993-2007 The MathWorks, Inc.

#ifndef _ENTROPYFILTMEX_H
#define _ENTROPYFILTMEX_H

#include "mex.h"
#include <math.h>
#include "neighborhood.h"

class EntropyFilter
{
  private:

    //Member variables
    //////////////////

    const mxArray *fPadImage;
    const mxArray *fPadImageSize;
    const mxArray *fNHood;
          int     fNBins;

    //Template method
    /////////////////////

    //////////////////////////////////////////////////////////////////////////
    //  local_entropy calculates the entropy of a neighborhood 
    //  around every pixel 
    /////////////////////////////////////////////////////////////////////////

    template< typename _T >
        void local_entropy(_T *inBuf, double *outBuf)
        {
            const mwSize      numElements  = mxGetNumberOfElements(fPadImage);
            const mwSize      numPadDims   = mxGetNumberOfDimensions(fPadImage);
            const int         numBins      = fNBins;
            mwSize           *padSize      = (mwSize *) mxMalloc(numPadDims * sizeof(mwSize));
            double           *pr           = (double *) mxGetData(fPadImageSize);

            for (mwSize p = 0; p < numPadDims; p++)
            {
                padSize[p] = (mwSize) pr[p];
            }

            double         entropy;
            double         temp;

            mwSize         numNeighbors;
            mwSize         n;

            Neighborhood_T       nHood;
            NeighborhoodWalker_T walker;

            int             *histCountPtr;
            mwSize           p;
            int              k;

            //Create Walker
            nHood = nhMakeNeighborhood(fNHood, NH_CENTER_MIDDLE_ROUNDDOWN);
            walker = nhMakeNeighborhoodWalker(nHood, padSize, numPadDims,
                                              NH_USE_ALL);
            numNeighbors = nhGetNumNeighbors(walker);

            //Initialize ptr for histogram counts
            histCountPtr = (int *)mxCalloc(numBins,sizeof(numBins));

            //Go to every pixel in the padded image, and get the indices of its
            //neighbors.  Use the indices to calculate the histogram counts and
            //then the entropy of that neighborhood.

            for (p = 0; p < numElements; p++)
            {           
                nhSetWalkerLocation(walker,p);

                // Get Idx into image
                while (nhGetNextInboundsNeighbor(walker, &n, NULL))
                {
                    histCountPtr[(int) inBuf[n]]++;
                }

                // Calculate Entropy based on normalized histogram counts
                // (sum should equal one).
                for (k = 0; k < numBins;k++)
                {
                    if (histCountPtr[k] != 0)
                    {
                        temp = (double) histCountPtr[k] / numNeighbors;
                        
                        // log base 2 (temp) = log(temp) / log(2)
                        entropy = temp * (log(temp)/log((double) 2));
                        outBuf[p] -= entropy;

                        //re-initialize for next neighborhood
                        histCountPtr[k] = 0;
                    }
                }
            }

            // Clean up
            nhDestroyNeighborhood(nHood);
            nhDestroyNeighborhoodWalker(walker);
            mxFree(histCountPtr);
            mxFree(padSize);
        }

 public:

    EntropyFilter();
    
    void setPadImage(const mxArray *padImage);
    void setPadImageSize(const mxArray *padSize);
    void setNHood(const mxArray *nHood);
    void setNBins(const mxArray *numBins);

    mxArray *evaluate(void);
};

#endif
