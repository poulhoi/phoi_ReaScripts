--[[
@description phoi_Create sampled notes from selected midi item
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

--[[
-- # phoi_Create sampled notes from selected midi item
-- Based heavily on this article: https://gestrument.com/create-a-playable-sampler-instrument-under-a-minute-part-1-reaper/
-- Select a midi item containing the lowest note to sample only before running the script.
-- The item length determines the length of the resulting sampled notes.
--]]

-- USER CONFIG
local maxOcts = 12 -- maximum amount of octaves to sample
local promptForSettings = true -- set to true to allow users to customise render settings; otherwise this script will determine the settings
local emptyNameWarning = true -- set to true to give option to rename track of item if its name is empty
local regionDeleteWarning = true -- set to true to warn user that all regions will be deleted

-- NAME
local scriptName = "phoi_Create sampled notes from selected midi item"

--- FUNCTIONS

function msg(msg)
    reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function toCSV(tt)
    -- Convert from table to CSV string
    
    local function escapeCSV(s) --Used to escape "'s by toCSV
        if string.find(s, '[,"]') then
            s = '"' .. string.gsub(s, '"', '""') .. '"'
        end
        return s
    end
            
    local s = ""

    for _,p in ipairs(tt) do    
        s = s .. "," .. escapeCSV(p)
    end

    return string.sub(s, 2)         -- remove first comma
end
    
function fromCSV(vals_csv, outputTypes)
    local t = {}
    local i = 0
    for line in vals_csv:gmatch("[^" .. "," .. "]*") do
        i = i + 1
                
        if #outputTypes == 1 and outputTypes[1] == "number" then
            t[i] = tonumber(line)
        elseif outputTypes[i] == "number" then
            t[i] = tonumber(line)
        else
            t[i] = line
        end
    end
    return t
end

function multiUserInput(outputTypes, windowName, numberOfParams, paramNames, defaultVals, saveVals, valsPersist, valsKeySuffix) 
    --[[ returns retval, input values as a table
    Examples:
    
    retval, inputs = multiUserInput({"number"}, "Test", 3, {"Threshold", "Ratio", "Output"}, {-18, 4, 6}, true, false, "")
    if retval then msg(inputs[1]) end
    
    Note: outputTypes can take a 1-element table, which will apply that value type to all inputs.
        Otherwise specify output type for each value
    --]]
    
    paramNames_csv = toCSV(paramNames)
    
    if saveVals and reaper.HasExtState("Main", scriptName .. "_Vals" .. valsKeySuffix) then -- restore previous values on run if saveVals is true and the values exist
        defaultVals_csv = reaper.GetExtState("Main", scriptName .. "_Vals" .. valsKeySuffix)
    else
        defaultVals_csv = toCSV(defaultVals)
    end
    

    
    retval, retvals_csv = reaper.GetUserInputs(tostring(windowName), numberOfParams, paramNames_csv, defaultVals_csv)
    
    if retval and saveVals then
        reaper.SetExtState("Main", scriptName .. "_Vals" .. valsKeySuffix, retvals_csv, valsPersist) -- save new defaults
    end
    
    if retval then
        vals = fromCSV(retvals_csv, outputTypes)
    else
        vals = nil
    end
    
    return retval, vals
end

function error(type)
    if type == 0 then 
        msgStr = "Error. Invalid input values. Choose a number of octaves between 1 and " .. maxOcts .. 
        " and a number of samples per octave between 1 and 12"
    elseif type == 1 then
        msgStr = "Error. Select a midi item."
    end
    msg(msgStr)
end

function setRenderSettings()
    local retval, render_config_path = reaper.get_config_var_string('defrenderpath')
    reaper.CSurf_OnPlayRateChange(1)
    reaper.GetSetProjectInfo(0, 'RENDER_SETTINGS', 128, true)
    reaper.GetSetProjectInfo(0, 'RENDER_BOUNDSFLAG', 3, true)
    reaper.GetSetProjectInfo(0, 'RENDER_CHANNELS', 2, true)
    reaper.GetSetProjectInfo(0, 'RENDER_SRATE', 48000, true)
    reaper.GetSetProjectInfo(0, 'RENDER_STARTPOS', 0, true)
    reaper.GetSetProjectInfo(0, 'RENDER_ENDPOS', 0, true)
    reaper.GetSetProjectInfo(0, 'RENDER_TAILFLAG', 0, true)
    reaper.GetSetProjectInfo(0, 'RENDER_DITHER', 0, true)
    reaper.GetSetProjectInfo(0, 'PROJECT_SRATE_USE', '1', true)
    reaper.GetSetProjectInfo_String(0, 'RENDER_FILE', render_config_path, true)
    reaper.GetSetProjectInfo_String(0, 'RENDER_PATTERN', '$track/$track_$region', true)
    reaper.GetSetProjectInfo_String(0, 'RENDER_FORMAT', 'ZXZhdyAAAA==', true)
end

function main()
    reaper.Undo_BeginBlock()

    if emptyNameWarning then
        local tr = reaper.GetMediaItem_Track(reaper.GetSelectedMediaItem(0, 0))
        local _, trName = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false)
        if trName == "" then
            local retval, newName = reaper.GetUserInputs("Set track name", 1, "New track name:", "SampledInstrument")
            if retval then reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", newName, true) end
        end
    end

    if promptForSettings then
        local prompt = reaper.ShowMessageBox( "Should this script determine your render settings? Otherwise, your current render settings will be applied", scriptName, 4 ) -- returns 6 for yes, 7 for no
        if prompt == 6 then
            setRenderSettings()
        end
    end

    if regionDeleteWarning then
        local retval, _, rgncount = reaper.CountProjectMarkers(0)
        if rgncount > 0 then
            local prompt = reaper.ShowMessageBox("This script will delete all regions in this project! Continue?", "Warning", 1)
            if prompt == 0 then
                return
            end
        end
    end

    local success, retvals_t = multiUserInput({"number"}, scriptName, 2, {"No. of octaves up", "No. of samples per octave"}, {4, 4}, true, false, "") 
    
    if success then

        -- select only first item if midi item, else abort
        item = reaper.GetSelectedMediaItem(0, 0) -- first item
        isMidi = reaper.TakeIsMIDI( reaper.GetActiveTake(item) )

        if not isMidi then
            error(1) 
            return 
        end

        while reaper.CountSelectedMediaItems(0) > 0 do
            reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(0, 0), false)
        end
        while reaper.CountSelectedTracks(0) > 0 do
            reaper.SetTrackSelected(reaper.GetSelectedTrack(0, 0), false)
        end
        reaper.SetMediaItemSelected(item, true)
        reaper.SetTrackSelected(reaper.GetMediaItem_Track(item), true)
        
        local octs, sampsPerOct = retvals_t[1], retvals_t[2]
        --msg(octs .. " and " .. sampsPerOct)

        if octs < 1 or octs > maxOcts or sampsPerOct < 1 or sampsPerOct > 12 then
            error(0)
            return
        end

        local transp = math.floor(12 / sampsPerOct) -- calculate amount of semitones to transpose each sample
        local samps = octs * sampsPerOct

        for i = 1, samps do
            reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWSMARKERLIST10"), 0) -- delete all regions

            for j = 1, transp do
                reaper.Main_OnCommand(reaper.NamedCommandLookup("_FNG_MIDI_UP_SEMI"), 0) -- transpose midi item up one semitone
            end

            reaper.Main_OnCommand(reaper.NamedCommandLookup("_FNG_MIDI_NAME"), 0) -- name midi item from note
            reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_REGIONSFROMITEMS"), 0) -- create region named from item
            reaper.Main_OnCommand(42230, 0) -- render using most recent settings
        
        end

        -- clean up
        for i = 1, samps * transp do
            reaper.Main_OnCommand(reaper.NamedCommandLookup("_FNG_MIDI_DN_SEMI"), 0) -- transpose midi item down one semitone
        end
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWSMARKERLIST10"), 0) -- delete all regions
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_FNG_MIDI_NAME"), 0) -- name midi item from note
        
    end
    reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
-- reaper.defer(function() end)  -- Prevent undo if necessary