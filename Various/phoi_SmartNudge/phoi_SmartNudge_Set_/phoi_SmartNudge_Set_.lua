--[[
@noindex
@description phoi_SmartNudge_Set_
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_SmartNudge_Set
Will set nudge values based on the name of the script.
All names should start with "phoi_SmartNudge_Set_", 
  followed by which parameter the script should set
  followed by _
  followed by what that parameter should be set to
    Value can be set to userInputNumber or userInputString to prompt for a new value
  
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
  phoi_SmartNudge_Set_param_position.lua 
    will set smart nudge to nudge position
  phoi_SmartNudge_Set_val_100.lua 
    will set smart nudge to nudge in 100 units at a time
  phoi_SmartNudge_Set_val_userInputNumber.lua 
    will prompt user and set smart nudge to new value
  phoi_SmartNudge_Set_unit_userInputString.lua
    will prompt user for new unit
]]--
-- USER CONFIG
local scriptName = "phoi_SmartNudge_Set_val_5"


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

function singleUserInput(outputType, windowName, paramName, defaultVal)
  retval, outString = reaper.GetUserInputs(tostring(windowName), 1, tostring(paramName), tostring(defaultVal))
  if retval then
    if outputType == "number" then
      return retval, tonumber(outString)
    else
      return retval, outString
    end
  else
    return
  end
end


----- END OF FUNCTIONS


function main()
  reaper.Undo_BeginBlock()
  local vals = {}

 -- get state if it exists. If no state exists, initialise to default values
  if reaper.HasExtState("phoi_SmartNudge", "vals_CSV") then
    vals = fromCSV(reaper.GetExtState("phoi_SmartNudge", "vals_CSV"), "")
  else
    vals = {"position", "grid", 1, 1}
  end
  
  local basePath = ({reaper. get_action_context()})[2]
  local baseName =  basePath:match("([^/\\]+)%.lua$") -- name of script file
  
  local varKeys = { -- which variable is the script changing?
     param = 1,
     unit = 2,
     val = 3,
     copies = 4,
   }

  local whatFromName = baseName:gsub("(phoi_SmartNudge_Set_)(%a+)(_.+)", "%2") -- get what script should change - "unit", "what", "val" or "copies"
  local valFromName = baseName:gsub("(phoi_SmartNudge_Set_)(%a+_)(.+)", "%3") -- get new value for script
  
  if valFromName == "userInputNumber" then -- if filename ends in "userInput", prompt user for value
    local defaultVal = vals[varKeys[whatFromName]] -- get default value for whatever parameter the function is changing
    retval, input = singleUserInput("number", "phoi_SmartNudge - Set " .. whatFromName, whatFromName .. ":", defaultVal)
    if retval and input ~= "" then 
      valFromName = input 
    else 
      return end
  elseif valFromName == "userInputString" then
    local defaultVal = vals[varKeys[whatFromName]] -- get default value for whatever parameter the function is changing
    retval, input = singleUserInput("string", "phoi_SmartNudge - Set " .. whatFromName, whatFromName .. ":", defaultVal)
    if retval and input ~= "" then 
      valFromName = input 
    else 
      return end
  end
   
  vals[varKeys[whatFromName]] = valFromName 
  reaper.SetExtState("phoi_SmartNudge", "vals_CSV", toCSV(vals), true) -- save new values
  
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