# This script opens audio file + transcript file pairs one by one,
# lets you play back each recording to check the transcript,
# and saves your brief comments for each file if you wish.
# The script can also count the number of lines and words (separated by spaces) 
# in each transcript file.
#
# You may use and modify the script freely.
# 
# Mietta Lennes 20.8.2025
#

form: "Review plain text transcripts of audio files"
	positive: "Start from file (number)", "1"
	text: 2, "Transcript folder", "/Users/lennes/corpora_in_progress/transcripts"
	word: "Transcript file extension", ".txt"
	text: 2, "Audio folder", "/Users/lennes/corpora_in_progress/audio"
	word: "Audio file extension", ".flac"
	text: 2, "Comment file", "transcript_comments.txt"
	comment: "If a file name is given with no path, the file will be saved" 
	comment: "in the folder where this Praat script is located."
	boolean: "Overwrite previous comments", 0
	boolean: "Calculate file durations", 1
	boolean: "Calculate text stats", 1
endform


#------------
writeInfoLine: "Starting from file 'start_from_file'"

fileNames$# = fileNames$#: (transcript_folder$ + "/*" + transcript_file_extension$)
files = size (fileNames$#)
# In case the user chose to overwrite, we add a title row to an empty file.
if overwrite_previous_comments = 1
		comments$ = "Timestamp (Date and time)	File"
		if calculate_file_durations = 1
			comments$ = comments$ + "	Dur (s)"
		endif
		if calculate_text_stats = 1
			comments$ = comments$ + "	Lines	Words"
		endif
		comments$ = comments$ + "	Comment"
		writeFileLine: comment_file$, comments$
endif

lines$ = ""
words$ = ""

# Loop through all the files found in the transcript folder:
for ifile from start_from_file to files
	Read Strings from raw text file: transcript_folder$ + "/" + fileNames$# [ifile]
	name$ = selected$ ("Strings")

	# Analyze the transcript text as a Strings object, to count lines and words:
	if calculate_text_stats = 1
		lines = Get number of strings
		lines$ = "'lines''tab$'"
		words = 0
		for line to lines
			tmp_line$ = Get string: line
				if tmp_line$ <> ""
					if index (tmp_line$, " ") = 0
						words = words + 1
						tmp_line$ = ""
					endif
				endif
				# Divide the utterance into words at (one or more) space characters
				while index(tmp_line$," ") > 0 or length(tmp_line$) > 0
					words = words + 1
					if index(tmp_line$, " ") > 0
						tmp_line$ = right$(tmp_line$, length(tmp_line$)-index(tmp_line$, " "))
						while left$ (tmp_line$,1 ) = " "
							tmp_line$ = right$(tmp_line$, length(tmp_line$)-1)
						endwhile
					else
						tmp_line$ = ""
					endif
				endwhile
		endfor
		words$ = "'words''tab$'"
	endif	

	# Open the transcript text in a Strings editor window:
	View & Edit
	endeditor

	# Read the corresponding audio file:
	Read from file: audio_folder$ + "/" + name$ + audio_file_extension$
	dur$ = ""
	if calculate_file_durations = 1
		dur = Get total duration
		dur$ = "'dur:2''tab$'"
	endif
	Edit
	endeditor

	beginPause: "Evaluate the transcript 'ifile'/'files' and continue."
		comment: "You may now play portions of the audio file to check the transcript."
		comment: "Click on the grey bars below the waveform. Hit Esc to stop playback."
		comment: "When done, type a brief comment for this file if you wish:"
		text: 5, "textcomment", ""
		comment: "The comment will be added to 'comment_file$', if you click Save and continue."
	clicked = endPause: "Save and continue", "Exit", 1

if clicked = 1

	# Append the details about this transcript (and audio) file 
	# to the tab-separated comment file:
	appendInfoLine: "Saving the comment for file 'name$' ('ifile'/'files'):  " + textcomment$
	appendFileLine: comment_file$, "[" + date$() + "]'tab$''name$''tab$''dur$''lines$''words$'" + textcomment$
	selectObject: "Sound 'name$'"
	plusObject: "Strings 'name$'"
	Remove
elsif clicked = 2
	selectObject: "Sound 'name$'"
	plusObject: "Strings 'name$'"
	Remove
	appendInfoLine: ""
	appendInfoLine: "Started from file 'start_from_file', stopped at file 'ifile'/'files'."
	appendInfoLine: "Your previous comments can be found in 'comment_file$'"
	appendInfoLine: "(excluding the last viewed file 'ifile', 'name$')."
	exit
	
endif


endfor

#--- All done.

# Remove the last objects that are left in the object list.
selectObject: "Sound 'name$'"
plusObject: "Strings 'name$'"
Remove

appendInfoLine: "Done: 'ifile'/'files'."


