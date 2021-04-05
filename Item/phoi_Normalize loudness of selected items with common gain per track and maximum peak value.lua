--[[
@description phoi_Normalize loudness of selected items with common gain per track and maximum peak value
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local lufsTarget = -23
local maxPeak = -10
local prompt = true

-- NAME
local scriptName = "phoi_Normalize loudness of selected items with common gain per track and maximum peak value"

-- FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

-- FUNCTIONS
function TrimItemVol(item, amt) -- amt in decibel

	local LN10_OVER_TWENTY = 0.11512925464970228420089957273422

	local function dbToVal(x) return math.exp(x*LN10_OVER_TWENTY) end

	local function valToDb(x)
		if x < 0.0000000298023223876953125 then
			return -150
		else
			return math.max(-150, math.log(x)* 8.6858896380650365530225783783321); 
		end
	end

	prevVolDb = valToDb(reaper.GetMediaItemInfo_Value(item, "D_VOL"))
	newVolDb = prevVolDb + amt
	newVol = dbToVal(newVolDb)
	reaper.SetMediaItemInfo_Value(item, "D_VOL", newVol)
end
	
function GetTracksOfSelectedItems()
	local idx = 1
	local tracks = {}
	for i = 1, reaper.CountSelectedMediaItems(0) do
		it = reaper.GetSelectedMediaItem(0, i-1)
		if i == 1 or reaper.GetMediaItem_Track(it) ~= tracks[idx-1] then -- if first iter or different than last track of item
			tracks[idx] = reaper.GetMediaItemTrack(it)
			idx = idx + 1
		end
	end
	return tracks
end
	
-- END OF FUNCTIONS


function main()
	reaper.Undo_BeginBlock()
	local count = reaper.CountSelectedMediaItems(0)
	if count > 0 then
		if prompt then
			local ret = reaper.ShowMessageBox("Warning: You're about to normalise the Loudness of " .. count .. " items. It might take some time. Continue?", scriptName, 1) -- 1 = ok, 2 = cancel
			if ret == 2 then return end
		end
	else -- if no items selected
		return
	end
	local tracks = GetTracksOfSelectedItems()
	for i = 1, #tracks do
		local tr = tracks[i]
		local trItems = {}
		local trAdj -- final volume adjustment of all items of the track
		for j = 0, reaper.CountTrackMediaItems(tr) - 1 do
			local it = reaper.GetTrackMediaItem(tr, j)
			local itAdj
			if reaper.IsMediaItemSelected(it) then
				local tk = reaper.GetActiveTake(it)
				if tk and not reaper.TakeIsMIDI(tk) then
					trItems[#trItems+1] = it
					local retval, itLufs = reaper.NF_AnalyzeTakeLoudness_IntegratedOnly(tk)
					if retval then
						local itPeak = reaper.NF_GetMediaItemMaxPeak( it )
						local lufsAdj = lufsTarget - itLufs
						local itAdj
						if itPeak + lufsAdj > maxPeak then -- if adjustment based on loudness would cross the maximum peak threshold, adjust based on peak
							itAdj = maxPeak - itPeak
						else
							itAdj = lufsAdj
						end

						if not trAdj then
							trAdj = itAdj
						else
							trAdj = math.min(trAdj, itAdj)
						end
					end
				end
			end
		end
		if trAdj then -- if a final track volume adjustment value exists
			for k = 1, #trItems do
				TrimItemVol(trItems[k], trAdj)
			end
		end
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()