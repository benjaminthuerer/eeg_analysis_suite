% EEG-data processing for EEG-TMS combined
% Consciousness Study Oslo
% 
% [EEG,locFile] = UiO_trials(data_struct,subj_name,EEG,locFile)
% 
% data_struct: structure of the csv-file specified for subject and
%               experiment
% EEG: EEG structure of previous function. If empty [] this function will
%       load the last processed data (if availeble)
% subj_name: subject name according to csvfile
% locFile: locFile of previous function. If empty [] this function will
%       load the last processed locFile (if availeble)
%
% This function will epoch the continous data into trials and remove bad
% 
% by questions: benjamin.thuerer@kit.edu
% 
function [EEG,locFile] = UiO_trials(data_struct,subj_name,EEG,locFile)

if nargin < 2
    error('provide at least data_struct and subject name. See help UiO_trials')
end

exist data_struct.load_data;

if ans == 0
    data_struct.load_data = '0';
end

% check if EEG structure is provided. If not, load previous data
if isempty(EEG)
    if str2double(data_struct.load_data) == 0
        [EEG,locFile] = UiO_load_data(data_struct,subj_name,'after_pca');   
    else
        [EEG,locFile] = UiO_load_data(data_struct,subj_name,[],'specific_data');
    end
end
  
% epoch data to trials (EEG*times*trials)
EEG = pop_epoch( EEG, {  'R128'  }, [str2double(data_struct.trial_start)/EEG.srate str2double(data_struct.trial_end)/EEG.srate] ...
    , 'newname', ' resampled epochs', 'epochinfo', 'yes');

%remove bad epochs either automized (1) or by inspection (2)
if str2double(data_struct.trial_rejection) == 1
    EEG = pop_eegthresh(EEG,1,[1:EEG.nbchan-2],-str2double(data_struct.trial_threshold),str2double(data_struct.trial_threshold),EEG.times(1)/1000,EEG.times(end)/1000,0,1);
elseif str2double(data_struct.trial_rejection) == 2
    MElec = squeeze(mean(EEG.data,1));
    [~,idx(1)] = min(abs(EEG.times-(-500)));
    [~,idx(2)] = min(abs(EEG.times-(500)));
    
    goodTrial = [];
    badTrial = [];

    % plot the average over channels for each trial and distinguish between good
    % and bad trials according to the mouse / space click
    for Ei = 1:size(MElec,2)
        h = figure;
        plot(EEG.times(idx(1):idx(2)),MElec(idx(1):idx(2),Ei));
        title(['Trial ' int2str(Ei) ': press space to remove trial']);
        grid
        axis([-500 500 -15 15]);
        ylabel('Amplitude (\muV)'); xlabel('Time (ms)');
        button = waitforbuttonpress;
        if button == 0
            goodTrial(end+1) = Ei;
        else
            badTrial(end+1) = Ei;
        end
        close(h)
    end

    % plot the average for each trial again and show the actual
    % marking of the trial. Press space if you changed your mind
    for Ei = 1:size(MElec,2)
        if find(goodTrial==Ei)
            Stigma = 'good';
        else
            Stigma = 'bad';
        end
        h = figure;
        plot(EEG.times(idx(1):idx(2)),MElec(idx(1):idx(2),Ei));
        title({['Trial ' int2str(Ei) ' marked as ' Stigma] ; ...
            ['if you want to change the mark (regardless of direction g-->b; b-->g) press space']});
        grid
        axis([-500 500 -15 15]);
        ylabel('Amplitude (\muV)'); xlabel('Time (ms)');
        button = waitforbuttonpress;
        if button ~= 0
            if find(badTrial==Ei)
                idx_Ei = badTrial == Ei;
                badTrial(idx_Ei) = [];
            else
                badTrial(end+1) = Ei;
            end
        end
        close(h)
    end

    % sort bad trials and remove bad trials from the dataset
    badTrial = sort(badTrial);
    EEG.nbchan = EEG.nbchan-length(badChan);
    EEG.data(badChan,:) = [];
else
    warning('trial rejection is not accuratly provided in csvfile. Rejection is done automatically')
end
    
% store rejected trials in the structure
EEG.accBadEpochs = [];
EEG.accBadEpochs = find(EEG.reject.rejthresh);

% loc file entry
locFile{end+1} = {'epoched',['epoched data from ' data_struct.trial_start 'to ' data_struct.trial_end 'ms. ' ...
    num2str(EEG.accBadEpochs) ' trials are rejected by ' data_struct.trial_rejection ' ' ...
    '(0 = visual inspection; 1 = automatically)']};

end


