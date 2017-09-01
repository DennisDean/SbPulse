function santen_bardin_mod_12(data_file, graph_title, x_label, y_label,comments, ...
    assay_cov, algor_value, start_peak, Sample_id,yscale,zero_time,time_scale, ...
    user_y_scale)
% Program calculates the modified Santen - Bardin Function
%
% First created: August 14, 2002
% Programmer: Dennis A. Dean
%
% Overview:
% This script sumarizes the requirements for pulse detection.  The
% pulse detection specification was taken from four papers: Bardin
% et.al-1973, Whitcomb et. al.-1990, Adam et. al.- 1994, and
% Hayes et. al. - 1990
%
% Because the method was evolved to be used under different situations
% It was not clear in the literature the complete reasoning for different
% rules. Several meetings with Janet Hall were undertaken to refine the
% technique.
%
% Dr. Hall provided a data set where the stumulus was known which
% allowed us to explicitly verify the algorithm.
%
% Program use:
% After testing the complete algoithm it is clear that there are
% certain situation which can confound pulse detection with the method.
% Since the method has already been validated we decided to take the
% approach of setting flag for each of the selection criterion
%
% Input:
%    data_file - Two columns (Time (min), LH concentation(iul))
%    graph_title - figure title (string)
%    x_label - x axis label (string)
%    y_label - y axis label (string)
%    comments - text comments for output
%    assay_cv - assay coefficient of variation (4-10 %)
%
% Output:
%    dat_file.txt - A text file is automatically written in the same
%    directory
%    data_file.fig - figure file is automatically created and written to
%    disk
%    data_file.jpg - a jpg file is automatically created and written to
%    disk
%
% Last revision:
%    December 11, 2003
%    March 23, 2004  Made output excel friendly
%    March 25, 2004  Corrected output for minimum amplitude
%    March 28, 2004  Changed minimum number of points from 3 to 2
%    October , 2004  Major upgrade to 1.0.3 Interface changes reccomended
%                    by Dr. Hall. Created flag to reduce output for release
%    December, 2004  Fixed figure saving bug+
%    December, 2004  Remove Pulses with missing data - set by GAP_TOLERENCE
%
% Algorithmn revision (January 3, 2005)
% Implementing Santen Bartin in software required detail specification of
% pulse identification including (1) identifying potential pulses,
% (2) identifing the start of the pulse, (3) dealing with missing points,
% and (4) Discerning noise and pulses in rapidly decreasing pulse trains
%
% After meeting with Drs. Hall and Klerman, the following rules were added
% to the software.  Although required by the software, Dr. Hall felt that
% these rules are not part of Santen Bardin.
%
% (1) Identifying potential pulses
% Monitonically rising sequence of concentrations are used to idenitfy
% potential pulses.  This rule is approached knowing that many more
% pulse will be considered then would be tested by a human evaluation of
% the Santen Bardin method
%
% (2) Identify Pulse Start
% The max imum decline within the rise is identified.  All points above the
% maximum rise are marked as good.  The delta y below the max delta are
% checked.  when the delta is less then 1 cv then the start of the pulse
% has been found.
%
% (3) Dealing with missing points
% A new term, GAP_TOLERENCE, is introduced to exclude pulse rises that
% are missing data in excess of the GAP tolerence. Pulses that are excluded
% are identified graphically with a dashed line. The user is prompted with
% a dialog box that informs the user of the number of pulse rised excluded
% due to missing data.
%
% (4) Discerning noise and pulses in rapidly decreasing pulse trains
% Added a rule the remove pulses where the amplitude is less then
% cv*max(amplitued).  This seemed to work in our one example
%
% (5) New rule added to remove pulses found by program but not found by
% hand.  Rule employed at the Reproductive Endocrine Unit at Mass General
% Hospital.
%
% April 20, 2005
% Program inaccurately defines a gap in the data as a pulse rise.  Program
% expects that the time units are in hours
%
% April 26, 2005
% (3b) Implement 30 minute pulse rule.  In the last round of analysis we used
% < 1 cv difference in vertical difference to signal the start of the
% pulse.  This approach was inadequate.  In this version we are
% incorporating the 30 minute rule as done in the lab of Dr. Hall. The
% start of the pulse is at most 30 minutes from the pulse peak.
%
% May 6, 2005
% Modified 30 minute pulse width to 35 to account for two minutes of error
% on each side.  Same thing was done for gap.
%
% July 25, 2005
% Adding table of point removed with missing data. So that if using the
% point is decided upon it is easy to get the information
%
% August 2005
% Adding interface refinements in preparation for release. Allow user to
% start time at zero.  Infrastructure for covnerting between hours and
% minutes are included.
%
% August 10, 2005
% converting from rise identification from strickly monotonic to monotonic
%
% August 16, 2005
% Modified to read fileswith GnRh pulses identified
%
% September 2005
% Preparations for paper include adding user control of y axis and labeling
% hormones with assay type.  Test with Andrew suggests that we need to
% specify which is used so that program can be applied across assay and
% hormones
%
% Program prints out the wrong output.  However graph is labeled correctly
%
% February 2005
% Rule for pulse rise is less then 30 minutes needs to check if pulse
% following the shortening meets the pulse amplitude requirements
%
% February 2008
% Code for organizing figures modified to compensate for Matlab bug
% that affects placemnt of the initial dialog.
%

%---------------------------------------------------------- User Input
%

% Check if parameters are present
if ~(nargin == 13)
    % fprintf('--- santen_bardin_mod_9(data_file, graph_title, x_label, y_label,comments, assay_cov, algor_value, start_peak, Sample_id,zero_time,time_scale,user_y_scale)');
    return
end

% Set program constants
DEBUG = 0;
RELEASE_OUTPUT = 0;

% Set algorithmn constants
MINIMUM_AMPLITUDE = 1;
MINIMUM_NUMBER_OF_POINTS = 2;
ZERO_TIME_CHECKED  = 1;

%set to 25 minutes, assume time is in hours
GAP_TOLERENCE  = 25/60;
MAXIMUM_PULSE_WIDTH = 30/60 + 5/60;

% Define column specification
TIME_COLUMN            = 1;
STIMULUS_COLUMN        = 2;
CONCENTRATION_COLUMN_2 = 2;
CONCENTRATION_COLUMN_3 = 3;

% Define algorithm constants
debug = 1;
COF_LOWER = 4;
COF_UPPER = 7;
PULSE_START_INDEX = 1;
PULSE_END_INDEX   = 2;


%-------------------------------------------------------------------------
% select starting input file
% [fn,pn] = uigetfile('*.dat','Pulse LH data file (*.dat)');
if DEBUG == 1
    txt_fn = strcat(data_file,'.',num2str(algor_value),'.txt');
    fig_fn = strcat(data_file,'.',num2str(algor_value),'.fig');
    jpg_fn = strcat(data_file,'.',num2str(algor_value),'.jpg');
    emf_fn = strcat(data_file,'.',num2str(algor_value),'.emf');
else
    stripped_data_file = strrep(data_file,'.','_');
    txt_fn = strcat(data_file,'.txt');
    fig_fn = strcat(data_file,'.fig');
    jpg_fn = strcat(data_file,'.jpg');
    emf_fn = strcat(data_file,'.emf');
