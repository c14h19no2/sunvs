function h = gretna_surf_plot_3dsphere(x, y, z, scalefactor, shapefactor, AXIS, varargin)

%==========================================================================
% This function generates 3D sphere nodes for function gretna_surf_net_viewer.
%
%
% Syntax: function h = gretna_surf_plot_3dsphere(x, y, z, scalefactor, axis, varargin)
%
% Input:
%        x, y, z:
%                XYZ Corrdinate (N*1 matrix for each variable, where N is the
%                number of nodes).
%    scalefactor:
%                Size scale factor for each node (N*1 matrix).
%    shapefactor:
%                Shape factor for each node (N*1 matrix).
%                0: Shpere;
%                1: Cube;
%                2: Regular tetrahedron;
%                3: Dodecahedron.
%           axis:
%                Existing axis.
% Parameters:
%       colormap:
%                RGB infomation of each node (N*3 matrix).
%     texturemap:
%                Directorie & filename of the texture image file
%                of each node (N*1 cell).
%
% Created from
% Created by MathWorks Support Team, 2010 (https://www.mathworks.com/matlabcentral/answers/98968-how-do-i-make-a-scatter-plot-with-spheres).
% Modified by Ningkai WANG, 2020.
%
% Jinhui WANG, IBRR, SCNU, Guangzhou, 2020/01/13, jinhui.wang.1982@gmail.com
% Ningkai WANG,IBRR, SCNU, Guangzhou, 2020/01/13, Ningkai.Wang.1993@gmail.com
%==========================================================================

NUM_nodes = length(x);

if any(shapefactor<0) || any(shapefactor>3) || any(rem(shapefactor,1)~=0)
    error('Shape index must be integer between 0 to 3, please check your .node file');
end

p = inputParser;
addParameter(p, 'colormap',   [], @(x) size(x,2)==3 && size(x,1)==NUM_nodes && isnumeric(x));
addParameter(p, 'texturemap', {}, @(x) size(x,2)==1 && size(x,1)==NUM_nodes && iscell(x));
parse(p, varargin{:});

if isempty(p.Results.colormap) && isempty(p.Results.texturemap)
    error('Colormap or texturemap is needed!')
end

if any(shapefactor>2) && ~isempty(p.Results.texturemap)
    error('Only sphere and cube is supported in the texturemap mode');
end

x = x'; y = y'; z = z';
my_colors = p.Results.colormap;

%% Create unit nodes

% Create unit sphere
[xSph, ySph, zSph] = sphere(500);

% Create unit cube
if any(shapefactor == 1) 
    [xCube, yCube, zCube] = CreateUnitCube(p.Results.texturemap); 
    xCubeNode = cell(6,1);
    yCubeNode = cell(6,1);
    zCubeNode = cell(6,1);
end

if any(shapefactor == 2)
    TransMatrix = ...
        [cos(90), -sin(90), 0;...
         sin(90), cos(90),  0;...
         0,       0,        1];
    
    PTri1 = [0, 0, 1;...
        -1.2, 0.7, -1;...
        0,   -1.4, -1;...
        1.2,  0.7, -1];
    
    PTri1 = PTri1*TransMatrix.*0.95;
end

if any(shapefactor == 3)
    [Dodecahedron1] = CreateUnitDodecahedron .* 0.63;
end

% if any(shapefactor == 4)
%     [x1,y1,z1] = sphere(3);
%     x1 = x1(:);
%     y1 = y1(:);
%     z1 = z1(:);
%     P1 = [x1 y1 z1];
%     P1 = unique(P1,'rows');
% end

%%
if ~isempty(p.Results.colormap)
    for ind = 1:length(x)
        
        switch shapefactor(ind)
            case 0
                xNode = scalefactor(ind) * xSph;
                yNode = scalefactor(ind) * ySph;
                zNode = scalefactor(ind) * zSph;
                surf(AXIS, x(ind) + xNode, y(ind) + yNode, z(ind) + zNode,...
                    'FaceColor', my_colors(ind,:), 'EdgeColor', 'none');
                
            case 1
                for iCube = 1:6
                    xCubeNode{iCube} = scalefactor(ind) * xCube{iCube};
                    yCubeNode{iCube} = scalefactor(ind) * yCube{iCube};
                    zCubeNode{iCube} = scalefactor(ind) * zCube{iCube};
                    
                    surf(AXIS,...
                        x(ind) + xCubeNode{iCube}, ...
                        y(ind) + yCubeNode{iCube},...
                        z(ind) + zCubeNode{iCube},...
                        'FaceColor', my_colors(ind,:),...
                        'EdgeColor', 'none');
                end
                
            case 2
                PTri2 = PTri1 .* scalefactor(ind) + repmat([x(ind), y(ind), z(ind)], 4, 1);
                shp = alphaShape(PTri2);
                plot(shp,'FaceColor', my_colors(ind,:),'EdgeColor', 'none');
                
            case 3
                Dodecahedron2 = Dodecahedron1 .* scalefactor(ind) + repmat([x(ind), y(ind), z(ind)], 20, 1);
                shp = alphaShape(Dodecahedron2,100);
                plot(shp,'FaceColor', my_colors(ind,:),'EdgeColor', 'none');
                
%             case 4
%                 P2 = scalefactor(ind) .* P1;
%                 shp = alphaShape(P2,100);
%                 plot(shp,'FaceColor', my_colors(ind,:), 'EdgeColor', 'none');
                
        end
    end
    
elseif ~isempty(p.Results.texturemap)
    
    imageText = cell(length(p.Results.texturemap),1);
    
    for ind_texture = 1:length(p.Results.texturemap)
        imageText{ind_texture} = imread(p.Results.texturemap{ind_texture});
    end
    
    for ind = 1:length(x)
        switch shapefactor(ind)
            case 0
                xNode = scalefactor(ind) * xSph;
                yNode = scalefactor(ind) * ySph;
                zNode = scalefactor(ind) * zSph;
                
                surf(AXIS, x(ind) + xNode, y(ind) + yNode, z(ind) + zNode,...
            imageText{ind,1}, 'edgecolor', 'none', 'FaceColor', 'texturemap');
        
            case 1
                for iCube = 1:6
                    xCubeNode{iCube} = scalefactor(ind) * xCube{iCube};
                    yCubeNode{iCube} = scalefactor(ind) * yCube{iCube};
                    zCubeNode{iCube} = scalefactor(ind) * zCube{iCube};
                    
                    surf(AXIS,...
                        x(ind) + xCubeNode{iCube}, ...
                        y(ind) + yCubeNode{iCube},...
                        z(ind) + zCubeNode{iCube},...
                        imageText{ind,1},...
                        'FaceColor', 'texturemap',...
                        'EdgeColor', 'none');
                end
            case 2
                
        end
        
        
        
    end
end

h = findall(AXIS, 'Type', 'surface');
end

%% Create Unit Cube
function [xCube, yCube, zCube] = CreateUnitCube(Ind_Texturemap)

if ~isempty(Ind_Texturemap)
    DIM_Mesh = 100;
else
    DIM_Mesh = 2;
end

LineCube = linspace(-0.806, 0.806, DIM_Mesh);

xCube = cell(6,1);
yCube = cell(6,1);
zCube = cell(6,1);

[xCube{1}, yCube{1}, zCube{1}] = meshgrid(LineCube, LineCube,  0.806);
[xCube{2}, yCube{2}, zCube{2}] = meshgrid(LineCube, LineCube, -0.806);
[xCube{3}, yCube{3}, zCube{3}] = meshgrid(LineCube,  0.806, LineCube);
[xCube{4}, yCube{4}, zCube{4}] = meshgrid(LineCube, -0.806, LineCube);
[xCube{5}, yCube{5}, zCube{5}] = meshgrid( 0.806, LineCube, LineCube);
[xCube{6}, yCube{6}, zCube{6}] = meshgrid(-0.806, LineCube, LineCube);

for iCube = 1:6
    xCube{iCube} = squeeze(xCube{iCube});
    yCube{iCube} = squeeze(yCube{iCube});
    zCube{iCube} = squeeze(zCube{iCube});
end

end

%% Create Unit Tri
function [Dodecahedron] = CreateUnitDodecahedron

tau = (1+sqrt(5))/2;
Dodecahedron = [1,  1,  1;...
    1,   1, -1;...
    1,  -1,  1;...
    1,  -1, -1;...
    -1,  1,  1;...
    -1,  1, -1;...
    -1, -1,  1;...
    -1, -1, -1;...
    0,  tau,  1./tau;...
    0,  tau, -1./tau;...
    0, -tau,  1./tau;...
    0, -tau, -1./tau;...
     1./tau, 0,  tau;...
     1./tau, 0, -tau;...
    -1./tau, 0,  tau;...
    -1./tau, 0, -tau;...
     tau,  1./tau, 0;...
     tau, -1./tau, 0;...
    -tau,  1./tau, 0;...
    -tau, -1./tau, 0;...
    ];

end