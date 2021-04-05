--[[
@description phoi_Render selected area of tracks, muting items
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.01
@changelog Initial release
+ fix metadata
@provides
	[nomain] .
	[main] phoi_Render selected area of tracks, muting items - stereo, pre-fader.lua
	[main] phoi_Render selected area of tracks, muting items - stereo, post-fader.lua
	[main] phoi_Render selected area of tracks, muting items - multichannel, pre-fader.lua
	[main] phoi_Render selected area of tracks, muting items - multichannel, post-fader.lua
	[main] phoi_Render selected area of tracks, muting items - mono, pre-fader.lua
	[main] phoi_Render selected area of tracks, muting items - mono, post-fader.lua
	[main] phoi_Render stereo mixdown of selected area of tracks, muting items.lua
--]]

-- FUNCTIONS
local function msg(s)
	reaper.ShowConsoleMsg(tostring(s) .. "\n")
end

local function unselectAllItems ()
	while (reaper.CountSelectedMediaItems(0) > 0) do
		reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(0, 0), false)
	end
end

local function setItemsSelected (itemsT, unselectOthers) -- zero-indexed table of items as input
	if unselectOthers then unselectAllItems() end

	for i = 0, #itemsT do
		local item = itemsT[i]
		if reaper.ValidatePtr(item, "MediaItem*") then
			reaper.SetMediaItemSelected(item, true)
		end
	end
end

local function unselectAllTracks ()
	while (reaper.CountSelectedTracks(0) > 0) do
		reaper.SetTrackSelected(reaper.GetSelectedTrack(0, 0), false)
	end
end

local function setTracksSelected (tracksT, unselectOthers) -- zero-indexed table of tracks as input
	if unselectOthers then unselectAllTracks() end

	for i = 0, #tracksT do
		local track = tracksT[i]
		if reaper.ValidatePtr(track, "MediaTrack*") then
			reaper.SetTrackSelected(track, true)
		end
	end
end

function main()
	reaper.Undo_BeginBlock()

	local tracks = {}
	for i = 0, reaper.CountSelectedTracks(0) - 1 do
		tracks[i] = reaper.GetSelectedTrack(0, i)
	end

	local items = {} -- items to mute
	unselectAllItems()
	reaper.Main_OnCommand(40718, 0) -- select items on selected tracks in time selection
	for j = 0, reaper.CountSelectedMediaItems(0) - 1 do
		items[j] = reaper.GetSelectedMediaItem(0, j)
	end

	reaper.Main_OnCommand(act_id, 0) -- render

	local renderedTracks = {}
	for m = 0, reaper.CountSelectedTracks(0) - 1 do
		renderedTracks[m] = reaper.GetSelectedTrack(0, m)
	end

	for k = 0, #tracks do
		local tr = tracks[k]
		reaper.SetMediaTrackInfo_Value(tr, "B_MUTE", 0) --unmute track

		if reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERDEPTH") == 1 then -- if track is parent, add items on child tracks to table of items to be muted
			unselectAllTracks()
			reaper.SetTrackSelected(tr, true)
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELCHILDREN2"), 0) -- select children
			reaper.SetTrackSelected(tr, false) -- have only children selected
			reaper.Main_OnCommand(40718, 0) -- select items on selected tracks in time selection
			for n = 0, reaper.CountSelectedMediaItems(0) - 1 do
				items[#items+1] = reaper.GetSelectedMediaItem(0, n)
			end
		end
	end

	setItemsSelected(items, true)
	reaper.Main_OnCommand(40061, 0) -- split items at time selection
	for l = 0, reaper.CountSelectedMediaItems(0) - 1 do -- mute new selection of items after split
		local it = reaper.GetSelectedMediaItem(0, l)
		reaper.SetMediaItemInfo_Value( it, "B_MUTE", 1 )
	end

	unselectAllItems()
	setTracksSelected(renderedTracks, true)
	reaper.Main_OnCommand(40718, 0) -- select items on selected tracks in time selection
	
	reaper.Undo_EndBlock(scriptName, -1)
end


function Open_URL(url)
  if not OS then local OS = reaper.GetOS() end
  if OS=="OSX32" or OS=="OSX64" then
    os.execute("start \"\" \"".. url .. "\"")
   else
    os.execute("start ".. url)
  end
end

function CheckSWS()
  if reaper.NamedCommandLookup("_BR_VERSION_CHECK") == 0 then 
    local retval = reaper.ShowMessageBox("SWS extension is required by this script.\nHowever, it doesn't seem to be present for this REAPER installation.\n\nDo you want to download it now ?", "Warning", 1)
    if retval == 1 then
      Open_URL("http://www.sws-extension.org/download/pre-release/")
    end
  else
    return true
  end
end

local sws = CheckSWS()
if sws then
	reaper.PreventUIRefresh(1)
	main()
	reaper.PreventUIRefresh(-1)
	reaper.UpdateArrange()
end