end

% fid = fopen(txt_fn,'r') ;
% if fid ~= -1
%     status = fclose(fid);
%
%     destination = strcat(txt_fn,'.old');
%     copyfile(txt_fn, destination)
%
%     delete (txt_fn);
% end

try
fid = fopen(txt_fn,'wt') ;
catch
    warndlg('Could not open file for writing. Please close result file.');
    return
end   

% Print the graph title
fprintf(fid,'Graph Title:\t%s\n',graph_title);
fprintf(fid,'Sample ID:\t%s\n',Sample_id);
if (debug)

end
% Calculate stuff
%fprintf(fid,'Loading:\t%s\n',data_file);
%M = load2cols('',data_file);

try
    M = dlmread(data_file);
catch
    warndlg('Error opening data file. Please choose a different file.');
    return
end
    

[nr nc] = size(M);

if nc == 2
    x          = M(:,TIME_COLUMN)*time_scale;
    y          = M(:,CONCENTRATION_COLUMN_2);
    isStimulus = 0;
elseif nc == 3
    x          = M(:,TIME_COLUMN)*time_scale;
    stimulus   = M(:,STIMULUS_COLUMN);
    y          = M(:,CONCENTRATION_COLUMN_3);
    isStimulus = 1;
end

% Zero start time at users request
if zero_time == ZERO_TIME_CHECKED
    x = x - x(1,1);
end

% Calculate coefficient of variation
y_bar = mean(y);
y_sdev = std(y);

var_coeff_data = y_sdev/y_bar;

% determine range of data
y_min =min(y);
y_max = max(y);


if yscale == 1
    temp = y==0;
    temp = find(temp);
    x(temp) = 0.01;
end

% -------------------------------------------------------------------------
% print statistics
fprintf(fid,'Average LH value: %.4f\n',y_bar);
fprintf(fid,'Standard deviation of Y: %.4f\n',y_sdev);
if ~RELEASE_OUTPUT
    fprintf(fid,'Coefficient of Variation: %.4f\n',var_coeff_data);
    fprintf('Coefficient of Variation: %.4f\n',var_coeff_data);
end
fprintf(fid,'Minimum LH: %.4f\n',y_min);
fprintf(fid,'Maximum LH: %.4f\n',y_max);
fprintf(fid,'LH range: %.4f\n',y_max-y_min);

% Convert Assay cov to appropriate value
var_coeff = double(assay_cov/100);
% Code not needed below but kept for clarity
if var_coeff< 0.04
    var_coeff = 0.04;
    fprintf(fid,'Assay coefficient of variation out of required range.  Coefficient of reassigned to 4%%\n');
elseif var_coeff >0.10
    var_coeff = 0.10;
    fprintf(fid,'Assay coefficient of variation out of required range.  Coefficient of reassigned to 10%%\n');
end
fprintf(fid,'Assay cv: %.4f\n\n',var_coeff);
fprintf(fid,'Date: %s\n',date);
fprintf(fid,'\n\nComments:\n%s\n\n',comments);


%------------------------------------------------ Identify possible pulses
% Determine rising edges
num_data_pts = size(M);
num_data_pts = num_data_pts(1);

% Checking monotonically increasing first
secretory_sequence = [ ];
sequence_start = -1;
sequence_end = -1;

% Loop through data to find monotonically increasing data points
for i= 2:num_data_pts
    if y(i)>=y(i-1)
        % function is increasing
        if sequence_start == -1 ;
            sequence_start = i-1;
        end
    else
        % function is decreasing or equal
        if sequence_start ~= -1 ;
            sequence_end  = i-1;
            increment = y(sequence_end)-y(sequence_start);
            avg_incr = increment/(y_max-y_min);
            secretory_sequence = [secretory_sequence; [sequence_start sequence_end increment avg_incr]];

            % reset sequence variables
            sequence_start = -1;
            sequence_end = -1 ;
        end
    end % end if
end % next i

% find last rise if present
if sequence_start ~= -1 ;
    sequence_end  = i;
    increment = y(sequence_end)-y(sequence_start);
    avg_incr = increment/(y_max-y_min);
    secretory_sequence = [secretory_sequence; [sequence_start sequence_end increment avg_incr]];

    % reset sequence variables
    sequence_start = -1;
    sequence_end = -1 ;
end

% display sequence data
if ~RELEASE_OUTPUT
    fprintf(fid,'Monotonically increasing Secretory sequences\n');
    fprintf(fid,'%s\t%s\t%s\t%s\n','start','end','increment','avg_incr');
    fprintf('Monotonically increasing Secretory sequences\n');
    fprintf('%s\t%s\t%s\t%s\n','start','end','increment','avg_incr');
end
% disp(secretory_sequence);
% number of secretory spikes
number_of_spikes = size(secretory_sequence);
number_of_spikes = number_of_spikes(1);

if ~RELEASE_OUTPUT
    for i = 1:number_of_spikes
        fprintf(fid,'%f\t%f\t%.2f\t%.3f\n',secretory_sequence(i,1),secretory_sequence(i,2),secretory_sequence(i,3),secretory_sequence(i,4));
        fprintf('%f\t%f\t%.2f\t%.3f\n',secretory_sequence(i,1),secretory_sequence(i,2),secretory_sequence(i,3),secretory_sequence(i,4));
    end
    fprintf(fid,'Number of spikes: %.4f\n',number_of_spikes);
    fprintf('Number of spikes: %.4f\n',number_of_spikes);
end

%--------------------------------------------------------------------------
% display sequence data that meet 3x criteria
if ~RELEASE_OUTPUT
    fprintf(fid,'\n\nMonotonically increasing Secretory sequences greater then %.2f increment (3x assay cv)\n',3*var_coeff);
    fprintf(fid,'%10s%10s%10s%10s\n','start','end','increment','avg_incr');
    fprintf('\n\nMonotonically increasing Secretory sequences greater then %.2f increment (3x assay cv)\n',3*var_coeff);
    fprintf('%10s%10s%10s%10s\n','start','end','increment','avg_incr');
end

%
% go through and find appropriate sequences
secretory_sequence_20 = [];
%fprintf('\n\n');
for i= 1:number_of_spikes
    % fprintf('%d ----------------------\n',i)'
    % Use calculation similar to patty
    % Calculate hurdle

    %

    cvhurdle = y(secretory_sequence(i,1))*(1+3*var_coeff);
    cvhurdle_mag = cvhurdle-y(secretory_sequence(i,1));
    if  cvhurdle_mag <1
        cvhurdle_1 = y(secretory_sequence(i,1))*(1+3*var_coeff);
        cvhurdle = y(secretory_sequence(i,1))+1;
        %         fprintf('%d -----------------------\n',i);
        %         fprintf('\t%d\t\t%f cvhurdle %f\tcvhurdle %f\tcvhurdle_mag %f\n',secretory_sequence(i,1), x(secretory_sequence(i,1)),cvhurdle_1,cvhurdle,cvhurdle_mag);
    else
        %          fprintf('%d -----------------------\n',i);
        %         fprintf('\t%d\t\t%f\tcvhurdle %f\tcvhurdle_mag %f  \n',secretory_sequence(i,1), x(secretory_sequence(i,1)),cvhurdle,cvhurdle_mag);
        %
    end


    amp = y(secretory_sequence(i,2))-y(secretory_sequence(i,1));
    clear_cv = y(secretory_sequence(i,2)) - cvhurdle;
    clear_minimum = amp - MINIMUM_AMPLITUDE;

    if y(secretory_sequence(i,2))- cvhurdle >= 0
        %fprintf('%d) %d\t%f\t%f\t%f\t%f\n',i, x(secretory_sequence(i,1)), y(secretory_sequence(i,1))  , y(secretory_sequence(i,2))  ,amp, cvhurdle);
        secretory_sequence_20  = [secretory_sequence_20; secretory_sequence(i,:)];
    end
    %pause
