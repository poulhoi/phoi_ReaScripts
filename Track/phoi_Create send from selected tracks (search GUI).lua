--[[
@description phoi_Create send from selected tracks (search GUI)
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.01
@changelog Initial release
--]]

-- CONFIG
local searchRate = 0.05 
local autoCloseDefault = true

function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end


local tracks  = {}
local trackNames = {}
local trackNamesLower = {}
local hits = {}
local first, refresh = true, true
local clock = os.clock()
local autoClose = autoCloseDefault

function init()
	for i = 1, reaper.CountTracks(0) do
		local track = reaper.GetTrack(0, i-1)
		tracks[i] = track
		local _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", '', false)
		trackNames[i] = name
		trackNamesLower[i] = name:lower() --make all lowercase
	end
end

function ShowWindow()
	if not ctx then
		ctx = reaper.ImGui_CreateContext('phoi_Send to track', reaper.ImGui_ConfigFlags_None())
	end
	local rv, open = nil, true
--  reaper.ImGui_SetNextWindowPos(ctx, 500, 500)
--  reaper.ImGui_SetNextWindowSize(ctx, 500, 440)
	rv, open = reaper.ImGui_Begin(ctx, 'phoi_Send to track', open, reaper.ImGui_WindowFlags_None())
	if not rv then return open end

	local openSendPrefs = reaper.ImGui_Button(ctx, 'Send preferences...') -- button to open send preferences
	if openSendPrefs then
		reaper.ViewPrefs(0x0b2, '')
	end	
	reaper.ImGui_SameLine(ctx)
	local autoCloseSwitch = reaper.ImGui_Checkbox(ctx, 'Auto-close?', autoClose)
	if autoCloseSwitch then
		autoClose = not autoClose
		msg(autoClose)
	end

	if not oldText then oldText = '' end
	if first then reaper.ImGui_SetKeyboardFocusHere(ctx, 0) end
	reaper.ImGui_Dummy(ctx, 100, 10)
	local rv, text = reaper.ImGui_InputText(ctx, '<- Search!', oldText, reaper.ImGui_InputTextFlags_None())
	if refresh then
		local search = text:lower()
		local searchWords = {}
		for word in search:gmatch('[^%s]*') do
			searchWords[#searchWords+1] = word
		end
		
		hits = {}
		for i = 1, #tracks do
			local name = trackNamesLower[i]
			for j = 1, #searchWords do
				if name:find(searchWords[j]) then
					hits[#hits+1] = i -- store only the index
					break
				end
			end
		end
		refresh = false
	else
		local delta = os.clock() - clock
		if delta >= searchRate then
			refresh = true
			clock = os.clock()
		end
	end

	oldText = text
	reaper.ImGui_Dummy(ctx, 100, 10)
	local oops = false
	local function CreateSend(destTrack)
		local trackCount = reaper.CountSelectedTracks(0)
		if trackCount < 1 then 
			oops = true
			return 
		end
		reaper.Undo_BeginBlock()
		local targetTrackName

		if trackCount > 1 then
			targetTrackName = 'multiple tracks'
		else
			_, targetTrackName = reaper.GetSetMediaTrackInfo_String(reaper.GetSelectedTrack(0, 0), 'P_NAME', '', false)
		end

		local _, destTrackName = reaper.GetSetMediaTrackInfo_String(destTrack, 'P_NAME', '', false)

		for j = 0, trackCount - 1 do
			local targetTrack = reaper.GetSelectedTrack(0, j)
			reaper.CreateTrackSend(targetTrack, destTrack)
		end
		reaper.Undo_EndBlock("Create track send from " .. targetTrackName .. ' to ' .. destTrackName, 1)
	end

	for i = 1, #hits do
		local prefix = tostring(i):format("%i") .. ": "
		local trackChosen = reaper.ImGui_Button(ctx, prefix .. trackNames[hits[i]])
		if trackChosen then
			local destTrack = tracks[hits[i]]
			CreateSend(destTrack)
			if autoClose and not oops then
				reaper.ImGui_End(ctx)	
				return false
			end
		end
	end

	local function CreateSendToHit(x)
		local destTrack = tracks[hits[x]]
		CreateSend(destTrack)	
		if autoClose and not oops then
			reaper.ImGui_End(ctx)	
			return false
		else
			return true
		end
	end

	if reaper.ImGui_IsKeyDown(ctx, 13) then -- if enter is pressed, send to top track
		local val = CreateSendToHit(1)
		if not val then return false end
	end
	local ctrl = reaper.ImGui_GetKeyMods(ctx) & reaper.ImGui_KeyModFlags_Ctrl()
	if ctrl > 0 then
		for i = 49, 57 do -- create send with number keys
			if reaper.ImGui_IsKeyDown(ctx, i) then
				local val = CreateSendToHit(i-48)
				if not val then return false end
			end
		end
	end	
	if reaper.ImGui_IsKeyDown(ctx, 27) then -- if escape is pressed, close window
		reaper.ImGui_End(ctx)
		return false
	end


	reaper.ImGui_End(ctx)
	first = false
	return open
end


function loop()
	open = ShowWindow()
	if open then
		reaper.defer(loop)
	else
		reaper.ImGui_DestroyContext(ctx)
	end
end

init()
loop()