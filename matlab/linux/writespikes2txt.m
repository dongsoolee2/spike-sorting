function e = writespikes2txt(mat_data_path)
%
% function e = writespikes(mat_data_path)
%
% Write spike time files, one for each cell, after sorting is completed.
%
% Input:
% 	mat_data_path	- Full path to .mat file returned from spike sorting
%
% Output:
%	writes spikes to txt files, one per cell
%
% 2015-11-26 Lane McIntosh
% edited by Dongsoo Lee (2017-09-01) to deal with empty channels better

%% Load the sorting structure
try
    s = load(mat_data_path);
catch
    'Could not load MAT file!'
end

%% Store the g structure of the MAT file
g = s.g;
clear s;

%% Find the non-empty channels
chans = find(~cellfun(@isempty,g.chanclust))

%% Loop over these channels, writing each spike time
nchans = length(chans);
cellidx = 1;

for ci = 1:nchans
    % How many cells on this channel?
    [a, b] = size(g.chanclust{chans(ci)});
    ncells = a * b;
    
    for fi = 1:ncells

        
        % Compute the spike times by dividing by sample rate
        x = ceil(fi/b);
        y = rem(fi, b);
        if y == 0
            y = b;
        end

        %if ~isempty(g.chanclust{chans(ci)}{x, y})
        if ~isempty(g.chanclust{chans(ci)}{x, 1})
            % Open a text file for this cell
            fid = fopen(sprintf('c%02d.txt', cellidx), 'wt');
            fprintf(1, 'writing spike times for cell %d ... ', cellidx);

            spikes = (g.chanclust{chans(ci)}{x, y} ./ g.scanrate);
        
            % Write them to the file
            fprintf(fid, '%f\n', spikes);
        
            % Close the file
            fclose(fid);
            fprintf('done.\n');
        
            % Update cell counter
            cellidx = cellidx + 1;
        end
    end
end
