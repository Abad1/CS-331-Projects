-- interpit.lua
-- Cody Abad
-- Skeleton Code by Glenn G. Chappell
-- 2021-03-31
--
-- For CS F331 / CSCE A331 Spring 2021
-- Interpret AST from parseit.parse
-- Solution to Assignment 6, Exercise 2


-- *** To run a Caracal program, use caracal.lua, which uses this file.


-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local interpit = {}  -- Our module


-- *********************************************************************
-- Symbolic Constants for AST
-- *********************************************************************


local STMT_LIST    = 1
local WRITE_STMT   = 2
local RETURN_STMT  = 3
local ASSN_STMT    = 4
local FUNC_CALL    = 5
local FUNC_DEF     = 6
local IF_STMT      = 7
local FOR_LOOP     = 8
local STRLIT_OUT   = 9
local CR_OUT       = 10
local DQ_OUT       = 11
local CHAR_CALL    = 12
local BIN_OP       = 13
local UN_OP        = 14
local NUMLIT_VAL   = 15
local BOOLLIT_VAL  = 16
local READNUM_CALL = 17
local SIMPLE_VAR   = 18
local ARRAY_VAR    = 19


-- *********************************************************************
-- Utility Functions
-- *********************************************************************


-- numToInt
-- Given a number, return the number rounded toward zero.
local function numToInt(n)
    assert(type(n) == "number")

    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
local function strToNum(s)
    assert(type(s) == "string")

    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return tonumber(s) end)

    -- Return integer value, or 0 on error.
    if success then
        if value == nil then
            return 0
        else
            return numToInt(value)
        end
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
local function numToStr(n)
    assert(type(n) == "number")

    return tostring(n)
end


-- boolToInt
-- Given a boolean, return 1 if it is true, 0 if it is false.
local function boolToInt(b)
    assert(type(b) == "boolean")

    if b then
        return 1
    else
        return 0
    end
end


-- astToStr
-- Given an AST, produce a string holding the AST in (roughly) Lua form,
-- with numbers replaced by names of symbolic constants used in parseit.
-- A table is assumed to represent an array.
-- See the Assignment 4 description for the AST Specification.
--
-- THIS FUNCTION IS INTENDED FOR USE IN DEBUGGING ONLY!
-- IT SHOULD NOT BE CALLED IN THE FINAL VERSION OF THE CODE.
function astToStr(x)
    local symbolNames = {
        "STMT_LIST", "WRITE_STMT", "RETURN_STMT", "ASSN_STMT",
        "FUNC_CALL", "FUNC_DEF", "IF_STMT", "FOR_LOOP", "STRLIT_OUT",
        "CR_OUT", "DQ_OUT", "CHAR_CALL", "BIN_OP", "UN_OP",
        "NUMLIT_VAL", "BOOLLIT_VAL", "READNUM_CALL", "SIMPLE_VAR",
        "ARRAY_VAR"
    }
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            return "<Unknown numerical constant: "..x..">"
        else
            return name
        end
    elseif type(x) == "string" then
        return '"'..x..'"'
    elseif type(x) == "boolean" then
        if x then
            return "true"
        else
            return "false"
        end
    elseif type(x) == "table" then
        local first = true
        local result = "{"
        for k = 1, #x do
            if not first then
                result = result .. ","
            end
            result = result .. astToStr(x[k])
            first = false
        end
        result = result .. "}"
        return result
    elseif type(x) == "nil" then
        return "nil"
    else
        return "<"..type(x)..">"
    end
end


-- *********************************************************************
-- Primary Function for Client Code
-- *********************************************************************


