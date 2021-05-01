-- PA5.hs 
-- Cody Abad, skeleton from Glenn G. Chappell
-- 2021-03-16
--
-- For CS F331 / CSCE A331 Spring 2021
-- Solutions to Assignment 5 Exercise B

module PA5 where

-- collatzCounts
collatzCounts :: [Integer]
collatzCounts = map collatz[1 ..]
  where
    collatz n
      | n == 0          = 0
      | n == 1          = 0
      | n `mod` 2 == 1  = 1 + collatz (3 * n + 1)
      | n `mod` 2 == 0  = 1 + collatz (n `div` 2)

-- findList
findList :: Eq a => [a] -> [a] -> Maybe Int
findList a b
  | length a == 0              = Just 0
  | fst (inList a b 0) == True = Just (snd (inList a b 0))
  | otherwise                  = Nothing
  where
    inList a b index
      | a == take (length a) b = (True, index)
      | b == []                = (False, index)
      | otherwise              = inList (a) (drop 1 b) (index + 1)

-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
a ## b = checkElements (zip a b) 0
  where
    checkElements pairs count
      | pairs == []                          = count
      | fst (pairs !! 0) == snd (pairs !! 0) = checkElements (drop 1 pairs) (count + 1)
      | otherwise                            = checkElements (drop 1 pairs) (count)



-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB f a b
  | length a == 0      = []
  | length b == 0      = []
  | f (a !! 0) == True = (b !! 0):(filterAB f (drop 1 a) (drop 1 b))
  | otherwise          = filterAB f (drop 1 a) (drop 1 b)

-- sumEvenOdd
sumEvenOdd :: Num a => [a] -> (a, a)
sumEvenOdd list = foldr (\a b ->(fst a+fst b,snd a +snd b)) (0,0) (splitList list)
  where 
    splitList list
      | length list == 0 = []
      | length list == 1 = [(head list,0)]
      | otherwise        = (list !! 0,list !! 1) : splitList (drop 2 list)