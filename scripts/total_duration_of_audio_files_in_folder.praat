# This script calculates the total duration of all audio files (.wav/.flac) 
# in the selected folder.
#
# This script is distributed under the GNU General Public Licence.
# 2.7.2020 Mietta Lennes

input_path$ = chooseDirectory$: "Select the top directory of the corpus"
input_path$ = input_path$ + "/"

total_duration = 0
count = 0
	
numberOfSoundfiles = 0
	numberOfSoundfileExtensions = 2
	soundfile_extension_1$ = ".wav"
	soundfile_extension_2$ = ".flac"

echo Looking for files under 'input_path$' ...

if fileReadable (input_path$)
	Create Strings as file list: "files", input_path$
	numberOfFiles = Get number of strings
	for file to numberOfFiles
		select Strings files
		file$ = Get string... file
		for fileExtension from 1 to numberOfSoundfileExtensions
			extension$ = soundfile_extension_'fileExtension'$
			if right$ (file$, length(extension$)) = extension$
				numberOfSoundfiles = numberOfSoundfiles + 1
				soundfile$ = input_path$ + "/" + file$
				if fileReadable (soundfile$)
					Read from file: soundfile$
					duration = Get total duration
					Remove
					total_duration = total_duration + duration
					count = count + 1
				else
					printline "UNREADABLE: 'soundfile$'"
				endif
			endif
		endfor
	endfor	
else
	printline Path 'input_path$' is unreadable.
endif

select Strings files
Remove

duration_in_minutes = 'total_duration' / 60
avg_duration = total_duration / numberOfSoundfiles

printline 'numberOfSoundfiles' sound files found.
printline Total duration of the files: 'total_duration' seconds ('duration_in_minutes' minutes)
printline Average duration: 'avg_duration' seconds
