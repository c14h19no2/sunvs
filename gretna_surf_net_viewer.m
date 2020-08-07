function H = gretna_surf_net_viewer(pathNodeFile, pathEdgeFile, varargin)

%==========================================================================
% This function is used to display surfaces and brain networks.
%
%
% Syntax: function H = gretna_surf_net_viewer(pathNodeFile, pathEdgeFile, varargin)
% 
% Input:
%     pathNodeFile: 
%              The directory & filename of a .node file.
%                   
%     pathEdgeFile: 
%              The directory & filename of an .edge file. If there is no edge
%              to display, please set this variable as [].
% 
% parameters:
%      'multisurf':
%              load both hemis if possible.
%              0 = load single hemi;
%              1 = load both hemis (Default).
%   'usefsaverage':
%              Choose an average surface to display. This surface file will
%              define the shape of meshed object.
%              'inflated', an inflated brain surface (Default);
%              'central',  central surface;
%              'IXI555',   Template_T1_IXI555_MNI152_GS.gii released by CAT12;
%              'custom',   custom average surface.
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
%              'mc',     curv infomation for fsaverage surface;
%              'a2009s', boundary infomation for a2009s_150 (Destrieux atlas, 
%                        for detailed information, see gretna_label);
%              'DK40',   boundary infomation for DK40_70 (Desikan atlas);
%              'Fan',    boundary infomation for Fan_210;
%              'HCP',    boundary infomation for HCP_360;
%              'custom', custom underlay.
%   'TransParency':
%              Set the transparency for surface object, a value which
%              ranges from 0 to 1. The default value is 0.30.
%       'imgprint':
%              0 = No output (Default);
%              1 = Output to 'imgprintDir' (see below), which is a directory 
%                  you want the image to be output to.
%            'dpi':
%              Resolution, specified as a scalar (Default = 600).
%    'imgprintDir':
%              A data path that you want the image to be output to. When the 
%              'imgprint' is set to 1 and the value of 'imgprintDir' is unset,
%              the output directory will be set as the current working directory.
%           'view':
%              Object display orientation.
%              'l' = left,               'r' = right;
%              'a' = anterior,           'p' = posterior;
%              's' = superior (Default), 'i' = inferior.
%    'ModuleColor':
%              The color of each module.
%              A M*3 matrix which includes the RGB value (range from 0
%              to 1) of each module, where M is the number of module.
%              When this parameter is set as [], auto selected (Default);
%  'ModuleTexture':
%              The directory & filename of a .txt file. This text file
%              contains the directory & filename of M*1 images, where M is 
%              the number of module. each of these image indicates the 
%              texture of each module.
%     'NodeWeight':
%              1 = use weighted node size defined in .node file (Default);
%              0 = use equal size for each node.
%     'EdgeWeight':
%              1 = use weighted edge width defined in .edge file (Default);
%              0 = use equal width for each edge.
%   'LineColorPos':
%              RGB color (range from 0 to 1) for lines with postive
%              values. (Default: red, [252,146,114]./255).
%   'LineColorNeg':
%              RGB color (range from 0 to 1) for lines with negtive
%              values. (Default: blue, [127,205,187]./255).
%          'Label':
%              1 = display label;
%              0 = hide label (Default).
%           'Data':
%              A directory & filename of the surfaces file (a gifti file
%              in 164k fsaverage space) to be displayed (Default setting is
%              recommended).
%
%==========================================================================
% Example of .node file: 
%
%     -------------------------------------------------------------
%     Col1       col2       col3    col4       col5        col6
%     ----------------------HERE BEGINS----------------------------
%     23.703    48.904     -4.142    3           0   G_and_S_frontomargin
%     38.691    -72.746    -7.132    2+1i        0   G_and_S_occipital_inf
%     11.398    -31.895    63.072    1+2i        0   G_and_S_paracentral
%     12.311    -46.822    9.473     1           0   G_cingul_Post_ventral
%     -----------------------HERE ENDS-----------------------------
%     
%     .node file content:
%     Column 1: x-coordinates of nodes;
%     Column 2: y-coordinates of nodes;
%     Column 3: x-coordinates of nodes;
%     Column 4: Module index, including two parts:
%         real part:      denotes node color (depends on colormap);
%         Imaginary part: denotes node shape (depends on following shape indices);
%
%     shape indices:
%          Shape index for each node (N*1 matrix).
%              0: Shpere;
%              1: Cube;
%              2: Regular tetrahedron;
%              3: Dodecahedron.
%
% Jinhui WANG, IBRR, SCNU, Guangzhou, 2020/03/29, Jinhui.Wang.1982@gmail.com
% Ningkai WANG,IBRR, SCNU, Guangzhou, 2020/03/29, Ningkai.Wang.1993@gmail.com
%==========================================================================


