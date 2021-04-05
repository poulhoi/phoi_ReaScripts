--[[
@description phoi_Rename item with filepath and full name from input
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
# phoi_Rename item with filepath and full name from input

Designed for naming many sound assets at once for game audio, for example.

Will format name into appropriate folder structure from spaces and/or underscores in an input name.

if more than one item is selected, they will also be enumerated.

For example, 5 items with selected with input "Player Footsteps Left" will be renamed to "Player/Footsteps/Left/PlayerFootstepsLeft_01" to "..._05"
--]]

local sep
local platform = reaper.GetOS()
if platform == "OSX64" or platform == "OSX32" or platform == "OSX" or platform == "Other" then
  sep = [[/]]
else
  sep = [[\]] --win
end

function formatItemName(inputname)
  inputname = string.gsub(" "..inputname, "%W%l", string.upper):sub(2)
  inputname = inputname:gsub("%s", "_") -- replace spaces with underscores
  local pathname = inputname:gsub("_", sep) --replace underscore with separator
  if string.sub(pathname, -1) ~= sep then pathname = pathname .. sep end -- if missing, add separator at the end
  local fullname = pathname .. inputname
  return fullname
end

function main()
  reaper.Undo_BeginBlock()
  retval, basename = reaper.GetUserInputs("phoi_Rename items with filepath", 1, "Base name", "")
  itemCount = reaper.CountSelectedMediaItems(0) -- count selected items
  
  if itemCount < 1 then return end
  
  for i = 0, itemCount - 1, 1 do
    item = reaper.GetSelectedMediaItem(0, i)
    newName = formatItemName(basename)
    if itemCount > 1 then
      newName = newName .. "_" .. string.format("%02d", i + 1)
    end
    retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String(reaper.GetActiveTake(item), "P_NAME", newName, true) --set name of active take of item to newName
    
  end
  reaper.Undo_EndBlock("Rename item with filepath", -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
