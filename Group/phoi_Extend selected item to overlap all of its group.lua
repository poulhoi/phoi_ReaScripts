--[[
@description phoi_Extend selected item to overlap all of its group
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

local scriptName = "phoi_Extend selected item to overlap all of its group"

function msg(msg)
	reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

function unselectAllItems()
	while reaper.CountSelectedMediaItems(0) > 0 do
		reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(0, 0), false)
	end
end

function main()
	reaper.Undo_BeginBlock()
	local itemCount = reaper.CountSelectedMediaItems(0)
	
	if itemCount == 0 then return end
	
	local items = {}
	
	for j = 0, itemCount - 1, 1 do 
		items[j] = reaper.GetSelectedMediaItem(0, j)
	end
	
	for k = 0, itemCount - 1, 1 do
		mainItem = items[k]
		
		--unselect all items
		unselectAllItems()
		reaper.SetMediaItemSelected(mainItem, true) -- select only the current item
		reaper.Main_OnCommandEx(40034, 0, 0) --select all items in groups
	
		local groupCount = reaper.CountSelectedMediaItems(0)
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

		reaper.SetMediaItemInfo_Value(mainItem, "D_POSITION", minPos)
		reaper.SetMediaItemInfo_Value(mainItem, "D_LENGTH", maxEnd - minPos)
		
		-- correct offsets, i.e content remains in place
		for i = 0, reaper.CountTakes(mainItem) - 1 do
			local take = reaper.GetTake(mainItem, i)
			local curOffset = reaper.GetMediaItemTakeInfo_Value(take, 'D_STARTOFFS')
			local adj = minPos - mainItemPos
			reaper.SetMediaItemTakeInfo_Value(take, 'D_STARTOFFS', curOffset + adj)
		end	
	
	end
	reaper.Undo_EndBlock(scriptName, -1)
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()