# Get total duration of all .wav audio files in a directory
#
# Mietta Lennes
# 6.10.2017

form Get total duration of .wav audio files in a directory
  sentence directory wav/
endform

Create Strings as file list: "files", "'directory$'*.wav"
strings = Get number of strings
writeInfoLine: "'strings' files found! Processing..."

duration_sum = 0

for file to strings
	selectObject: "Strings files"
	file$ = Get string: file

	# Open the next sound file:
	Open long sound file: "'directory$''file$'"
	#appendInfoLine: file$
	
	wav$ = selected$ ("LongSound")
	total_duration = Get total duration
	appendInfoLine: "'file$'	'total_duration' s"
	duration_sum = duration_sum + total_duration

	Remove
endfor

appendInfoLine: "Total duration of all files: 'duration_sum' seconds"

minutes = floor(duration_sum / 60)
duration_sum = duration_sum - (minutes * 60)
seconds = ceiling (duration_sum)
hours = floor(minutes / 60)
minutes = minutes - (hours * 60)

appendInfoLine: "= 'hours':'minutes'.'seconds'"

