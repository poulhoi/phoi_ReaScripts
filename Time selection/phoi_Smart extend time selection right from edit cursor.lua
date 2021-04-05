--[[
@description phoi_Smart extend time selection right from edit cursor
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- NAME
local scriptName = "phoi_Smart extend time selection right from edit cursor"

--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function main()
	reaper.Undo_BeginBlock()
	local tl, tr = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
	local pos = reaper.GetCursorPositionEx(0)
	local snap_tr = reaper.SnapToGrid(0, tr)

	local bar = reaper.TimeMap2_beatsToTime( 0, 0, 1 )
	local _, div, _, _ = reaper.GetSetProjectGrid(0, false)
	local grid_unit = bar * div
	--msg('tl: ' .. tl .. '\ntr: ' .. tr)
	if tl == tr or (pos ~= tl and pos ~= tr) then -- if no time selection or edit cursor is not at edge
		tl = pos
		tr = reaper.SnapToGrid(0, pos + grid_unit)
	elseif pos == tr then
		tl = reaper.SnapToGrid(0, tl + grid_unit)
	else
		if snap_tr > tr then 
			tr = snap_tr
		else
			tr = reaper.SnapToGrid(0, tr + grid_unit)
		end
	end
	reaper.GetSet_LoopTimeRange2(0, true, false, tl, tr, false)

	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()