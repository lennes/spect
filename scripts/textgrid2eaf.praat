# This script will convert the selected TextGrid object into a simple EAF file, 
# readable by ELAN.
#
# RESTRICTIONS: 
# - Only time-aligned annotations in ELAN are supported (tier hierarchies 
#   cannot be created). 
# - Only IntervalTiers are supported in the original TextGrid object, for now.
# - This script expects the tier names in the TextGrid to begin with the participant 
#   (speaker) code, which is optionally followed by speaker_code_separator$ 
#   (the default is dash, -) and a string that refers to the "linguistic type" of the
#   tier. The tier type will be represented in the EAF file.
# 
# TIP: 
# This script can be called from the command line, e.g., on Linux:
# /usr/bin/praat --run textgrid2eaf.praat textgrids/conversation_D37.TextGrid
#
# TODO, in the near future:
# Separate the input parameters for defining tier type into a parameter file to be read
# at runtime. (The defaults might be the ones given in this script.)
#
# This script is distributed under the GNU General Public License.
# Mietta Lennes 10.9.2018


####################
#
# INITIAL SETTINGS - Please modify as required:
#
# Default directory for the EAF files (default = the same directory where 
# this Praat script is located).
# If you want the EAF files to be saved in a subdirectory instead, please create the 
# directory and edit the previous line accordingly, e.g.:
# eaf_dir$ = "EAF/"
#
eaf_dir$ = ""

#
# Set this to 1, if you want to manually indicate which participants are "interviewers"
# in each file:
indicate_interviewers_manually = 0
#
# If the aforementioned variable is set to '1', the user will be asked to determine 
# the role for each speaker, i.e., whether the speaker is an 'interviewer' (vs. 
# a regular speaker).
# For 'interviewers', the linguistic type in ELAN will be the regular type 
# supplemented with the string ", interviewer".
# Moreover, the participant metadata string will be preceded with the text "interviewer ".

# Set the following variable to 1, if you want to remove all tiers that are labeled 
# nothing but "original" in the TextGrid file. 
# Note that the existing TextGrid file will be replaced with the new, smaller one!
# (This feature can be useful, in case you used the semi-automatic alignment script which
# created the "original" tier and the tier is no longer needed.)
remove_original_tier = 1

# Add links to WAV, M4A and/or MP4 media files by the same name as the TextGrid file, 
# with the corresponding extension (default = add link to WAV file only)?
include_wav = 1
include_m4a = 0
include_mp4 = 0

# Speaker code separator (the string at the beginning of each tier name in the TextGrid)
# (this will be the first dash "-" that occurs in the string)
speaker_code_separator$ = "-"

# Define linguistic types that may be used for the tiers in this annotation file.
# (NB: Not all of these types need to actually occur in this file, but you might
# wish to have a common system of tier types for an entire corpus.)
numberOfTypes = 6
default_type = 1
type_1$ = "utterance"
type_2$ = "normalized utterance"
type_3$ = "word"
type_4$ = "normalized word"
type_5$ = "phone"
type_6$ = "comment"

# The string at the end of the tier in the TextGrid, on the basis of which the linguistic 
# type will be mapped (the strings must match the linguistic types as defined above):
type_1_string$ = "utterance"
type_2_string$ = "utterance-norm"
type_3_string$ = "word"
type_4_string$ = "word-norm"
type_5_string$ = "phone"
type_6_string$ = "comment"

# The author string to be inserted in the metadata of each EAF file:
author$ = "Praat script textgrid2eaf.praat"

# The annotator string to be inserted in the metadata of each annotation tier 
# in the EAF file:
annotator$ = ""


##
#####################

form Convert a TextGrid file to an EAF annotation file
	comment Please select the TextGrid file to be converted:
	sentence TextGrid_file F1_F2_excerpt.TextGrid
endform

# For GUI use, the preceding form-endform dialog can be replaced with the following 
# command:
#textGrid_file$ = chooseReadFile$: "Please select the TextGrid file to be converted:"


#------------------------------------
# Do not edit the part below (unless you know what you are doing): 

Text writing preferences: "UTF-8"
Text reading preferences: "UTF-8"

Read from file: textGrid_file$
gridname$ = selected$ ("TextGrid")
Convert to Unicode

eaf_file$ = eaf_dir$ + gridname$ + ".eaf"
deleteFile (eaf_file$)

# Media file names (for referencing from within the EAF):
mediafile_wav$ = gridname$ + ".wav"
mediafile_m4a$ = gridname$ + ".m4a"
mediafile_mp4$ = gridname$ + ".mp4"

