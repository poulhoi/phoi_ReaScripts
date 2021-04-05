--[[
@noindex
@description phoi_SmartNudge_SetParamsFromMultiUserInput
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_SmartNudge_SetParamsFromMultiUserInput
Will set nudge values based on user input in the form: [param],[val],[unit],[copies]
[copies] is optional

Parameters:
  param
    position
    leftTrim
    leftEdge
    rightEdge
    contents
    duplicate
    editCursor
  unit
    ms
    s
    grid
    beats
    bars
    samples
    frames
    itemSels
  val
    (any number)
  copies
    (integer)

example: 
  position,1,grid
    nudge position by 1 grid
]]--

-- USER CONFIG
local scriptName = "phoi_SmartNudge_SetParamsFromMultiUserInput"


--FUNCTIONS FOR DEBUG
function msg(msg)
  reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

-- FUNCTIONS
  
function fromCSV(vals_csv, outputTypes)
  local t = {}
  local i = 0
  for line in vals_csv:gmatch("[^" .. "," .. "]*") do
    i = i + 1
        
    if #outputTypes == 1 and outputTypes[1] == "number" then
      t[i] = tonumber(line)
    elseif outputTypes[i] == "number" then
      t[i] = tonumber(line)
    else
      t[i] = line
    end
  end
  return t
end

function toCSV(tt)
  -- Convert from table to CSV string
  
  local function escapeCSV(s) --Used to escape "'s by toCSV
    if string.find(s, '[,"]') then
      s = '"' .. string.gsub(s, '"', '""') .. '"'
    end
    return s
  end
      
  local s = ""

  for _,p in ipairs(tt) do  
    s = s .. "," .. escapeCSV(p)
  end

  return string.sub(s, 2)      -- remove first comma
end

function multiUserInput(outputTypes, windowName, numberOfParams, paramNames, defaultVals) 
  --[[ returns retval, input values as a table
  Examples:
  
  retval, inputs = multiUserInput({"number"}, "Test", 3, {"Threshold", "Ratio", "Output"}, {-18, 4, 6}, true, false, "")
  if retval then msg(inputs[1]) end
  
  Note: outputTypes can take a 1-element table, which will apply that value type to all inputs.
    Otherwise specify output type for each value
  --]]
  
  paramNames_csv = toCSV(paramNames)
  
  defaultVals_csv = toCSV(defaultVals)
  
  retval, retvals_csv = reaper.GetUserInputs(tostring(windowName), numberOfParams, paramNames_csv, defaultVals_csv)
  
  
  if retval then
    vals = fromCSV(retvals_csv, outputTypes)
  else
    vals = nil
  end
  
  return retval, vals
end

----- END OF FUNCTIONS


function main()
  reaper.Undo_BeginBlock()
  local vals = {}
  local input = {}

 -- get state if it exists. If no state exists, initialise to default values
  if reaper.HasExtState("phoi_SmartNudge", "vals_CSV") then
    vals = fromCSV(reaper.GetExtState("phoi_SmartNudge", "vals_CSV"), "")
  else
    vals = {"position", "grid", 1, 1}
  end
  
  
  retval, input = multiUserInput(
    {"string", "number", "string", "number"}, 
    "phoi_SmartNudge - nudge mode", 
    4, 
    {"What to nudge:", "Value", "Unit", "Copies (if duplicate)"},
    {vals[1], vals[3], vals[2], vals[4]}
    )
  if retval then
     --this is awful. Remaps so the inputs are in a correct order for recall by other scripts
    if input[1] ~= nil then
      vals[1] = input[1]
    end
    if input[2] ~= nil then
      vals[3] = input[2]
    end
    if input[3] ~= nil then
      vals[2] = input[3]
    end
    if input[1] ~= nil then
      vals[4] = input[4]
    end
  else 
    return
  end
  
  
  reaper.SetExtState("phoi_SmartNudge", "vals_CSV", toCSV(vals), true) -- save new values, remapped
  
  local helpstring = "phoi_SmartNudge: Nudge " ..  vals[1] .. " " .. vals[3] .. " " .. vals[2]
  if vals[1] == "duplicate" and vals[4] ~= nil then 
    helpstring = helpstring .. ", creating " .. vals[4] .. " copies" -- add duplicates parameter if mode is "duplicate"
  end
  reaper.Help_Set(helpstring, true)
  
  reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()