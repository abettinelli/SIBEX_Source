// Copyright 1993-2007 The MathWorks, Inc.
  
//////////////////////////////////////////////////////////////////////////////
//  Helper MEX-file for ENTROPYFILT.  
//  
//  Inputs:
//  prhs[0] - mxArray - Padded image
//  prhs[1] - int32_T - Size of unpadded image
//  prhs[2] - mxArray - Neighborhood
//  prhs[3] - double  - Number of bins for histogram calculation
//////////////////////////////////////////////////////////////////////////////

#include "UniformityFiltMex.h"
#include "iptutil_cpp.h"

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
mxArray *EntropyFilter::evaluate(void)
{
    mxAssert((fPadImage != NULL), 
             ERR_STRING("Filter::fPadImage","evaluate()"));
    mxAssert((fPadImageSize != NULL), 
             ERR_STRING("EntropyFilter::fNoPadImageSize","evaluate()"));
    mxAssert((fNHood != NULL), 
             ERR_STRING("Filter::fNHood","evaluate()"));
    mxAssert((fNBins != 0), 
             ERR_STRING("Filter::fNBins","evaluate()"));

    // Initialize variables
    void             *In;
    void             *Out;
    mxArray          *outputImage;

    const mxClassID  imageClass      = mxGetClassID(fPadImage);
    const mwSize     nImageDims      = mxGetNumberOfElements(fPadImageSize);
    mwSize          *padImageSize    = (mwSize *) mxMalloc(nImageDims * sizeof(mwSize));
    double          *pr              = (double *) mxGetData(fPadImageSize);

    for (mwSize p = 0; p < nImageDims; p++)
    {
        padImageSize[p] = (mwSize) pr[p];
    }

    outputImage =  mxCreateNumericArray(nImageDims,
                                        padImageSize,
                                        mxDOUBLE_CLASS,
                                        mxREAL);
    mxFree(padImageSize);

    In = mxGetData(fPadImage);    
    Out = mxGetData(outputImage);

    //calculate entropy
    switch (imageClass)
    {
    case mxLOGICAL_CLASS:
        local_entropy((mxLogical *)In, (double *)Out);
        break;
    case mxUINT8_CLASS:
        local_entropy((uint8_T *)In, (double *)Out);
        break;
    default:
        mexErrMsgIdAndTxt("Images:entropyfiltmex:invalidMexInput",
                          "Image should be uint8 or logical.");
        break;
    }

    return(outputImage);
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
EntropyFilter::EntropyFilter()
{
    //Initialize member variables
    fPadImage        = NULL;
    fPadImageSize    = NULL;    
    fNHood           = NULL;
    fNBins           = 0;

}

//////////////////////////////////////////////////////////////////////////////
// padded image
//////////////////////////////////////////////////////////////////////////////
void EntropyFilter::setPadImage(const mxArray *padImage)
{
    fPadImage = padImage;
}

//////////////////////////////////////////////////////////////////////////////
// Size of padded image (int32_T)
//////////////////////////////////////////////////////////////////////////////
void EntropyFilter::setPadImageSize(const mxArray *padSize)
{
    fPadImageSize = padSize;
}

//////////////////////////////////////////////////////////////////////////////
// Full neighborhood 
//////////////////////////////////////////////////////////////////////////////
void EntropyFilter::setNHood(const mxArray *nHood)
{
    fNHood = nHood;
}

//////////////////////////////////////////////////////////////////////////////
// Number of Bins (int)
//////////////////////////////////////////////////////////////////////////////
void EntropyFilter::setNBins(const mxArray *nBins)
{
    fNBins = (int)mxGetScalar(nBins);
}


//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
EntropyFilter entropyFilter;

extern "C"
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    (void) nlhs;  // unused parameter
 
    if (nrhs != 4)
    {
        mexErrMsgIdAndTxt("Images:entropyfiltmex:invalidNumInputs",
                          "%s",
                          "ENTROPYFILTMEX needs 4 input arguments.");
    }

    entropyFilter.setPadImage(prhs[0]);
    entropyFilter.setPadImageSize(prhs[1]);
    entropyFilter.setNHood(prhs[2]);
    entropyFilter.setNBins(prhs[3]);

    //Filter the image
    plhs[0] = entropyFilter.evaluate();
}
