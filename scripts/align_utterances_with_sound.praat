# Automatic alignment of text in selected tiers in TextGrid file
# with the corresponding sound file
#
# Alignment is performed using the eSpeak based automatic 
# aligner available in the TextGrid editor window in Praat, see, e.g., 
# http://info.linguistlist.org/aardvarc/resources/AARDVARC_Boersma_Abstract.pdf.
#
# This script is distributed under GNU General Public License.
# Mietta Lennes 16.5.2017
#


# This is where the aligned TextGrid will be written:
outputdir$ = ""

form Align the text within utterance tiers in a TextGrid 
   word TextGrid_file /Users/lennes/Desktop/pohjantuuli/pohjantuuli_ja_aurinko_utt.TextGrid
   word Sound_file_(WAV) /Users/lennes/Desktop/pohjantuuli/pohjantuuli_ja_aurinko.wav
	sentence Process_tier_names_containing_(empty=all) utterance
	optionmenu Language: 9
		option Afrikaans
		option Albanian
		option Amharic-test
		option Aragonese
		option Armenian
		option Dutch
		option English
		option English-us
		option Finnish
		option French
		option German
		option Hungarian
		option Italian
		option Russian
		option Spanish
		option Swedish
endform

grid = Read from file: textGrid_file$
gridname$ = selected$("TextGrid")
gridfilename$ = outputdir$ + gridname$ + "_aligned.textgrid"
numberOfTiers = Get number of tiers

sound = Read from file: sound_file$
selectObject: sound
plusObject: grid
View & Edit
editor: "TextGrid " + gridname$
Alignment settings: language$, "yes", "yes", "yes"

for tier from 1 to numberOfTiers
	endeditor
	selectObject: grid
	tier$ = Get tier name: tier
	typeint = Is interval tier: tier
	numberOfIntervals = Get number of intervals: tier
	selectObject: sound
	plusObject: grid
	editor: "TextGrid " + gridname$
	if (process_tier_names_containing$ =="" or index(tier$, process_tier_names_containing$) > 0) and typeint = 1
		for i from 1 to numberOfIntervals
			Align interval
			Select next interval
			Zoom to selection
			Zoom out
		endfor
		appendInfoLine: "Aligned the intervals in tier 'tier' ('tier$') - language: 'language$'"
		numberOfTiers = numberOfTiers + 2
		tier = tier + 2
		Select next tier
	endif
	Select next tier
endfor
	
endeditor


selectObject: grid
Save as text file: gridfilename$

