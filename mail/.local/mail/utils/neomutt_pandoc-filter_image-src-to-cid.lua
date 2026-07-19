--[[
image-src-to-cid
• pandoc filter
• converts image sources to Content-IDs (cids)
• created for use by script 'neomutt_multipart-convert'
• to ensure predictability the cids are produced by md5sum

Copyright © 2026 David Nebauer

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

function Image(el)
	src = el.src
	-- no need to handle tilde at start of 'src' -
	-- although that would cause this 'md5sum' command to fail if run
	-- at a bash prompt, it works fine when run through 'io.popen'
	cmd = "md5sum " .. src .. "|cut -d ' ' -f 1"
	handle = io.popen(cmd, "r")
	cid = handle:read("*a")
	handle:close()
	el.src = "cid:" .. cid
	return el
end
