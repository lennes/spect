#
#### NB: THIS SCRIPT IS A DRAFT - IT MAY NOT WORK AS EXPECTED!
#
# This script goes through sound (.wav) and annotation (.TextGrid) files in a directory,
# opens each pair as Sound and TextGrid, 
# performs acoustic analyses of all matching target intervals 
# within a given tier that has a given label,
# collects some information about the intervals in a couple of other tiers 
# at and around the target item, 
# and saves the results in a tab-separated text file.
#
# This script is distributed under the GNU General Public License.
# Mietta Lennes 12.4.2021

form Analyze formants within labeled segments in files
	comment Directory of sound files
	text sound_directory /Users/lennes/Desktop/testi1/
	sentence Sound_file_extension .wav
	comment Directory of TextGrid files
	text textGrid_directory /Users/lennes/Desktop/testi1/
	sentence TextGrid_file_extension .TextGrid
	comment Full path of the resulting text file:
	text resultfile /Users/lennes/Desktop/results.txt
	comment ---
	sentence Target_segment s
	comment Which tier contains the target segments?
	sentence Phone_tier phone
	comment Which tier contains the syllable intervals?
	sentence Syllable_tier syllable
	comment Which tier contains the word intervals?
	sentence Word_tier word
endform


date$ = date$()
writeInfoLine: "'date$'"
appendInfoLine: ""


#### Analysis parameters

# Spectral analysis
spectral_analysis_window_shape$ = "rectangular"

# Formant analysis parameters
time_step_formant = 0.01
maximum_number_of_formants = 5
maximum_formant = 5500
window_length = 0.025
preemphasis_from = 50

#Pitch analysis parameters
pitch_analysis_margin = 0.05
time_step_pitch = 0
pitch_floor = 80
pitch_ceiling = 350

######

# Here, you make a listing of all the sound files in a directory.
# The example gets file names ending with ".wav" from corpus/

Create Strings as file list... list 'sound_directory$'*'sound_file_extension$'
numberOfFiles = Get number of strings

# Check if the result file exists:
if fileReadable (resultfile$)
	pause The result file 'resultfile$' already exists! Do you want to overwrite it?
	filedelete 'resultfile$'
endif

resultlines = 0

# Write a row with column titles to the result file:
# (remember to edit this if you add or change the analyses!)

titleline$ = "Filename"
titleline$ = titleline$ + "	PhoneLabel"
titleline$ = titleline$ + "	PhoneDuration"
titleline$ = titleline$ + "	MaximumPitch"
titleline$ = titleline$ + "	CentreOfGravity"
titleline$ = titleline$ + "	PositionInSyllable"
titleline$ = titleline$ + "	NumberOfPhonesInSyllable"
titleline$ = titleline$ + "	SyllableLabel"
titleline$ = titleline$ + "	PositionInWord"
titleline$ = titleline$ + "	NumberOfSyllables"
titleline$ = titleline$ + "	WordLabel"
titleline$ = titleline$ + newline$
fileappend 'resultfile$' 'titleline$'

# Go through all the sound files, one by one:

for ifile to numberOfFiles
	filename$ = Get string... ifile
	# A sound file is opened from the listing:
	Read from file... 'sound_directory$''filename$'
	soundname$ = selected$ ("Sound", 1)

	# Open a TextGrid by the same name:
	gridfile$ = "'textGrid_directory$''soundname$''textGrid_file_extension$'"
	if fileReadable (gridfile$)

		Read from file... 'gridfile$'
		gridname$ = selected$ ("TextGrid", 1)

		# Find the tier number that has the label given in the form:
		call GetTier 'phone_tier$' phone_tier

		if phone_tier > 0
		
			appendInfoLine: "Analyzing TextGrid file: 'gridname$'"

			numberOfIntervals = Get number of intervals... phone_tier
			call GetTier 'syllable_tier$' syllable_tier
			call GetTier 'word_tier$' word_tier

			call InitializeVariables

			# Pass through all intervals in the selected tier:
			for interval to numberOfIntervals
				label$ = Get label of interval... phone_tier interval
				if label$ = target_segment$
					# if the interval label matches the target text, get its start and end time:
					start = Get starting point... phone_tier interval
					end = Get end point... phone_tier interval
					midpoint = (start + end) / 2
					segment_duration = end - start

					call Analysis
					
					# If the other tiers exists, check position in them:
					if syllable_tier > 0
						call CheckPosition phone_tier interval syllable_tier syllable
						out_of_phones = out_of
						syllable_label$ = Get label of interval... syllable_tier syllable_interval
					else
						position_in_syllable = 0
						out_of_phones = 0
					endif
					if word_tier > 0
						call CheckPosition syllable_tier syllable_interval word_tier word
						out_of_syllables = out_of
						word_label$ = Get label of interval... word_tier word_interval
					else
						position_in_word = 0
						out_of_syllables = 0
					endif

					# Collect a line of results and save it to the text file:

					resultline$ = soundname$
					resultline$ = resultline$ + "	'label$'"
					resultline$ = resultline$ + "	'segment_duration:5'"

					# One column will be added per each acoustic analysis result:
					resultline$ = resultline$ + "	'pitch_max'"
					resultline$ = resultline$ + "	'centre_of_gravity'"

					# Columns for denoting the position of the target segment within syllables and words:
					resultline$ = resultline$ + "	'position_in_syllable'"
					resultline$ = resultline$ + "	'out_of_phones'"
					resultline$ = resultline$ + "	'syllable_label$'"
					resultline$ = resultline$ + "	'position_in_word'"
					resultline$ = resultline$ + "	'out_of_syllables'"
					resultline$ = resultline$ + "	'word_label$'"

					resultline$ = resultline$ + newline$
					
					resultlines = resultlines + 1

					fileappend 'resultfile$' 'resultline$'

					# Make sure the same results are not accidentally copied to the following segments that are analyzed:
					call InitializeVariables

					select TextGrid 'soundname$'
				endif
			endfor
		endif
		# Remove the TextGrid object from the object list
		select TextGrid 'soundname$'
		Remove
	endif
	# Remove the sound object from the object list
	select Sound 'soundname$'
	Remove
	select Strings list
	# and go on with the next sound file!