printline Copying tier contents and metadata from 'gridname$'.TextGrid 
printline   to EAF file: 'eaf_file$'...

numberOfTiers = Get number of tiers
total_duration = Get total duration

Create Table with column names... annotations 1 tier annotation_start_or_end text annotation_id timeslot_id
annotation_id = 0
timeslot_index = 0
annotation_start = 0
participants = 0
participants_1$ = ""

select TextGrid 'gridname$'

if remove_original_tier = 1
	### Check for tiers labeled as "original" and remove them.
	### (These are leftovers from the semi-automatic alignment script.)
	### The TextGrid file will be replaced.
	for tier to numberOfTiers
		tier_label$ = Get tier name... tier
		if tier_label$ = "original"
			Remove tier: tier
			Save as text file: textGrid_file$
			numberOfTiers = numberOfTiers - 1
			tier = tier - 1
		endif
	endfor
endif


# Get the tier names and their number of intervals:
for tier to numberOfTiers
	type_number_'tier' = default_type
	interval_'tier' = 1
	numberOfIntervals_'tier' = Get number of intervals... tier
	tier_name_'tier'$ = Get tier name... tier
	# Check whether there is a participant code in the original tier name:
	rest$ = tier_name_'tier'$
	participant_'tier'$ = ""
	participant_length = index(tier_name_'tier'$,speaker_code_separator$) - 1
	# If a speaker code separator was found, the tier name will be considered as 
	# the speaker/participant code:
	if participant_length > 0
		participant$ = left$(tier_name_'tier'$,participant_length)
		participant_'tier'$ = participant$
		rest_'tier'$ = right$(tier_name_'tier'$, (length(tier_name_'tier'$)- participant_length - 1))
	# If a speaker code separator was not found, the tier name will be considered as 
	# the speaker/participant code and the linguistic type will be set to default:
	else
		rest_'tier'$ = type_'default_type'_string$
		participant_'tier'$ = tier_name_'tier'$
		participant$ = tier_name_'tier'$
		### Special case: tiers with nothing but the label "comment"
		### -> empty participant code, tier type = "comment":
		if participant_'tier'$ = "comment"
			rest_'tier'$ = "comment"
			participant_'tier'$ = ""
		endif
		####
	endif
	# Find out with which linguistic type the latter part of the tier name matches:
	for t from 1 to numberOfTypes
		if type_'t'_string$ = rest_'tier'$
			type_title_'tier'$ = type_'t'$
			type_number_'tier' = t
		endif
	endfor
	if participant$ <> ""
		if participants_1$ = ""
			# If this is the first participant found, add it to position 1 in the participant list.
			participants_1$ = participant$
			participants = 1
		else
			for part to participants
				if participant$ = participants_'part'$
					# This participant was already found in a previous tier.
					part = participants
				elsif part = participants
					# This participant was not found before. Add it to the list and increase counter:
					participants = participants + 1
					participants_'participants'$ = participant$
					part = participants
				endif
			endfor
		endif
	endif
endfor

# (This part is for manually marking the interviewer tiers. It can only be run in GUI!)
if indicate_interviewers_manually = 1
	Edit

	# Ask the user to indicate which of the participants are interviewers:
	printline Number of participants: 'participants'
	for part to participants
		part$ = participants_'part'$
		printline - 'part$'
		isInterviewer_'part' = 0
	endfor
	
	####
	beginPause: "Which of the participants are interviewers?"
	for part to participants
		part$ = participants_'part'$
		boolean: "Speaker_'part' ('part$')", 0
	endfor
	endPause: "Continue", 1
	for part to participants
		isInterviewer_'part' = speaker_'part'
	endfor
	####

	endeditor

	for tier to numberOfTiers
		participant$ = participant_'tier'$
		for part to participants
			# If this participant is an interviewer, get the corresponding linguistic type:
			if participants_'part'$ = participant$ and isInterviewer_'part' = 1
				type_title_'tier'$ = type_title_'tier'$ + ", interviewer"
				participant_'tier'$ = "interviewer " + participant_'tier'$
			endif
		endfor
	endfor

endif
# (After marking the interviewer tiers, the script continues normally.)


