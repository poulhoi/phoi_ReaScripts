--[[
@description phoi_Generate tracks from channel list text file
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- Generates named tracks with set input channels from a list of tracks in a .txt file as one would write in preparation for a recording session.

-- CONFIG
local separatorPattern = "%s*[-_:]%s+" -- pattern separating channel number and track name

--FUNCTIONS
function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function read_lines(filepath)
	
	reaper.Undo_BeginBlock() -- Begin undo group
	
	local f = io.input(filepath)
	repeat
		
		s = f:read ("*l") -- read one line
		if s then  -- if not end of file (EOF)
		
			local channelStr = s:match("^%d+-?%d*")
			--local channelStr = s:match("^(%d+-?d*)"..separatorPattern)
			local trackName = s:match(separatorPattern.."(.+)$")

			count_tracks = reaper.CountTracks(0)
				
			i = 0
			
			last_track_id = count_tracks + i
			reaper.InsertTrackAtIndex(last_track_id, true)
			last_track = reaper.GetTrack(0, last_track_id)
			
			retval, track_name = reaper.GetSetMediaTrackInfo_String(last_track, "P_NAME", trackName, true)
			local recInputVal = 0
			if channelStr:find("-") then --if stereo or multichannel
				inputStartChanStr = channelStr:match("^(%d+)-") 
				inputEndChanStr = channelStr:match("-(%d+)$")
				inputStartChan, inputEndChan = tonumber(inputStartChanStr)-1, tonumber(inputEndChanStr)-1
				chanDiff = inputEndChan - inputStartChan 
				if chanDiff > 1 then -- if multichannel
					recInputVal = 2048 -- multichannel bit
					numberChans = chanDiff + 1
					if numberChans % 2 > 0 then -- if odd
						numberChans = numberChans + 1
					end
					reaper.SetMediaTrackInfo_Value(last_track, "I_NCHAN", numberChans)
				else
					recInputVal = 1024 -- stereo bit
				end
				recInputVal = recInputVal + inputStartChan
			else	
				inputStartChan = tonumber(channelStr)-1
				recInputVal = inputStartChan
			end
			reaper.SetMediaTrackInfo_Value(last_track, "I_RECINPUT", recInputVal) 
		end
	
	until not s  -- until end of file

	f:close()

	reaper.Undo_EndBlock("Generate tracks from channel list text file", -1) -- End undo group
	
end

-- START -----------------------------------------------------
retval, filetxt = reaper.GetUserFileNameForRead("", "Import tracks from file", "")

if retval then 
	
	reaper.PreventUIRefresh(1)
	read_lines(filetxt)
	
	-- Update TCP
	reaper.TrackList_AdjustWindows(false)
	reaper.UpdateTimeline()
	
	reaper.UpdateArrange()
	reaper.PreventUIRefresh(-1)
	
end