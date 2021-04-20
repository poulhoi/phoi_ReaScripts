--[[
@description phoi_Render stereo mixdown of selected area of tracks, muting items
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.014
@changelog Initial release
+ fix metadata packaging
+ credited X-Raym for SWS-checking functions
@noindex
--]]

-- USER CONFIG
local act_id = 41716 -- render action id
local destChanPref = 0 -- 0 for stereo, 1024 for mono

-- NAME
local scriptName = "phoi_Render stereo mixdown of selected area of tracks, muting items"

--FUNCTIONS FOR DEBUG
local function msg(s)
	reaper.ShowConsoleMsg(tostring(s) .. "\n")
end

--- FUNCTIONS

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

----- END OF FUNCTIONS

function main()
	reaper.Undo_BeginBlock()

	l, r = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
	if l == r then -- if no time selection
		reaper.ShowMessageBox("No time selection active.", "Error", 0)
		return
	end

	local tracks = {}
	local rcv
	for i = 0, reaper.CountSelectedTracks(0) - 1 do
		local tr = reaper.GetSelectedTrack(0, i)
		tracks[i] = tr
		if i == 0 then
			rcv_idx = reaper.GetMediaTrackInfo_Value(tr, "IP_TRACKNUMBER") - 1
			reaper.InsertTrackAtIndex( rcv_idx, false )
			rcv = reaper.GetTrack(0, rcv_idx)
		end
		send_idx = reaper.CreateTrackSend(tr, rcv)
		reaper.SetTrackSendInfo_Value( tr, 0, send_idx, "D_VOL", 1.0 ) -- set volume of send to 0 dB
		reaper.SetTrackSendInfo_Value( tr, 0, send_idx, "I_SENDMODE", 0 ) -- always post-fader
		reaper.SetTrackSendInfo_Value( tr, 0, send_idx, "I_SRCCHAN", 0 ) -- audio send, channels 1-2
		reaper.SetTrackSendInfo_Value( tr, 0, send_idx, "I_DESTCHAN", destChanPref )
		reaper.SetTrackSendInfo_Value( tr, 0, send_idx, "I_MIDIFLAGS", 31 ) -- first 5 bits = 1 -> no MIDI
	end

	local items = {} -- items to mute
	unselectAllItems()
	reaper.Main_OnCommand(40718, 0) -- select items on selected tracks in time selection
	for j = 0, reaper.CountSelectedMediaItems(0) - 1 do
		items[j] = reaper.GetSelectedMediaItem(0, j)
	end

	reaper.SetOnlyTrackSelected(rcv)
	reaper.Main_OnCommand(act_id, 0) -- render
	renderedTrack = reaper.GetSelectedTrack2(0, 0, false)
	reaper.GetSetMediaTrackInfo_String( renderedTrack, "P_NAME", "Rendered Mix", true )
	reaper.DeleteTrack( rcv )

	for k = 0, #tracks do
		local tr = tracks[k]
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
	reaper.SetOnlyTrackSelected(renderedTrack)
	reaper.Main_OnCommand(40718, 0) -- select items on selected tracks in time selection
	
	reaper.Undo_EndBlock(scriptName, -1)
end

-- Borrowed these from X-Raym.
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