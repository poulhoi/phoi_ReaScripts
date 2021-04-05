--[[
@description phoi_Make track color brighter
@author Poul Høi
@links 
	Repository https://github.com/poulhoi/phoi_ReaScripts
@version 1.0
@changelog Initial release
--]]

-- CONFIG
local l_increment = 0.075 -- change value to affect track colors in different increments

-- Thanks to X-Raym for the following color conversion functions


-- Mod from https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
function hue2rgb(p, q, t)
	if t < 0 then t = t + 1 end
	if t > 1 then t = t - 1 end
	if t < 1/6 then return p + (q - p) * 6 * t end
	if t < 1/2 then return q end
	if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
	return p
end

--[[
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param	 Number	r			 The red color value
 * @param	 Number	g			 The green color value
 * @param	 Number	b			 The blue color value
 * @return	Array					 The HSL representation
]]
function rgbToHsl(r, g, b)
	r, g, b = r / 255, g / 255, b / 255

	local max, min = math.max(r, g, b), math.min(r, g, b)
	local h, s, l

	l = (max + min) / 2

	if max == min then
		h, s = 0, 0 -- achromatic
	else
		local d = max - min
		if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
		if max == r then
			h = (g - b) / d
			if g < b then h = h + 6 end
		elseif max == g then h = (b - r) / d + 2
		elseif max == b then h = (r - g) / d + 4
		end
		h = h / 6
	end

	return h, s, l or 255
end

--[[
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param	 Number	h			 The hue
 * @param	 Number	s			 The saturation
 * @param	 Number	l			 The lightness
 * @return	Array					 The RGB representation
]]
function hslToRgb(h, s, l)
	local r, g, b

	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else

		local q
		if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
		local p = 2 * l - q

		r = hue2rgb(p, q, h + 1/3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1/3)
	end
	r = math.floor((r * 255) + 0.5)
	g = math.floor((g * 255) + 0.5)
	b = math.floor((b * 255) + 0.5)
	return r, g, b
end

function main()
	local trackCount = reaper.CountSelectedTracks(0)
	for i = 0, trackCount - 1, 1 do
		local track = reaper.GetSelectedTrack(0, i)
		local prevColorNative = reaper.GetTrackColor(track)
		local prevColorR, prevColorG, prevColorB = reaper.ColorFromNative(prevColorNative)
		local prevColorH, prevColorS, prevColorL = rgbToHsl(prevColorR, prevColorG, prevColorB)
		local newColorL = math.min(prevColorL + l_increment, 1.0)
		local newColorNative = reaper.ColorToNative(hslToRgb(prevColorH, prevColorS, newColorL))
		reaper.SetTrackColor(track, newColorNative)
	end
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()