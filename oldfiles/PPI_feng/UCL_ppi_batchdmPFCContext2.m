% This batch script analyses the Attention to Visual Motion fMRI dataset
% available from the SPM site using PPI:
% http://www.fil.ion.ucl.ac.uk/spm/data/attention/
% as described in the SPM manual:
%  http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf

% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Guillaume Flandin & Darren Gitelman
% $Id: ppi_spm_batch.m 17 2009-09-28 15:37:01Z guillaume $

% Directory containing the attention data
%---------------------------------------------------------------------
% data_path = 'C:\data\path-to-data';'sub103' 'sub104'
%data_path = spm_select(1,'dir','Select the attention data directory');'sub1' 'sub2' 'sub3' 'sub4'
%   subjects = {'cuixirui_01'  'cuixirui_04' 'cuixirui_05' 'cuixirui_06' 'cuixirui_07' 'cuixirui_08' 'cuixirui_10' 'cuixirui_11' 'cuixirui_12' 'cuixirui_13' 'cuixirui_14' 'cuixirui_15'  'cuixirui_16' 'cuixirui_17' 'cuixirui_18' 'cuixirui_19' 'cuixirui_20' 'cuixirui_21'  'cuixirui_22'  'cuixirui_23' 'cuixirui_25'  'cuixirui_26' 'cuixirui_28'};% 'cuixirui_12' 'sub113' 'sub113' 'sub114' 'sub115' 'sub116'  'sub103' 'sub104' 'sub105' 'sub106' 'sub107' 'sub108' 'sub109' 'sub111' 'sub112' 'sub114' 'sub115' 'sub116' 'sub118' 'sub119' 'sub120' 'sub121' 'sub122' 'sub124' 'sub125' 'sub126' 'sub127' 'sub128' 'sub129' 'sub130' };%'sub105' 'sub106' 'sub107' 'sub108' 'sub109' 'sub110' 'sub111' 'sub112' 'sub113' 'sub113' 'sub114' 'sub115' 'sub116' 'sub117' 'sub118' };% 'sub101' 'sub102' 'sub103''sub4' 'sub5' 'sub6' 'sub7' 'sub8' 'sub9' 'sub10' 'sub11' 'sub12' 'sub13' 'sub14' 'sub15' 'sub16'};%{ 'sub2'  'sub3' 'sub4' 'sub5' 'sub6' 'sub7' 'sub8' 'sub9' 'sub10' 'sub11' 'sub12'};


data_fad = 'E:\ShenBo\GR\Model\FirstLevel';
SubList = dir(fullfile(data_fad,'2*'));
contrast_dir = {};
PPIName = 'PPI_rAI_C2_Sh_S-O';
contrastmatrix = [5 1 -1;6 1 1];
nb_sess =3;
% Initialise SPM
%---------------------------------------------------------------------
spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only (does nothing in SPM5)

for sub = 1:length (SubList)
    for sess =1:nb_sess
        % Working directory (useful for .ps outputs only)
        %---------------------------------------------------------------------
        clear jobs
        
        data_path = fullfile(data_fad,SubList(sub).name);
        VOI_path = fullfile(data_fad,SubList(sub).name,'VOI');
        jobs{1}.util{1}.cdir.directory = cellstr(data_path);
        spm_jobman('run',jobs);
        
        
        load ([VOI_path '/VOI_rAI_' num2str(sess) '.mat']);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % PSYCHO-PHYSIOLOGIC INTERACTION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % GENERATE PPI STRUCTURE
        % =====================================================================
        PPI = spm_peb_ppi(fullfile(data_path,'SPM.mat'),'ppi',xY,...
            contrastmatrix,[PPIName,num2str(sess)],1);   % contrast!!!!!!!!!!!!!!!!!!!!!!!!!!!
        %number of condition, 1, contrast
        
        clear jobs
        PPI_dir = [data_path,'/PPI'];
        
        if ~exist (PPI_dir)
            mkdir(PPI_dir);
        end;
        
        jobs{1}.util{1}.md.basedir = cellstr(PPI_dir);
        jobs{1}.util{1}.md.name = 'PPI';
        spm_jobman('run',jobs);
    end;
end;

%%
for sub=1:length(SubList)
    
    %dicom_path = fullfile(dicomfad, dicom_sub{subnr},'\attractive')
    old_path=fullfile(data_fad, SubList(sub).name);
    %mkdir([raw_path, '\gender']);
    new_path=fullfile(data_fad, SubList(sub).name,'PPI',PPIName);
    if ~exist (new_path)
        mkdir(new_path);
    end
    %destination2=fullfile(dicomfad, dicom_sub{subnr},'\attractive\run2');
    
    cd (old_path)
    movefile(['PPI_' PPIName '*.mat'],new_path);
    %copyfile('rp*.txt',new_path);
    % movefile('fr*-0002-*.hdr',destination1);
    display (['moving files from  ',old_path,' to ',new_path ]);
    % movefile('fr*-0003-*.img',destination2);
    % movefile('fr*-0003-*.hdr',destination2);
    % display (['moving files from',dicom_path,'to',destination2 ]);
end;