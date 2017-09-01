# SbPulse
Modified Santen-Bartin Pulse Detection Algorithm for Lutenizing Hormone

## Overview
A MATLAB implemention of the Modified Santen-Bartin pulse detection extended to account for missing data.  The implementation build on the methods described in the three references listed below.

First created: August 14, 2002
Last change: February 14, 2008
Programmer: Dennis A. Dean, II, PhD

### References

Bardin et. al., Episodic Luteinizing Hormone Secretion in Man: Pulse Analysis, Clinical Interpretation, Physiologic Mechanisms, 1973

Whitcomb et. al, Utility of Free -subunit as an Alternative Neuroendocrine Marker of Gonadotropin-Releasing Hormone (GnRH) Simulation of the Gonadadotroph in the Human: Evidence from Normal and GnRH-D, 1990

Adams et. al., The Midcycle Gonadotropin Surge in Normal Women Occurs in the Face of an Unchanging Gonadotrpin-Releasing Hormone Pulse Frequency, 1994

### Note

The interface was built with a 2008 MATLAB version.

## Implementation Details

### File list



### Function Prototype
function santen_bardin_mod_12 (data_file, graph_title, x_label, y_label,comments, assay_cov, algor_value, start_peak, Sample_id, yscale, zero_time, time_scale, user_y_scale

### Input
   data_file - Two columns (Time (min), LH concentration (iul))
   graph_title - figure title (string)
   x_label - x axis label (string)
   y_label - y axis label (string)
   comments - text comments for output
   assay_cv - assay coefficient of variation (4-10 %)

### Output
   dat_file.txt - A text file is automatically written in the same
   directory
   data_file.fig - figure file is automatically created and written to
   disk
   data_file.jpg - a jpg file is automatically created and written to
   disk

### Revisions
   March 23, 2004  Made output excel friendly
   March 25, 2004  Corrected output for minimum amplitude
   March 28, 2004  Changed minimum number of points from 3 to 2
   October , 2004  Major upgrade to 1.0.3 Interface changes reccomended
                   by Dr. Hall. Created flag to reduce output for release
   December, 2004  Fixed figure saving bug+
   December, 2004  Remove Pulses with missing data - set by GAP_TOLERENCE

#### Algorithmn revision (January 3, 2005)
Implementing Santen Bartin in software required detail specification of
pulse identification including (1) identifying potential pulses,
(2) identifing the start of the pulse, (3) dealing with missing points,
and (4) Discerning noise and pulses in rapidly decreasing pulse trains

(1) Identifying potential pulses
Monitonically rising sequence of concentrations are used to idenitfy
potential pulses.  This rule is approached knowing that many more
pulse will be considered then would be tested by a human evaluation of
the Santen Bardin method

(2) Identify Pulse Start
The max imum decline within the rise is identified.  All points above the
maximum rise are marked as good.  The delta y below the max delta are
checked.  when the delta is less then 1 cv then the start of the pulse
has been found.

(3) Dealing with missing points
A new term, GAP_TOLERENCE, is introduced to exclude pulse rises that
are missing data in excess of the GAP tolerence. Pulses that are excluded
are identified graphically with a dashed line. The user is prompted with
a dialog box that informs the user of the number of pulse rised excluded
due to missing data.

(4) Discerning noise and pulses in rapidly decreasing pulse trains
Added a rule the remove pulses where the amplitude is less then
cv*max(amplitued).  This seemed to work in our one example

(5) New rule added to remove pulses found by program but not found by
hand.  Rule employed at the Reproductive Endocrine Unit at Mass General
Hospital.

#### April 20, 2005
Program inaccurately defines a gap in the data as a pulse rise.  Program
expects that the time units are in hours

#### April 26, 2005
(3b) Implement 30 minute pulse rule.  In the last round of analysis we used
< 1 cv difference in vertical difference to signal the start of the
pulse.  This approach was inadequate.  In this version we are
incorporating the 30 minute rule as done in the lab of Dr. Hall. The
start of the pulse is at most 30 minutes from the pulse peak.

#### May 6, 2005
Modified 30 minute pulse width to 35 to account for two minutes of error
on each side.  Same thing was done for gap.

#### July 25, 2005
Adding table of point removed with missing data. So that if using the
point is decided upon it is easy to get the information

#### August 2005
Adding interface refinements in preparation for release. Allow user to
start time at zero.  Infrastructure for covnerting between hours and
minutes are included.

#### August 10, 2005
Converting from rise identification from strickly monotonic to monotonic

#### August 16, 2005
Modified to read files with GnRh pulses identified

#### September 2005
Preparations for paper include adding user control of y axis and labeling
hormones with assay type.  Test with Andrew suggests that we need to
specify which is used so that program can be applied across assay and
hormones

#### February 2005
Rule for pulse rise is less then 30 minutes needs to check if pulse
following the shortening meets the pulse amplitude requirements

#### February 2008
Code for organizing figures modified to compensate for Matlab bug
that affects placement of the initial dialog.
