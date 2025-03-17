.data
ARRAY:
.word 2, 1, 6, 5, 4, 3

TEMP:
.word 0, 0, 0, 0, 0, 0

LUT://predefined indices for 6 values in a predefined array
.byte 0, 4, 8, 12, 16, 20, 24

decoder_hex:
.byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71

.text
.global _start
_start:
LDR R0, =LUT
LDR R1, =ARRAY
LDR R2, =TEMP
MOV R3, #0//L
MOV R4, #5//R
BL MERGESORT
END:
B END

//R3 = L, R4 = R, R5 = m
MERGESORT:
PUSH {R3, R4, R5, R6, LR}
CMP R3, R4
BLT BODY
POP {R3, R4, R5, R6, LR}
BX LR
BODY:
ADD R5, R3, R4//m = (L + R) /2
LSR R5, #1//R5 = (R3 + R4) / 2

//R6 is a temp register used for swaping R4(R) and R5(m)
MOV R6, R5
MOV R5, R4//R5 = previous R value which after first pass will be previous m value
MOV R4, R6//R4 = new m value for comparison

BL MERGESORT

ADD R4, #1// m + 1

//Now need m + 1 to be in place of L
//So swap R4(m+1) with R3(L)
MOV R6, R4
MOV R4, R3
MOV R3, R6
//Now R4 = L and R3 = m + 1
//Next we need R5 to swap with R4
//because R5 = R and R4 = L
//R4 is used in the comparison (L < R)
MOV R6, R5
MOV R5, R4
MOV R4, R6
//Now R5 = L and R4 = R
//Now we are ready to call merger sort on right subarry

BL MERGESORT
SUB R3, #1
//Now call merge
BL MERGE
POP {R3, R4, R5, R6, LR}
BX LR

MERGE:
PUSH {R4, R5, R6, R7, R8, R9, R10, R11, LR}
MOV R6, R5 // R6 = i
MOV R7, R5 // R7 = k
MOV R8, R3 // R8 = j
ADD R8, #1

WHILE1:
CMP R6, R3
CMPLE R8, R4
BGT WHILE2

LDRB R9, [R0, R6]
LDR R9, [R1, R9] // R9 = ARRAY[i]
LDRB R10, [R0, R8]
LDR R10, [R1, R10] // R10 = ARRAY[j]

CMP R9, R10
BGE ELSE1
LDRB R11, [R0, R7]
STR R9, [R2, R11] // TEMP[k] = ARRAY[i]
ADD R6, #1 // i++
ADD R7, #1 // k++
B WHILE1
ELSE1:
LDRB R11, [R0, R7]
STR R10, [R2, R11] // TEMP[k] = ARRAY[j]
ADD R8, #1 // j++
ADD R7, #1 // k++
B WHILE1

WHILE2:
CMP R6, R3
BGT WHILE3
LDRB R9, [R0, R6]
LDR R9, [R1, R9]
LDRB R11, [R0, R7]
STR R9, [R2, R11] // TEMP[k] = ARRAY[i]
ADD R6, #1 // i++
ADD R7, #1 // k++
B WHILE2

WHILE3:
CMP R8, R4
BGT FOR_LOOP
LDRB R10, [R0, R8]
LDR R10, [R1, R10]
LDRB R11, [R0, R7]
STR R10, [R2, R11] // TEMP[k] = ARRAY[j]
ADD R8, #1 // j++
ADD R7, #1 // k++
B WHILE3

FOR_LOOP:

BL DISPLAY
BL DELAY
BL DELAY
BL DELAY
BL DELAY

CMP R5, R7
BGE EXIT
LDRB R11, [R0, R5]
LDR R9, [R2, R11] // TEMP[i]
STR R9, [R1, R11] // ARRAY[i] = TEMP[i]
ADD R5, #1

B FOR_LOOP

EXIT:
POP {R4, R5, R6, R7, R8, R9, R10, R11, LR}
BX LR



DISPLAY:
PUSH {R0,R1,R2,R3,R4,R5,R6,R7, LR}
LDR R0, =ARRAY
MOV R7, #0
LDR R1, [R0]
ORR R7, R1
LDR R1, [R0, #4]
LSL R1, #4
ORR R7, R1
LDR R1, [R0, #8]
LSL R1, #8
ORR R7, R1
LDR R1, [R0, #12]
LSL R1, #12
ORR R7, R1
LDR R1, [R0, #16]
LSL R1, #16
ORR R7, R1
LDR R1, [R0, #20]
LSL R1, #20

ORR R7, R1
B disp
disp:
LDR R0, =decoder_hex // Data Array
LDR r1, =0x0 // Register with hex disp all Zeros
LDR R2, =0xF // 1's in first 4 places 0x000..001111
MOV R3, #8 //
MOV R6, #4
AND R5, R2, R7
ADD R5, R0 // R5 now points to the array value needed
LDRB R5, [R5] // R5 now holds the encoded data for least significant value
ORR r1, R5 // Enter R5 into display holder
B first_shifter
first_shifter:
LDR R4, =0xff200020 // Address of Hex displays 0,1,2,3
LSL R2, #4 // Shift masking bit 0xf -> 0xf0
AND R5, R2, R7 // We get the next 4 bits of R7
LSR R5, R6 // Shift back to be first number
ADD R5, R0 // R5 now points to the array value needed
LDRB R5, [R5] // R5 holds byte for second nibble
LSL R5, R3 // Shift left to be in right place for OR

ADD R6, #4
ADD R3, #8
ORR r1, R5
CMP R3, #32
BNE first_shifter // Stop after 4 HEX enabled or shifting is 0x20
STR r1, [r4] // Display the accumulated value from R1
B second_shifter
second_shifter:
LDR R4, =0xff200030 // Address of Hex displays 4,5
LDR r1, =0x0 // Reset display holder
LSL R2, #4
AND R5, R2, R7
LSR R5, #16 // 0xf0000 -> 0x0000f
ADD R5, R0
LDRB R5, [R5]
ORR r1, R5
LSL R2, #4
AND R5, R2, R7
LSR R5, #20 // 0xf00000 -> 0x00000f
ADD R5, R0
LDRB R5, [R5]
LSL R5, #8
ORR r1, R5

STR r1, [R4]
POP {R0,R1,R2,R3,R4,R5,R6,R7,LR}
BX LR
DELAY:
PUSH {R0}
LDR R0, =0x4ffff
LOOP22:
SUBS R0, #1//Decrementing counter by #1 and updating the condition flags
BNE LOOP22//Repeating the loop if Z != 0
POP {R0}
BX LR