end % next i
% fprintf('\n\n');
% disp(secretory_sequence_20);

% cv_h = +3*var_coeff
% secretory_sequence_20

% pause

% number of secretory spikes

number_of_spikes_20 = size(secretory_sequence_20);
number_of_spikes_20 = number_of_spikes_20(1);

if ~RELEASE_OUTPUT
    for i = 1:number_of_spikes_20
        fprintf(fid,'%f\t%f\t%.2f\t%.3f\n',secretory_sequence_20(i,1),secretory_sequence_20(i,2),secretory_sequence_20(i,3),secretory_sequence_20(i,4));
        fprintf('%f\t%f\t%.2f\t%.3f\n',secretory_sequence_20(i,1),secretory_sequence_20(i,2),secretory_sequence_20(i,3),secretory_sequence_20(i,4));
        %fprintf('%f\t%f\t%.2f\t%.3f\n',secretory_sequence_20(i,1),secretory_sequence_20(i,2),secretory_sequence_20(i,3),secretory_sequence_20(i,4));
    end
    fprintf(fid,'Number of spikes meetings 3x assay cov criterion(%.2f): %.4f\n',3*var_coeff,number_of_spikes_20);
    fprintf('Number of spikes meetings 3x assay cov criterion(%.2f): %.4f\n',3*var_coeff,number_of_spikes_20);
    %fprintf('Number of spikes meetings 3x assay cov criterion(%.2f): %.4f\n',3*var_coeff,number_of_spikes_20);
end

if algor_value >=2
    %--------------------------------------------------------------------------
    % Determine pulse that meat  1 IUL minimum

    %
    % go through and find appropriate sequences
    secretory_sequence_min_amp = [];
    number_of_spikes_20 = size(secretory_sequence_20);
    number_of_spikes_20 = number_of_spikes_20(1);

    for i= 1:number_of_spikes_20
        if secretory_sequence_20(i,3)>=  MINIMUM_AMPLITUDE
            secretory_sequence_min_amp  = [secretory_sequence_min_amp; secretory_sequence_20(i,:)];
        end
    end % next i

    % disp(secretory_sequence_20);

    % number of secretory spikes
    if ~RELEASE_OUTPUT
        fprintf(fid,'\n\nNumber of spikes meetings minmium amplitude (1 IUL)\n');
        fprintf(fid,'%s\t%s\t%s\t%s\n','start','end','increment','avg_incr');
        fprintf('\n\nNumber of spikes meetings minmium amplitude (1 IUL)\n');
        fprintf('%s\t%s\t%s\t%s\n','start','end','increment','avg_incr');
    end

    number_of_spikes_min_amp = size(secretory_sequence_min_amp);
    number_of_spikes_min_amp = number_of_spikes_min_amp(1);
    if ~ RELEASE_OUTPUT
        for i= 1:number_of_spikes_min_amp
            fprintf(fid,'%f\t%f\t%.2f\t%.3f\n',secretory_sequence_min_amp(i,1),secretory_sequence_min_amp(i,2),secretory_sequence_min_amp(i,3),secretory_sequence_min_amp(i,4));
            fprintf('%f\t%f\t%.2f\t%.3f\n',secretory_sequence_min_amp(i,1),secretory_sequence_min_amp(i,2),secretory_sequence_min_amp(i,3),secretory_sequence_min_amp(i,4));
        end % next i
        fprintf(fid,'Number of spikes meetings minmium amplitude (1 IUL):\t%.4f\n',number_of_spikes_min_amp);
        fprintf('Number of spikes meetings minmium amplitude (1 IUL):\t%.4f\n',number_of_spikes_min_amp);
    end

    if algor_value >= 3
        %--------------------------------------------------------------------------
        % Must have at least 3 point

        %
        % go through and find appropriate sequences
        secretory_sequence_min_points = [];
        number_of_spikes_min_points = size(secretory_sequence_min_amp);
        number_of_spikes_min_points = number_of_spikes_min_points(1);

        for i= 1:number_of_spikes_min_points
            num_points = secretory_sequence_min_amp(i,2)-secretory_sequence_min_amp(i,1)+1;
            if  num_points >=MINIMUM_NUMBER_OF_POINTS
                secretory_sequence_min_points  = [secretory_sequence_min_points; secretory_sequence_min_amp(i,:)];
            end
        end % next i


        % disp(secretory_sequence_min_points);

        % number of secretory spikes
        if ~RELEASE_OUTPUT
            fprintf(fid,'\n\nNumber of spikes meetings minmium number of points\n');
            fprintf(fid,'%s\t%s\t%s\t%s\n','start','end','increment','avg_incr');
            fprintf('\n\nNumber of spikes meetings minmium number of points\n');
            fprintf('%s\t%s\t%s\t%s\n','start','end','increment','avg_incr');
        end

        number_of_spikes_min_points = size(secretory_sequence_min_points);
        number_of_spikes_min_points = number_of_spikes_min_points(1);
        if ~RELEASE_OUTPUT
            for i= 1:number_of_spikes_min_points
                fprintf(fid,'%f\t%f\t%.2f\t%.3f\n',secretory_sequence_min_points(i,1),secretory_sequence_min_points(i,2),secretory_sequence_min_points(i,3),secretory_sequence_min_points(i,4));
                fprintf('%f\t%f\t%.2f\t%.3f\n',secretory_sequence_min_points(i,1),secretory_sequence_min_points(i,2),secretory_sequence_min_points(i,3),secretory_sequence_min_points(i,4));
            end % next i
            fprintf(fid,'Number of spikes meetings minmium number of points (%d): %.4f\n',MINIMUM_NUMBER_OF_POINTS, number_of_spikes_min_points);
            fprintf('Number of spikes meetings minmium number of points (%d): %.4f\n',MINIMUM_NUMBER_OF_POINTS, number_of_spikes_min_points);
        end

        if algor_value >= 4
            %--------------------------------------------------------------------------
            % A second point that is either greater then minimum amplitude or greater then 3x CX

            %
            % go through and find appropriate sequences
            secretory_sequence_2nd_point = [];
            number_of_spikes_min_points = size(secretory_sequence_min_points);
            number_of_spikes_min_points = number_of_spikes_min_points(1);

            %             number_of_spikes_min_points
            %             secretory_sequence_min_points
            for i= 1:number_of_spikes_min_points
                % Determine point hurdle
                cvhurdle = y(secretory_sequence_min_points(i,1))*(1+3*var_coeff);


                % Determine if second point meets criterion
                snd_point = y(secretory_sequence_min_points(i,2)-1);
                first_point = y( secretory_sequence_min_points(i,1));
                scnd_amp = snd_point - first_point;
                scnd_percent = scnd_amp/(y_max-y_min);

                % Check if point after meets criterion
                test3 =0;
                if (secretory_sequence_min_points(i,2)+1)<= length(y)
                    % if there is a point following peak check
                    third_point = y(secretory_sequence_min_points(i,2)+1);
                    first_point = y( secretory_sequence_min_points(i,1));
                    third_amp = third_point - first_point;
                    third_percent = third_amp/(y_max-y_min);

                    if DEBUG >=1
                        fprintf('A third point has been found after the peak (x=%d)\n',x(secretory_sequence_min_points(i,2)+1));
                    end
                else
                    third_amp = 0;
                    third_percent = 0;
                    third_point = 0;
                end
                %test1 = 0;
                %test2 = 0;
                % fprintf('%d) --- Check second point (%.3f,%.3f)\n',i,third_point,cvhurdle);
                test1 = scnd_amp >= MINIMUM_AMPLITUDE;
                test2 = third_amp >= MINIMUM_AMPLITUDE;
                test3 = snd_point >= cvhurdle;
                test4 = third_point >= cvhurdle;
                check_test = (test1+test2+test3+test4);
                if   check_test>0
                    secretory_sequence_2nd_point  = [secretory_sequence_2nd_point; secretory_sequence_min_points(i,:)];
                end

            end % next i
            % disp(secretory_sequence_2nd_point);
            % number of secretory spikes
            if ~RELEASE_OUTPUT
                fprintf(fid,'\n\nNumber of spikes meetings having a second point with an amplitude >3x assay cov or amplitude > minimum amplitude \n');
                fprintf(fid,'%s\t%s\t%s\t%s\n','start','end','increment','avg_incr');
                fprintf('\n\nNumber of spikes meetings having a second point with an amplitude >3x assay cov or amplitude > minimum amplitude \n');
                fprintf('%s\t%s\t%s\t%s\n','start','end','increment','avg_incr');
            end

            number_of_spikes_2nd_points = size(secretory_sequence_2nd_point);
            number_of_spikes_2nd_points = number_of_spikes_2nd_points(1);
            if ~RELEASE_OUTPUT
                for i= 1:number_of_spikes_2nd_points
                    fprintf(fid,'%f\t%f\t%.2f\t%.3f\n',secretory_sequence_2nd_point(i,1),secretory_sequence_2nd_point(i,2),secretory_sequence_2nd_point(i,3),secretory_sequence_2nd_point(i,4));
                    fprintf('%f\t%f\t%.2f\t%.3f\n',secretory_sequence_2nd_point(i,1),secretory_sequence_2nd_point(i,2),secretory_sequence_2nd_point(i,3),secretory_sequence_2nd_point(i,4));
                end % next i
                fprintf(fid,'Number of spikes meetings having a second point with an amplitude >3x assay cov (%.2f) or amplitude > minimum amplitude (%d): %d\n',3*var_coeff, MINIMUM_AMPLITUDE, number_of_spikes_2nd_points);
                fprintf('Number of spikes meetings having a second point with an amplitude >3x assay cov (%.2f) or amplitude > minimum amplitude (%d): %d\n',3*var_coeff, MINIMUM_AMPLITUDE, number_of_spikes_2nd_points);
            end


        end %     if algor_value >= 4 a second point that meets (1) or (2)
    end % algor_value>3  must have 3 point in accent
