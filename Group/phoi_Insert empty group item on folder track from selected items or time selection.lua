--[[
@description phoi_Insert empty group item on folder track from selected items or time selection
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- NAME
local scriptName = "phoi_Insert empty group item on folder track from selected items or time selection"


--FUNCTIONS FOR DEBUG
function Msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

--FUNCTIONS
function RemoveDecimalPoint(str)
	local decPoint = str:find("%.")
	if decPoint then str = str:sub(0, decPoint - 1) end
	return str
end

function SelectTracksOfSelectedItems()
	for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
		local it = reaper.GetSelectedMediaItem(0, i)
		local it_track = reaper.GetMediaItem_Track(it)
		reaper.SetTrackSelected(it_track, true)
	end
end

function SaveSelectedTracks( t )
	if not t then t = {} end
	local count_sel_tracks = reaper.CountSelectedTracks()
	for i = 0, count_sel_tracks - 1 do
		t[i+1] = reaper.GetSelectedTrack( 0, i )
	end
	return t
end

function UnselectAllItems()
	while reaper.CountSelectedMediaItems(0) > 0 do
		local it = reaper.GetSelectedMediaItem(0, 0)
		reaper.SetMediaItemSelected(it, false)
	end
end

-- RESTORE INITIAL TRACKS SELECTION
function RestoreSelectedTracks (table)
	while reaper.CountSelectedTracks(0) > 0 do
		local tr = reaper.GetSelectedTrack(0, 0)
		reaper.SetTrackSelected(tr, false)
	end
	for _, track in ipairs(table) do
		reaper.SetTrackSelected(track, true)
	end
end

----- END OF FUNCTIONS


function main()
	local orig_tl, orig_tr = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
	reaper.Main_OnCommand(40290, 0) -- Time selection: Set time selection to items
	SelectTracksOfSelectedItems()
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELPARENTS"), 0) -- select parents of selected tracks
	local sel_tracks = SaveSelectedTracks()
	UnselectAllItems()
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELCHILDREN"), 0) -- select only children of selected folder tracks
	reaper.Main_OnCommand(40718, 0) -- select all items on selected tracks in time selection
	reaper.Main_OnCommand(40290, 0) -- set time selection to items
	RestoreSelectedTracks(sel_tracks)
	local folders = {}
	tr_count = reaper.CountSelectedTracks(0)
	for i = 0, tr_count - 1 do
		local tr = reaper.GetSelectedTrack(0, i)
		folders[i] = tr
	end
	for i = 0, tr_count - 1 do
		local tr = folders[i]
		reaper.SetOnlyTrackSelected(tr)
		reaper.Main_OnCommand(40142, 0) -- insert empty item
		local new_empty = reaper.GetSelectedMediaItem(0, 0)
		local _, tr_name = reaper.GetTrackName(tr)
		if not tr_name then tr_name = "" end
		local group_items = {} -- table of group items
		for j = 0, reaper.CountTrackMediaItems(tr) - 1 do
			local tr_it = reaper.GetTrackMediaItem(tr, j)
			local retval, tr_it_note = reaper.GetSetMediaItemInfo_String( tr_it, "P_NOTES", "", false )
			if retval and (tr_it_note:find(" Item Group ") or tr_it == new_empty) then 
				group_items[#group_items+1] = tr_it 
			end
		end
		if #group_items > 0 then
			for j = 1, #group_items do
				local it = group_items[j]
				local s = tr_name .. " Item Group " .. RemoveDecimalPoint(tostring(j))
				reaper.GetSetMediaItemInfo_String( it, "P_NOTES", s, true )
			end
		else
			local s = tr_name .. " Item Group 1" 
			reaper.GetSetMediaItemInfo_String( new_empty, "P_NOTES", s, true )
		end
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELCHILDREN2"), 0) -- select children of selected tracks
		reaper.Main_OnCommand(40718, 0) -- Item: Select all items on selected tracks in current time selection
		reaper.Main_OnCommand(40032, 0) -- Group items
	end
	for i = 0, tr_count - 1 do
		local tr = folders[i]
		reaper.SetTrackSelected(tr, true)
	end

	reaper.GetSet_LoopTimeRange2(0, true, false, orig_tl, orig_tr, false) --
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
reaper.defer(function() end)   -- Prevent undo if necessary