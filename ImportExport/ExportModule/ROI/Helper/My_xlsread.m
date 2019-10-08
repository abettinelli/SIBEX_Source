function rawData=My_xlsread(file,sheet,range,mode,customFun)


% initialise variables
rawData = {};

Sheet1 = 1;

sheet = Sheet1;
range = '';

% handle input values
if nargin < 1 || isempty(file)
    error('MATLAB:xlsread:FileName','Filename must be specified.');
end

if ~ischar(file)
    error('MATLAB:xlsread:InputClass','Filename must be a string.');
end

if nargin > 1
    % Verify class of sheet parameter
    if ~ischar(sheet) && ...
            ~(isnumeric(sheet) && length(sheet)==1 && ...
              floor(sheet)==sheet && sheet >= -1)
        error('MATLAB:xlsread:InputClass',...
            'Sheet argument must a string or an integer.');
    end

    if isequal(sheet,-1)
        range = ''; % user requests interactive range selection.
    elseif ischar(sheet)
        if ~isempty(sheet)
            % Parse sheet and range strings
            if isempty(strfind(sheet,':'))
            else
                range = sheet; % only range was specified. 
                sheet = Sheet1;% Use default sheet.
            end
        else
            sheet = Sheet1; % set sheet to default sheet.
        end
    end
end
if nargin > 2
    % verify class of range parameter
    if ~ischar(range)
        error('MATLAB:xlsread:InputClass',...
            'Range argument must a string. See HELP XLSREAD.');
    end
end
if nargin >= 4
    % verify class of mode parameter
    if ~isempty(mode) && ~(strcmpi(mode,'basic'))
        warning('MATLAB:xlsread:InputClass',...
            'Import mode string is invalid. XLSREAD resets mode to normal.');
        mode = '';
    end
else
    mode = '';
end

custom = false;
if nargin >= 5 
    if strcmpi(mode,'basic') || ~ispc
        warning('MATLAB:xlsread:Incompatible',...
         ['Custom functions cannot be used in basic mode or on non-Windows platforms.\n'...
          'The custom function argument will be ignored.'])
    elseif ~isa(customFun,'function_handle')
            warning('MATLAB:xlsread:NotHandle', ...
                'The fifth argument to XLSREAD must be a function handle.');
    else
        custom = true;
    end
end 
    
%==============================================================================
% handle requested Excel workbook filename
try
    file = My_validpath(file,'.xls');
catch
    err = lasterror;
    err.identifier = 'MATLAB:xlsread:FileNotFound';
    err.message = sprintf('XLSREAD unable to open file %s.\n%s',...
                           file,...
                           err.message);
    rethrow(err);
end
%==============================================================================
% select import mode from either normal or basic mode.
if strcmpi(mode,'basic') || ~ispc
    warning('MATLAB:xlsread:Mode',...
        ['XLSREAD has limited import functionality on non-Windows platforms\n'...
            'or in basic mode.  Refer to HELP XLSREAD for more information.']);
    try		
       rawData = xlsreadold(file,sheet);		
    catch
        err = lasterror;
        if isempty(err.identifier)
            err.identifier = 'MATLAB:xlsreadold:FormatError';
        end
        rethrow(err);
    end
    return;
else
    % Attempt to start Excel as ActiveX server process.
    try
        Excel = actxserver('excel.application');
    catch
        % revert to old XLSREAD that uses BIFFREAD
        warning('MATLAB:xlsread:ActiveX',...
            ['Could not start Excel server for import. '...
                'Refer to documentation.']);
        try
            err = lasterror;
            
            rawData = xlsreadold(file,sheet);            
        catch
            errnew = lasterror;
            message=sprintf('%s\n%s', err.message, errnew.message);
			errnew.message = message;
            if isempty(errnew.identifier)
                errnew.identifier = 'MATLAB:xlsreadold:FormatError';
            end
            rethrow(errnew);
        end
        return;
    end
