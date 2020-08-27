function varargout = gretna_surf_display(Data, varargin)

%==========================================================================
% This function is used to display surfaces and brain networks.
%
%
% Syntax: function varargout = gretna_surf_display(Data, varargin)
% 
% Input:
%             Data: 
%                  A directory & filename of the surfaces file (a gifti file
%                  in 164k fsaverage space) to be displayed.
% 
% parameters:
%      'multisurf':
%              load both hemispheres if possible.
%              0 = load single hemisphere (Default);
%              1 = load both hemisphere.
%   'usefsaverage':
%              Choose an average surface to display. This surface file will
%              define the shape of meshed object.
%              'inflated', an inflated brain surface (Default);
%              'central',  central surface;
%              'IXI555',   Template_T1_IXI555_MNI152_GS.gii released by CAT12;
%              'custom',   custom average surface..
%     'useOverlay':
%              Choose a gifti file to be the mesh overlay.
%              'none',   no overlay mesh (Default);
%              'mc',     curv infomation for fsaverage surface;
%              'a2009s', boundary infomation for a2009s_150 (Destrieux atlas, 
%                        for detailed information, see gretna_label);
%              'DK40',   boundary infomation for DK40_70 (Desikan atlas);
%              'Fan',    boundary infomation for Fan_210;
%              'HCP',    boundary infomation for HCP_360;
%              'custom', custom underlay.
%    'useUnderlay':
%              Choose a gifti file to be the mesh underlay, this underlay will
%              be the underlay texture of the display object.
%              'none',   no overlay mesh (Default);
%              'mc',     curv infomation for fsaverage surface (Recommended);
%              'a2009s', boundary infomation for a2009s_150 (Destrieux atlas, 
%                        **for detailed information**, see gretna_label);
%              'DK40',   boundary infomation for DK40_70 (Desikan atlas);
%              'Fan',    boundary infomation for Fan_210;
%              'HCP',    boundary infomation for HCP_360;
%              'custom', custom underlay.
%   'TransParency':
%              Set the transparency for surface object, a value which
%              ranges from 0 to 1. The default value is 0.55
%           'view':
%              Object display orientation
%              'l' = left,               'r' = right;
%              'a' = anterior,           'p' = posterior;
%              's' = superior (Default), 'i' = inferior.
%       'Colormap':
%              Color look-up table, as a matrix of 3 columns.
%              e.g. jet(16), hot(64), white(256), etc.
%       'imgprint':
%              0 = No output (Default);
%              1 = Output to 'imgprintDir' (see below), which is a directory 
%                  you want the image to be output to.
%    'imgprintDir':
%              A data path that you want the image to be output to. When the 
%              'imgprint' is set to 1 and the value of 'imgprintDir' is unset,
%              the output directory will be set as the current working directory.
%           
% 
% Ningkai WANG,IBRR, SCNU, Guangzhou, 2020/03/29, Ningkai.Wang.1993@gmail.com
% Jinhui WANG, IBRR, SCNU, Guangzhou, 2020/03/29, jinhui.wang.1982@gmail.com
%==========================================================================


%% Add path
Dir_thisFunction = which('gretna_surf_display');
[PathF, ~, ~] = fileparts(Dir_thisFunction);
addpath([PathF filesep 'nodalBoundaryList']);
addpath([PathF filesep 'inflatedGiftiFiles']);



%% Default parameters
job.default.usefsaverage  = 'inflated';
job.default.useOverlay    = 'none';
job.default.useUnderlay   = 'none';
job.default.TransParency  = 0.45;
job.default.Colormap      = hot(256);

job.my.fsaverage.central  = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces','lh.central.freesurfer.gii')};
job.my.fsaverage.inflated = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces','lh.inflated.freesurfer.gii')};
job.my.fsaverage.IXI555   = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces','lh.central.Template_T1_IXI555_MNI152_GS.gii')};

Path_Boundary             = fullfile(fileparts(which('gretna_surf_display')), 'nodalBoundaryList');
job.my.Overlay.mc         = {fullfile(spm('dir'),'toolbox','cat12','templates_surfaces','lh.mc.freesurfer.gii')};
job.my.Overlay.a2009s     = {fullfile(Path_Boundary, 'lh.nodalBoundaryList_a2009s_150.gii')};
job.my.Overlay.dk40       = {fullfile(Path_Boundary, 'lh.nodalBoundaryList_DK40_70.gii')};
job.my.Overlay.fan        = {fullfile(Path_Boundary, 'lh.nodalBoundaryList_Fan_210.gii')};
job.my.Overlay.hcp        = {fullfile(Path_Boundary, 'lh.nodalBoundaryList_HCP_360.gii')};

