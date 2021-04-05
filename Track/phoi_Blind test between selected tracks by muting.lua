--[[
@description phoi_Blind test between selected tracks by muting
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local scriptName = "phoi_Blind test between selected tracks by muting"

function mute(tr, val)
	reaper.SetMediaTrackInfo_Value(tr, "B_MUTE", val)
end

function main()
	reaper.Undo_BeginBlock()
	local trackCount = reaper.CountSelectedTracks(0)
	local randomUpper = trackCount - 1
	if randomUpper < 1 then return end
	
	local dice = math.random(0, randomUpper)
	
	local prevDice = tonumber(reaper.GetExtState(scriptName, "prevDice")) -- get previous random value
	
	while(dice == prevDice) do -- loops through until new random value is generated
		dice = math.random(0, randomUpper)
	end
	
	for i = 0, trackCount - 1 do
		track = reaper.GetSelectedTrack(0, i)
		if i == dice then 
			mute(track, 0)
		else
			mute(track, 1)
		end
	end
	
	reaper.SetExtState(scriptName, "prevDice", dice, false)
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()