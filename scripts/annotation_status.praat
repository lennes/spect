# This script runs through all TextGrid files in a corpus, checks which tiers
# have been annotated and counts the number of annotated intervals in each tier.
#
# This script is distributed under GNU General Public License.
# Mietta Lennes 1.6.2010
# Updated 28.9.2011 (ML)
# 2019-09-23: Tested and updated for Praat v6.1.03 (ML)

# Define a path to your corpus (where your sounds and TextGrids are):
input_path$ = "/Users/lennes/Demo/corpus/"

# Initial annotation tier column names for the table
numberOfTierNames = 4
tier1$ = "utterance"
tier2$ = "word"
tier3$ = "syllable"
tier4$ = "phone"
titleline$ = "File"

# Run the procedures that get a list of all the files in your corpus
call ListFilesInCorpus


# First, run through all files to collect all the different tier names:
for gridfile from 1 to numberOfGridfiles

	gridfile$ = gridfile_'gridfile'$
	Read from file... 'gridfile$'
	gridname$ = selected$("TextGrid")

	numberOfTiers = Get number of tiers
	
	for tier to numberOfTiers
		tier$ = Get tier name... tier

		# Check if a tier column already exists by this name:
		name_exists = 0
		tiername_number = 0
		for tiername to numberOfTierNames
			if tier'tiername'$ = tier$
				name_exists = 1
				tiername_number = tiername
				tiername = numberOfTierNames
			endif
		endfor
		# If this was a new tier label, add it as a column to the table:
		if tiername_number = 0
			numberOfTierNames = numberOfTierNames + 1
			tier'numberOfTierNames'$ = tier$
			printline Found a new tier label: 'tier$'
			tiername_number = numberOfTierNames
		endif

	endfor
	# Remove the TextGrid object
	Remove

endfor

for tiername to numberOfTierNames
	column_text'tiername'$ = ""
	titleline$ = titleline$ + "	" + tier'tiername'$
endfor
titleline$ = titleline$ + newline$
filedelete 'input_path$'annotation_status.txt
fileappend 'input_path$'annotation_status.txt 'titleline$'


# Make another run through all files to count intervals and points in each tier:

for gridfile from 1 to numberOfGridfiles

	gridfile$ = gridfile_'gridfile'$
	Read from file... 'gridfile$'
	gridname$ = selected$("TextGrid")

	for tiername to numberOfTierNames
		column_text'tiername'$ = ""
	endfor
	
	numberOfTiers = Get number of tiers
	
	for tier to numberOfTiers
		tier$ = Get tier name... tier

		# Check if a tier column already exists by this name:
		name_exists = 0
		tiername_number = 0
		for tiername to numberOfTierNames
			if tier'tiername'$ = tier$
				name_exists = 1
				tiername_number = tiername
				tiername = numberOfTierNames
			endif
		endfor

		# Is the current tier an interval tier or a point tier?
		interval_tier = Is interval tier... tier
		if interval_tier = 1
			# In case this is an interval tier, check how many intervals there are and how many have been labeled:
			numberOfIntervals = Get number of intervals... tier
			labeled_intervals = 0
			for interval to numberOfIntervals
				label$ = Get label of interval... tier interval
				if label$ <> "" and label$ <> "xxx"
					labeled_intervals = labeled_intervals + 1
				endif
			endfor
			column_text'tiername_number'$ = "'labeled_intervals' ('numberOfIntervals')"
		else
			# In case this is a point tier, check how many points there are and how many have been labeled:
			numberOfPoints = Get number of points... tier
			labeled_points = 0
			for point to numberOfPoints
				label$ = Get label of point... tier point
				if label$ <> "" and label$ <> "xxx"
					labeled_points = labeled_points + 1
				endif
			endfor
			column_text'tiername_number'$ = "'numberOfPoints' ('labeled_points')"
		endif
		# In case the tier only contains one single interval or point, record the label in this interval/point:
		if column_text'tiername_number'$ = "1 (1)"
			if interval_tier = 1
				column_text'tiername_number'$ = Get label of interval... tier 1
			else
				column_text'tiername_number'$ = Get label of point... tier 1
			endif
		endif
	endfor
	# Remove the TextGrid object
	Remove

	line$ = gridname$
	for tiername to numberOfTierNames
		line$ = line$ + "	" + column_text'tiername'$
	endfor
	printline 'line$'
	line$ = line$ + newline$
	fileappend 'input_path$'annotation_status.txt 'line$'

	# Wipe this file from the list of sound files:
	for soundfile to numberOfSoundfiles
		soundfile$ = soundfile_'soundfile'$
		if index(soundfile$,"'gridname$'.") > 0
			soundfile_'soundfile'$ = ""
		endif
	endfor

endfor

# Add the sound files that do not have any annotations yet:
for soundfile to numberOfSoundfiles
	if soundfile_'soundfile'$ <> ""
		soundfile$ = soundfile_'soundfile'$
		Open long sound file... 'soundfile$'
		soundname$ = selected$("LongSound")
		Remove
		printline - 'soundname$' has not been annotated yet
		line$ = soundname$ 
		for tiername to numberOfTierNames
			column_text'tiername'$ = ""
			titleline$ = titleline$ + "	" + tier'tiername'$
		endfor
		fileappend 'input_path$'annotation_status.txt 'line$''newline$'
	endif
