--[[
@description phoi_SmartNudge
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.1
@changelog Initial release
+ fix metadata
+ include parameter names in singular, fix bug when using fractional values
@metapackage
@provides
  [main] phoi_SmartNudge_left.lua 
  [main] phoi_SmartNudge_left_strong.lua 
  [main] phoi_SmartNudge_right.lua 
  [main] phoi_SmartNudge_right_strong.lua 
  [main] phoi_SmartNudge_SetParamsFromMultiUserInput.lua 
  [main] phoi_SmartNudge_SetToDefault.lua 
  [main] phoi_SmartNudge_DisplayCurrentSettings.lua 
  phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_val_5.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_param_leftTrim.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_val_10.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_param_rightEdge.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_val_1.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_unit_frames.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_unit_bars.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_param_editCursor.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_val_500.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_val_userInputNumber.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_param_crossfade.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_copies_userInputNumber.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_param_contents.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_param_position.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_param_envelopepoints.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_param_duplicate.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_val_100.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_val_250.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_unit_beats.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_unit_itemSels.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_val_50.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_unit_ms.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_unit_s.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_unit_samples.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_unit_grid.lua
  [main] phoi_SmartNudge_Set_/phoi_SmartNudge_Set_.lua > phoi_SmartNudge_Set_/phoi_SmartNudge_Set_val_25.lua
--]]

--FUNCTIONS FOR DEBUG
function msg(msg)
  reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

-- FUNCTIONS
  
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

function crossfadeNudge(unit, val, reverse)
  local iC = reaper.CountSelectedMediaItems(0)
    local items = {}
    
    for i = 0, iC - 1 do -- get all sel items
      items[i] = reaper.GetSelectedMediaItem(0, i)
    end
    
    for i = 0, iC - 1 do
      if i > 0 then --if this is not first iteration
        local it = items[i]
        local prevIt = items[i-1]
        local itTr = reaper.GetMediaItemTrack(it)
        local prevItTr = reaper.GetMediaItemTrack(prevIt)
        
        -- only continue if item is not the first in selection on its track
        -- if the track of this item is equal to the track of the previous item, not first item on track
        
        
        if itTr == prevItTr then
        
          reaper.Main_OnCommand(40289, 0) -- unselect all items
 
          reaper.SetMediaItemSelected(it, true) -- select the current item per iteration
          reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELPREVITEM"), 0) -- select previous item
          reaper.ApplyNudge(0, 0, 3, unit, val, reverse, 0) -- nudge right trim with set params
        
          reaper.Main_OnCommand(40289, 0) -- unselect all items
          reaper.SetMediaItemSelected(it, true) -- select the current item per iteration
          reaper.ApplyNudge(0, 0, 1, unit, val, reverse, 0) -- nudge left trim with set params
        end
      end
    end
    
    reaper.Main_OnCommand(40289, 0) -- unselect all items
    
    for i = 0, iC - 1 do
      
      reaper.SetMediaItemSelected(items[i], true) -- reselect all items
    end
    
end

function envNudge(unit, val, reverse)
  local env =  reaper.GetSelectedEnvelope( 0 )
  if not env then return end