%% Add path
Dir_thisFunction = which('gretna_surf_net_viewer');
[PathF, ~, ~] = fileparts(Dir_thisFunction);
addpath([PathF filesep 'nodalBoundaryList']);
addpath([PathF filesep 'inflatedGiftiFiles']);



%% User input Parser
p = inputParser;
validScalar = @(x) isnumeric(x) && isscalar(x);
addParameter(p, 'multisurf',     1,             validScalar);
addParameter(p, 'hemi',          'lh',          @ischar);
addParameter(p, 'usefsaverage',  'inflated',    @ischar);
addParameter(p, 'useOverlay',    'none',        @ischar);
addParameter(p, 'useUnderlay',   'mc',          @ischar);
addParameter(p, 'TransParency',  0.30,          validScalar);
addParameter(p, 'view',          'top',         @ischar);
addParameter(p, 'imgprint',      0);
addParameter(p, 'imgprintDir',   []);
addParameter(p, 'dpi',           600,           validScalar);

addParameter(p, 'ModuleColor',   [],                 @(x) size(x,2)==3 && isnumeric(x));
addParameter(p, 'ModuleTexture', '',                 @ischar);
addParameter(p, 'LineColorPos',  [252,146,114]./255, @(x) length(x)==3 && isnumeric(x));
addParameter(p, 'LineColorNeg',  [85,165,145]./255,  @(x) length(x)==3 && isnumeric(x));
addParameter(p, 'NodeWeight',    1,                  @isnumeric);
addParameter(p, 'EdgeWeight',    1,                  @isnumeric);
addParameter(p, 'Label',         0,                  @isnumeric);
addParameter(p, 'LabelFontName', 'Arial',            @ischar);

% Surface mesh
addParameter(p, 'Data', 'lh.inflated.Uniform.gii', @ischar);

% Surface material
addParameter(p, 'AmbientStrength',    0.9,           validScalar);
addParameter(p, 'DiffuseStrength',    0.01,          validScalar);
addParameter(p, 'SpecularStrength',   0.01,          validScalar);
addParameter(p, 'SpecularExponent',   0.01,           validScalar);

parse(p, varargin{:});



%% Jobs
jobpass.multisurf    = p.Results.multisurf;
jobpass.usefsaverage = p.Results.usefsaverage;
jobpass.useOverlay   = p.Results.useOverlay;
jobpass.useUnderlay  = p.Results.useUnderlay;
jobpass.TransParency = p.Results.TransParency;

cjob                 = struct2cell(jobpass);
fjob                 = fieldnames(jobpass);
PARAs                = reshape({fjob{:};cjob{:}},1,[]);

job.hemi             = p.Results.hemi;
job.LineColorPos     = p.Results.LineColorPos;
job.LineColorNeg     = p.Results.LineColorNeg;
job.NodeWeight       = p.Results.NodeWeight;
job.EdgeWeight       = p.Results.EdgeWeight;

job.view             = p.Results.view;
job.imgprint         = p.Results.imgprint;
job.imgprintDir      = p.Results.imgprintDir;
job.dpi              = p.Results.dpi;

job.pathNodeFile     = pathNodeFile;
job.pathEdgeFile     = pathEdgeFile;
job.colorModules     = p.Results.ModuleColor;

if ~isempty(p.Results.ModuleTexture)
    job.TextureModules = importdata(p.Results.ModuleTexture);
else
    job.TextureModules = '';
end

job.Label            = p.Results.Label;
job.LabelFontName    = p.Results.LabelFontName;
job.Data             = p.Results.Data;

if job.Data == 'lh.inflated.Uniform.gii'
    switch job.hemi
        case {'lh','l'}
            job.Data = 'lh.inflated.Uniform.gii';
        case {'rh','r'}
            job.Data = 'rh.inflated.Uniform.gii';
    end
end

H = gretna_surf_display(job.Data, PARAs{:});