-- interp
-- Interpreter, given AST returned by parseit.parse.
-- Parameters:
--   ast     - AST constructed by parseit.parse
--   state   - Table holding Caracal variables & functions
--             - AST for function xyz is in state.f["xyz"]
--             - Value of simple variable xyz is in state.v["xyz"]
--             - Value of array item xyz[42] is in state.a["xyz"][42]
--   incall  - Function to call for line input
--             - incall() inputs line, returns string with no newline
--   outcall - Function to call for string output
--             - outcall(str) outputs str with no added newline
--             - To print a newline, do outcall("\n")
-- Return Value:
--   state, updated with changed variable values
function interpit.interp(ast, state, incall, outcall)
    -- Each local interpretation function is given the AST for the
    -- portion of the code it is interpreting. The function-wide
    -- versions of state, incall, and outcall may be used. The
    -- function-wide version of state may be modified as appropriate.


    -- Forward declare local functions
    local interp_stmt_list
    local interp_stmt
    local eval_expr


    -- interp_stmt_list
    -- Given the ast for a statement list, execute it.
    function interp_stmt_list(ast)
        for i = 2, #ast do
            interp_stmt(ast[i])
        end
    end


    -- interp_stmt
    -- Given the ast for a statement, execute it.
    function interp_stmt(ast)
        if ast[1] == WRITE_STMT then
            for i = 2, #ast do
                if ast[i][1] == STRLIT_OUT then
                    local str = ast[i][2]
                    outcall(str:sub(2, str:len()-1))
                elseif ast[i][1] == CR_OUT then
                    outcall("\n")
                elseif ast[i][1] == DQ_OUT then
                    outcall('"')
                elseif ast[i][1] == CHAR_CALL then
                    local n = eval_expr(ast[i][2])
                    if (n > 255) or (n < 0) then
                         n = 0
                    end
                    outcall(string.char(n))
                else  -- Expression
                    local val = eval_expr(ast[i])
                    outcall(numToStr(val))
                end
            end
        elseif ast[1] == FUNC_DEF then
            local funcname = ast[2]
            local funcbody = ast[3]
            state.f[funcname] = funcbody
        elseif ast[1] == FUNC_CALL then
            local funcname = ast[2]
            local funcbody = state.f[ast[2]]
            if funcbody == nil then
                funcbody = { STMT_LIST }
            end
            interp_stmt_list(funcbody)
        elseif ast[1] == RETURN_STMT then
            state.v["return"] = eval_expr(ast[2])
        elseif ast[1] == ASSN_STMT then
            local varname = ast[2][2] 
            local value = eval_expr(ast[3])
            if ast[2][1] == SIMPLE_VAR then
                state.v[varname] = value
            else
                local index = eval_expr(ast[2][3])
                if state.a[varname] == nil then
                  state.a[varname] = {}
                end
                state.a[varname][index] = value
            end  
        elseif ast[1] == IF_STMT then
            local i = 2
            while (i < #ast) do
                local condition = eval_expr(ast[i])
                if condition ~= 0 then
                    interp_stmt_list(ast[i + 1])
                    break
                end
                if (ast[i + 2] ~= nil) and condition == 0 then
                    if ast[i + 2][1] == STMT_LIST then
                        interp_stmt_list(ast[i + 2])
                    end
                end
                i = i + 2
            end
        elseif ast[1] == FOR_LOOP then
            if ast[2] == {} then
                interp_stmt_list(ast[5])
            else
                interp_stmt(ast[2])
                while (eval_expr(ast[3]) == 1) do
                    interp_stmt_list(ast[5])
                    interp_stmt(ast[4])
                end
                
            end
        end
    end


    -- eval_expr
    -- Given the AST for an expression, evaluate it and return the
    -- value.
    function eval_expr(ast)
        local result
        if ast[1] == NUMLIT_VAL then
            result = strToNum(ast[2])
        
        elseif ast[1] == BOOLLIT_VAL then
            if ast[2] == "true" then
                result = 1
            else
                result = 0
            end
        elseif ast[1] == SIMPLE_VAR then
            if state.v[ast[2]] == nil then
                result = 0
            else
                result = state.v[ast[2]]
            end
        elseif ast[1] == ARRAY_VAR then
            if state.a[ast[2]] == nil then
                result = 0
            elseif state.a[ast[2]][eval_expr(ast[3])] == nil then
                result = 0
            else
                result = state.a[ast[2]][eval_expr(ast[3])]
            end
        elseif ast[1] == READNUM_CALL then
            result = strToNum(incall())
        elseif ast[1] == FUNC_CALL then
            interp_stmt(ast)
            if state.v["return"] ~= nil then
                result = state.v["return"]
            else
              result = 0
            end
        elseif ast[1][1] == BIN_OP then
            local lhs = eval_expr(ast[2])
            local rhs = eval_expr(ast[3])
            if ast[1][2] == "+" then
                result = lhs + rhs
            elseif ast[1][2] == "-" then
                result = lhs - rhs
            elseif ast[1][2] == "*" then
                result = lhs * rhs
            elseif ast[1][2] == "/" then
                if rhs == 0 then
                    result = 0
                else
                    result = numToInt(lhs / rhs)
                end
            elseif ast[1][2] == "%" then
                if rhs == 0 then
                    result = 0
                else
                    result = lhs % rhs
                end
            elseif ast[1][2] == "==" then
                result = boolToInt(lhs == rhs)
            elseif ast[1][2] == "!=" then
                result = boolToInt(lhs ~= rhs)
            elseif ast[1][2] == "<" then
                result = boolToInt(lhs < rhs)
            elseif ast[1][2] == "<=" then
                result = boolToInt(lhs <= rhs)
            elseif ast[1][2] == ">" then
                result = boolToInt(lhs > rhs)
            elseif ast[1][2] == ">=" then
                result = boolToInt(lhs >= rhs)
            elseif ast[1][2] == "and" then
                if (lhs ~= 0) and (rhs ~= 0) then
                    result = 1
                else
                    result = 0
                end
            elseif ast[1][2] == "or" then
                if (lhs ~= 0) or (rhs ~= 0) then
                    result = 1
                else
                    result = 0
                end
            end
        elseif ast[1][1] == UN_OP then
            if ast[1][2] == "+" then
                result = eval_expr(ast[2])
            elseif ast[1][2] == "-" then
                result = (-1) * eval_expr(ast[2])
            elseif ast[1][2] == "not" then
                val = eval_expr(ast[2])
                if  val ~= 0 then
                    result = 0
                else
                    result = 1
                end
            end
        end

        return result
    end


    -- Body of function interp
    interp_stmt_list(ast)
    return state
end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return interpit

