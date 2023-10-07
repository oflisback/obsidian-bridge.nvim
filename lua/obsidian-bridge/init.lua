local api = vim.api
local config = require("obsidian-bridge.config")
local network = require("obsidian-bridge.network")
local obsidianUtil = require("obsidian.util")

local M = {}

local configuration = nil

api.nvim_create_augroup("obsidian-bridge.nvim", {
	clear = true,
})

local function get_active_buffer_markdown_filename()
	local bufnr = vim.api.nvim_get_current_buf()
	local filename_incl_path = vim.api.nvim_buf_get_name(bufnr)
	if filename_incl_path == nil or string.sub(filename_incl_path, -3) ~= ".md" then
		return nil
	end
	return string.match(filename_incl_path, ".+/(.+)$")
end

local function on_buf_enter()
	local filename = get_active_buffer_markdown_filename()
	if filename == nil then
		return
	end

	-- Reset prev_line when we swap buffers, we can't be sure that we
	-- can skip scrolling, setting to nil to make sure we always scroll on
	-- first vertical cursor movement.
	vim.b.prev_line = nil

	local api_key = config.get_api_key()
	if api_key ~= nil then
		network.open_in_obsidian(filename, configuration, api_key)
	end
end

local function on_cursor_moved()
	if get_active_buffer_markdown_filename() == nil then
		return
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local line = cursor[1]

	if vim.b.prev_line == nil or line ~= vim.b.prev_line then
		local api_key = config.get_api_key()
		if api_key ~= nil then
			network.scroll_into_view(line, configuration, api_key)
			vim.b.prev_line = line
		end
	end
end

function M.open_note(vault_dir, note_name)
	local notes = obsidianUtil.find_note(vault_dir, note_name)
	if #notes > 0 then
		local path = notes[1]
		vim.api.nvim_command("e " .. tostring(path))
		return true
	end
	return false
end

function M.setup(user_config)
	configuration = config.get_final_config(user_config)

	function ObsidianBridgeDailyNote()
		local api_key = config.get_api_key()
		if api_key ~= nil then
			network.execute_command(configuration, api_key, "daily-notes")
			-- Assuming daily note format: YYYY-MM-DD
			-- If obsidian.nvim is available, open the daily note. Check at runtime.
			if obsidianUtil ~= nil then
				local note_name = os.date("%Y-%m-%d") .. ".md"
				-- See if we can use
				local success = M.open_note(configuration.vault_dir, note_name)
				if not success then
					-- didn't find the new note, wait for x ms and try again
					M.open_note(configuration.vault_dir, note_name)
				end
			end
		end
	end

	-- Register the command
	vim.cmd("command! ObsidianBridgeDailyNote lua ObsidianBridgeDailyNote()")

	function ObsidianBridgeOpenGraph()
		local api_key = config.get_api_key()
		if api_key ~= nil then
			network.execute_command(configuration, api_key, "graph:open")
		end
	end
	-- Register the command
	vim.cmd("command! ObsidianBridgeOpenGraph lua ObsidianBridgeOpenGraph()")

	api.nvim_create_autocmd("BufEnter", {
		callback = on_buf_enter,
		pattern = "*",
		group = "obsidian-bridge.nvim",
	})

	if configuration.scroll_sync then
		api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			callback = on_cursor_moved,
			pattern = "*",
			group = "obsidian-bridge.nvim",
		})
	end

	return M
end

return M