endfor



#------------- THE FOLLOWING PROCEDURES MAKE A LIST OF ALL THE FILES IN YOUR CORPUS.
#
# This procedure checks all subdirectories under 'input_path$' (defined at the beginning of the script)
# and collects a complete list of sound (.wav/.aif) and TextGrid (.TextGrid) files.

procedure ListFilesInCorpus

numberOfSoundfiles = 0
numberOfGridfiles = 0
	numberOfSoundfileExtensions = 2
	soundfile_extension_1$ = ".wav"
	soundfile_extension_2$ = ".aif"
	numberOfTextGridExtensions = 1
	gridfile_extension_1$ = ".TextGrid"

echo Looking for files under 'input_path$'...

if fileReadable (input_path$) and right$ (input_path$, 1) <> "/"
	# Get a text file that contains a number of paths to corpus files:
	Read Strings from raw text file... 'input_path$'
	Rename... input_path
	numberOfPaths = Get number of strings
	for path to numberOfPaths
		select Strings input_path
		input_path2$ = Get string... path
		if right$ (input_path2$, 1) <> "/"
			printline Path 'input_path2$' is readable.
			for ext to numberOfSoundfileExtensions
				extension$ = soundfile_extension_'ext'$
				Create Strings as file list... tempfilelist 'input_path2$'/*'extension$'
				numberOfFiles = Get number of strings
				for file to numberOfFiles
					file$ = Get string... file
					numberOfSoundfiles = numberOfSoundfiles + 1
					soundfile_'numberOfSoundfiles'$ = input_path2$ + "/" + file$		
				endfor
				Remove
			endfor
			for ext to numberOfTextGridExtensions
				extension$ = gridfile_extension_'ext'$
				Create Strings as file list... tempfilelist 'input_path2$'/*'extension$'
				numberOfFiles = Get number of strings
				for file to numberOfFiles
					file$ = Get string... file
					numberOfGridfiles = numberOfGridfiles + 1
					gridfile_'numberOfGridfiles'$ = input_path2$ + "/" + file$		
				endfor
				Remove
			endfor
		else
			call CollectFiles 'input_path2$'
		endif
	endfor
	select Strings input_path
	Remove
else
	call CollectFiles 'input_path$'
endif

printline 'numberOfGridfiles' TextGrid files and 'numberOfSoundfiles' sound files found.

endproc


#---------
procedure CollectFiles inputdir$
	
		if right$ (inputdir$, 1) = "/"
			inputdir$ = left$(inputdir$, length(inputdir$)-1)
		endif

		numberOfDirs = 1
		dir_1$ = inputdir$

		# Check if the input directory contains subdirectories:
		dir$ = inputdir$
		dir_index = numberOfDirs
		Create Strings as directory list... subdirs_'dir_index' 'dir$'
		Sort
		numberOfSubdirs = Get number of strings

		repeat
			more_subdirs_exist = 0
			for subdir to numberOfSubdirs
				dir$ = Get string... subdir
				if dir$ <> "." and dir$ <> ".."
					#pause 'dir$'
					numberOfDirs = numberOfDirs + 1
					dir$ = dir_'dir_index'$ + "/" + dir$
					dir_'numberOfDirs'$ = dir$
				endif
			endfor
			Remove
			dir_index = dir_index + 1
			if numberOfDirs >= dir_index
				dir$ = dir_'dir_index'$
				Create Strings as directory list... subdirs_'dir_index' 'dir$'
				numberOfSubdirs = Get number of strings
				more_subdirs_exist = 1
			else
				numberOfSubdirs = 0
			endif
		until dir_index >= numberOfDirs and numberOfSubdirs = 0
		if more_subdirs_exist = 1
			select Strings subdirs_'dir_index'
			Remove
		endif
		printline   Found 'numberOfDirs' directories in total.

	# First, get files from the current input directory level, then from all 
	# subdirectories that were collected above:

	for dir to numberOfDirs	
	
		subdir_path$ = dir_'dir'$
		
		# Save lists of Sound and TextGrid files into arrays:
		
		for ext to numberOfSoundfileExtensions
			extension$ = soundfile_extension_'ext'$
			Create Strings as file list... tempfilelist 'subdir_path$'/*'extension$'
			Sort
			numberOfFiles = Get number of strings
			for file to numberOfFiles
				file$ = Get string... file
				numberOfSoundfiles = numberOfSoundfiles + 1
				soundfile_'numberOfSoundfiles'$ = subdir_path$ + "/" + file$		
			endfor
			Remove
		endfor
		
		for ext to numberOfTextGridExtensions
			extension$ = gridfile_extension_'ext'$
			Create Strings as file list... tempfilelist 'subdir_path$'/*'extension$'
			Sort
			numberOfFiles = Get number of strings
			for file to numberOfFiles
				file$ = Get string... file
				numberOfGridfiles = numberOfGridfiles + 1
				gridfile_'numberOfGridfiles'$ = subdir_path$ + "/" + file$		
			endfor
			Remove
		endfor

	endfor

endproc
