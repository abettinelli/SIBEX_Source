function metadata = dicom_prep_metadata(IOD_UID, metadata, X, map, txfr)
%DICOM_PREP_METADATA  Set the necessary metadata values for this IOD.
%   METADATA = DICOM_PREP_METADATA(UID, METADATA, X, MAP, TXFR) sets all
%   of the type 1 and type 2 metadata derivable from the image (e.g. bit
%   depths) or that must be unique (e.g. UIDs).  This function also
%   builds the image pixel data.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/12/18 07:36:02 $

switch (IOD_UID)
case '1.2.840.10008.5.1.4.1.1.2'
    metadata(1).(dicom_name_lookup('0008', '0060')) = 'CT';

    metadata = My_dicom_prep_ImagePixel(metadata, X, map, txfr);
    metadata = My_dicom_prep_FrameOfReference(metadata);
    metadata = My_dicom_prep_SOPCommon(metadata, IOD_UID);
    metadata = My_dicom_prep_FileMetadata(metadata, IOD_UID, txfr);
    metadata = My_dicom_prep_GeneralStudy(metadata);
    metadata = My_dicom_prep_GeneralSeries(metadata);
    metadata = My_dicom_prep_GeneralImage(metadata);
    
case '1.2.840.10008.5.1.4.1.1.4'
    metadata(1).(dicom_name_lookup('0008', '0060')) = 'MR';

    metadata = My_dicom_prep_ImagePixel(metadata, X, map, txfr);
    metadata = My_dicom_prep_FrameOfReference(metadata);
    metadata = My_dicom_prep_SOPCommon(metadata, IOD_UID);
    metadata = My_dicom_prep_FileMetadata(metadata, IOD_UID, txfr);
    metadata = My_dicom_prep_GeneralStudy(metadata);
    metadata = My_dicom_prep_GeneralSeries(metadata);
    metadata = My_dicom_prep_GeneralImage(metadata);
    
case '1.2.840.10008.5.1.4.1.1.7'
    name = dicom_name_lookup('0008', '0060');
    if (~isfield(metadata, name))
        metadata(1).(name) = 'OT';
    end
    
    metadata = My_dicom_prep_ImagePixel(metadata, X, map, txfr);
    metadata = My_dicom_prep_FrameOfReference(metadata);
    metadata = My_dicom_prep_SOPCommon(metadata, IOD_UID);
    metadata = My_dicom_prep_FileMetadata(metadata, IOD_UID, txfr);
    metadata = My_dicom_prep_GeneralStudy(metadata);
    metadata = My_dicom_prep_GeneralSeries(metadata);
    metadata = My_dicom_prep_GeneralImage(metadata);
    metadata = My_dicom_prep_SCImageEquipment(metadata);
    
otherwise
    
    % Unsupported SOP Class in verification mode.  Display a message.
    if (desktop('-inuse'))
        docRef = '<a href="matlab:doc(''dicomwrite'')">help dicomwrite</a>';
    else
        docRef = 'help dicomwrite';
    end
                     
    msg = sprintf('%s\n%s\n%s', ...
                'Unsupported SOP class (%s) in full verification mode.', ...
                'Consider using ''CreateMode'' with a value of ''Copy''.', ...
                ['Type ' docRef ' for more details.']);
    error('Images:dicom_prep_metadata:unsupportedClass', msg, IOD_UID)
    
end