job.my.Underlay           = job.my.Overlay;



%% User input Parser
p = inputParser;
validScalar = @(x) isnumeric(x) && isscalar(x);

addParameter(p, 'multisurf',    0,                         validScalar);
addParameter(p, 'usefsaverage', job.default.usefsaverage,  @ischar);
addParameter(p, 'useOverlay',   job.default.useOverlay,    @ischar);
addParameter(p, 'useUnderlay',  job.default.useUnderlay,   @ischar);
addParameter(p, 'TransParency', job.default.TransParency,  validScalar);
addParameter(p, 'rangeClip',    [],                        @(x) isnumeric(x) && length(x)==2);
addParameter(p, 'rangeClim',    [],                        @(x) isnumeric(x) && length(x)==2);
addParameter(p, 'Colormap',     job.default.Colormap,      @isnumeric);
addParameter(p, 'view',         'top',                     @ischar);
addParameter(p, 'imgprint',     0);
addParameter(p, 'imgprintDir',  '');

parse(p, varargin{:});

job.multisurf    = p.Results.multisurf;
job.usefsaverage = p.Results.usefsaverage;
job.useOverlay   = p.Results.useOverlay;
job.useUnderlay  = p.Results.useUnderlay;
job.TransParency = 1 - p.Results.TransParency;
job.rangeClip    = p.Results.rangeClip;
job.rangeClim    = p.Results.rangeClim;
job.Colormap     = p.Results.Colormap;
job.view         = p.Results.view;
job.imgprint     = p.Results.imgprint;
job.imgprintDir  = p.Results.imgprintDir;

switch lower(job.usefsaverage)
    case 'central'
        job.fsaverage   = job.my.fsaverage.central;
    case 'inflated'
        job.fsaverage   = job.my.fsaverage.inflated;
    case 'ixi555'
        job.fsaverage   = job.my.fsaverage.IXI555;
    case 'custom'
        job.fsaverage   = spm_select(1, 'mesh', 'Select Mesh files...');
    otherwise
        error('Invaild fsaverage');
end

switch lower(job.useOverlay)
    case 'none'
        
    case 'mc'
        job.Overlay = job.my.Overlay.mc;
    case {'a2009s','dk40','fan','hcp'}
        job.Overlay = job.my.Overlay.(lower(job.useOverlay));
    case 'custom'
        job.Overlay = spm_select(1, 'mesh', 'Select Overlay files...');
    otherwise
        error('Invaild Overlay');
end

switch lower(job.useUnderlay)
    case 'none'
        
    case 'mc'
        job.Underlay = job.my.Underlay.mc;
    case {'a2009s','dk40','fan','hcp'}
        job.Underlay = job.my.Underlay.(lower(job.useUnderlay));
    case 'custom'
        job.Underlay = spm_select(1, 'mesh', 'Select Underlay files...');
    otherwise
        error('Invaild Overlay');
end



%% Plot surface
sinfo = cat_surf_info(Data, 1, 1);

H     = plot_hemi(sinfo, job);

set(H.patch, 'FaceAlpha', job.TransParency);
% H     = cat_surf_render('Colourmap', H, bone, 64); % change colormap

if nargout == 0
    varargout{1} = [];
else
    varargout{1} = H;
end



%% Colormap
H = cat_surf_render('ColourMap',H.axis, job.Colormap);



%% Add Range

if ~isempty(job.rangeClip)
    
    rangeClip = job.rangeClip;
    
    if rangeClip(1)==rangeClip(2) && rangeClip(1)>=0
        rangeClip = rangeClip + 2.*[-eps eps];
    elseif rangeClip(1)==rangeClip(2) && rangeClip(1)<0
        rangeClip = rangeClip - 2.*[-eps eps];
    end
    
    if rangeClip(1)>rangeClip(2), rangeClip = fliplr(rangeClip); end
    
    H = cat_surf_render('clip', H, rangeClip);
end

if ~isempty(job.rangeClim)
    
    rangeClim = job.rangeClim;
    
    if rangeClim(1)==rangeClim(2) && rangeClim(1)>=0
        rangeClim = rangeClim + 2.*[-eps eps];
    elseif rangeClim(1)==rangeClim(2) && rangeClim(1)<0
        rangeClim = rangeClim - 2.*[-eps eps];
    end
    
    if rangeClim(1)>rangeClim(2), rangeClim = fliplr(rangeClim); end
    
    H = cat_surf_render('clim', H, rangeClim);
