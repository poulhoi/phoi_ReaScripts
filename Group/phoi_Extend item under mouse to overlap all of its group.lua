--[[
@description phoi_Extend item under mouse to overlap all of its group
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local scriptName = "phoi_Extend item under mouse to overlap all of its group"

function unselectAllItems()
	while reaper.CountSelectedMediaItems(0) > 0 do
		reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(0, 0), false)
	end
end

function selectItemsFromTable(t)
	unselectAllItems()
	for i = 1, #t do
		reaper.SetMediaItemSelected(t[i], true)
	end
end

function main()
	reaper.Undo_BeginBlock()

	--save selected items
	local items = {}
	for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
		items[#items+1] = reaper.GetSelectedMediaItem(0, i)
	end

	--unselect all items
	unselectAllItems()
	
	-- get item under mouse
	local mainItem, _ = reaper.BR_ItemAtMouseCursor()
	if not mainItem then return end
	reaper.SetMediaItemSelected(mainItem, true)
	
	if not mainItem then -- abort if no item under mouse
		selectItemsFromTable(items)
		return
	end
	
	reaper.Main_OnCommandEx(40034, 0, 0) --select all items in groups
	groupCount = reaper.CountSelectedMediaItems(0)
	
	local minPos, maxEnd
	for i = 0, groupCount - 1, 1 do -- for each item in the group
	
		local item = reaper.GetSelectedMediaItem(0, i)
		local curPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		local curEnd = curPos + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		
		
		if i == 0 then -- if this is first iteration
			minPos = curPos
			maxEnd = curEnd
		else -- else compare with previous value and find minimum/maximum
			minPos = math.min(minPos, curPos)
			maxEnd = math.max(maxEnd, curEnd)
		end
		
	end

	local mainItemPos = reaper.GetMediaItemInfo_Value(mainItem, "D_POSITION")
	local mainItemEnd = mainItemPos + reaper.GetMediaItemInfo_Value(mainItem, "D_LENGTH")

	local mainLen = maxEnd - minPos
	reaper.SetMediaItemInfo_Value(mainItem, "D_POSITION", minPos)
	reaper.SetMediaItemInfo_Value(mainItem, "D_LENGTH", mainLen)
	
	-- correct offsets, i.e content remains in place
	for i = 0, reaper.CountTakes(mainItem) - 1 do
		local take = reaper.GetTake(mainItem, i)
		local curOffset = reaper.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')
		local adj = minPos - mainItemPos
		reaper.SetMediaItemTakeInfo_Value(take, 'D_STARTOFFS', curOffset + adj)
	end	
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()