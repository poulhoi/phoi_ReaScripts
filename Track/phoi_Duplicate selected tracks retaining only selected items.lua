--[[
@description phoi_Duplicate selected tracks retaining only selected items
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- USER CONFIG
local mute_originals = true -- to mute the items on the original track that are duplicated

-- NAME
local scriptName = "phoi_Duplicate selected tracks retaining only selected items"

--FUNCTIONS FOR DEBUG
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end
--- END FUNCTIONS

function main()
	reaper.Undo_BeginBlock()

	local tracks = {}
	
	for i = 1, reaper.CountSelectedTracks(0) do -- only consider tracks with selected items on them
		local tr = reaper.GetSelectedTrack(0, i-1)
		local item_selected = false
		for j = 0, reaper.CountTrackMediaItems(tr) - 1 do
			local it = reaper.GetTrackMediaItem(tr, j)
			if reaper.IsMediaItemSelected(it) then
				tracks[#tracks+1] = tr
				break
			end
		end
	end

	local items_to_select = {}
	local tracks_to_select = {}

	for i = 1, #tracks do
		local tr = tracks[i]
		local tr_items = {} -- 1-indexed array of items
		for j = 0, reaper.CountTrackMediaItems(tr) - 1 do
			local it = reaper.GetTrackMediaItem(tr, j)
			if reaper.IsMediaItemSelected(it) then
				tr_items[#tr_items+1] = it
				reaper.SetMediaItemSelected(it, false)
			end
		end

		reaper.SetOnlyTrackSelected(tr)
		reaper.Main_OnCommand(40062, 0) -- duplicate track

		local dup = reaper.GetSelectedTrack(0, 0) -- duplicated track is selected after action
		tracks_to_select[#tracks_to_select+1] = dup
		local items_to_delete = {}

		for j = 0, reaper.CountTrackMediaItems(dup) - 1 do
			local dup_it = reaper.GetTrackMediaItem(dup, j)
			if dup_it then
				local dup_it_pos = reaper.GetMediaItemInfo_Value(dup_it, "D_POSITION")
				local match = false
				for k = 1, #tr_items do
					local pos = reaper.GetMediaItemInfo_Value(tr_items[k], "D_POSITION")
					if dup_it_pos == pos then
						match = true
						break
					end
				end
				if not match then 
					items_to_delete[#items_to_delete+1] = dup_it
				else
					items_to_select[#items_to_select+1] = dup_it
				end
			end
		end

		for j = 1, #items_to_delete do
			reaper.DeleteTrackMediaItem(dup, items_to_delete[j])
		end

		if mute_originals then
			for j = 1, #tr_items do
				reaper.SetMediaItemInfo_Value(tr_items[j], "B_MUTE", 1)
			end
		end

	end

	for i = 1, #items_to_select do
		reaper.SetMediaItemSelected(items_to_select[i], true)
	end

	for i = 1, #tracks_to_select do
		reaper.SetTrackSelected(tracks_to_select[i], true)
	end

	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()