end % algor_value>2 minimum amplitude

% ************************************************
% Bad hack just to make it work

if algor_value == 1
    secretory_sequence_20 = secretory_sequence_20;
elseif algor_value == 2
    secretory_sequence_20 = secretory_sequence_min_amp;
elseif algor_value == 3
    secretory_sequence_20 = secretory_sequence_min_points;
elseif algor_value == 4
    secretory_sequence_20 = secretory_sequence_2nd_point;
else
    fprintf(fid,'Wrong setting for algorithmn- setting to complete analysis');
end

% number of secretory spikes
number_of_spikes_20 = size(secretory_sequence_20);
number_of_spikes_20 = number_of_spikes_20(1);
if ~RELEASE_OUTPUT
    fprintf(fid,'Number of secretory spikes: %d\n',number_of_spikes_20);
end
%----------------------------------------------------------------
% Calculation of area under the curve
area_array = [];
for i= 1:number_of_spikes_20-1
    % Assuming linear segments
    pulse_start = secretory_sequence_20(i,1);
    pulse_end = secretory_sequence_20(i+1,1);

    % For each point calculate the area under the curve
    area = 0;
    for j = pulse_start:(pulse_end-1)
        x1 = x(j);
        y1 = y(j);
        x2 = x(j+1);
        y2 = y(j+1);

        area = area + (x2-x1)*(y2-0.5*(y2-y1));
    end
    area_array = [area_array; [pulse_start pulse_end  area]];
end % next i

% calculate area of last pulse

if number_of_spikes_20>0
    pulse_start = secretory_sequence_20(number_of_spikes_20);
    pulse_end = num_data_pts;
    area = 0;
    for j = pulse_start:(pulse_end-1)
        x1 = x(j);
        y1 = y(j);
        x2 = x(j+1);
        y2 = y(j+1);
        area = area + (x2-x1)*(y2-0.5*(y2-y1));
    end
    area_array = [area_array; [pulse_start pulse_end  area]];
    % display sequence data that meet 20% criteria
    secretory_sequence_20 = [secretory_sequence_20 area_array];

end


% fprintf('Monotonically increasing Secretory sequences greater then %.2f increment (3x assay cv)\n',3*var_coeff);
% fprintf('%10s%10s%10s%10s%10s%10s%10s\n','up start','up end','increment','avg_incr','start','end','AUC');
% disp(secretory_sequence_20);
%----------------------------------------------------------------------
% Calculate apparent half life by calculating regression
regression_info = [];
for i= 1:number_of_spikes_20
    % Assuming linear segments
    pulse_start = secretory_sequence_20(i,2);
    pulse_end = secretory_sequence_20(i,6);
    pulse_width = (x(pulse_end) - x(pulse_start));

    if pulse_width >= 40
        keep = 1;
    else
        keep =0;
    end


    check = (pulse_end - pulse_start);
    if  check >=2
        % For each point calculate the linear regression
        % Compute regression for line
        p= polyfit(x(pulse_start:pulse_end),y(pulse_start:pulse_end),1);

        m = p(1);
        b = p(2);

        % For each point calculate the linear regression
        % Compute regression for log of values
        y_L = log(y(pulse_start:pulse_end));
        p_L= polyfit(x(pulse_start:pulse_end),y_L,1);

        m_L = p_L(1);
        b_L = p_L(2);
    else
        m = 0;
        b = 0;
        m_L = 0;
        b_L =0;
        keep = 0  ;
    end  % number of points in pulse analysis

    regression_info = [regression_info;[pulse_start pulse_end pulse_width m b m_L m_L keep]];
end % next i

