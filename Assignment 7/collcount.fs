\ collcount.fs
\ Cody Abad
\ CS 331
\ Assignment 7 Exercise 2
\
\ contains word collcount which counts
\ the numbers in a collatz sequence


: collatz { n -- c }
  n 1 =
  if
    n
  else
    n 2 mod 1 =
    if
      n 3 * 1 +
      swap 1 + swap \ increase counter
      recurse
    else
      n 2 /
      swap 1 + swap \ increase counter
      recurse
    endif
  endif
;

: collcount
  0 swap \ counter for how many numbers in the sequence
  collatz
  drop
;