% function CreateRFXs
clear; % Clean up your workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Change your parameters in following section:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cwd = '/data2/KangGuanlan/RMIS/PPI/First_level_0_0';
SubList = dir(fullfile(cwd,'2*'));
contrast_dir = {}; 

cwdadd = '/data2/KangGuanlan/RMIS/PPI/PPI_result/lMVis/N_inc-c';
mkdir(cwdadd);


stats = 'PPI/lMVis/N_inc-c';               %The name of dir of stats 
nses = 5;                       %How many sessions per subject?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%End of your parameters section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_defaults
global defaults
cd(cwd)   % CHANGE TO YOUR PATH
tic

RFXHOME = cwdadd;

subdir = fullfile(cwd,SubList(1).name);
cd(subdir);
cd(stats);
load SPM;

ocon=length(SPM.xCon);   %How many contrasts are totally in SPM.mat.
ionc=1;
%length(SPM.Sess(1).U)*length(SPM.Sess)+1+1; %The order that user define

%create rfxdir of every contrast defined by users
for xcon= ionc:ocon
    swd=SPM.xCon(xcon).name;
    swd(find(swd == ' ')) = '';
    swd(find(swd == '&')) = '+';
    rfxdir=fullfile(RFXHOME, sprintf('%d_%s',xcon,swd));
    if (exist(rfxdir) ~= 7)
        disp(sprintf('creating %s directory',rfxdir)) 
        switch (spm_platform('filesys'))
            case 'win' 
                eval(sprintf('!md %s', rfxdir));
            case 'unx'
                eval(sprintf('!mkdir %s', rfxdir));
        end
    end
end

for sub = 1:length(SubList)
    
    %disp(sprintf('copying sub%d files',subs(sub))) 

    subdir = fullfile(cwd, SubList(sub).name);
    cd(subdir);
    cd(stats);
    load SPM;
    pwd
    
    for xcon= ionc:ocon
        swd=SPM.xCon(xcon).name;
        swd(find(swd == ' ')) = '';
        swd(find(swd == '&')) = '+';
        rfxdir=fullfile(RFXHOME, sprintf('%d_%s',xcon,swd));
        
        
        surfile=SPM.xCon(xcon).Vcon.fname;
        if xcon < 10
            desfile=fullfile(rfxdir, [SubList(sub).name, sprintf('_con_000%d.img',xcon)]);
        elseif xcon >= 10
            desfile=fullfile(rfxdir, [SubList(sub).name, sprintf('_con_00%d.img', xcon)]);
        end
        % desfile=fullfile(rfxdir, sprintf('sub%d_%s', sub, SPM.xCon(xcon).Vcon.fname));
        copyfile(surfile,desfile);
        
        [pth,nam,ext] = fileparts(surfile);
        hdr_surfile=fullfile(pth,[nam '.hdr']);
        if xcon < 10
            hdr_desfile=fullfile(rfxdir, [SubList(sub).name,sprintf('_con_000%d.hdr', xcon)]);
        elseif xcon >= 10
            hdr_desfile=fullfile(rfxdir, [SubList(sub).name,sprintf('_con_00%d.hdr', xcon)]);
        end
        copyfile(hdr_surfile,hdr_desfile);
    end
    
end % for sub
disp(sprintf('.........copying files is over.........')) 
toc