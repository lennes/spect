# This Praat script will clean up given tier(s) in a given TextGrid file
# and try to "sentencify" the content in order to create suitable input for a
# text parser. The script is intended for cleaning up after the AaltoASR speech recognizer.
#
# A text file will be created that contains the "sentences", one sentence per line.
# The "sentence" units will be added to the original TextGrid file in a new tier
# called "utterance". Previously existing "utterance" tiers will be removed.
#
# This script is distributed under GNU General Public License.
# Mietta Lennes 16.5.2017
#

# This is where the output TextGrid and text files will be written:
outputdir$ = ""

# For now, we process tier names that include the string "word" (since this is in AaltoASR output):
process_tier_names_containing$ = "word"

# Example call from command line:
#    /usr/bin/praat sentencify_tiers_in_textgrid_file.praat "/Users/lennes/Desktop/pohjantuuli/pohjantuuli_ja_aurinko.textgrid"
#
form Collect sentence-like units from a TextGrid file
	word File /Users/lennes/Desktop/pohjantuuli/pohjantuuli_ja_aurinko.TextGrid
endform

Read from file: file$
gridname$ = selected$("TextGrid")
textfilename$ = outputdir$ + gridname$ + ".txt"
gridfilename$ = outputdir$ + gridname$ + "_utt.textgrid"

numberOfTiers = Get number of tiers
sentence = 0

writeInfoLine: "Processing TextGrid 'gridname$'"


for tier from 1 to numberOfTiers
	tier$ = Get tier name: tier
	appendInfoLine: "Checking tier 'tier' ('tier$')..."
	if tier = 1 and tier$ = "utterance"
		Remove tier: tier
		numberOfTiers = numberOfTiers - 1
		appendInfoLine: "  - Removed"
		tier$ = Get tier name: tier
	endif
	if index(process_tier_names_containing$, tier$) > 0
		newtier = tier + 1
		newtier2 = tier + 2
		Insert interval tier: newtier, "'tier$'-clean"
		Insert interval tier: newtier2, "utterance"
		appendInfoLine: "Inserted tiers 'newtier' ('tier$'-clean) and 'newtier2' ('tier$'-sent), processing..."
		numberOfIntervals = Get number of intervals: tier
		prev_int$ = ""
		prev_pause = 0
		start = 0
		prev_end = 0
		new_int = 1
		new_int2 = 1
		text_'sentence'$ = ""
		for i from 1 to numberOfIntervals	
			int$ = Get label of interval: tier, i
			end = Get end point: tier, i
			if int$ = ""
				dur = end - prev_end
				if dur > 0.05 or i = 1
					call cleanText
					Set interval text: newtier2, new_int2, string$
					if new_int2 > 1
						Insert boundary: newtier2, prev_end
						new_int2 = new_int2 + 1
					endif
					#appendInfoLine: string$
					sentence = sentence + 1
					text_'sentence'$ = ""
					# If this is the very first sentence, begin new text file:
					if sentence = 1
						writeFile: textfilename$
					# Insert empty line before each new tier:
					elsif i = 1
						appendFileLine: textfilename$, ""
					endif
					appendFileLine: textfilename$, string$
					if i < numberOfIntervals
						Insert boundary: newtier, end
						new_int = new_int + 1
						Insert boundary: newtier2, end
						new_int2 = new_int2 + 1
					endif
				else
					newtime = prev_end + dur / 2
					Insert boundary: newtier, newtime
					Remove left boundary: newtier, new_int
				endif
			else
				text_'sentence'$ = text_'sentence'$ + int$ + " "
				Set interval text: newtier, new_int, int$
				if i < numberOfIntervals
					Insert boundary: newtier, end
					new_int = new_int + 1
				endif
			endif
			prev_int$ = int$			
			prev_end = Get end point: tier, i
		endfor
		tier = tier + 1
		numberOfTiers = numberOfTiers + 1
	endif
endfor
Save as text file: gridfilename$
appendInfoLine: "... Finished."


procedure cleanText
	# To include more cleanup for each sentence…
	string$ = text_'sentence'$
	string$ = left$(string$, length(string$)-1)
endproc