end
%==============================================================================
try
     % open workbook
    Excel.DisplayAlerts = 0; 
    ExcelWorkbook = Excel.workbooks.Open(file);
    format = ExcelWorkbook.FileFormat;
    if  strcmpi(format, 'xlCurrentPlatformText') == 1
        error('MATLAB:xlsread:FileFormat', 'File %s not in Microsoft Excel Format.', file);
    end

    if nargin >= 2
        % User specified at least a worksheet or interactive range selection.
        if ~isequal(sheet,-1)
            % Activate indicated worksheet.
            activate_sheet(Excel,sheet);

            try % importing a data range.
                if ~isempty(range)
                    % The range is specified.
                    Select(Range(Excel,sprintf('%s',range)));
                    DataRange = get(Excel,'Selection');
                else
                    % Only the worksheet is specified. 
                    % Activate upper left cell on sheet. 
                    Activate(Range(Excel,'A1'));
                    
                    % Select range of occupied cells in active sheet.
                    DataRange = Excel.ActiveSheet.UsedRange;
                end
            catch % data range error.
                error('MATLAB:xlsread:RangeSelection',...
                    'Data range is invalid.');
            end

        else
            % User requests interactive range selection.
            % Set focus to first sheet in Excel workbook.
            activate_sheet(Excel,Sheet1);

            % Make Excel interface the active window.
            set(Excel,'Visible',true);

            % bring up message box to prompt user.
            uiwait(warndlg({'Select data region in Excel worksheet.';...
                    'Click OK to continue in MATLAB'},...
                    'Data Selection Dialogue','modal'));
            DataRange = get(Excel,'Selection');
            set(Excel,'Visible',false); % remove Excel interface from desktop
        end
    else
        % No sheet or range or interactive range selection. 
        % Activate default worksheet.
        activate_sheet(Excel,Sheet1);
        
        % Select range of occupied cells in active sheet.
        DataRange = Excel.ActiveSheet.UsedRange;
    end

    %Call the custom function if it was given.  Provide customOutput if it
    %is possible.
    if custom
		if nargout(customFun) < 2
			DataRange = customFun(DataRange);
            customOutput = {};
		else
			[DataRange, customOutput] = customFun(DataRange);	
		end
	end
	
    % get the values in the used regions on the worksheet.
    rawData = DataRange.Value;
        
catch
    err = lasterror;
    try
        ExcelWorkbook.Close(false); % close workbook without saving any changes
    end
    rethrow(err);	% rethrow original error
end
    
try
    ExcelWorkbook.Close(false); % close workbook without saving any changes
    %This call could fail if the file is "locked".  This is the same
    %message you would get if you opened the file in Excel, and then tried
    %to close the workbook (NOT the application).
    Excel.Quit;
catch
    warn = lasterror;
    warning(warn.identifier, '%s', warn.message);
    Excel.Quit;
end



%--------------------------------------------------------------------------
function activate_sheet(Excel,Sheet)
% Activate specified worksheet in workbook.

% Initialise worksheet object
WorkSheets = Excel.sheets;

% Get name of specified worksheet from workbook
try
    TargetSheet = get(WorkSheets,'item',Sheet);
catch
    error('MATLAB:xlsread:WorksheetNotFound',...
          'Specified worksheet was not found.');
end

%Activate silently fails if the sheet is hidden
set(TargetSheet, 'Visible','xlSheetVisible');
% activate worksheet
Activate(TargetSheet);

%--------------------------------------------------------------------------
function rawResult=xlsreadold(filename,sheet)
% Basic import mode. Range specification not available.
% Interactive range selection not available.
% Read Excel file as binary image file
if nargin > 1
    if isequal(sheet,1) || isequal(sheet,-1)
        sheet = ''; 
    elseif ~ischar(sheet)
        error('MATLAB:xlsread:WorksheetNotFound',...
            'In basic mode, sheet argument must be a string.');
    end
end
% read XLS file
biffvector = biffread(filename);

% get sheet names
[data, names] = biffparse(biffvector);

% if the names array is empty, this is an old style biff record with 
% no sheet name.  Just return data and empty text cell array.
if isempty(names) 
    matrixResult = data;
    cellResult = cell(names);
	if nargout > 2
	    rawResult = num2cell(data);
	end
    return;
end

if nargin == 1 || isempty(sheet)
    % just get the first sheet
    [n, s] = biffparse(biffvector, names{1});
else
    % try to read this sheet
    try
        [n, s] = biffparse(biffvector, sheet);
    catch
        error('MATLAB:xlsread:WorksheetNotFound',...
            'Specified worksheet was not found.');
    end
end


if nargout > 2
	% create raw data return
	if isempty(s)
		rawResult = num2cell(n);
	else
		rawResult = cell(max(size(n),size(s)));
		rawResult(1:size(n,1),1:size(n,2)) = num2cell(n);
		for i = 1:size(s,1)
			for j = 1:size(s,2)
				if (~isempty(s{i,j}) && (i > size(n,1) || j > size(n,2) || isnan(n(i,j))))
					rawResult(i,j) = s(i,j);
				end
			end
		end
	end
	% trim all-empty-string leading rows from raw array
	while size(rawResult,1)>1 && all(cellfun('isempty',rawResult(1,:)))
		rawResult = rawResult(2:end,:);
	end
	% trim all-empty-string leading columns from raw array
	while size(rawResult,2)>1 && all(cellfun('isempty',rawResult(:,1)))
		rawResult = rawResult(:,2:end);
	end
	% replace empty raw data with NaN, to comply with specification
	rawResult(cellfun('isempty',rawResult))={NaN};
end	
