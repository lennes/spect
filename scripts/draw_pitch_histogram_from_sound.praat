# This script calculates a Pitch object from a Sound object,
# displays basic F0 statistics, draws a histogram according to the distribution 
# of the calculated pitch points, and saves all the original pitch values to a plain text file.
#
# Exactly one Sound object must be selected in the object window.
# 
# This script is distributed under the GNU General Public License.
# Mietta Lennes 30.9.2013
#
# ---- Updates ----
# 2022-11-24: 	Fixed in order to work with the new Praat scripting syntax 
#				(tested in Praat version 6.2.23). / ML
#


form Draw F0 histogram from Sound object
   comment Give the F0 analysis parameters:
	positive Minimum_pitch_(Hz) 80
	positive Maximum_pitch_(Hz) 400
	positive Time_step_(s) 0.01
   comment Save F0 point data to a text file in the directory:
	text directory 
	comment (Empty directory = the same directory where this script file is.)
   comment Number of "bars" in the histogram:
	integer Number_of_bins 30
	choice Pitch_scale_for_drawing 1
		button Hertz
		button mel
		button semitones re 100 Hz
		button ERB
endform

Erase all

# Define the name of the text file:
soundname$ = selected$ ("Sound")
filename$ = directory$ + "f0points_'soundname$'.txt"
# Delete the old file if it exists:
if fileReadable(filename$)
	pauseScript: "Do you want to overwrite the old file 'filename$'?"
	deleteFile: filename$
endif

# Calculate F0 values
To Pitch: time_step, minimum_pitch, maximum_pitch
numberOfFrames = Get number of frames

# Loop through all frames in the Pitch object:
selectObject: "Pitch 'soundname$'"
unit$ = "Hertz"
min_Hz = Get minimum: 0, 0, "Hertz", "Parabolic"
min$ = "'min_Hz'"
max_Hz = Get maximum: 0, 0, "Hertz", "Parabolic"
max$ = "'max_Hz'"
mean_Hz = Get mean: 0, 0, "Hertz"
mean$ = "'mean_Hz'"
stdev_Hz = Get standard deviation: 0, 0, "Hertz"
stdev$ = "'stdev_Hz'"
median_Hz = Get quantile: 0, 0, 0.50, "Hertz"
median$ = "'median_Hz'"
quantile25_Hz = Get quantile: 0, 0, 0.25, "Hertz"
quantile25$ = "'quantile25_Hz'"
quantile75_Hz = Get quantile: 0, 0, 0.75, "Hertz"
quantile75$ = "'quantile75_Hz'"
if pitch_scale_for_drawing > 1
	unit$ = unit$ + "	'pitch_scale_for_drawing$'"
	min = Get minimum: 0, 0, pitch_scale_for_drawing$, "Parabolic"
	min$ = min$ + "	'min'"
	max = Get maximum: 0, 0, pitch_scale_for_drawing$, "Parabolic"
	max$ = max$ + "	'max'"
	mean = Get mean: 0, 0, pitch_scale_for_drawing$
	mean$ = mean$ + "	'mean'"
	if pitch_scale_for_drawing <> 3 
		pitch_scale_short$ = pitch_scale_for_drawing$
	else
		pitch_scale_short$ = "semitones"
	endif
	stdev = Get standard deviation: 0, 0, pitch_scale_short$
	stdev$ = stdev$ + "	'stdev'"
	median = Get quantile: 0, 0, 0.50, pitch_scale_for_drawing$
	median$ = median$ + "	'median'"
	quantile25 = Get quantile: 0, 0, 0.25, pitch_scale_for_drawing$
	quantile25$ = quantile25$ + "	'quantile25'"
	quantile75 = Get quantile: 0, 0, 0.75, pitch_scale_for_drawing$
	quantile75$ = quantile75$ + "	'quantile75'"
endif

# Print the statistics to the Info window:
appendInfoLine: "F0 statistics from sound: 'soundname$'"
appendInfoLine: ""
appendInfoLine: " 	'unit$'"
appendInfoLine: "Min	'min$'"
appendInfoLine: "Max	'max$'"
appendInfoLine: "Median	'median$'"
appendInfoLine: "25% quantile	'quantile25$'"
appendInfoLine: "75% quantile	'quantile75$'"
appendInfoLine: "Mean	'mean$'"
appendInfoLine: "Stdev	'stdev$'"
appendInfoLine: ""
appendInfoLine: "---"
appendInfoLine: "Selected options"
appendInfoLine: "Minimum pitch: 'minimum_pitch' Hz"
appendInfoLine: "Maximum pitch: 'maximum_pitch' Hz"
appendInfoLine: "Time step: 'time_step' s"
appendInfoLine: "Number of bins in the histogram: 'number_of_bins'"

# Collect and save the pitch values from the individual frames to the text file:
for iframe to numberOfFrames
	timepoint = Get time from frame: iframe
	f0 = Get value in frame: iframe, pitch_scale_for_drawing$
	if f0 <> undefined
		appendFileLine: filename$, "'f0'"
	endif
endfor

# Convert the original minimum and maximum parameters in order to define the x scale of the 
# picture, if required:
if pitch_scale_for_drawing = 2
	minimum_pitch = hertzToMel(minimum_pitch)
	maximum_pitch = hertzToMel(maximum_pitch)
elsif pitch_scale_for_drawing = 3
	minimum_pitch = hertzToSemitones(minimum_pitch)
	maximum_pitch = hertzToSemitones(maximum_pitch)
elsif pitch_scale_for_drawing = 4
	minimum_pitch = hertzToErb(minimum_pitch)
	maximum_pitch = hertzToErb(maximum_pitch)
endif

# Read the saved pitch points as a Table object and convert into a Matrix object:
Read Table from tab-separated file: filename$
Down to Matrix

# Draw the Histogram
Draw distribution: 0, 0, 0, 0, minimum_pitch, maximum_pitch, number_of_bins, 0, 0, "yes"
Text bottom: "yes", pitch_scale_for_drawing$

appendInfoLine: ""
appendInfoLine: "The defined pitch values from all frames were saved to the file"
appendInfoLine: "'filename$'."