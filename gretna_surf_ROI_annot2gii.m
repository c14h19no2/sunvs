function gretna_surf_ROI_annot2gii(pathAnnot, indROIs, valueROIs, varargin)

%==========================================================================
% This function is used to convert annot format to gii format.
%
% Syntax: function gretna_surf_ROI_annot2gii(pathAnnot, indROIs, valueROIs, varargin)
%
% Input:
%      pathAnnot:
%                The directory & filename of the annot file.
%        indROIs:
%                The indexes of ROIs defined by the annot file, an N*1 matrix, 
%                where N denotes the number of ROIs.
%     valueROIs:
%                The values of ROIs, an N*1 matrix.
%     parameters:
%       'usefsaverage':
%                Choose an average surface to display. This surface file will
%                define the shape of meshed object.
%                'inflated',     an inflated brain surface (Default);
%                'central',      central surface;
%                'IXI555',       Template_T1_IXI555_MNI152_GS.gii released by CAT12;
%                'inflated_32k', an inflated brain surface, 32k mesh version;
%                'central_32k',  central surface, 32k mesh version;
%                'IXI555_32k',   Template_T1_IXI555_MNI152_GS.gii released by CAT12,
%                                32k mesh version;
%                'custom',       custom average surface.
%
% Jinhui WANG, IBRR, SCNU, Guangzhou, 2020/03/24, jinhui.wang.1982@gmail.com
% Ningkai WANG,IBRR, SCNU, Guangzhou, 2020/03/24, Ningkai.Wang.1993@gmail.com
%==========================================================================

[~, label, colortable] = read_annotation(pathAnnot, 0);
[~, filename1, ~]      = fileparts(pathAnnot);
filename2              = filename1;
sinfo                  = cat_surf_info(pathAnnot, 0, 0);

d = 0;

while isempty(sinfo.side)
    d = d + 1;
    if d == 1
        prompt   = {'Enter hemi (left or right)'};
    else
        prompt   = {'Enter hemi (left or right)\n PLEASE CHECK YOUR SPELL!'};
    end
    
    dlgtitle = 'Input';
    dims     = [1 35];
    definput = {'rh'};
    answer   = inputdlg(prompt, dlgtitle, dims, definput);
    
    if ~isempty(answer)
        answer = answer{:};
        
        switch lower(answer)
            case {'lh', 'left', 'lh.', 'left.'}
                sinfo.side = 'lh'; SIDE_annot = 'lh';
                filename2 = ['lh.' filename1];
            case {'rh', 'right', 'rh.', 'right.'}
                sinfo.side = 'rh'; SIDE_annot = 'rh';
                filename2 = ['rh.' filename1];
        end
    else
        return
    end
end

switch length(label)
    case 163842
        defaultUsefsaverage = 'inflated';
    case 32492
        defaultUsefsaverage = 'inflated_32k';
end

pathFsaverageCentral      = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces', [SIDE_annot, '.central.freesurfer.gii'])};
pathFsaverageInflated     = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces', [SIDE_annot, '.inflated.freesurfer.gii'])};
pathFsaverageIXI555       = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces', [SIDE_annot, '.central.Template_T1_IXI555_MNI152_GS.gii'])};
pathFsaverageCentral_32k  = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces_32k', [SIDE_annot, '.central.freesurfer.gii'])};
pathFsaverageInflated_32k = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces_32k', [SIDE_annot, '.inflated.freesurfer.gii'])};
pathFsaverageIXI555_32k   = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces_32k', [SIDE_annot, '.central.Template_T1_IXI555_MNI152_GS.gii'])};

p = inputParser;
addParameter(p, 'usefsaverage', defaultUsefsaverage,  @ischar);
parse(p, varargin{:}); usefsaverage = p.Results.usefsaverage;

switch lower(usefsaverage)
    case 'central'
        pathFsaverage   = pathFsaverageCentral;
    case 'inflated'
        pathFsaverage   = pathFsaverageInflated;
    case 'ixi555'
        pathFsaverage   = pathFsaverageIXI555;
    case 'central_32k'
        pathFsaverage   = pathFsaverageCentral_32k;
    case 'inflated_32k'
        pathFsaverage   = pathFsaverageInflated_32k;
    case 'ixi555_32k'
        pathFsaverage   = pathFsaverageIXI555_32k;
    case 'custom'
        pathFsaverage   = spm_select(1, 'mesh', 'Select Mesh files...');
    otherwise
        error('Invaild fsaverage');
end

if nargin==1
    indROIs = [];
else
    cdata = zeros(length(label),1);
    IND_ROI = label==colortable.table(1,5);
    cdata(IND_ROI) = nan;
end

if ~isempty(indROIs)
    for i_ROI = 1:length(indROIs(:))
        IND_ROI = label==colortable.table(indROIs(i_ROI)+1,5);
        cdata(IND_ROI) = valueROIs(i_ROI);
    end
end

F       = gifti(pathFsaverage);
F.cdata = cdata;

save(F,[pwd filesep filename2 '.gii'],'Base64Binary');

end