# Collect the time stamps of all annotated intervals:
for tier to numberOfTiers
	for interval to numberOfIntervals_'tier'
		label$ = Get label of interval... tier interval
		if label$ <> ""
			if index(label$,"&") > 0
				printline
				printline Warning: interval 'interval' in tier 'tier' contains the & character! 
				printline The original label is:
				printline 'label$'
				printline
				printline   The character will be removed. You may wish to edit the TextGrid at this location
				printline   and re-run the conversion process?
				label$ = left$ (label$, index(label$,"&") - 1) + right$ (label$, (length(label$) - index(label$,"&")))
			endif
			timeslot_index = timeslot_index + 1
			annotation_id = annotation_id + 1
			annotation_id$ = "a'annotation_id'"
			annotation_start = Get starting point... tier interval
			annotation_start = annotation_start * 1000
			annotation_end = Get end point... tier interval
			annotation_end = annotation_end * 1000
			select Table annotations
			if timeslot_index > 1
				Insert row... timeslot_index
			endif
			Set numeric value... timeslot_index tier tier
			Set numeric value... timeslot_index annotation_start_or_end 'annotation_start:0'
			Set string value... timeslot_index text 'label$'
			Set string value... timeslot_index annotation_id 'annotation_id$'
			timeslot_index = timeslot_index + 1
			Insert row... timeslot_index
			Set numeric value... timeslot_index tier tier
			Set numeric value... timeslot_index annotation_start_or_end 'annotation_end:0'
			Set string value... timeslot_index text 'label$'
			Set string value... timeslot_index annotation_id 'annotation_id$'
		endif
		select TextGrid 'gridname$'
	endfor
endfor

select Table annotations
Sort rows... annotation_start_or_end
timeslot_index = 0
numberOfRows = Get number of rows
for row to numberOfRows
	timeslot_index = row
	timeslot_id$ = "ts'row'"
	Set string value... row timeslot_id 'timeslot_id$'
endfor

# Get the date and time in the format required by EAF:
date$ = date$()
# System date format:  Tue Jun 24 13:50:39 2014
# Required format for EAF:  DATE="2014-06-24T13:51:37+02:00"
#printline 'date$'
month$ = mid$(date$,5,3)
if month$ = "Jan"
	month$ = "01"
elsif month$ = "Feb"
	month$ = "02"
elsif month$ = "Mar"
	month$ = "03"
elsif month$ = "Apr"
	month$ = "04"
elsif month$ = "May"
	month$ = "05"
elsif month$ = "Jun"
	month$ = "06"
elsif month$ = "Jul"
	month$ = "07"
elsif month$ = "Aug"
	month$ = "08"
elsif month$ = "Sep"
	month$ = "09"
elsif month$ = "Oct"
	month$ = "10"
elsif month$ = "Nov"
	month$ = "11"
else month$ = "12"
endif
day$ = mid$(date$,9,2)
clock$ = "T" + mid$ (date$,12,8) + "+02:00"
eaf_date$ = right$ (date$,4) + "-" + month$ + "-" + day$ + clock$
#printline 'eaf_date$'

# Write the header part to the EAF file:
fileappend 'eaf_file$' <?xml version="1.0" encoding="UTF-8"?>'newline$'<ANNOTATION_DOCUMENT AUTHOR="'author$'" DATE="'eaf_date$'" FORMAT="2.8" VERSION="2.8" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.mpi.nl/tools/elan/EAFv2.8.xsd">'newline$'    <HEADER MEDIA_FILE="" TIME_UNITS="milliseconds">'newline$'

if include_wav = 1
fileappend 'eaf_file$'         <MEDIA_DESCRIPTOR MEDIA_URL="./'mediafile_wav$'" MIME_TYPE="audio/x-wav" RELATIVE_MEDIA_URL="./'mediafile_wav$'"/>'newline$'
endif

if include_m4a = 1
fileappend 'eaf_file$'         <MEDIA_DESCRIPTOR MEDIA_URL="./'mediafile_m4a$'" MIME_TYPE="unknown" RELATIVE_MEDIA_URL="./'mediafile_m4a$'"/>'newline$'
endif

if include_mp4 = 1
fileappend 'eaf_file$'         <MEDIA_DESCRIPTOR MEDIA_URL="./'mediafile_mp4$'" MIME_TYPE="unknown" RELATIVE_MEDIA_URL="./'mediafile_mp4$'"/>'newline$'
endif

# If the user did not opt for any linked media files, just add the placeholder:
if include_wav = 0 and include_m4a = 0 and include_mp4 = 0
fileappend 'eaf_file$'         <MEDIA_DESCRIPTOR MEDIA_URL="" MIME_TYPE="unknown" RELATIVE_MEDIA_URL=""/>'newline$'
endif

