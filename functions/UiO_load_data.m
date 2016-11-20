% EEG-data processing for EEG-TMS combined
% Consciousness Study Oslo
% 
% [EEG,locFile] = UiO_load_data(data_struct,subj_name,file_step)
% 
% data_struct: structure of the csv-file specified for subject and
%               experiment
% subj_name: subject name according to csvfile
% file_step: last step in EEG-analysis to load that file
%
% This function will load the eeg file and locFile of the last processing
% step in the EEG-analysis.
% 
% by questions: benjamin.thuerer@kit.edu
%
function [EEGF,LOCF] = UiO_load_data(data_struct,subj_name,file_step,specific_name)

% create file and loc name
if nargin < 4
    load_name = [subj_name{1} '_' data_struct.session '_' file_step];
    loc_name = [subj_name{1} '_' data_struct.session '_locFile'];
else
    load_name = data_struct.load_data;
    if strfind(load_name,'.mat')
        load_name = load_name(1:end-4);
    end
    Session_idx = strfind(load_name,data_struct.session);
    line_idx = strfind(load_name(Session_idx(end):end),'_');
    loc_name = [load_name(1:line_idx(end)) '_locFile'];
end

% check if file_save path is provided and check for / or \
if str2double(data_struct.save_folder) == 0
    if isempty(strfind(data_struct.vhdrsource,'\'))
        char_idx = strfind(data_struct.vhdrsource,'/'); 
    else
        char_idx = strfind(data_struct.vhdrsource,'\');
    end
    data_path = data_struct.vhdrsource(1:char_idx(end));
    load_file = [data_path  load_name];
    load_loc = [data_path loc_name];
else
    % if save_folder path provided, check if / or \ is used
    subfolder1 = subj_name{1};
    subfolder2 = data_struct.session;
    
    if isempty(strfind(data_struct.save_folder,'\'))
        load_folder2 = [data_struct.save_folder '/' subfolder1 '/' subfolder2];
        load_file = [load_folder2 '/' load_name];
        load_loc = [load_folder2 '/' loc_name]; 
    else
        load_folder2 = [data_struct.save_folder '\' subfolder1 '\' subfolder2];
        load_file = [load_folder2 '\' load_name];
        load_loc = [load_folder2 '\' loc_name];
    end    
end

disp(['load data: ' load_name]);
load([load_file '.mat']);
load([load_loc '.mat']);

% this step is not necessary...
EEGF = EEG;
LOCF = locFile;

end