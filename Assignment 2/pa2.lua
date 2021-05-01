--pa2.lua
--Cody Abad
--CS 331 Spring 2020
--Assignment 1

local pa2 = {}

--function filterArray
--Takes a function and a table, and returns a table that only
--contains values that return true when passed to the given function.
function pa2.filterArray(p,t)
  local temp = {} 
  local count = 1
  for i,v in ipairs(t) do
    if p(v) == true then
      temp[count] = v
      count = count + 1
    end
  end
  return temp
end

--function concatMax
--takes a string and a number, and returns a string that is a 
--concatination 
function pa2.concatMax(s,n)
  local temp = ""
  local count = n/(string.len(s))
  for i = 1,count do
    temp = temp .. s
  end
  return temp
end


--function collatz
--takes a number and returns a collatz sequence
function pa2.collatz(k)
  
  local num = k
  
  local function iter(dummy1, dummy2)
    
    if (num == 0) then
      return nil
    end
    if(num == 1) then
      num = num - 1
      return 1
    end
    
    local save_num = num
    if (num % 2 == 0) then
      num = num/2
    elseif (num % 2 == 1) then
      num = num * 3 + 1
    end
    return save_num
  end
  return iter, nil, nil
end

--coroutine substrings
--yields every possible substring of a given string
function pa2.substrings(s)
  local start,finish,gap = 0,0,1
  coroutine.yield("")
  while(gap <= string.len(s)) do
    start = 1
    finish = gap
    while(finish <= string.len(s)) do
      coroutine.yield(string.sub(s,start,finish))
      start = start + 1
      finish = finish + 1
    end
    gap = gap + 1
  end
end

return pa2