fileappend 'eaf_file$'         <PROPERTY NAME="URN">urn:nl-mpi-tools-elan-eaf:ebed2e4a-eae9-4083-84c9-6425946f862c</PROPERTY>'newline$'        <PROPERTY NAME="lastUsedAnnotationId">'annotation_id$'</PROPERTY>'newline$'    </HEADER>'newline$'

printline    Writing time slots to EAF...

# Write the time slots:
fileappend 'eaf_file$'     <TIME_ORDER>'newline$'
for row to numberOfRows
	tier = Get value... row tier
	timeslot_id$ = Get value... row timeslot_id
	time_value = Get value... row annotation_start_or_end
	fileappend 'eaf_file$'     <TIME_SLOT TIME_SLOT_ID="'timeslot_id$'" TIME_VALUE="'time_value'"/>'newline$'
endfor
fileappend 'eaf_file$'     </TIME_ORDER>'newline$'

printline    Writing tier contents to EAF...
# Figure out the linguistic type for each tier and write the annotations therein:
Sort rows... tier annotation_id annotation_start_or_end
tier = 1
previous_tier = 0
previous_annotation_id$ = ""
participant$ = ""
tier_started = 0
for row to numberOfRows
	tier = Get value... row tier
	tier$ = tier_name_'tier'$
	if tier > previous_tier
		if previous_tier > 0
			# Write the end of the previous tier:
			fileappend 'eaf_file$'     </TIER>'newline$'
			tier_started = 0
		endif
		# Write the preamble for this tier:
		participant$ = participant_'tier'$
		participant$ = " PARTICIPANT=""'participant$'"""
		type$ = type_title_'tier'$
		fileappend 'eaf_file$'     <TIER LINGUISTIC_TYPE_REF="'type$'"'participant$' TIER_ID="'tier$'">'newline$'
		tier_started = 1
		previous_tier = tier		
	endif
	# Write the row as an annotation element, in case the current row and the previous row have the same annotation id:
	annotation_id$ = Get value... row annotation_id
	if previous_annotation_id$ = annotation_id$
		prev_row = row - 1
		start_ref$ = Get value... prev_row timeslot_id
		end_ref$ = Get value... row timeslot_id
		text$ = Get value... row text
		fileappend 'eaf_file$'         <ANNOTATION>'newline$'            <ALIGNABLE_ANNOTATION ANNOTATION_ID="'annotation_id$'" TIME_SLOT_REF1="'start_ref$'" TIME_SLOT_REF2="'end_ref$'">'newline$'                <ANNOTATION_VALUE>'text$'</ANNOTATION_VALUE>'newline$'            </ALIGNABLE_ANNOTATION>'newline$'        </ANNOTATION>'newline$'
	endif
	previous_annotation_id$ = annotation_id$
endfor
if tier_started = 1
	fileappend 'eaf_file$'     </TIER>'newline$'
endif

# Insert the linguistic type descriptions into the EAF file:
for type to numberOfTypes
	line$ = "    <LINGUISTIC_TYPE GRAPHIC_REFERENCES=""false"" LINGUISTIC_TYPE_ID="""
	line$ = line$ + type_'type'$
	line$ = line$ + """ TIME_ALIGNABLE=""true""/>"
	line$ = line$ + newline$
	fileappend 'eaf_file$' 'line$'
endfor

if indicate_interviewers_manually = 1
	for type to numberOfTypes
		line$ = "    <LINGUISTIC_TYPE GRAPHIC_REFERENCES=""false"" LINGUISTIC_TYPE_ID="""
		type$ = type_'type'$ + ", interviewer"
		line$ = line$ + type$
		line$ = line$ + """ TIME_ALIGNABLE=""true""/>"
		line$ = line$ + newline$
		fileappend 'eaf_file$' 'line$'
	endfor
endif

# Insert the final lines into the EAF file:
fileappend 'eaf_file$'     <CONSTRAINT DESCRIPTION="Time subdivision of parent annotation's time interval, no time gaps allowed within this interval" STEREOTYPE="Time_Subdivision"/>'newline$'    <CONSTRAINT DESCRIPTION="Symbolic subdivision of a parent annotation. Annotations refering to the same parent are ordered" STEREOTYPE="Symbolic_Subdivision"/>'newline$'    <CONSTRAINT DESCRIPTION="1-1 association with a parent annotation" STEREOTYPE="Symbolic_Association"/>'newline$'    <CONSTRAINT DESCRIPTION="Time alignable annotations within the parent annotation's time interval, gaps are allowed" STEREOTYPE="Included_In"/>'newline$'</ANNOTATION_DOCUMENT>'newline$'

select Table annotations
Remove

select TextGrid 'gridname$'
Remove

printline ... Done!