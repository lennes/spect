# This script calculates the Edit Distance between two strings using
# a dynamic programming algorithm.
#
# The Edit Distance of two strings is defined as the minimum number of point mutations
# required to change string 1 into string 2. 
# A point mutation can be either a substitution of a character, an insertion of a character, 
# or a deletion of a character.
#
# The resulting edit distance is stored in the local variable val.
# 
# This script is distributed under the GNU General Public License.
# 25.11.2005 Mietta Lennes

form Calculate Edit Distance between two strings
	comment Give a string:
	text string1 miekka
	comment Give another string:
	text string2 merkki
endform

xdim = length(string1$)
ydim = length(string2$)

Create simple Matrix... strings ydim xdim 0

# Set up character arrays ("labels" for the matrix dimensions):

tmpstring1$ = string1$
x = 0
while tmpstring1$ <> ""
	tmp1$ = left$ (tmpstring1$, 1)
	x = x + 1
	x'x'$ = tmp1$
	tmpstring1$ = right$ (tmpstring1$, (length(tmpstring1$) - 1))
endwhile

tmpstring2$ = string2$
y = 0
while tmpstring2$ <> ""
	tmp2$ = left$ (tmpstring2$, 1)
	y = y + 1
	y'y'$ = tmp2$
	tmpstring2$ = right$ (tmpstring2$, (length(tmpstring2$) - 1))
endwhile

# Calculate distances char by char, row by row:
for y from 1 to ydim

	for x from 1 to xdim
		prevrow = y - 1
		prevcol = x - 1
		
		prevrowcolvalue = 0
		if prevrow > 0 and prevcol > 0
			prevrowcolvalue =  Get value at xy... prevcol prevrow
		endif
		
		sym1$ = x'x'$
		sym2$ = y'y'$
		if sym1$ <> sym2$
			prevrowcolvalue = prevrowcolvalue + 1
		endif

		prevcolvalue = 0
		if prevcol > 0
			prevcolvalue = Get value at xy... prevcol y
		endif
		prevcolvalue = prevcolvalue + 1
		
		prevrowvalue = 0
		if prevrow > 0
			prevrowvalue = Get value at xy... x prevrow
		endif
		prevrowvalue = prevrowvalue + 1
		
		if prevrowcolvalue < prevcolvalue
			val = prevrowcolvalue
		else
			val = prevcolvalue
		endif
		if prevrowvalue < val
			val = prevrowvalue
		endif
		
		Set value... y x val

	endfor
	
endfor

echo 'val'