-- LOCAL FUNCTIONS
  local function saveSelectedItems () -- zero-indexed table of items as output
    local items = {}
    for i = 0, reaper.CountSelectedMediaItems(0) - 1 do 
      items[i] = reaper.GetSelectedMediaItem(0, i)
    end
    return items
  end

  local function setItemsSelected (itemsT) -- zero-indexed table of items as input
    for i = 0, #itemsT do
      local item = itemsT[i]
      if reaper.ValidatePtr(item, "MediaItem*") then
        reaper.SetMediaItemSelected(item, true)
      end
    end
  end

  -- new method using cut/paste - clears clipboard
  local items = saveSelectedItems()
  local pos1 = reaper.GetCursorPosition() -- original edit cursor pos
  --local origL, origR = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- original time selection

  local tempPos
  local lastPoint
  -- find the leftmost point in point selection
  for j = -1, reaper.CountAutomationItems(env) - 1 do -- automation item id -1 is underlying envelope
    for k = 0, reaper.CountEnvelopePointsEx(env, j) do
      local retval, time, _, _, _, selected = reaper.GetEnvelopePointEx( env, j, k )
      if retval and selected then
        if not tempPos then
          tempPos = time
          lastPoint = time
        else
          tempPos = math.min(tempPos, time)
          lastPoint = math.max(lastPoint, time)
        end
      end
    end
  end
  if not (tempPos or lastPoint) then return end

  --reaper.GetSet_LoopTimeRange2(0, true, false, tempPos, lastPoint, false) -- set to point selection
  --reaper.Main_OnCommand(40726, 0) -- 4 points at time selection

  reaper.SetEditCurPos2(0, tempPos, false, false) -- go to leftmost point
  reaper.Main_OnCommand(40336, 0) -- cut selected points

  reaper.ApplyNudge(0, 0, 6, unit, val, reverse, 0) -- nudge edit cursor
  reaper.Main_OnCommand(42398, 0) -- paste points


  reaper.SetEditCurPos(pos1, false, false) -- reset pos
  setItemsSelected(items)
  reaper.CF_SetClipboard( '' ) -- clear clipboard, prevent unwanted pasting of points later
  --reaper.GetSet_LoopTimeRange2(0, true, false, origL, origR, false) -- reset time selection
end

function smartNudge(what, unit, val, copies, reverse)

  what = what:lower()
  unit = unit:lower()
  local whats = { -- store value for each name as keys for a table for easier recall of values
    position = 0,
    pos = 0,
    lefttrim = 1,
    leftedge = 2,
    rightedge = 3,
    contents = 4,
    content = 4,
    cont = 4,
    duplicate = 5,
    dup = 5,
    editcursor = 6,
    cursor = 6,
    edit = 6,
    crossfade = 7,
    crossf = 7,
    cross = 7,
    xfade = 7,
    x = 7,
    envelopepoints = 8,
    envelope = 8,
    envpoints = 8,
    env = 8,
    points = 8,
    automation = 8,
    auto = 8
    }

  local units = {
    ms = 0,
    s = 1,
    grid = 2,
    gridunits = 2,
    gridunit = 2,
    beats = 13,
    bars = 16,
    bar = 16,
    measures = 16,
    measure = 16,
    takter = 16,
    takt = 16,
    samples = 17,
    samps = 17,
    samp = 17,
    smp = 17,
    frames = 18,
    frame = 18,
    frams = 18,
    fram = 18,
    itemsels = 21,
    items = 21
  }
  
  if whats[what] < 7 then -- if not crossfade nudge
    reaper.ApplyNudge(0, 0, whats[what], units[unit], val, reverse, copies)
  elseif whats[what] == 7 then -- if crossfade nudge
    crossfadeNudge(units[unit], val, reverse)
  elseif whats[what] == 8 then -- if envelope nudge
    envNudge(units[unit], val, reverse)
  end
end




----- END OF USEFUL FUNCTIONS


function main()
  reaper.Undo_BeginBlock()
  
  if not reaper.HasExtState("phoi_SmartNudge", "vals_CSV") or not settingValMult or settingReverse == nil then return end
  
  local vals = fromCSV(reaper.GetExtState("phoi_SmartNudge", "vals_CSV"), "all")
  local what, unit, val, copies = vals[1], vals[2], vals[3], vals[4]
  smartNudge(what, unit, tonumber(val) * settingValMult, copies, settingReverse)
  

  if settingValMult ~= 1 then val = tostring(tonumber(val) * settingValMult) end
  local decPoint = val:find("%.")
  if decPoint then val = val:sub(0, decPoint + 1) end

  local s = ''
  if tonumber(val) > 1 and unit:sub(-1) ~= 's' then s = 's' end -- append 's' to unit name if appropriate
  local dir = 'right'
  if settingReverse then dir = 'left' end
  scriptName = "Nudge " .. what .. " " .. val .. " " .. unit .. s .. " to the " .. dir
  if what:find('dup') then
    scriptName = scriptName .. ", creating " .. copies .. " copies"
  end
  reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()