end



%% view
switch lower(job.view)
    case {'r',      'right'},                 cat_surf_render('view', H, [  90   0]); viewname = '.r';
    case {'l',      'left'},                  cat_surf_render('view', H, [ -90   0]); viewname = '.l';
    case {'t', 's', 'top',    'superior'},    cat_surf_render('view', H, [   0  90]); viewname = '.s';
    case {'b', 'i', 'bottom', 'inferior'},    cat_surf_render('view', H, [-180 -90]); viewname = '.i';
    case {'f', 'a', 'front',  'anterior'},    cat_surf_render('view', H, [-180   0]); viewname = '.a';
    case {'p',      'back',   'posterior'},   cat_surf_render('view', H, [   0   0]); viewname = '.p';
    otherwise
        if isnumeric(job.view) && size(job.view)==2
            view(job.view);
            viewname = sprintf('.%04dx%04d', mod(job.view, 360));
        else
            error('Unknown view.\n')
        end
end



%% print image
if job.imgprint || ~isempty(job.imgprintDir)
    
    if isempty(job.imgprintDir)
        ppp = pwd;
    else
        ppp = job.imgprintDir;
    end
    
    if ~exist(ppp, 'dir')
        mkdir(ppp);
    end
    [~, fname, ~] = fileparts(Data);
    pfname        = fullfile(ppp, sprintf('%s%s.%s', fname, viewname, 'tif'));
    print(H.figure , '-dtiff' , '-r600', pfname );
end

end



%% plot single hemi
function [H, sinfo] = plot_hemi(sinfo, job)

for i = 1:length(sinfo)
    sinfo(i)       = rename_sinfo(sinfo(i));
    sinfo(i).Pmesh = cat_surf_rename(job.fsaverage, 'side', sinfo(i).side);
    
    if strcmp('r',sinfo(i).side(1))
        oside = ['l' sinfo(i).side(2)];
    else
        oside = ['r' sinfo(i).side(2)];
    end
    
    if job.multisurf
        Pmesh = [sinfo(i).Pmesh cat_surf_rename(sinfo(i).Pmesh, 'side', oside)];
        Pdata = [sinfo(i).Pdata cat_surf_rename(sinfo(i).Pdata, 'side', oside)];
    else
        Pmesh = sinfo(i).Pmesh;
        Pdata = sinfo(i).Pdata;
    end
    
    H = cat_surf_render('disp', Pmesh, 'Pcdata', Pdata, 'results', -1);

    %% add overlay
    if isfield(job,'Overlay')
        if job.multisurf
            MhOverlay = combine_multisurf(job.Overlay{:});
            updateTexture(H, MhOverlay);
        else
            ShOverlay = cat_surf_rename(job.Overlay, 'side', sinfo(i).side);
            H = cat_surf_render('overlay', H, ShOverlay{:});
        end
    end
    
    %% add underlay
    if isfield(job, 'Underlay') 
        if job.multisurf
            MhUnderlay = combine_multisurf(job.Underlay{:});
            setappdata(H.patch, 'curvature', double(MhUnderlay.cdata));
            setappdata(H.axis, 'handles', H);
            d = getappdata(H.patch, 'data');
            updateTexture(H, d);
        else
            ShUnderlay = cat_surf_rename(job.Underlay, 'side', sinfo(i).side);
            H = cat_surf_render('underlay', H, ShUnderlay{:});
        end
    end
    
end
end



%% combine multi surface
function Mh = combine_multisurf(Mh)

sinfo = cat_surf_info(Mh, 1, 1);
sinfo = rename_sinfo(sinfo);

if strcmp('r', sinfo.side)
    oside = ['l' sinfo.side(2)];
else
    oside = ['r' sinfo.side(2)];
end

Moh = cat_surf_rename(Mh, 'side', oside);
Moh = Moh{:};
Mh  = gifti(Mh);
Moh = gifti(Moh);

if isfield(Mh,'faces')
    Mh.faces = [double(Mh.faces); double(Moh.faces) + size(double(Mh.vertices),1)];
end

if isfield(Mh,'vertices')
    Mh.vertices = [double(Mh.vertices); double(Moh.vertices)];
end

if isfield(Mh,'cdata')
    Mh.cdata = [double(Mh.cdata); double(Moh.cdata)];
end

end



%% search another hemi 
function sinfo = rename_sinfo(sinfo)

