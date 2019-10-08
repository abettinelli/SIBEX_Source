
DESCRIPTION:  Reformate image from file
//  arguments:
//          1. Name of image mapping configuration file."
//          2. Name of txt status file
//          3. Name of deformation field configuration file(optional)."
//  if 3 is not available, it is rigid mapping.

// Example:  Reformate  configureMapping.Info status.txt  FieldFile.Info


//Structure of Image mapping Configurature file


D:\\Research\\NonRigid\\3DImageReformate\\TestData\\DoseData    //source data path
Endian = 0                                                      //endian of source data
float                                                           //data type of source data
x_dim = 84        
y_dim = 68  
z_dim = 53                                                      //dimension of source data   
x_pixdim = 0.400000
y_pixdim = 0.400000
z_pixdim = 0.400000                                             //pix resolution of source data      
x_start = -19.332100
y_start = -57.790798
z_start = -7.686500                                             //starting point of source data    
D:\\Research\\NonRigid\\3DImageReformate\\TestData\\DoseOut     //target data path  
Endian = 1                                                      //endian of target data   
unsigned short                                                  //data type of target data
x_dim = 84                  
y_dim = 68
z_dim = 40                                                      //dimension of target data
x_pixdim = 0.2500000
y_pixdim = 0.2500000
z_pixdim = 0.200000                                             //pix resolution of target data 
x_start = -19.332100
y_start = -57.790798
z_start = -27.686500                                            //starting point of target data  
thetax = 10
thetay = 10
thetaz = 5                                                      //degree of rotations                             
transx = 10
transy = 10
transz = 10                                                     //translation   

















