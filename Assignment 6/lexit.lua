-- lexit.lua
-- VERSION 4
-- Cody Abad
-- Glenn G. Chappell
-- Started: 2021-02-03
-- Updated: 2021-02-16
--
-- For CS F331 / CSCE A331 Spring 2021
-- In-Class Lexer Module

-- History:
-- - v1:
--   - Framework written. Lexer treats every character as punctuation.
-- - v2:
--   - Add state LETTER, with handler. Write skipWhitespace. Add
--     comment on invariants.
-- - v3
--   - Finished (hopefully). Add states DIGIT, DIGDOT, DOT, PLUS, MINUS,
--     STAR. Comment each state-handler function. Check for MAL lexeme.
-- - v4
--   - Converted and renamed to lexit.lua for use with caracal programming
--     language

-- Usage:
--
--    program = "print a+b;"  -- program to lex
--    for lexstr, cat in lexer.lex(program) do
--        -- lexstr is the string form of a lexeme.
--        -- cat is a number representing the lexeme category.
--        --  It can be used as an index for array lexer.catnames.
--    end


-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local lexit = {}  -- Our module; members are added below


-- *********************************************************************
-- Public Constants
-- *********************************************************************


-- Numeric constants representing lexeme categories
lexit.KEY    = 1
lexit.ID     = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP     = 5
lexit.PUNCT  = 6
lexit.MAL    = 7


-- catnames
-- Array of names of lexeme categories.
-- Human-readable strings. Indices are above numeric constants.
lexit.catnames = {
    "Keyword",
    "Identifier",
    "NumericLiteral",
    "StringLiteral",
    "Operator",
    "Punctuation",
    "Malformed"
}


-- *********************************************************************
-- Kind-of-Character Functions
-- *********************************************************************

-- All functions return false when given a string whose length is not
-- exactly 1.


