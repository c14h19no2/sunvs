function verNeighbors = sunvs_verNeighbors(NUM_layer, template)

%==========================================================================
% This function is used to find neighbors of all vertices in the brain
% surface. For a given vertex, its neighbors are defined vertices that can
% be reached via N layers of faces in the brain surface.
%
% Syntax: function verNeighbors = sunvs_ver_neighbors(Layer)
%
% Input:
%          NUM_layer:
%                  The number of layers.
%          template:
%                  'fsaverage_164k';
%                  'fs_LR_32k_lh' & 'fs_LR_32k_rh';;
% Output:
%       verNeighbors:
%                  A M*N cell including neighbors of every layer, with M
%                  indicating the number of vertex and N indicating the
%                  number of layers + 1. E.g., the 1st column of verNeighbors
%                  includes the vertex itself, the 2nd column includes the
%                  neighbors of the first layer, the 3rd column includes
%                  the neighbors of the second layer, and so on.
%
% Ningkai WANG,HZNU, Hangzhou, 2017/1/17, ningkai.wang.1993@gmail.com
% Jinhui WANG, HZNU, Hangzhou, 2017/1/17, jinhui.wang.1982@gmail.com
%==========================================================================

PATH_thisFile = which('sunvs_ver_neighbors');
PATH_thisFolder = fileparts(PATH_thisFile);
PATH_matFolder = [PATH_thisFolder filesep 'nodalBoundaryList'];

switch template
    case 'fsaverage_164k'
        facesStruct = load([PATH_matFolder filesep 'faces_fsaverage_164k.mat']);
    case 'fsaverage_32k'
        error('fsaverage_32k is not supported');
    case 'fs_LR_32k_lh'
        facesStruct = load([PATH_matFolder filesep 'faces_fs_LR_32k_lh.mat']);
    case 'fs_LR_32k_rh'
        facesStruct = load([PATH_matFolder filesep 'faces_fs_LR_32k_rh.mat']);
end

faces = facesStruct.faces;

Num_ver = max(faces(:));
verNeighbors = cell(Num_ver,NUM_layer+1);
[Length_faces,Width_faces] = size(faces);

for iVer              = 1:Num_ver
    verNeighbors{iVer,1} = iVer;
end

for iVer     = 1:Num_ver
    List_nei = [];
    
    for         iWidth_faces                      =  1:Width_faces;
        for     iLength_faces                     =  1:Length_faces;
            if  faces(iLength_faces,iWidth_faces) == iVer
                List_nei                          =  [List_nei faces(iLength_faces,:)];
            end
        end
    end
    
    [Ver_all_nei,Firstloc] = unique(List_nei','first');
    Locresult              = sortrows([Firstloc,Ver_all_nei]);
    verNeighbors{iVer,2}      = Locresult(:,2);
    verNeighbors{iVer,2}      = verNeighbors{iVer,2}(verNeighbors{iVer,2}~=iVer);
    
end

% calculate the outer neighbors
if NUM_layer >= 2
    for Num_neilist  = 3:NUM_layer+1
        for iVer     = 1:Num_ver
            List_nei = [];
            for ii       = 1:length(verNeighbors{iVer,Num_neilist-1})
                List_nei = [List_nei;verNeighbors{verNeighbors{iVer,Num_neilist-1}(ii),2}];
            end
            verNeighbors{iVer,Num_neilist} = unique(List_nei);
            verNeighbors{iVer,Num_neilist} = setdiff(verNeighbors{iVer,Num_neilist},verNeighbors{iVer,Num_neilist-1});
            verNeighbors{iVer,Num_neilist} = setdiff(verNeighbors{iVer,Num_neilist},verNeighbors{iVer,Num_neilist-2});
        end
    end
end

return