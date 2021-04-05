--[[
@noindex
@description phoi_SmartNudge_SetToDefault
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local scriptName = "phoi_SmartNudge_SetToDefault"
local defaults = {"position", "grid", 1, 1}

--FUNCTIONS FOR DEBUG
function msg(msg)
  reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

-- FUNCTIONS


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


----- END OF FUNCTIONS


function main()
  reaper.Undo_BeginBlock()
 
  reaper.SetExtState("phoi_SmartNudge", "vals_CSV", toCSV(defaults), true) -- save new defaults
  
  reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()