-- isLetter
-- Returns true if string c is a letter character, false otherwise.
local function isLetter(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
        return false
    end
end


-- isDigit
-- Returns true if string c is a digit character, false otherwise.
local function isDigit(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end


-- isWhitespace
-- Returns true if string c is a whitespace character, false otherwise.
local function isWhitespace(c)
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r"
      or c == "\f" then
        return true
    else
        return false
    end
end


-- isPrintableASCII
-- Returns true if string c is a printable ASCII character (codes 32 " "
-- through 126 "~"), false otherwise.
local function isPrintableASCII(c)
    if c:len() ~= 1 then
        return false
    elseif c >= " " and c <= "~" then
        return true
    else
        return false
    end
end


-- isIllegal
-- Returns true if string c is an illegal character, false otherwise.
local function isIllegal(c)
    if c:len() ~= 1 then
        return false
    elseif isWhitespace(c) then
        return false
    elseif isPrintableASCII(c) then
        return false
    else
        return true
    end
end


-- *********************************************************************
-- The Lexer
-- *********************************************************************


-- lexit
-- Our lexer
-- Intended for use in a for-in loop:
--     for lexstr, cat in lexer.lex(program) do
-- Here, lexstr is the string form of a lexeme, and cat is a number
-- representing a lexeme category. (See Public Constants.)
function lexit.lex(program)
    -- ***** Variables (like class data members) *****

    local pos       -- Index of next character in program
                    -- INVARIANT: when getLexeme is called, pos is
                    --  EITHER the index of the first character of the
                    --  next lexeme OR program:len()+1
    local state     -- Current state for our state machine
    local ch        -- Current character
    local lexstr    -- The lexeme, so far
    local category  -- Category of lexeme, set when state set to DONE
    local handlers  -- Dispatch table; value created later

    -- ***** States *****

    local DONE   = 0
    local START  = 1
    local LETTER = 2
    local DIGIT  = 3
    local DIGDOT = 4
    local DOT    = 5
    local PLUS   = 6
    local MINUS  = 7
    local STAR   = 8
    local STRLIT = 9
    local OP     = 10

    -- ***** Character-Related Utility Functions *****

    -- currChar
    -- Return the current character, at index pos in program. Return
    -- value is a single-character string, or the empty string if pos is
    -- past the end.
    local function currChar()
        return program:sub(pos, pos)
    end

    -- nextChar
    -- Return the next character, at index pos+1 in program. Return
    -- value is a single-character string, or the empty string if pos+1
    -- is past the end.
    local function nextChar()
        return program:sub(pos+1, pos+1)
    end

    -- drop1
    -- Move pos to the next character.
    local function drop1()
        pos = pos+1
    end

    -- add1
    -- Add the current character to the lexeme, moving pos to the next
    -- character.
    local function add1()
        lexstr = lexstr .. currChar()
        drop1()
    end

    -- skipWhitespace
    -- Skip whitespace and comments, moving pos to the beginning of
    -- the next lexeme, or to program:len()+1.
    local function skipWhitespace()
        while true do
            -- Skip whitespace characters
            while isWhitespace(currChar()) do
                drop1()
            end

            -- Done if no comment
            if currChar() ~= "#" then
                break
            end
            
            -- Skip comment
            drop1()  -- Drop leading "#"
            while true do
                if currChar() == "\n" then -- End of input?
                  drop1()
                  break
                end
                if currChar() == "" then  -- End of input?
                   return
                end
                drop1()  -- Drop character inside comment
            end
        end
    end

    -- ***** State-Handler Functions *****

    -- A function with a name like handle_XYZ is the handler function
    -- for state XYZ

    -- State DONE: lexeme is done; this handler should not be called.
    local function handle_DONE()
        error("'DONE' state should not be handled\n")
    end

    -- State START: no character read yet.
    local function handle_START()
        if isIllegal(ch) then
            add1()
            state = DONE
            category = lexit.MAL
        elseif isLetter(ch) or ch == "_" then
            add1()
            state = LETTER
        elseif isDigit(ch) then
            add1()
            state = DIGIT
        elseif ch == "." then
            add1()
            state = DOT
        elseif ch == "+" then
            add1()
            state = PLUS
        elseif ch == "-" then
            add1()
            state = MINUS
        elseif ch == "*" or ch == "/" 
               or ch == "[" or ch == "]" 
               or ch == "%" then
            add1()
            state = STAR
        elseif ch == "!" and nextChar() == "=" then
            add1()
            state = OP
        elseif ch == "<" or ch == ">"
               or ch == "=" then
            add1()
            state = OP
        elseif ch == '"' then
            add1()
            state = STRLIT
        else
            add1()
            state = DONE
            category = lexit.PUNCT
        end
    end

    -- State LETTER: we are in an ID.
    local function handle_LETTER()
        if isLetter(ch) or ch == "_" or isDigit(ch) then
            add1()
        else
            state = DONE
            if lexstr == "and" or lexstr == "char"
              or lexstr == "cr" or lexstr == "def"
              or lexstr == "dq" or lexstr == "elseif"
              or lexstr == "else" or lexstr == "false"
              or lexstr == "for" or lexstr == "if"
              or lexstr == "not" or lexstr == "or"
              or lexstr == "readnum" or lexstr == "return"
              or lexstr == "true" or lexstr == "write" then
                category = lexit.KEY
            else
                category = lexit.ID
            end
        end
    end
    
    -- State STRLIT: we are in a STRLIT and have not seen an end quote.
    local function handle_STRLIT()
      
      while currChar() ~= '"' do
        if currChar() == "\n" or currChar() == "" then
          state = DONE
          category = lexit.MAL
          return
        end
        add1()
      end
      
      if currChar() == '"' then
        add1()
      end
  
      state = DONE
      category = lexit.STRLIT
    end
    
    -- State DIGIT: we are in a NUMLIT, and we have NOT seen ".".
    local function handle_DIGIT()
        if ch == "e" and nextChar() == "+" and isDigit(program:sub(pos+2, pos+2))then
          add1()
          add1()
          while isDigit(currChar()) do
            add1()
          end
          state = DONE
          category = lexit.NUMLIT
          return
        elseif ch == "e" and isDigit(nextChar()) then
          add1()
          while isDigit(currChar()) do
            add1()
          end
          state = DONE
          category = lexit.NUMLIT
          return
        elseif ch == "E" and nextChar() == "+" and isDigit(program:sub(pos+2, pos+2)) then
          add1()
          add1()
          while isDigit(currChar()) do
            add1()
          end
          state = DONE
          category = lexit.NUMLIT
          return
        elseif ch == "E" and isDigit(nextChar()) then
          add1()
          while isDigit(currChar()) do
            add1()
          end
          state = DONE
          category = lexit.NUMLIT
          return
        elseif isDigit(ch) then
            add1()
        elseif ch == "." then
            state = DONE
            category = lexit.NUMLIT
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end
    

    -- State DIGDOT: we are in a NUMLIT, and we have seen ".".
    local function handle_DIGDOT()
        if isDigit(ch) then
            add1()
        else
            state = DONE
            category = lexit.NUMLIT
        end
    end

    -- State DOT: we have seen a dot (".") and nothing else.
    local function handle_DOT()
      state = DONE
      category = lexit.PUNCT
    end

    -- State PLUS: we have seen a plus ("+") and nothing else.
    local function handle_PLUS()
       state = DONE
       category = lexit.OP
    end

    -- State MINUS: we have seen a minus ("-") and nothing else.
    local function handle_MINUS()
      state = DONE
      category = lexit.OP
    end

    -- State STAR: we have seen a star ("*"), or slash ("/")
    -- or bracket ("[", "]"), or percent ("%")
    -- and nothing else.
    local function handle_STAR()  -- Handle * or /
        state = DONE
        category = lexit.OP
    end
    
    --State OP: we have seen a "!", "<", ">", or "="
    -- and nothing else
    local function handle_OP()
      if ch == "=" then
            add1()
            state = DONE
            category = lexit.OP
        else
            state = DONE
            category = lexit.OP
        end
    end
    

    -- ***** Table of State-Handler Functions *****

    handlers = {
        [DONE]=handle_DONE,
        [START]=handle_START,
        [LETTER]=handle_LETTER,
        [DIGIT]=handle_DIGIT,
        [DIGDOT]=handle_DIGDOT,
        [DOT]=handle_DOT,
        [PLUS]=handle_PLUS,
        [MINUS]=handle_MINUS,
        [STAR]=handle_STAR,
        [STRLIT]=handle_STRLIT,
        [OP]=handle_OP,
    }

    -- ***** Iterator Function *****

    -- getLexeme
    -- Called each time through the for-in loop.
    -- Returns a pair: lexeme-string (string) and category (int), or
    -- nil, nil if no more lexemes.
    local function getLexeme(dummy1, dummy2)
        if pos > program:len() then
            return nil, nil
        end
        lexstr = ""
        state = START
        while state ~= DONE do
            ch = currChar()
            handlers[state]()
        end

        skipWhitespace()
        return lexstr, category
    end

    -- ***** Body of Function lex *****

    -- Initialize & return the iterator function
    pos = 1
    skipWhitespace()
    return getLexeme, nil, nil
end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return lexit

