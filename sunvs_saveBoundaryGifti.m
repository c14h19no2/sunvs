function sunvs_saveBoundaryGifti(PATH_lh_annotFile, PATH_rh_annotFile, NAME_file)
%==========================================================================
% This function generate gifti files containing atlas boundary.
%
%
% Syntax: sunvs_saveBoundaryGifti(PATH_lh_annotFile, PATH_rh_annotFile, NAME_file)
% 
% Input:
%     PATH_lh_annotFile: 
%              The directory & filename of an .annot file.
%     PATH_rh_annotFile: 
%              The directory & filename of an .annot file. 
%     NAME_file:
%              File name.
%==========================================================================

[~,~, ext] = fileparts(PATH_lh_annotFile);

switch ext
    case '.annot'
        [~, label_lh, colortable_lh] =  read_annotation(PATH_lh_annotFile);
        [~, label_rh, colortable_rh] =  read_annotation(PATH_rh_annotFile);
        label_dim_lh = colortable_lh.table(2:end,5);
        label_dim_rh = colortable_rh.table(2:end,5);
    case '.gii'
        lh = gifti(PATH_lh_annotFile);
        rh = gifti(PATH_rh_annotFile);
        label_lh = double(lh.cdata);
        label_rh = double(rh.cdata);
        label_dim_lh = unique(label_lh);
        label_dim_rh = unique(label_rh);
        label_dim_lh = label_dim_lh(~isnan(label_dim_lh)&label_dim_lh~=0);
        label_dim_rh = label_dim_rh(~isnan(label_dim_rh)&label_dim_rh~=0);
        
end

Num_node_lh = length(label_dim_lh);
Num_node_rh = length(label_dim_rh);
NumVer      = length(label_lh);

PATH_thisFile   = which('sunvs_saveBoundaryGifti');
PATH_thisFolder = fileparts(PATH_thisFile);
PATH_matFolder  = [PATH_thisFolder filesep 'nodalBoundaryList'];
PATH_catMfile   = which('cat12');
PATH_catFolder  = fileparts(PATH_catMfile);


switch NumVer
case 163842
    structNei = load([PATH_matFolder filesep 'vertexNeighbor_fsaverage_164k_2layers.mat']);
    verNeighbors_lh = structNei.verNeighbors;
    verNeighbors_rh = structNei.verNeighbors;
    PATH_lh_giftiTemplate = [PATH_catFolder filesep 'templates_surfaces'...
     filesep 'lh.central.Template_T1_IXI555_MNI152_GS.gii'];
    PATH_rh_giftiTemplate = [PATH_catFolder filesep 'templates_surfaces'...
     filesep 'rh.central.Template_T1_IXI555_MNI152_GS.gii'];
case 32492
    structNei_lh    = load([PATH_matFolder filesep 'vertexNeighbor_fs_LR_32k_2layers_lh.mat']);
    structNei_rh    = load([PATH_matFolder filesep 'vertexNeighbor_fs_LR_32k_2layers_rh.mat']);
    verNeighbors_lh = structNei_lh.verNeighbors;
    verNeighbors_rh = structNei_rh.verNeighbors;
    PATH_lh_giftiTemplate = [PATH_catFolder filesep 'templates_surfaces_32k'...
     filesep 'lh.central.Template_T1_IXI555_MNI152_GS.gii'];
    PATH_rh_giftiTemplate = [PATH_catFolder filesep 'templates_surfaces_32k'...
     filesep 'rh.central.Template_T1_IXI555_MNI152_GS.gii'];
end

fs_centralIXI_lh = gifti(PATH_lh_giftiTemplate);
fs_centralIXI_rh = gifti(PATH_rh_giftiTemplate);

verlist_Node_lh   = cell(Num_node_lh,1);
Boundlist_Node_lh = cell(Num_node_lh,2);

verlist_Node_rh   = cell(Num_node_rh,1);
Boundlist_Node_rh = cell(Num_node_rh,2);

len_vernei_lh = zeros(NumVer,1);
len_vernei_rh = zeros(NumVer,1);

for i = 1:NumVer
    len_vernei_lh(i) = length(verNeighbors_lh{i,2});
    len_vernei_rh(i) = length(verNeighbors_rh{i,2});
end

for i_node_lh = 1:Num_node_lh
    verlist_Node_lh{i_node_lh} = find(label_lh==label_dim_lh(i_node_lh));
    ver_Nei_list = verNeighbors_lh(verlist_Node_lh{i_node_lh},2);
    ver_Nei_list_cat = cat(1,ver_Nei_list{:});
    for i_ver_node_lh = 1:length(verlist_Node_lh{i_node_lh})
        ver_num = find(ver_Nei_list_cat == verlist_Node_lh{i_node_lh}(i_ver_node_lh));
        if length(ver_num) <= len_vernei_lh(verlist_Node_lh{i_node_lh}(i_ver_node_lh)) - 1
            Boundlist_Node_lh{i_node_lh,1} = [Boundlist_Node_lh{i_node_lh,1} verlist_Node_lh{i_node_lh}(i_ver_node_lh)];
            Boundlist_Node_lh{i_node_lh,2} = [Boundlist_Node_lh{i_node_lh,2};verNeighbors_lh{verlist_Node_lh{i_node_lh}(i_ver_node_lh),2}];
        end
    end
end

for i_node_rh = 1:Num_node_rh
    verlist_Node_rh{i_node_rh} = find(label_rh==label_dim_rh(i_node_rh));
    ver_Nei_list = verNeighbors_rh(verlist_Node_rh{i_node_rh},2);
    ver_Nei_list_cat = cat(1,ver_Nei_list{:});
    for i_ver_node_rh = 1:length(verlist_Node_rh{i_node_rh})
        ver_num = find(ver_Nei_list_cat == verlist_Node_rh{i_node_rh}(i_ver_node_rh));
        if length(ver_num) <= len_vernei_rh(verlist_Node_rh{i_node_rh}(i_ver_node_rh)) - 1
            Boundlist_Node_rh{i_node_rh,1} = [Boundlist_Node_rh{i_node_rh,1} verlist_Node_rh{i_node_rh}(i_ver_node_rh)];
            Boundlist_Node_rh{i_node_rh,2} = [Boundlist_Node_rh{i_node_rh,2};verNeighbors_rh{verlist_Node_rh{i_node_rh}(i_ver_node_rh),2}];
        end
    end
end

fs_centralIXI_lh.cdata = zeros(NumVer,1);
for i_node_lh = 1:Num_node_lh
    fs_centralIXI_lh.cdata(Boundlist_Node_lh{i_node_lh,1},1) = 1;
    fs_centralIXI_lh.cdata(Boundlist_Node_lh{i_node_lh,2},1) = 1;
end

fs_centralIXI_rh.cdata = zeros(NumVer,1);
for i_node_rh = 1:Num_node_rh
    fs_centralIXI_rh.cdata(Boundlist_Node_rh{i_node_rh,1},1) = 1;
    fs_centralIXI_rh.cdata(Boundlist_Node_rh{i_node_rh,2},1) = 1;
end

save(fs_centralIXI_lh, ['lh.' NAME_file '.gii'], 'Base64Binary');
save(fs_centralIXI_rh, ['rh.' NAME_file '.gii'], 'Base64Binary');

end
