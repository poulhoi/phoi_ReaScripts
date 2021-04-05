--[[
@description phoi_Toggle width of selected tracks between 0 and 100
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_Toggle width of selected tracks between 0 and 100
Meant to keep tracks that are inverted to still be inverted, but still toggle between stereo and mono.
--]]

-- NAME
local scriptName = "phoi_Toggle width of selected tracks between 0 and 100"

--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

----- END OF FUNCTIONS

function main()
	reaper.Undo_BeginBlock()
	for i = 0, reaper.CountSelectedTracks(0) - 1 do
		local tr = reaper.GetSelectedTrack(0, i)
		local prevWidth = reaper.GetMediaTrackInfo_Value(tr, 'D_WIDTH')
		local absPrevWidth = math.abs(prevWidth)
		local newWidth = 1

		if (absPrevWidth > 0 and absPrevWidth <= 1) then
			newWidth = 0
		else
			newWidth = 1
		end
		reaper.SetMediaTrackInfo_Value(tr, 'D_WIDTH', newWidth)
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()