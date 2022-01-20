function SUV_BW_factor = GetSUVScaleFactor(info)
% 
% Determines dose for normalising the SUV counts
% :return: SUV body weight
%

% Check whether required settings are provided
if ~isfield(info.RadiopharmaceuticalInformationSequence.Item_1, 'RadionuclideTotalDose')
    warning('Radionuclide total dose (0x0018, 0x1074) was not specified in the Radiopharmaceutical information sequence (0x0054, 0x0016).')
    SUV_BW_factor = NaN;
    return
end

switch info.DecayCorrection
    case {'NONE', 'START'}
        
        if ~isfield(info, 'ActualFrameDuration')
            warning('ActualFrameDuration (0018,1242) is not known.')
            SUV_BW_factor = NaN;
            return
        end
        
        if ~isfield(info, 'AcquisitionDate') || ~isfield(info, 'AcquisitionTime')
            warning('Acquisition date (0008,0022) and time (0008,0032) are not known.')
            SUV_BW_factor = NaN;
            return
        end
        
        if ~isfield(info.RadiopharmaceuticalInformationSequence.Item_1, 'RadiopharmaceuticalStartTime')
            warning('Time of radionucleitide injection (0018,1072) is not known.')
            SUV_BW_factor = NaN;
            return
        end
        
        if ~isfield(info.RadiopharmaceuticalInformationSequence.Item_1, 'RadionuclideHalfLife')
            warning('Radionucleitide half-life (0018,1075) in the Radiopharmaceutical information sequence (0x0054, 0x0016) is not known.')
            SUV_BW_factor = NaN;
            return
        end
end

switch info.DecayCorrection
    case 'START'
        if ~isfield(info, 'FrameReferenceTime')
            warning('Frame reference time (0054,1300) is not known.')
            SUV_BW_factor = NaN;
            return
        end
end

% Parametri
try
    p_FrameDuration     = info.ActualFrameDuration/1000;
    p_RefTime           = info.FrameReferenceTime/1000;
    
    p_Weight            = info.PatientWeight;    
    p_TotalDose         = info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideTotalDose;
    p_HalfLife          = info.RadiopharmaceuticalInformationSequence.Item_1.RadionuclideHalfLife;
    
    p_StartTime         = date2sec(info.RadiopharmaceuticalInformationSequence.Item_1.RadiopharmaceuticalStartTime);
    p_AcquisitionTime   = date2sec(info.AcquisitionTime);
    p_SeriesTime        = date2sec(info.SeriesTime);
catch
    SUV_BW_factor = p_TotalDose;
    return;
end

% Process for different decay corrections
switch info.DecayCorrection

    case 'START'
        % Decay correction of pixel values for the period from pixel acquisition up to scan start
        % Additionally correct for decay between administration and acquisition start
        
        % Back compute start reference time from acquisition date and time.
        decay_constant = log(2) / p_HalfLife;
        
        % Compute decay during frame. Note that frame duration is converted from ms to s.
        decay_during_frame = decay_constant * p_FrameDuration;
        
        % Time at which the average count rate is found.
        time_count_average = 1 / decay_constant * log(decay_during_frame / (1-exp(-decay_during_frame)));
        
        % Set reference start time (this may coincide with the series time, but series time may be unreliable).
        reference_start_time = p_AcquisitionTime + (time_count_average - p_RefTime);
        
        decay_factor = power(2, (reference_start_time - p_StartTime) / p_HalfLife);
        decayed_dose = p_TotalDose / decay_factor;
        
    case 'NONE'
        % No decay correction; 
        % Correct for period between administration and acquisition + 1/2 frame duration
        
        frame_center_time = p_AcquisitionTime + round(p_FrameDuration / 2);
        decay_factor = power(2, (frame_center_time - p_StartTime) / p_HalfLife);
        decayed_dose = p_TotalDose / decay_factor;
        
    case 'ADMIN'
        % Decay correction of pixel values for the period from pixel acquisition up to administration
        % No additional correction required
        decayed_dose = p_TotalDose;
        
    otherwise
        warning('Decay correction (0x0054, 0x1102) was not recognized {info.DecayCorrection} and could not be parsed')
        decayed_dose = NaN;
end

% Update decay factor parameter and decay correction
SUV_BW_factor =  decayed_dose / (p_Weight * 1000);
