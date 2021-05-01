-- median.hs
-- Cody Abad
-- CS 331 Spring 2021
-- Program that calculates the median of given integers

-- This program will crash if anything besides an integer is entered when
-- it says "Enter a number"

module Main where

import Data.List (sort)

getInput list = do
    putStr "Enter number (blank line to end): "
    num <- getLine
    putStr "\n"
    if num == ""
      then return list
      else getInput ((read num::Integer):list)

median list
    | (length list) `mod` 2 == 0 = ((sort list) !! (((length list) - 1) `div` 2))
    | otherwise = ((sort list) !! ((length list) `div` 2))

main = do
    putStrLn "Enter a list of integers, one on each line."
    putStrLn "I will compute the median of the list."
    a <- getInput []
    if a == []
        then do putStrLn "Empty list - no median"
        else putStrLn (show a) >> putStr "Median is " >> putStrLn (show (median a))
    putStrLn "Press y to continue, or anything else to quit"
    b <- getLine
    if b == "y"
        then do main
        else return ()