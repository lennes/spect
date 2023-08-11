# This Praat script will change the sample rate of all the audio files in the given folder.
# The resampled files will be copied to a subfolder under the existing folder.
# If some of the files already have the target sampling rate, they will be copied as such.
# All resulting files (copied or resampled) will be saved in WAV format (Praat default).
#
# For details regarding the resampling algorithm, see the built-in manual in Praat (Sound: Resample...).
# 
# This script is distributed under the GNU General Public License.
# 10.3.2002 Mietta Lennes
#
# Changes:
# 11.8.2023 Upgraded the script to support different audio file formats and the current Praat script syntax. 
#           The results will now be saved/copied under a new subfolder, without deleting the source files. 

form Change sample rate in sound files
   sentence Sound_file_extension .wav
   sentence Directory /Users/lennes/tmp/
   comment (Empty directory path = the directory where this Praat script is located)
   positive New_sample_rate_(Hz) 22050
   positive Precision_(samples) 50
   boolean Suppress_warnings yes
   comment (This prevents the script from pausing at warnings about clipped samples, for instance.)
endform

Create Strings as file list: "list", "'directory$'*'sound_file_extension$'"
numberOfFiles = Get number of strings
if numberOfFiles = 0
	exitScript: "Nothing to do, no files found in dir:'directory$'"
else
	newfolder$ = "resampled_to_'new_sample_rate'"
	createFolder: "'directory$''newfolder$'"
	writeInfoLine: "Found 'numberOfFiles' files:"
endif
for ifile to numberOfFiles
   selectObject: "Strings list"
   sound$ = Get string: ifile
	Read from file: "'directory$''sound$'"
	name$ = selected$ ("Sound")
	oldrate = Get sample rate
	if oldrate > new_sample_rate
		appendInfoLine: "'ifile'/'numberOfFiles':  Downsampling file 'name$' from 'oldrate' Hz (saving as WAV)"
		Resample: new_sample_rate, precision
		if suppress_warnings = 1
			nowarn Save as WAV file: "'directory$''newfolder$'/'name$'.wav"
		else
			Save as WAV file: "'directory$''newfolder$'/'name$'.wav"
		endif
		Remove
		selectObject: "Sound 'name$'"
	elsif oldrate < new_sample_rate
		appendInfoLine: "'ifile'/'numberOfFiles':  Upsampling file 'name$' from 'oldrate' Hz (saving as WAV)"
		Resample: new_sample_rate, precision
		if suppress_warnings = 1
			nowarn Save as WAV file: "'directory$''newfolder$'/'name$'.wav"
		else
			Save as WAV file: "'directory$''newfolder$'/'name$'.wav"
		endif
		Remove
		selectObject: "Sound 'name$'"
	else
		appendInfoLine: "'ifile'/'numberOfFiles':  No need to resample file 'name$' (just copying the original to WAV)"
		Save as WAV file: "'directory$''newfolder$'/'name$'.wav"
	endif
	Remove
	# pauseScript: "Continue?"
endfor

select Strings list
Remove

appendInfoLine: ""
appendInfoLine: "Finished! 'numberOfFiles' files were saved to 'directory$''newfolder$'."
