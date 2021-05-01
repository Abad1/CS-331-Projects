;addpairs.scm
;Cody Abad
;CS 331
;Assignment 7 Exercise 3
;
;Contains procedure "addpairs" which makes a list
;of the sum of every 2 arguments it's given.
;
;If there is an odd number of arguments, the last
;argument will be at the end of the list unchanged.

#lang scheme


(define (addpairs . xs)
  (if (null? xs)
      (list)
      (if (= (length xs) 1)
          (list (car xs))
          (cons (+ (car xs) (car (cdr xs))) (apply addpairs (cdr (cdr xs))))
       )
   )
)
