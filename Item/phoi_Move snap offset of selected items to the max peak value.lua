--[[
@description phoi_Move snap offset of selected items to the max peak value
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- NAME
local scriptName = "phoi_Move snap offset of selected items to the max peak value"

--FUNCTIONS FOR DEBUG
function msg(msg)
  reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function main()
  for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    if item and not reaper.TakeIsMIDI(reaper.GetActiveTake(item)) then
      _, pos = reaper.NF_GetMediaItemMaxPeakAndMaxPeakPos( item )
      reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", pos)
    end
  end
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()