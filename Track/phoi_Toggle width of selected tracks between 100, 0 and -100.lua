--[[
@description phoi_Toggle width of selected tracks between 100, 0 and -100
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- NAME
local scriptName = "phoi_Toggle width of selected tracks between 100, 0 and -100"

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

		if absPrevWidth > 0 and absPrevWidth < 1 then
			newWidth = 0
		elseif prevWidth > 0.99 then
			newWidth = -1
		elseif prevWidth < -0.99 then
			newWidth = 0
		end
		reaper.SetMediaTrackInfo_Value(tr, 'D_WIDTH', newWidth)
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()