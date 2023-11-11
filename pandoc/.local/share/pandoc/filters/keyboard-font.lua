--[[
keyboard-font – change font of text flagged with the 'font=kbd' attribute

Copyright © 2023 David Nebauer

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]
-- luacheck: ignore 111 113
---@diagnostic disable:undefined-global, lowercase-global

-- requires: font 'Linux Biolinum Keyboard O'
--           (provided by debian package 'fonts-linuxlibertine')

function Span(el)
	font = el.attributes["font"]

	-- return unchanged unless font set to 'kbd'
	if font == nil or font ~= "kbd" then
		return nil
	end

	-- {html,epub}: transform attribute to:
	--              <span style="..."></span>
	if FORMAT:match("html") or FORMAT:match("epub") then
		-- remove font attribute
		el.attributes["font"] = nil
		-- use style attribute instead
		el.attributes["style"] = "font-family: 'Linux Biolinum Keyboard O';"
			.. "border-radius: revert;"
			.. "font-size: revert;"
			.. "background-color: revert;"
			.. "padding: revert;"
		-- return full span element
		return el

	-- latex/pdf: transform element to:
	--            \textmykbdfont{content}
	elseif FORMAT:match("latex") then
		-- remove font attribute
		el.attributes["font"] = nil
		-- encapsulate in latex code
		table.insert(el.content, 1, pandoc.RawInline("latex", "\\textmykbdfont{"))
		table.insert(el.content, pandoc.RawInline("latex", "}"))
		return el.content

	-- other format: return unchanged
	else
		return nil
	end
end
