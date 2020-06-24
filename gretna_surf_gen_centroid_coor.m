function [CenCoor] = gretna_surf_gen_centroid_coor(Path_gifti, Path_annot)

%==========================================================================
% This function is used to calculate centroid coordination included of each ROI
% in a gifti image, where the ROIs are defined by an annot file.
% 
%
% Syntax: function [CenCoor] = gretna_surf_gen_centroid_coor(Path_filename, Path_annot)
%
% Input:
%  Path_filename:
%                The directory & filename of a gifti file, this gifti file defines
%                the shape of the surface.
%     Path_annot:
%                The directory & filename of a template annot file, the annot file
%                is an atlas file which defines ROIs.
%
% Output:
%        CenCoor:
%                The centroid coordination of each ROI.
%
% Jinhui WANG, IBRR, SCNU, Guangzhou, 2020/01/24, jinhui.wang.1982@gmail.com
% Ningkai WANG,IBRR, SCNU, Guangzhou, 2020/01/24, Ningkai.Wang.1993@gmail.com
%==========================================================================

g        = gifti(Path_gifti);
Vertices = g.vertices;

if nargin == 1
    c            = g.cdata;
    Label_region = unique(c(~isnan(c)));
    Num_regs     = max(Label_region);
elseif nargin == 2
    [~, Label, Colortable] = read_annotation(Path_annot);
    Label_region = Colortable.table(2:end, 5);
    Num_regs     = length(Label_region);
end

CenCoor = zeros(Num_regs,3);

for i_roi    = 1:Num_regs
    Ind_roi  = Label_region(i_roi);
    Index    = Label == Ind_roi;
    CenCoor(i_roi,:) = mean(Vertices(Index,:), 1);
end

end