endfor

appendInfoLine: ""
appendInfoLine: "…Done!"
appendInfoLine: ""
appendInfoLine: "'resultlines' lines were written to 'resultfile$'."


Remove


#-------------
# This procedure finds the number of a tier that has a given label.

procedure GetTier name$ variable$
        numberOfTiers = Get number of tiers
        itier = 1
        repeat
                tiername$ = Get tier name... itier
                itier = itier + 1
        until tiername$ = name$ or itier > numberOfTiers
        if tiername$ <> name$
                'variable$' = 0
        else
                'variable$' = itier - 1
        endif

endproc

# -------------
# This procedure will check how many intervals in tier sel_tier are included
# in a simultaneous interval in position_tier, and what is the running index
# number of sel_interval of these intervals. Use for, e.g., checking
# what the position of a word is within an utterance.
# position = index number of sel_interval
# out_of = number of sel_tier intervals within the interval in position_tier

procedure CheckPosition sel_tier sel_interval position_tier variable$

select TextGrid 'gridname$'

position = 0
out_of = 0
sel_number_of_intervals = Get number of intervals... sel_tier

# Initial overflow means that the sel_interval starts before the unit in position_tier starts.
# Final overflow means that the sel_interval ends after the unit in position_tier ends.
'variable$'_initial_overflow = 0
'variable$'_final_overflow = 0

tempStart1 = Get starting point... sel_tier sel_interval
tempEnd1 = Get end point... sel_tier sel_interval
tempMiddle1 = (tempStart1 + tempEnd1) / 2

# The corresponding unit in position_tier is the interval that occurs around the mid point of sel_interval:
tempInterval2 = Get interval at time... position_tier tempMiddle1
tempStart2 = Get starting point... position_tier tempInterval2
tempEnd2 = Get end point... position_tier tempInterval2

'variable$'_label$ = Get label of interval... position_tier tempInterval2
'variable$'_interval = tempInterval2

if tempStart1 >= tempStart2 and tempEnd1 <= tempEnd2
	i1 = Get interval at time... sel_tier tempStart2
	tempStart = i1
	endpoint = Get end point... sel_tier i1
	# count how many intervals of sel_tier fit in the interval in position_tier
	repeat
		if i1 = sel_interval
			position = i1 - tempStart + 1
		endif
		out_of = out_of + 1
		i1 = i1 + 1
		if i1 <= sel_number_of_intervals
			endpoint = Get end point... sel_tier i1
		endif
	until endpoint > tempEnd2 or i1 > sel_number_of_intervals
# Else, the sel_interval was not completely included by any interval in tier position_tier
elsif tempStart1 < tempStart2 and tempEnd1 <= tempEnd2
	# if there is initial overflow, the sel_interval is always the first unit:
	'variable$'_initial_overflow = 1
	position = 1
	i1 = Get interval at time... sel_tier tempStart2
	tempStart = i1
	endpoint = Get end point... sel_tier i1
	# count how many intervals of sel_tier fit in the interval in position_tier
	repeat
		out_of = out_of + 1
		i1 = i1 + 1
		endpoint = Get end point... sel_tier i1
	until endpoint > tempEnd2	
elsif tempStart1 >= tempStart2 and tempEnd1 > tempEnd2
	'variable$'_final_overflow = 1
	position = out_of
	i1 = Get interval at time... sel_tier tempStart2
	tempStart = i1
	endpoint = Get end point... sel_tier i1
	# count how many intervals of sel_tier fit in the interval in position_tier
	repeat
		out_of = out_of + 1
		i1 = i1 + 1
		endpoint = Get end point... sel_tier i1
	until endpoint > tempEnd2	
else
	position = 1
	out_of = 1
	'variable$'_initial_overflow = 1
	'variable$'_final_overflow = 1
endif

position_in_'variable$' = position

endproc


######
procedure InitializeVariables

		segment_duration = 0
		syllable_label$ = ""
		word_label$ = ""
		centre_of_gravity = 0
		pitch_max = 0

endproc


######
procedure Analysis

	# (Here, we should potentially add a margin around the segment to be analyzed, 
	# to make sure the sample is long enough for instance if analyzing pitch.)

	analysis_window_start = start
	analysis_window_end = end

	select Sound 'soundname$'
	Extract part: analysis_window_start, analysis_window_end, spectral_analysis_window_shape$, 1, "yes"
	Rename: "tmp"

	# Starting from here, you can add everything that should be 
	# analysed of the Sound object corresponding to the target interval.
	#


	# Try analyzing the pitch maximum within the target segment (NB this would potentially require 
	# a longer sound interval to be extracted first!):

	To Pitch: time_step_pitch, pitch_floor, pitch_ceiling 
	pitch_max = Get maximum: start, end, "Hertz", "parabolic"
	# Get rid of the Pitch object
	Remove
	select Sound 'soundname$'



	# Next, we analyze the spectrum of the target interval.

	To Spectrum: "yes"
	
	centre_of_gravity = Get centre of gravity: 2.0


	# Starting from here, you can add everything that should be 
	# analysed of the Spectrum object corresponding to the target interval.
	#






	#
	# after the Spectrum object has been analyzed, we remove it from the Object list:
	Remove
	select Sound tmp
	Remove

	# Select the TextGrid again (and go back to continue searching for the next target item).
	select TextGrid 'soundname$'

endproc