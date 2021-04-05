--[[
@noindex
@description phoi_SmartNudge_DisplayCurrentSettings
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_SmartNudge_DisplayCurrentSettings
Will display current nudge values 
]]--

-- USER CONFIG
local scriptName = "phoi_SmartNudge_DisplayCurrentSettings"


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

----- END OF FUNCTIONS


function main()
  local vals = {}
  local helpstring = ""
 -- get and display state if it exists
  if reaper.HasExtState("phoi_SmartNudge", "vals_CSV") then
    vals = fromCSV(reaper.GetExtState("phoi_SmartNudge", "vals_CSV"), "")
    helpstring = "phoi_SmartNudge: Nudge " ..  vals[1] .. " " .. vals[3] .. " " .. vals[2]
    if vals[1] == "duplicate" and vals[4] ~= nil then 
      helpstring = helpstring .. ", creating " .. vals[4] .. " copies" -- add duplicates parameter if mode is "duplicate"
    end
  else
    helpstring = "phoi_SmartNudge: No setting found"
  end

  
  reaper.Help_Set(helpstring, true)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()