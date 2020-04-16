function matlabStyleHinter(fileName,varargin)
flagWarnings=false;
flagDiary=false;

if ~exist('fileName','var') || isempty(fileName)
    dirMFiles=dir('*.m');
    fileName={dirMFiles.name};
end

if iscell(fileName)
    %multiple files, recursive call
    for iFile=1:length(fileName)
        thisFile=fileName{iFile};
        fprintf('File: %s\n',thisFile)
        matlabStyleHinter(thisFile,varargin{:})
    end
    return
end

%automatically add .m extension if necessary
[~,~,ext]=fileparts(fileName);
if isempty(ext)
    fileName=[fileName '.m'];
end

%optional parameters
ivarargin=1;
while ivarargin<=length(varargin)
    switch lower(varargin{ivarargin})
        case 'flagwarnings'
            ivarargin=ivarargin+1;
            flagWarnings=varargin{ivarargin};
        case 'diary'
            flagDiary=true;
        otherwise
            error(['Argument ' varargin{ivarargin} ' not valid!'])
    end
    ivarargin=ivarargin+1;
end

%list of "actions" that trigger a message.
%Each "action" is a [1x2] or [1x3] cell array.
%action{1} is a regexp. If a match if found, a warning is triggered.
%action{2} is either a message to display or a function to call when a
%   warning is triggered
%action{3}, if present, is a struct of flags for controlling the
%   normalization of lines prior to the regexp match. For instance, to
%   check for particular string literals, we should not remove string
%   literals, while in general they should be ignored.
actionList={
    {'''(true|false)''','Use the logical type variables true and false, not strings (type `doc logical` and links therein for more information).',struct('removeString',false)}
    {';.*;','Do not insert multiple commands on the same line.',struct('removeArrays',true)}
    {'hold (on|off);','hold on and hold off commands do not need the trailing semicolon.'}
    {'\<(input|keyboard)\s*\(','All functions and tests should not require direct input from the user. If it is a function, use only its arguments. If it is a test, the data should be automatically generated (preferably in a random way).'}
    {'\<eval\s*\(','Avoid the use of eval.'}
    {'if\s*\([^&|]*\)', 'In Matlab, the if statement syntax does not require parentheses (i.e., use `if iCell==1` instead of `if (iCell==1)`). If instead you need to combine multiple boolean expressions (e.g., `if (a==1) && (b==2)`), it is more clear to use an intermediate flag (e.g., `flagIsABOrdered=(a==1) && (b==2); if flagIsABOrdered ...'}
    {'\<[a-zA-Z]\w?\s*[\(|=]', @isIdentifierTooShort} 
    {'for\s+[^ijk]\w*\s*=', 'Prefix iterator variable names with i, j, k etc. (e.g., instead of `for cell=1:5` use `for iCell=1:nbCells`).'}
    {'\<(quiver|figure|plot|alpha|angle|axes|axis|balance|beta|contrast|gamma|image|info|input|length|line|mode|power|rank|run|start|text|type)\>[\s\w,\]]*=','Avoid variable names that shadow functions'}
    {'\<global\>','Do not use global variables.'}
    {'~(','This type of logical negation can be usually avoided by reversing the condition (e.g., `if ~(i==1)` should be changed to `if i~=1`)'}
    {'\<(?:sym|syms|solve)\>',@(context,idx) aFileNameContains('sym',['Do not use symbolic variables for standard computations. ' ...
        'You can use the symbolic toolbox to derive expressions, but then write those expressions as standard Matlab functions. '  ...
        'For scripts/functions that perform the derivation, include the word `Sym` in the file name.'],context,idx)}
    {'\<(?:figure|plot?|quiver?)\>',@(context,idx) aFileNameContains('(?:test|plot)','Display figures only in test or plot functions (i.e.,the file name should contain `test` or `plot`).',context,idx)}
    {'((&&|\|\|)\S|\S(&&|\|\|))','Surround && and || by spaces.'}
    {'\<(for|while|function|global|switch|try|if|elseif)[{\(]','Follow MATLAB keywords by spaces.',struct('caseInsensitive',false)}
    {'pinv\s*\([\w_\:\(\)]*)\s*\*','Use the backslash operator instead of multiplying pinv() with another vector or matrix.'}
    {'\*\s*pinv\s*\(','Use the slash operator instead of multiplying by pinv().'}
    };

if flagWarnings
    actionList=[actionList 
        {'\<length\s*\(','Warning: the function length() when called on a 2-D array behaves differently depending on whether the array contains a single column or not. Consider using `size(...,2)` instead.'}
        ];
end

fid=fopen(fileName,'rt');
if fid<0
    error('File %s not found', fileName); %#ok<PFCEL>