%% Nodes setting
if ~isempty(job.pathNodeFile)
    
    fid   = fopen(job.pathNodeFile);
    Nodes = textscan(fid,'%n %n %n %n %n %s','CommentStyle','#');
    fclose(fid);
    
    MAT_Corr      = cell2mat(Nodes(1, 1:3));
    [Size_Node,~] = size(MAT_Corr(:,1));
    
    if ~isempty(Nodes(1, 4))
        Module_Nodes = cell2mat(Nodes(1, 4)); % Encode color and shape
    else
        Module_Nodes = ones(Size_Node,1);
    end
    
    if ~isempty(Nodes(1, 5))
        Size_Node    = cell2mat(Nodes(1, 5)); % Encode size
    else
        Size_Node    = ones(Size_Node, 1)*20;
    end
    
    CORR_Nodes_Exist = MAT_Corr(Size_Node > 0, :);
    Size_Nodes_Exist = Size_Node(Size_Node > 0);
    Num_Nodes_Exist  = length(Size_Nodes_Exist);
    
    if job.NodeWeight     == 1
        Size_Nodes_Exist   = (mapminmax(Size_Nodes_Exist)+4) * 0.64;
    elseif job.NodeWeight == 0
        Size_Nodes_Exist   = ones(length(Size_Nodes_Exist),1) * 2 * 1.75;
    end
    
    Module_Nodes_Exist = Module_Nodes(Size_Node > 0);
    hold on;
    
    Module_Nodes_Exist_shape    = imag(Module_Nodes_Exist);
    Module_Nodes_Exist_colntext = real(Module_Nodes_Exist);
    
    % Texturemap and colormap
    if isempty(job.TextureModules) % colormap
        
        if isempty(job.colorModules)
            job.colorModules = lines(max(Module_Nodes_Exist_colntext));
        elseif size(job.colorModules,1) == 1
            job.colorModules = repmat(job.colorModules, Num_Nodes_Exist, 1);
        end
        
        Color_Nodes = job.colorModules(Module_Nodes_Exist_colntext, :);
        H.Nodes = gretna_surf_plot_3dsphere(CORR_Nodes_Exist(:, 1), CORR_Nodes_Exist(:, 2),...
            CORR_Nodes_Exist(:, 3), Size_Nodes_Exist, Module_Nodes_Exist_shape,...
            H.axis, 'colormap', Color_Nodes);
    else % Texturemap
        
        if size(job.TextureModules,1) == 1
            job.TextureModules = repmat(job.TextureModules, Num_Nodes_Exist, 1);
        end
        
        Texture_Nodes = job.TextureModules(Module_Nodes_Exist_colntext, :);
        H.Nodes = gretna_surf_plot_3dsphere(CORR_Nodes_Exist(:, 1), CORR_Nodes_Exist(:, 2),...
                CORR_Nodes_Exist(:, 3), Size_Nodes_Exist, Module_Nodes_Exist_shape,...
                H.axis, 'texturemap', Texture_Nodes);
    end
    
    hold off;
end