% Print half life information
if ~ RELEASE_OUTPUT
    fprintf(fid,'\n\nApparent half (D=Decline)\n');
    fprintf(fid,'--------------------------------------------------------\n');
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','Pulse ID','D Start','D End','D Width','m','b','m log','b log');
    fprintf('\n\nApparent half (D=Decline)\n');
    fprintf('--------------------------------------------------------\n');
    fprintf('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','Pulse ID','D Start','D End','D Width','m','b','m log','b log');
end

reg_size = size(regression_info);
reg_size = reg_size(1,1);

if ~RELEASE_OUTPUT
    for i = 1:reg_size
        fprintf(fid,'%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',i,regression_info(i,1),regression_info(i,2),regression_info(i,3),regression_info(i,4),regression_info(i,5),regression_info(i,6),regression_info(i,7));
        fprintf('%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',i,regression_info(i,1),regression_info(i,2),regression_info(i,3),regression_info(i,4),regression_info(i,5),regression_info(i,6),regression_info(i,7));
    end
    fprintf(fid,'\n\n');
    fprintf('\n\n');
end

% disp(regression_info );

%---------------------------------
% Pulse Summary
pulse_array = [];
for i= 1:number_of_spikes_20
    % Assuming linear segments
    sec_start = secretory_sequence_20(i,1);
    sec_end = secretory_sequence_20(i,2);
    sec_width = x(sec_end)-x(sec_start);
    sec_change = y(sec_end)-y(sec_start);

    dec_start = regression_info(i,1);
    dec_end = regression_info(i,2);
    dec_width = x(dec_end)-x(dec_start);
    dec_change = y(dec_end)-y(dec_start);

    area_uc = secretory_sequence_20(i,7);
    keep = regression_info(i,8);

    pulse_array = [pulse_array; [sec_start sec_end sec_width sec_change dec_start  dec_end  dec_width  dec_change area_uc keep]];
end

