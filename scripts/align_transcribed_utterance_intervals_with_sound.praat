# Automatic alignment of transcribed utterances in selected tiers within a TextGrid file
# with the corresponding sound file.
#
# Alignment is performed using the eSpeak based automatic 
# aligner available in the TextGrid editor window in Praat, see, e.g., 
# http://info.linguistlist.org/aardvarc/resources/AARDVARC_Boersma_Abstract.pdf.
#
# This script is distributed under GNU General Public License.
# Mietta Lennes 16.5.2017
# 
# Updated 2021-02-26: List of languages according to Praat v6.1.31
# Updated 2019-10-16: Tested to work on Praat v6.1.04
# Updated 2019-12-13: Added all supported languages to the option menu
#
# NB:
# In older Praat versions (<= v6.1.03), the script may fail 
# due to a bug in the forced alignment command in Praat.
# The bug was fixed in Praat 6.1.04.
# 
# Note also:
# The list of languages may not be compatible with Praat versions < v6.1.31!
#


# This is where the aligned TextGrid will be written:
outputdir$ = ""

form Align the text within utterance tiers in a TextGrid 
   word TextGrid_file /Users/lennes/Demo/forced_alignment_in_Praat/pohjantuuli/pohjantuuli_ja_aurinko.TextGrid
   word Sound_file_(WAV) /Users/lennes/Demo/forced_alignment_in_Praat/pohjantuuli/pohjantuuli_ja_aurinko.wav
	sentence Process_tier_names_containing_(empty=all) utterance
	optionmenu Language: 31
		option Afrikaans
		option Albanian
		option Amharic
		option Arabic
		option Aragonese
		option Armenian (East Armenia)
		option Armenian (West Armenia)
		option Assamese
		option Azerbaijani
		option Basque
		option Bengali
		option Bishnupriya Manipuri
		option Bosnian
		option Bulgarian
		option Catalan
		option Chinese (Cantonese)
		option Chinese (Mandarin)
		option Croatian
		option Czech
		option Danish
		option Dutch
		option English (America)
		option English (Caribbean)
		option English (Great Britain)
		option English (Lancaster)
		option English (Received Pronunciation)
		option English (Scotland)
		option English (West Midlands)
		option Esperanto
		option Estonian
		option Finnish
		option French (Belgium)
		option French (France)
		option French (Switzerland)
		option Gaelic (Irish)
		option Gaelic (Scottish)
		option Georgian
		option German
		option Greek
		option Greek (Ancient)
		option Greenlandic
		option Guarani
		option Gujarati
		option Hakka Chinese
		option Hindi
		option Hungarian
		option Icelandic
		option Indonesian
		option Interlingua
		option Italian
		option Japanese
		option Kannada
		option Konkani
		option Korean
		option Kurdish
		option Kyrgyz
		option Latin
		option Latvian
		option Lingua Franca Nova
		option Lithuanian
		option Lojban
		option Macedonian
		option Malay
		option Malayalam
		option Maltese
		option Marathi
		option Myanmar (Burmese)
		option Māori
		option Nahuatl (Classical)
		option Nepali
		option Norwegian Bokmål
		option Oriya
		option Oromo
		option Papiamento
		option Persian
		option Persian (Pinglish)
		option Polish
		option Portuguese (Brazil)
		option Portuguese (Portugal)
		option Punjabi
		option Romanian
		option Russian
		option Serbian
		option Setswana
		option Sindhi
		option Sinhala
		option Slovak
		option Slovenian
		option Spanish (Latin America)
		option Spanish (Spain)
		option Swahili
		option Swedish
		option Tamil
		option Tatar
		option Telugu
		option Turkish
		option Urdu
		option Vietnamese (Central)
		option Vietnamese (Northern)
		option Vietnamese (Southern)
		option Welsh
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