%% Edges setting
if ~isempty(job.pathEdgeFile)
    MAT_Edges = importdata(job.pathEdgeFile);
    MAT_Edges = MAT_Edges(Size_Node>0, Size_Node>0);
    MAT_Edges = triu(MAT_Edges);
    
    [Node1_Pos_Edge, Node2_Pos_Edge] = find(MAT_Edges>0);
    [Node1_Neg_Edge, Node2_Neg_Edge] = find(MAT_Edges<0);
    
    NUM_Pos_Edge = length(Node1_Pos_Edge);
    NUM_Neg_Edge = length(Node1_Neg_Edge);
    
    if NUM_Pos_Edge > 0
        Corr_Node1_Pos_Edge   = MAT_Corr(Node1_Pos_Edge,:)';
        Corr_Node2_Pos_Edge   = MAT_Corr(Node2_Pos_Edge,:)';
        MAT_Pos_Edge_XYZ      = zeros(2,NUM_Pos_Edge*3);
        MAT_Pos_Edge_XYZ(1,:) = Corr_Node1_Pos_Edge(:);
        MAT_Pos_Edge_XYZ(2,:) = Corr_Node2_Pos_Edge(:);
        CELL_Pos_Edge_XYZ     = num2cell(MAT_Pos_Edge_XYZ, 1);
        job.LineColorPos      = repmat(job.LineColorPos, NUM_Pos_Edge, 1);
        
        if job.EdgeWeight     == 1
            CELL_Pos_Edge_Width = num2cell((mapminmax(MAT_Edges(MAT_Edges>0)')'+1.5)*2.2);
        elseif job.EdgeWeight == 0
            CELL_Pos_Edge_Width = num2cell(ones(NUM_Pos_Edge,1)*2.2);
        end
        
        CELL_Pos_Edge_Color   = num2cell(job.LineColorPos, 2);
        hold on;
        
        H.EdgesPos            = plot3(CELL_Pos_Edge_XYZ{:});
        set(H.EdgesPos,{'LineWidth'},CELL_Pos_Edge_Width);
        set(H.EdgesPos,{'Color'},CELL_Pos_Edge_Color);
        hold off;
    end
    
    if NUM_Neg_Edge > 0
        Corr_Node1_Neg_Edge   = MAT_Corr(Node1_Neg_Edge,:)';
        Corr_Node2_Neg_Edge   = MAT_Corr(Node2_Neg_Edge,:)';
        MAT_Neg_Edge_XYZ      = zeros(2,NUM_Neg_Edge*3);
        MAT_Neg_Edge_XYZ(1,:) = Corr_Node1_Neg_Edge(:);
        MAT_Neg_Edge_XYZ(2,:) = Corr_Node2_Neg_Edge(:);
        CELL_Neg_Edge_XYZ     = num2cell(MAT_Neg_Edge_XYZ, 1);
        job.LineColorNeg      = repmat(job.LineColorNeg, NUM_Neg_Edge, 1);
        
        if job.EdgeWeight == 1
            CELL_Neg_Edge_Width = num2cell((mapminmax(MAT_Edges(MAT_Edges<0)')'+1.5)*2.2);
        elseif job.EdgeWeight == 0
            CELL_Neg_Edge_Width = num2cell(ones(NUM_Neg_Edge,1)*3);
        end
        
        CELL_Neg_Edge_Color = num2cell(job.LineColorNeg, 2);
        hold on;
        
        H.EdgesNeg = plot3(CELL_Neg_Edge_XYZ{:});
        set(H.EdgesNeg,{'LineWidth'},CELL_Neg_Edge_Width);
        set(H.EdgesNeg,{'Color'},CELL_Neg_Edge_Color);
        hold off;
    end
end



%% Light, material and background

% Surface material
job.AmbientStrength  = p.Results.AmbientStrength;
job.DiffuseStrength  = p.Results.DiffuseStrength;
job.SpecularStrength = p.Results.SpecularStrength;
job.SpecularExponent = p.Results.SpecularExponent;

set(H.patch,...
    'AmbientStrength',  job.AmbientStrength,...
    'DiffuseStrength',  job.DiffuseStrength,...
    'SpecularStrength', job.SpecularStrength,...
    'SpecularExponent', job.SpecularExponent);

% Nodes Material
if ~isempty(job.pathNodeFile)
    Material_Nodes = findobj(H.Nodes, 'Type', 'Surface');
    set(Material_Nodes, 'AmbientStrength', 0.65, 'DiffuseStrength', 0.35, 'SpecularStrength', 0.35, 'SpecularExponent', 10);
end

% Light Setting
H.light(1) = camlight(H.light(1));
H.light(2) = light('Position',[0 0 1], 'Color', [0.4 0.4 0.4]);
H.light(3) = light('Position',[0 1 0], 'Color', [0.1 0.1 0.06]);
H.light(4) = light('Position',[0 0 -1],'Color', [0.4 0.4 0.4]);
H.light(5) = light('Position',[0 -1 0],'Color', [0.4 0.4 0.4]);



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

if ~isempty(pathNodeFile) 
    if ~isempty(Nodes(1, 6)) && job.Label==1
        Label_Node = Nodes{1, 6}; % Encode label
        for i_label = 1:length(Label_Node)
            if MAT_Corr(i_label,1) <= 0
                text(MAT_Corr(i_label,1)-5, MAT_Corr(i_label,2)-5,...
                    MAT_Corr(i_label,3)-5, num2str(Label_Node{i_label,1}),...
                    'HorizontalAlignment', 'right', 'FontSize', 15, 'FontName', job.LabelFontName);
            elseif MAT_Corr(i_label,1) >= 0
                text(MAT_Corr(i_label,1)+5, MAT_Corr(i_label,2)+5,...
                    MAT_Corr(i_label,3)+5, num2str(Label_Node{i_label,1}),...
                    'HorizontalAlignment', 'left', 'FontSize', 15, 'FontName', job.LabelFontName);
            end
        end
    end
end


%% print
if job.imgprint || ~isempty(job.imgprintDir)
    %%
    if isempty(job.imgprintDir)
        ppp = pwd;
    else
        ppp = job.imgprintDir;
    end
    
    if ~exist(ppp, 'dir')
        mkdir(ppp);
    end
    [~, fname, ~] = fileparts(pathNodeFile);
    pfname        = fullfile(ppp, sprintf('%s%s.%s', fname, viewname, 'tif'));
    
    print(H.figure , '-dtiff' , ['-r' num2str(job.dpi)], pfname );
end

end