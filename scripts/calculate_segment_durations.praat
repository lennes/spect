# This script will calculate the durations of all labeled segments in a TextGrid object.
# The results will be saved in a text file, each line containing the label text and the 
# duration of the corresponding segment.
# A TextGrid object needs to be selected in the Object list.
#
# This script is distributed under the GNU General Public License.
# 4.11.2020 Mietta Lennes

# ask the user for the tier number
form Calculate durations of labeled segments
	comment Which tier of the TextGrid object would you like to analyse?
	sentence Tier word
	comment Next, you will be asked to locate a directory where the results can be saved…
endform

textfile$ = chooseWriteFile$: "Save the results in text file", "durations.txt"

if textfile$ = ""
	writeInfoLine: "No text file was selected. The results will be shown below but not saved."	
endif

call GetTier 'tier$' tier

if tier > 0
	# check how many intervals there are in the selected tier:
	numberOfIntervals = Get number of intervals: tier

	# loop through all the intervals
	for interval from 1 to numberOfIntervals
		label$ = Get label of interval: tier, interval
		# if the interval has some text as a label, then calculate the duration.
		if label$ <> ""
			start = Get starting point: tier, interval
			end = Get end point: tier, interval
			duration = end - start
			# Append the label and the duration to the end of the text file, separated with a tab.	
			resultline$ = "'label$'	'duration'"
			if textfile$ <> ""
				appendFileLine: textfile$, resultline$
			else
				# If the file name was empty, the result will be shown in the Info window instead:
				appendInfoLine: resultline$
			endif
		endif
	endfor
endif

if textfile$ <> ""
	writeInfoLine: "Finished! The results were saved in 'textfile$'."	
endif




#-------------
# This procedure finds the number of a tier that has a given label.

procedure GetTier name$ variable$
        numberOfTiers = Get number of tiers
        itier = 1
        repeat
                tier$ = Get tier name: itier
                itier = itier + 1
        until tier$ = name$ or itier > numberOfTiers
        if tier$ <> name$
                'variable$' = 0
        else
                'variable$' = itier - 1
        endif

	if 'variable$' = 0
		exitScript: "The tier "'name$'" is missing from the selected TextGrid 'soundname$'."
	endif

endproc

