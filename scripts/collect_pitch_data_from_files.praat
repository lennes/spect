# This script goes through sound and TextGrid files in a directory,
# opens each pair of Sound and TextGrid, calculates the pitch maximum
# of each labeled interval, and saves results to a text file.
# To make some other or additional analyses, you can modify the script
# yourself... it should be reasonably well commented! ;)
#
# This script is distributed under the GNU General Public License.
# Copyright 4.7.2003 Mietta Lennes http://orcid.org/0000-0003-4735-3017
# Praat new syntax version 2016-08-14 stefan.werner@uef.fi
# A few more slight improvements 2016-11-24 Mietta Lennes http://orcid.org/0000-0003-4735-3017

form Analyze pitch maxima from labeled segments in files
	comment Which tier do you want to analyze?
	sentence Tier äänteet
	comment Pitch analysis parameters
	positive Time_step 0.01
	positive Minimum_pitch_(Hz) 75
	positive Maximum_pitch_(Hz) 300
	comment Filename extensions for the files to be analyzed:
	sentence Sound_file_extension .wav
	sentence TextGrid_file_extension .TextGrid
endform

writeInfoLine: "- Select the directory with the sound files to be analyzed"
sound_directory$ = chooseDirectory$: "Select the directory with the sound files to be analyzed"
appendInfoLine: "- Select the directory with the TextGrid files to be analyzed"
textGrid_directory$ = chooseDirectory$: "Select the directory with the TextGrid files to be analyzed"

resultfile$ = chooseWriteFile$: "Save the analysis results to file:", "pitchresults.txt"

# Here, you make a listing of all the sound files in a directory.

fileList = Create Strings as file list: "Files in directory", sound_directory$ +"/*" + sound_file_extension$

numberOfFiles = Get number of strings
appendInfoLine: "'newline$''numberOfFiles' sound files found in 'sound_directory$'"

# Check if the result file exists:
if fileReadable (resultfile$)
  # uncomment next line if you want to stop the script before it overwrites an old result file
	# pauseScript: "The result file ", resultfile$, " already exists! Do you want to overwrite it?"
	deleteFile: resultfile$
endif

# Write a row with column titles to the result file:
# (remember to edit this if you add or change the analyses!)

titleline$ = "Filename" + tab$ + "Segment label" +  tab$ + 	"Maximum pitch (Hz)"
appendFileLine: resultfile$, titleline$

# Go through all the sound files, one by one:

for ifile to numberOfFiles
	filename$ = Get string: ifile
	# A sound file is opened from the listing:
	sound = Read from file: sound_directory$ + "/" + filename$
  # Starting from here, you can add everything that should be 
	# repeated for every sound file that was opened:
	soundname$ = selected$ ("Sound")
	pitch = To Pitch: time_step, minimum_pitch, maximum_pitch
	# Open a TextGrid by the same name:
	gridfile$ = textGrid_directory$ + "/" + soundname$ + textGrid_file_extension$
	if fileReadable (gridfile$)
		tg = Read from file: gridfile$
		# Find the tier number that has the label given in the form:
		@getTier: tier$
		numberOfIntervals = Get number of intervals: getTier.number
		# Pass through all intervals in the selected tier:
		for interval to numberOfIntervals
			label$ = Get label of interval: getTier.number, interval
			if label$ <> ""
				# if the interval has an unempty label, get its start and end:
				start = Get starting point: getTier.number, interval
				end = Get end point: getTier.number, interval
				# get the Pitch maximum at that interval
				selectObject: pitch
				pitchmax = Get maximum: start, end, "Hertz", "None"
				# Save result to text file:
				resultline$ = soundname$ + tab$ + label$ + tab$ + fixed$ (pitchmax, 0)
				appendFileLine: resultfile$, resultline$
				selectObject: tg
			endif
		endfor
		# Remove the TextGrid object from the object list
		selectObject: tg
		Remove
	endif
	# Remove the temporary objects from the object list
	selectObject: sound
	plusObject: pitch
	Remove
	selectObject: fileList
	# and go on with the next sound file!
endfor

Remove

appendInfoLine: "'newline$'Finished!"
appendInfoLine: "'newline$'The analysis results were saved to this file: 'newline$'  'resultfile$'"


#-------------
# This procedure finds the number of a tier that has a given name.
# (There is no real need for a proc here since the code is only run once
# - but you may find the snippet useful in your own scripts.)

procedure getTier: .tiername$
        numberOfTiers = Get number of tiers
        itier = 1
        .number = 0
        repeat
                tryTier$ = Get tier name: itier
                itier = itier + 1
        until tryTier$ = tier$ or itier > numberOfTiers
        if tryTier$ <> tier$
                .number = 0
        else
                .number = itier - 1
        endif

	if .number = 0
		exitScript: "The tier called ",  tier$,  " is missing from the file ",  soundname$, "!"
	endif

endproc
