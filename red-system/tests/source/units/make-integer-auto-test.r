REBOL [
  Title:   "Generates Red/System integer! tests"
	Author:  "Peter W A Wood"
	File: 	 %make-integer-auto-test.r
	Version: 0.2.0
	Tabs:	 4
	Rights:  "Copyright (C) 2011-2012 Peter W A Wood. All rights reserved."
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"
]

;; initialisations 
tests: copy ""                          ;; string to hold generated tests
test-number: 0                          ;; number of the generated test
make-dir %auto-tests/
file-out: %auto-tests/integer-auto-test.reds

;; create a block of values to be used in the binary ops tests
test-values: [
            0                   ; zero
  -2147483648                   ; min
   2147483647                   ; max
                                ;; DO NOT USE -1 as it crashes REBOL !!!!
            3
           -7
            5
       123456
        28230
        -6681
        44095
        65536
]


;; create blocks of operators to be applied
test-binary-ops: [
  +
  -
  *
  /
  //
  or
  xor
  and
]

test-no-zeroes: [         ;; zero not allowed as operand2
  / 
  //
]

test-comparison-ops: [
  =
  <>
  <
  >
  >=
  <=
]

test-comparison-values: [
  -1
  0
  +1
]

;; create test file with header
append tests "Red/System [^(0A)"
append tests {  Title:   "Red/System auto-generated integer! tests"^(0A)}
append tests {	Author:  "Peter W A Wood"^(0A)}
append tests {  File: 	 %integer-auto-test.reds^(0A)}
append tests {  License: "BSD-3 - https://github.com/dockimbel/Red/blob/origin/BSD-3-License.txt"^(0A)}
append tests "]^(0A)^(0A)"
append tests "^(0A)^(0A)comment {"
append tests "  This file is generated by make-integer-auto-test.r^(0A)"
append tests "  Do not edit this file directly.^(0A)"
append tests "}^(0A)^(0A)"
append tests join ";make-length:" 
                  [length? read %make-integer-auto-test.r "^(0A)^(0A)"]
append tests "#include %../../../../../quick-test/quick-test.reds^(0A)^(0A)"
append tests {~~~start-file~~~ "Auto-generated tests for integers"^(0A)^(0A)}
append tests {===start-group=== "Auto-generated tests for integers"^(0A)^(0A)}

write file-out tests
tests: copy ""

;; binary operator tests - in global context
foreach op test-binary-ops [
  foreach operand1 test-values [
    foreach operand2 test-values [
      ;; only write a test if REBOL produces a result
      if attempt [expected: do reduce [operand1 op operand2]][
        
        ;; don't write tests for certain ops with zero second operand
        if not all [
          operand2 = 0
          find test-no-zeroes op 
        ][
          expected: to-integer expected
          
          ;; convert REBOL's // operator to Red/System's % operator
          nop: either op = first [//][#"%"][op]
          
          ;; test with literal values
          test-number: test-number + 1
          append tests join {  --test-- "integer-auto-} [test-number {"^(0A)}]
          append tests "  --assert "
          append tests reform [expected " = (" operand1 nop operand2 ")^(0A)"]
          
          ;; test with variables
          test-number: test-number + 1
          append tests join {  --test-- "integer-auto-} [test-number {"^(0A)}]
          append tests join "      i: " [operand1 "^(0A)"]
          append tests join "      j: " [operand2 "^(0A)"]
          append tests rejoin ["      k:  i " nop " j^(0A)"]
          append tests "  --assert "
          append tests reform [expected " = k ^(0A)"]
          
          ;; write tests to file
          write/append file-out tests
          tests: copy ""
        ]
      ]
      recycle
    ]
  ]
]

;; binary operator tests - inside a function

;; write function spec
append tests "  integer-auto-test-func: func [^(0A)"
;append tests "    return: [integer!]^(0A)"
append tests "      /local^(0A)"
append tests "      i [integer!]^(0A)"
append tests "      j [integer!]^(0A)"
append tests "      k [integer!]^(0A)"
append tests "    ][^(0A)"
write/append file-out tests
tests: copy ""

foreach op test-binary-ops [
  foreach operand1 test-values [
    foreach operand2 test-values [
      ;; only write a test if REBOL produces a result
      if attempt [expected: do reduce [operand1 op operand2]][
        
        ;; don't write tests for certain ops with zero second operand
        if not all [
          operand2 = 0
          find test-no-zeroes op 
        ][
          expected: to-integer expected
          
          ;; convert REBOL's // operator to Red/System's % operator
          nop: either op = first [//][#"%"][op]
         
          ;; test with variables inside the function
          test-number: test-number + 1
          append tests join {    --test-- "integer-auto-} [test-number {"^(0A)}]
          append tests join "      i: " [operand1 "^(0A)"]
          append tests join "      j: " [operand2 "^(0A)"]
          append tests rejoin ["      k:  i " nop " j^(0A)"]
          append tests "    --assert "
          append tests reform [expected " = k ^(0A)"]
          
          
          ;; write tests to file
          write/append file-out tests
          tests: copy ""
        ]
      ]
      recycle
    ]
  ]
]

;; write closing bracket and function call
append tests "  ]^(0a)"
append tests "integer-auto-test-func^(0a)"
write/append file-out tests
tests: copy ""


;; comparison tests
foreach op test-comparison-ops [
  foreach operand1 test-values [
    foreach operand2 test-comparison-values [
      ;; only write a test if REBOL produces a result
      if all [
        attempt [operand2: operand1 + operand2]
        none <> attempt [expected: do reduce [operand1 op operand2]]
      ][
        test-number: test-number + 1
        append tests join {  --test-- "integer-auto-} [test-number {"^(0A)}]
        append tests "  --assert "
        append tests reform [expected " = (" operand1 op operand2 ")^(0A)"]

        ;; write tests to file
        write/append file-out tests
        tests: copy ""
      ]
    ]
  ]
]


;; write file epilog
append tests "^(0A)===end-group===^(0A)^(0A)"
append tests {~~~end-file~~~^(0A)^(0A)}

write/append file-out tests
      
print ["Number of assertions generated" test-number]