if isempty(sinfo.side)
    prompt   = {'Enter hemi'};
    dlgtitle = 'Input';
    dims     = [1 35];
    definput = {'lh'};
    answer   = inputdlg(prompt, dlgtitle, dims, definput);
    answer   = answer{:};
    
    switch lower(answer)
        case {'lh', 'left', 'lh.', 'left.'}
            sinfo.side = 'lh';
        case {'rh', 'right', 'rh.', 'right.'}
            sinfo.side = 'rh';
    end
end
end



%% update texture of underlay and overlay
% From cat_surf_render
function C = updateTexture(H, v, col, texLight)

% Get colourmap
if ~exist('col', 'var'), col = getappdata(H.patch, 'colourmap'); end
if isempty(col), col = white(256); end
if ~exist('FaceColor', 'var'), FaceColor = 'interp'; end % default: interp
setappdata(H.patch, 'colourmap',col);
if ~exist('texLight', 'var'), texLight = 1; end
    
% Get curvature
curv = getappdata(H.patch, 'curvature');

if size(curv,2) == 1
    th = 0.15;
    curv((curv<-th)) = -th;
    curv((curv>th))  =  th;
    curv = 0.5*(curv + th)/(2*th);
    curv = 0.5 + repmat(curv,1,3);
end
 
% Project data onto surface mesh
if nargin < 2, v = []; end

if ischar(v)
    [p,n,e] = fileparts(v);
    if ~strcmp(e, '.mat') && ~strcmp(e, '.nii') && ~strcmp(e, '.gii') && ~strcmp(e, '.img') % freesurfer format
      v = cat_io_FreeSurfer('read_surf_data', v);
    else
      if strcmp([n e], 'SPM.mat')
        swd = pwd;
        spm_figure('GetWin', 'Interactive');
        [~,v] = spm_getSPM(struct('swd', p));
        cd(swd);
      else
        try spm_vol(v); catch, v = gifti(v); end;
      end
    end
end

if isa(v,'gifti'), v = double(v.cdata); end
if isa(v,'file_array'), v = v(); end

if isempty(v)
    v = zeros(size(curv))';
elseif ischar(v) || iscellstr(v) || isstruct(v)
    v = spm_mesh_project(H.patch,v);
elseif isnumeric(v) || islogical(v)
    if size(v, 2) == 1
        v = v';
    end
else
    error('Unknown data type.');
end

v(isinf(v)) = NaN;
setappdata(H.patch, 'data', v);

% Create RGB representation of data according to colourmap
C = zeros(size(v, 2), 3);
clim = getappdata(H.patch, 'clim');
if isempty(clim), clim = [false NaN NaN]; end

mi = clim(2); ma = clim(3);

if any(v(:))
    if size(col, 1) > 3 && size(col, 1) ~= size(v, 1)
        if size(v,1) == 1
            if ~clim(1), mi = min(v(:)); ma = max(v(:)); end
            C = squeeze(ind2rgb(floor(((v(:) - mi)/(ma - mi)) * size(col, 1)), col));
        elseif isequal(size(v),[size(curv, 1), 3])
            C = v; v = v';
        else
            if ~clim(1), mi = min(v(:)); ma = max(v(:)); end
            for i=1:size(v, 1)
                C = C + squeeze(ind2rgb(floor(((v(i,:) - mi)/(ma - mi))*size(col, 1)), col));
            end
        end
    else
        if ~clim(1), ma = max(v(:)); end
        for i = 1 : size(v, 1)
            C = C + v(i, :)'/ma * col(i, :);
        end
    end
end

clip = getappdata(H.patch, 'clip');

if ~isempty(clip)
    v(v > clip(2) & v < clip(3)) = NaN;
    setappdata(H.patch, 'clip', [true clip(2) clip(3)]);
end

setappdata(H.patch, 'clim', [false mi ma]);

% Build texture by merging curvature and data
if size(curv, 1) == 1
  curv = repmat(curv, 3, 1)';
end

if size(C, 1) ~= size(curv, 1)
  error('Colordata does not fit to underlying mesh.');
end

C = repmat(~any(v, 1), 3, 1)' .* curv + repmat(any(v, 1), 3, 1)' .* C;

if texLight == 1
    C = mapminmax(C')'.*1/16 + 0.9375;
end

set(H.patch, 'FaceVertexCData', C, 'FaceColor', FaceColor, 'CDataMapping', 'direct');

% Update colourbar
if isfield(H, 'colourbar')
    cat_surf_render('Colourbar', H);
end

end