if ~ RELEASE_OUTPUT
    fprintf(fid,'Pulse Summary (R=Rise, D=Decline)\n');
    fprintf(fid,'--------------------------------------------------------\n');
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Pulse ID','R Start','R End','R Width','R Height','D Start','D End','D Width','D Height','Auc');
    fprintf('Pulse Summary (R=Rise, D=Decline)\n');
    fprintf('--------------------------------------------------------\n');
    fprintf('%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'Pulse ID','R Start','R End','R Width','R Height','D Start','D End','D Width','D Height','Auc');
end

reg_size = size(pulse_array);
reg_size = reg_size(1,1);

if ~ RELEASE_OUTPUT
    for i = 1:reg_size
        fprintf(fid,'%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',i,pulse_array(i,1),pulse_array(i,2),pulse_array(i,3),pulse_array(i,4),pulse_array(i,5),pulse_array(i,6),pulse_array(i,7),pulse_array(i,6),pulse_array(i,7));
        fprintf('%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',i,pulse_array(i,1),pulse_array(i,2),pulse_array(i,3),pulse_array(i,4),pulse_array(i,5),pulse_array(i,6),pulse_array(i,7),pulse_array(i,6),pulse_array(i,7));
    end
    fprintf(fid,'\n\n');
    fprintf('\n\n');
end

% disp(pulse_array );
%--------------------------------------------
% Based on Beth's reccomendation pulses
% are excluded if there is more then a 25 minute
% gap in the data.  GAP_TOLERENCE introduced as
% a variable.


% For each point
count = 0;
deleted_rises = 0;
new_regression_info = [];
new_pulse_array = [];
new_secretory_sequence_20 =  [];
pulses_w_gaps = [];
regression_info_w_gaps = [];
secretory_sequence_20_w_gaps = [];
for i= 1:number_of_spikes_20
    % Check if there is a gap
    %
    % pulse start - x(pulse_array(i,1))
    % pulse peak  - x(pulse_array(i,2))


    GAP_Present = 0;
    p_start = pulse_array(i,1);
    p_end = pulse_array(i,2);

    %fprintf('%f',x(p_start))
    for j = p_start+1:p_end
        delta_t = x(j) - x(j-1);
        if delta_t >= GAP_TOLERENCE
            GAP_Present = 1;
            count = count+1;
            break
        end
        %fprintf(' %f ',delta_t)
    end
    %fprintf('\n')


    if GAP_Present
        % fprintf('--- Gap present\n');

        % delete entry from ampltidue list
        new_pulse_array = new_pulse_array;

        % remember deleted information
        pulses_w_gaps = [pulses_w_gaps; pulse_array(i,:) ];

        %regression_info_w_gaps = [regression_info_w_gaps;regression_info_w_gaps(i,:)];
        secretory_sequence_20_w_gaps = [secretory_sequence_20_w_gaps; secretory_sequence_20(i,:)];

        % update arrays for plotting
        new_regression_info = new_regression_info;
        new_secretory_sequence_20 = new_secretory_sequence_20;
    else
        % fprintf('--- no Gap present\n');
        new_pulse_array = [new_pulse_array;pulse_array(i,:)];

        % update arrays for plotting
        new_regression_info = [new_regression_info;regression_info(i,:)];
        new_secretory_sequence_20 = [new_secretory_sequence_20; secretory_sequence_20(i,:)];
    end
end

% % Update pulse list
pulse_array = new_pulse_array;
number_of_spikes_20 = number_of_spikes_20 - count;
deleted_rises = count;

% Update plot variables
regression_info = new_regression_info;
secretory_sequence_20 = new_secretory_sequence_20;

% ---------------------------------------------------
% (2) Determine pulse start
% Extract start of pulse by working backwards.
%

for i= 1:number_of_spikes_20
    % Assuming linear segments
    sec_start = secretory_sequence_20(i,1);
    sec_end = secretory_sequence_20(i,2);

    % Statistically significant change
    minimum_delta = var_coeff*y(sec_start);

    % starting from peak calc delta y
    % find start
    delta_y = [];
    pt_count = 0;
    delta_index_count = [];
    for j = sec_end:-1:sec_start+1
        pt_count = pt_count+1;
        delta_y(pt_count) =  y(j) -y(j-1);
        delta_index_count(pt_count) =  delta_y(pt_count)>minimum_delta;
    end

    % identify maximum delta
    max_pulse_index = find(max(delta_y)==delta_y);
    delta_index_count(1:max_pulse_index) = 1;

    % update start
    new_sec_start = sec_end  - sum(delta_index_count);
    secretory_sequence_20(i,1) =new_sec_start;
end



%------------------------------------------------------------
% (3) Discerning pulse rise from back ground noise
% Remove every amplitude that is less then one cv of the
% amplitude

[nr nc] = size(secretory_sequence_20);

if nr >0
    max_amp = max(secretory_sequence_20(:,3));
    max_amp_index = find(max_amp == secretory_sequence_20(:,3));
    minimum_statistical_amplitude = var_coeff*max_amp;
    new_secretory_sequence_20 = [];
    new_regression_info = [];
    count_screen_3 = 0;
    AMPLITUDE_INDEX_C = 3;
    for i= 1:number_of_spikes_20
        if secretory_sequence_20(i,AMPLITUDE_INDEX_C)>= minimum_statistical_amplitude
            new_secretory_sequence_20 = [new_secretory_sequence_20;secretory_sequence_20(i,:)];
            new_regression_info = [new_regression_info;regression_info(i,:)];
            count_screen_3 = count_screen_3+1;
        end
    end

    % update pulse list
    number_of_spikes_20   = count_screen_3;
    secretory_sequence_20 = new_secretory_sequence_20;
    regression_info       = new_regression_info;
end

%----------------------------------------------------------------
% (5) Remove pulses with three points that are followed by a rise.

[nr nc] = size(secretory_sequence_20);

if nr >0
    
    new_secretory_sequence_20 = [];
    new_regression_info_20 = [];

    PULSE_START_POINT_INDEX = 1;
    PULSE_END_POINT_INDEX   = 2;

    count_screen_4 = 0;

    for i= 1:nr
        % Determine number of points
        start_point = secretory_sequence_20(i,PULSE_START_POINT_INDEX);
        peak_point  = secretory_sequence_20(i,PULSE_END_POINT_INDEX);
        num_points_in_rise = peak_point - start_point  + 1;


        if and( num_points_in_rise == 2 , (peak_point + 2) <= length(x))
            % check if next two points are decending
            diff_1 = y(peak_point+1) - y(peak_point);
            diff_2 = y(peak_point+2) - y(peak_point);

            if and (diff_1 <= 0, diff_2 < 0)
                % Three point pulse found should remove
                new_secretory_sequence_20 = [new_secretory_sequence_20;secretory_sequence_20(i,:)];
                new_regression_info = [new_regression_info;regression_info(i,:)];
                count_screen_4 = count_screen_4 + 1;
            else
                if DEBUG == 1
                    fprintf('  peak_point of eliminated pulse = %d\n',peak_point);
                end
            end
            
            
            
        else
            % add points to list
            new_secretory_sequence_20 = [new_secretory_sequence_20;secretory_sequence_20(i,:)];
            new_regression_info = [new_regression_info;regression_info(i,:)];
            count_screen_4 = count_screen_4 + 1;
        end

        if DEBUG == 1
            fprintf('   num_points_in_rise = %d\n',num_points_in_rise);
        end

    end

    % update pulse list
    number_of_spikes_20   =  count_screen_4;
    count_screen_3 = count_screen_4; % ? needed further down, bad programmings
    secretory_sequence_20 = new_secretory_sequence_20;
    regression_info       = new_regression_info;
end
%------------------------------------------------------------
% (3b) Limit pulse rise width to less then 30 minutes
%
long_pulse_width_found = 0;
for i = 1:number_of_spikes_20
    current_pulse_width = x(secretory_sequence_20(i,PULSE_END_INDEX)) - x(secretory_sequence_20(i,PULSE_START_INDEX));
    %fprintf('Pulse width = %.2f\n', current_pulse_width);
    if current_pulse_width > MAXIMUM_PULSE_WIDTH
        % Update variables
        long_pulse_width_found = 1;

        % Adjust pulse start
        adjusted_pulse_width = -1;
        pulse_rise_indexes =  secretory_sequence_20(i,PULSE_START_INDEX):secretory_sequence_20(i,PULSE_END_INDEX);
        for j = pulse_rise_indexes
            adjusted_pulse_width = x(secretory_sequence_20(i,PULSE_END_INDEX)) - x(j);
            %fprintf('%i) %.2f\n', j, adjusted_pulse_width);
            if adjusted_pulse_width <= MAXIMUM_PULSE_WIDTH
                new_pulse_start_index = j;
                break
            end
        end

        % Echo results to screen
        fprintf('Pulse width greater then 30 minutes found:index %d, pulse width = %.2f, adj pulse width = %.2f', i, current_pulse_width, adjusted_pulse_width)


        % Update result tables
        secretory_sequence_20(i,PULSE_START_INDEX) = new_pulse_start_index;
    end
end

%-------------------------------------------------------
% (4) Use rise and decend to interpolate pulse start
%
x_interpolate = [];
x_exp_interp = [];
for i= 1:number_of_spikes_20
    % Assuming linear segments
    sec_start = secretory_sequence_20(i,1);
    sec_end = secretory_sequence_20(i,2);

    % Look for valid points with in an hour
    prev_decline_end   = sec_start-1;
    prev_decline_start = prev_decline_end;
    for i = 1:5
        if prev_decline_end-i>0
            if y(prev_decline_end)-y(prev_decline_end-i)<1
                prev_decline_start = prev_decline_end-i;
            end
        end
    end

    if (prev_decline_end-prev_decline_start)==0
        % Can't compute decend fit
        x_interpolate =[x_interpolate; -1];
    else
        % compute best fit line
        p_rise = polyfit(x(sec_start:sec_end),y(sec_start:sec_end),1);
        p_approach = polyfit(x(prev_decline_start:prev_decline_end),y(prev_decline_start:prev_decline_end),1);
        p_approach_e = polyfit(x(prev_decline_start:prev_decline_end),log(y(prev_decline_start:prev_decline_end)),1);

        %
        % prev_decline_start
        % prev_decline_end
        % rise_pts = [x(sec_start:sec_end),y(sec_start:sec_end)]
        % decend_pts = [x(prev_decline_start:prev_decline_end),y(prev_decline_start:prev_decline_end)]

        % linear interpolate
        x0 = x(sec_start);
        f = @(x)polyval(p_rise,x)-polyval(p_approach,x);
        [x_intersection fval] = fzero(f,x0);
        x_interpolate =[x_interpolate; x_intersection];

        %         % exponential interpolate
        %         x0 = x(sec_start);
        %         f = @(x)polyval(p_rise,x)-polyval(p_approach_e,x);
        %         [x_intersection fval] = fzero(f,x0);
        %         x_interpolate =[x_interpolate; x_intersection];
        %         x_exp_interp
    end
end

% Code moves results from secretory sequence to pulse_array
%---------------------------------
% Pulse Summary
pulse_array = [];
for i= 1:number_of_spikes_20
    % Assuming linear segments
    sec_start = secretory_sequence_20(i,1);
    sec_end = secretory_sequence_20(i,2);
    sec_width = x(sec_end)-x(sec_start);
    sec_change = y(sec_end)-y(sec_start);

    dec_start = regression_info(i,1);
    dec_end = regression_info(i,2);
    dec_width = x(dec_end)-x(dec_start);
    dec_change = y(dec_end)-y(dec_start);

    area_uc = secretory_sequence_20(i,7);
    keep = regression_info(i,8);

    pulse_array = [pulse_array; [sec_start sec_end sec_width sec_change dec_start  dec_end  dec_width  dec_change area_uc keep]];
end

% assign pulse peak

%--------------------------------------------------------- output
%
% Print Pulse Start Values
%
% if start_peak == 0

fprintf('\n\nGraph Title:\t%s\n',graph_title);
fprintf('Sample_id:\t%s\n',Sample_id);
fprintf('Assay Covariance:\t%.1f\n',assay_cov);
fprintf(fid,'\n\nPulse Start Values\nPulse ID\tPoint ID\tX Value\tAmp\n');
fprintf('Pulse Start Values\nPulse ID\tPoint ID\tX Value\tAmp\n');
for i= 1:number_of_spikes_20
    fprintf(fid,'%d\t%.3f\t%.3f\t%.3f\n',i,pulse_array(i,1), x(pulse_array(i,1)), y(pulse_array(i,2))-y(pulse_array(i,1)) );
    fprintf('%d\t%.3f\t%.3f\t%.3f\n',i,pulse_array(i,1), x(pulse_array(i,1)), y(pulse_array(i,2))-y(pulse_array(i,1)));
    %  fprintf('item printed \n');
    % end
end  % next i
% end

%%----------------------------------------
% Print Pulse Peak Values

% if start_peak == 1
fprintf('\n\nGraph Title:\t%s\n',graph_title);
fprintf('Sample_id:\t%s\n',Sample_id);
fprintf('Assay Covariance:\t%.1f\n',assay_cov);
fprintf(fid,'\n\nPulse Peak Values\nPulse ID\tPoint ID\tX Value\tAmp\n');
fprintf('Pulse Peak Values\nPulse ID\tPoint ID\tX Value\tAmp\n');
for i= 1:number_of_spikes_20
    fprintf(fid,'%d\t%.3f\t%.3f\t%.3f\n',i,pulse_array(i,2), x(pulse_array(i,2)),  y(pulse_array(i,2))-y(pulse_array(i,1)));
    fprintf('%d\t%.3f\t%.3f\t%.3f\n',i,pulse_array(i,2), x(pulse_array(i,2)),  y(pulse_array(i,2))-y(pulse_array(i,1)));
    %  fprintf('item printed \n');
    % end
end  % next i
% end


%%----------------------------------------
% Print in Patty Excel Format for easy comparison
% Print Pulse Start Values
if start_peak == 0
    fprintf(fid,'\n\nGraph Title:\t%s\n',graph_title);
    fprintf(fid,'Sample_id:\t%s\n',Sample_id);
    fprintf(fid,'\n\n#\tPulse Time\tNadir\tPeak Pt\tAmp\tCV Hurdle\tIPI\tClear CV\tClear Marker Min\n');
    %fprintf('\n\nPulse start values\n');
    %fprintf('\n\n#\tPulse Time\tNadir\tPeak Pt\tAmp\tCV Hurdle\tIPI\tClear CV\tClear Marker Min\n');
    for i= 1:number_of_spikes_20
        cvhurdle = y(pulse_array(i,1))*(1+3*var_coeff);

        % Calculate interpulse interval
        ipi = 0;
        if i >1
            % Use peaks to calculate interpulse interval
            ipi = x(pulse_array(i,1)) - x(pulse_array(i-1,1));
        end
        amp = pulse_array(i,4);
        clear_cv = y(pulse_array(i,2))- cvhurdle;
        clear_minimum = amp - MINIMUM_AMPLITUDE;
        fprintf(fid,'%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',i,x(pulse_array(i,1)),  y(pulse_array(i,1)), y(pulse_array(i,2)), pulse_array(i,4),cvhurdle, ipi, clear_cv, clear_minimum);
        %fprintf('%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',i,x(pulse_array(i,1)),  y(pulse_array(i,1)), y(pulse_array(i,2)), pulse_array(i,4),cvhurdle, ipi, clear_cv, clear_minimum);
        %  fprintf('item printed \n');
        % end
    end  % next i
end
%%----------------------------------------
% Print in Patty Excel Format for easy comparison
% Print Pulse Peak Values

if start_peak == 1
    fprintf(fid,'\n\nPulse peak values\n');
    fprintf(fid,'\n\n#\tPulse Time\tNadir\tPeak Pt\tAmp\tCV Hurdle\tIPI\tClear CV\tClear Marker Min\n');
    for i= 1:number_of_spikes_20
        % Calculate hurdle
        cvhurdle = y(pulse_array(i,1))*(1+3*var_coeff);
        amp = pulse_array(i,4);
        clear_cv = y(pulse_array(i,2))- cvhurdle;
        clear_minimum = amp - MINIMUM_AMPLITUDE;

        % Calculate interpulse interval
        ipi = 0;
        if i >1
            % Use peaks to calculate interpulse interval
            ipi = x(pulse_array(i,2)) - x(pulse_array(i-1,2));
        end

        fprintf(fid,'%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',i,x(pulse_array(i,2)),  y(pulse_array(i,1)), y(pulse_array(i,2)), pulse_array(i,4),cvhurdle, ipi, clear_cv, clear_minimum);
        %  fprintf('item printed \n');
        % end
    end  % next i
end

%% Print pulses that have been eliminated due to missing information
[num_pulses_removed_with_missing_data nc] = size(pulses_w_gaps);

if num_pulses_removed_with_missing_data >=1
    % Pulses identified but removed due to missing data
    fprintf('\n\n\nPulses identified but removed due to missing data:');
    fprintf(fid,'\n\n\nPulses identified but removed due to missing data:');



    %----------------------------------------
    % Print Pulse Start Values

    % if start_peak == 0
    fprintf('\n\nGraph Title:\t%s\n',graph_title);
    fprintf('Sample_id:\t%s\n',Sample_id);
    fprintf('Assay Covariance:\t%.1f\n',assay_cov);
    fprintf(fid,'\n\nPulse Start Values\nPulse ID\tPoint ID\tX Value\tAmp\n');
    fprintf('Pulse Start Values\nPulse ID\tPoint ID\tX Value\tAmp\n');
    for i= 1:num_pulses_removed_with_missing_data
        fprintf(fid,'%d\t%.3f\t%.3f\t%.3f\n',i,pulses_w_gaps(i,1), x(pulses_w_gaps(i,1)), y(pulses_w_gaps(i,2))-y(pulses_w_gaps(i,1)));
        fprintf('%d\t%.3f\t%.3f\t%.3f\n',i,pulses_w_gaps(i,1), x(pulses_w_gaps(i,1)), y(pulses_w_gaps(i,2))-y(pulses_w_gaps(i,1)));
        %         fprintf(fid,'%d\t%.3f\t%.3f\t%.3f\t%.3f\n',i,pulses_w_gaps(i,1), x(pulses_w_gaps(i,1)), y(pulses_w_gaps(i,2))-y(pulses_w_gaps(i,1)),x_interpolate(i) );
        %         fprintf('%d\t%.3f\t%.3f\t%.3f\t%.3f\n',i,pulses_w_gaps(i,1), x(pulses_w_gaps(i,1)), y(pulses_w_gaps(i,2))-y(pulses_w_gaps(i,1)), x_interpolate(i));
        %  fprintf('item printed \n');
        % end
    end  % next i
    % end


    % if start_peak == 1
    fprintf('\n\nGraph Title:\t%s\n',graph_title);
    fprintf('Sample_id:\t%s\n',Sample_id);
    fprintf('Assay Covariance:\t%.1f\n',assay_cov);
    fprintf(fid,'\n\nPulse Peak Values\nPulse ID\tPoint ID\tX Value\tAmp\n');
    fprintf('Pulse Peak Values\nPulse ID\tPoint ID\tX Value\tAmp\n');
    for i= 1:num_pulses_removed_with_missing_data
        fprintf(fid,'%d\t%.3f\t%.3f\t%.3f\n',i,pulses_w_gaps(i,2), x(pulses_w_gaps(i,2)),  y(pulses_w_gaps(i,2))-y(pulses_w_gaps(i,1)));
        fprintf('%d\t%.3f\t%.3f\t%.3f\n',i,pulses_w_gaps(i,2), x(pulses_w_gaps(i,2)),  y(pulses_w_gaps(i,2))-y(pulses_w_gaps(i,1)));
        %  fprintf('item printed \n');
        % end
    end  % next i
    % end

end


fclose(fid);

%----------------------------------------
% plot results


%----------------------------------------
% plot raw data
screen_height = 4;
screen_width  = 3;
set(gcf,'Units','pixels');
dialog_position = get(gcf,'Position');

%----------------------------------------
% set figure size


% Set figure Size
% Use predetermined sizes
d_height    = 500;
d_width     = 598;
screen_dim = get(0,'ScreenSize');
dialog_height = dialog_position(2)- 4;
left_edge = dialog_position(1)+dialog_position(3)+7;
pos1 = [left_edge dialog_height+5 d_width  (d_height+37)]

h = figure('Visible', 'off', 'Units', 'Pixels', ...
           'WVisualMode',    'manual','Position',pos1)

hold off

set(h, 'Position', pos1) ;
set(h,'Visible', 'on');

% Prepare to draw multiple entries


% Plot output 
plot(x',y','-s','LineWidth', 2);
title(graph_title,'FontSize',16,'FontWeight','bold','Interpreter','none');
xlabel(x_label,'FontSize',12,'FontWeight','bold') ;
ylabel(y_label,'FontSize',12,'FontWeight','bold');
set(gcf,'DefaultAxesLineWidth',2);

% Make plot look like Origin

% Store y scaling values
v = axis;
xmin = v(1);
xmax = v(2);
ymin = v(3);
ymax = v(4);

if user_y_scale  > 0
    v(3) = 0;
    v(4) = user_y_scale;  
    axis(v);
    ymin = v(3);
    ymax = v(4);  
end

%----------------------------------------
% plot secretory portion of pulse

hold on
for i= 1:number_of_spikes_20
    x_s = [];
    y_s= [];
    pt_start =secretory_sequence_20(i,1);
    pt_end = secretory_sequence_20(i,2);
    for j = pt_start : pt_end
        x_s = [ x_s; x(j) ];
        y_s = [ y_s; y(j) ];
    end

    % Find missing segments
    missing_segments = [];
    for j = 2:length(y_s)
        if (x_s(2)-x_s(1))>GAP_TOLERENCE
            missing_segments = [missing_segments; j];

        end
    end

    % Plot secrtory
    plot(x_s',y_s','m','LineWidth', 2);

end % next i


% Mark Missing pulses
if deleted_rises
    % Plot missing_segments

    %     deleted_rises
    %     secretory_sequence_20_w_gaps

    for i= 1:deleted_rises
        x_miss = [];
        y_miss= [];
        pt_start =secretory_sequence_20_w_gaps(i,1);
        pt_end = secretory_sequence_20_w_gaps(i,2);
        for j = pt_start : pt_end
            x_miss = [ x_miss; x(j) ];
            y_miss = [ y_miss; y(j) ];
        end
        %
        %         for j = missing_segments
        %             x_miss = x_miss(j-1:j,1);
        %             y_miss = y_miss(j-1:j,1);
        % %             line(x_s,y_s,'Color','w','LineWidth', 2,'LineStyle','-');
        % %             line(x_s,y_s,'Color','m','LineWidth', 2,'LineStyle','--');
        %         end
        %         [x_miss;y_miss]

        % Plot secrtory
        plot(x_miss',y_miss','-w','LineWidth', 2);
        plot(x_miss',y_miss','--m','LineWidth', 2);
    end
end
%----------------------------------------
% plot linear portion of curve
hold on
for i= 1:number_of_spikes_20
    x_s = [];
    y_s= [];
    pt_start =secretory_sequence_20(i,1);
    pt_end = secretory_sequence_20(i,2);

    x_s =  x(regression_info(i,1):regression_info(i,2));
    p   = [regression_info(i,4) regression_info(i,5)];

    y_s = polyval(p,x_s);

    plot(x_s',y_s,'g','LineWidth', 2);
end  % next i

%----------------------------------------
% plot start of pulse
% hold on
if start_peak  == 0

    increment = (ymax-ymin)/10;
    txt_height = ymax;
    new_ymax = ymax +increment;

    axis([xmin xmax ymin new_ymax] );

    for i= 1:number_of_spikes_20
        pt_start =secretory_sequence_20(i,1);
        % regression_info(i,8)
        % if regression_info(i,8)==1
        text(x(pt_start),txt_height,'*');
        if isStimulus == 0
            line([x(pt_start) x(pt_start)],[ymin  new_ymax],'Color','k');
        end
        %  fprintf('item printed \n');
        % end
    end  % next i

end

% Plot when stimulus is given
if isStimulus == 1

    stim_indexes = find(stimulus);
    [nr nc] = size(stim_indexes);

    if nr > 0
    increment = (ymax-ymin)/10;
    txt_height = ymax;
    new_ymax = ymax +increment;
        for i= 1:nr
            pt_start =stim_indexes(i);
            % regression_info(i,8)
            % if regression_info(i,8)==1
            line([x(pt_start) x(pt_start)],[ymin  new_ymax],'Color','k');
            %  fprintf('item printed \n');
            % end
        end  % next i
    end
end

if start_peak  == 1
    increment = (ymax-ymin)/10;
    txt_height = ymax;
    new_ymax = ymax +increment;

    axis([xmin xmax ymin new_ymax] );

    for i= 1:number_of_spikes_20
        pt_end =secretory_sequence_20(i,2);
        % regression_info(i,8)
        % if regression_info(i,8)==1
        text(x(pt_end),txt_height,'*');
        if isStimulus == 0
            line([x(pt_end) x(pt_end)],[ymin  new_ymax],'Color','k');
        end
        %  fprintf('item printed \n');
        % end
    end  % next i
end

%-------------------------------
% if flag set convert to log format
if yscale == 1
    set(gca,'YScale','Log');
end


%-------------------------------------------------------------------------
% Save graphics
print -dmeta;
saveas(h,fig_fn, 'fig');
saveas(h,jpg_fn, 'jpg');

%-------------------------------------------------------------------------
% Display warning
% Warn user about missing data points
gap_minutes = floor(GAP_TOLERENCE*60);
if deleted_rises
    s = sprintf('A potential pulse rise was removed due missing data in excess of the gap tolerence (%d min). The removed rise is marked with a dashed line.', gap_minutes);
    if deleted_rises == 1
        msgbox (s,'Missing Data Warning','warn')
    elseif deleted_rises >1
        msgbox (s,'Missing Data Warning','warn')
    end
end


if long_pulse_width_found
    s = sprintf('A pulse width of greater then 30 minutes was identified. Pulse width shortened to first sample that predicts a pulse width of less then or equal to 30 minutes.  The pulse width is measured from peak to nadir.');
    msgbox (s,'Pulse Width Warning','warn')
end

set(h, 'Position', pos1) ;