end

%add file name and identifier to context struct
context.fileName=fileName;
context.fid=fid;

if flagDiary
    diary diary.txt
    diary on
end

%run our custom regexp-based tests
disp('* Programming style report')
actionCheck(context,actionList)

%run Matlab's standard checks
disp('* Matlab Code Analyzer report')
matlabCheck(context)

if flagDiary
    diary off
end

function matlabCheck(context)
%Show report from Matlab Code Analyzer
report=checkcode(context.fileName);
if isempty(report)
    disp('    No problems found')
else
    nbEntries=length(report);
    for iEntry=1:nbEntries
        entry=report(iEntry);
        fprintf('Line %d, column %d: %s\n',...
            entry.line, entry.column(1),...
            entry.message)
    end
end

function actionCheck(context,actionList)
%Show report on custom regexp style specifications
nbActions=length(actionList);

flagContinueReading=true;
context.flagAnyErrorFound=false;
context.cnt=1;
while flagContinueReading
    lineStr=fgetl(context.fid);
    context.lineStr=lineStr;
    if isnumeric(lineStr) && lineStr==-1
        flagContinueReading=false;
    else
        for iAction=1:nbActions
            action=actionList{iAction};
            if length(action)<3
                action{3}=[];
            end
            lineStrNorm=lineNormalization(lineStr,action{3});
            context.lineStrNorm=lineStrNorm;
            idx=regexp(lineStrNorm,action{1},'once');
            if ~isempty(idx)
                if actionHasFunction(action)
                    %Action has a custom function, call it
                    flag=action{2}(context,idx);
                    context.flagAnyErrorFound=context.flagAnyErrorFound|flag;
                else
                    %By default, just show message
                    displayLineWithMarker(context,action{2},idx)
                    context.flagAnyErrorFound=true;
                end
            end
        end
    end
    context.cnt=context.cnt+1;
end

if ~context.flagAnyErrorFound
    disp('    No problems found')
end


function lineStr=lineNormalization(lineStr,flags)
%remove comments
lineStr=regexprep(lineStr,'%.*','');
%normalize case
if ~isfield(flags,'caseInsensitive') || flags.caseInsensitive
    lineStr=lower(lineStr);
end
if ~isfield(flags,'removeString') || flags.removeString
    %remove tick (') characters from strings, and empty strings (i.e., double
    %ticks)
    lineStr=regexprep(lineStr,'''{2}','');
    %remove string literals
    lineStr=regexprep(lineStr,'''[^'']*''','');
end
if isfield(flags,'removeArrays') && flags.removeArrays
    lineStr=regexprep(lineStr,'\[[^\]]*(\]|$)','');
end

function flag=actionHasFunction(action)
flag=isa(action{2}, 'function_handle');

function flag=isIdentifierTooShort(context,idx)
msg='Avoid the use of very short identifiers (variable or function names). E.g., instead of `for i=1:l`, use `for iCell=1:nbCells`.';
%check that the regexp did not find "if" as an identifier
flagIsIf=strcmpi(context.lineStrNorm(idx:idx+1),'if');
flagIsField= idx~=1 && context.lineStrNorm(idx-1)=='.';
flag=~flagIsIf && ~flagIsField;
if flag
    displayLineWithMarker(context,msg,idx)
end

function flagNameMissingStr=aFileNameContains(strName,msg,context,idx)
flagNameMissingStr=isempty(regexp(lower(context.fileName),strName,'once'));
if flagNameMissingStr
    %By default, just show message
    indent='    ';
    fprintfWrap('Line %d: %s\n',context.cnt,msg)
    regexpDisplay(context.lineStr,idx,indent)
end

function displayLineWithMarker(context,msg,idx)
%Displays error message and also echoes the line with a marker at the found
%position
indent='    ';
fprintfWrap('Line %d: %s\n',context.cnt,msg)
regexpDisplay(context.lineStr,idx,indent)

function fprintfWrap(varargin)
%Get string equivalent to fprintf output
str=sprintf(varargin{:});
%Get command window size
cmsz = get(0,'CommandWindowSize'); 
width = cmsz(1); 
%Wrap string
strWrap=regexprep(str,['.{1,' num2str(width) '}\s'],'$0\n');
fprintf(strWrap(1:end-1))

%Display a string together with regular expression matches
function regexpDisplay(str,expression,indent)
if ~exist('indent','var')
    indent='';
end

if isnumeric(expression)
    idx=expression;
else
    idx=regexp(str,expression);
end

if isempty(idx)
    disp('No matches')
else
    indicators=repmat(' ',1,length(str));
    indicators(idx)='^';
    fprintf('%s%s\n%s%s\n',indent,str,indent,indicators)
end
