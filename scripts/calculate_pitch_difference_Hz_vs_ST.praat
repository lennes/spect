form: "Calculate the differences of frequency pairs"
	positive: "Frequency 1 (Hz)", "1000"
	positive: "Frequency 2 (Hz)", "1050"
endform

var1 = hertzToSemitones: frequency_1
var2 = hertzToSemitones: frequency_2 
diffHz = abs(frequency_2 - frequency_1)
diffST = abs(var2 - var1)
appendInfoLine: "Frequencies in Hz (1 | 2), difference (Hz), pitch in ST (1 | 2), diff (ST)"
appendInfoLine: "'frequency_1'	'frequency_2'	'diffHz'		'var1'	'var2' 'diffST'"
