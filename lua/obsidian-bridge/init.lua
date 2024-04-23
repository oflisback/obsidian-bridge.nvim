local api = vim.api
local commands = require("obsidian-bridge.commands")
local config = require("obsidian-bridge.config")
local network = require("obsidian-bridge.network")

local M = {}

local configuration = nil

api.nvim_create_augroup("obsidian-bridge.nvim", {
	clear = true,
})

local function is_obsidian_vault(path)
	local current_path = vim.fn.expand(path)
	while current_path ~= "/" do
		local obsidian_folder = current_path .. "/.obsidian"
		if vim.fn.isdirectory(obsidian_folder) == 1 then
			return true
		end
		current_path = vim.fn.fnamemodify(current_path, ":h")
	end
	return false
end

local function get_active_buffer_obsidian_markdown_filename()
	local bufnr = vim.api.nvim_get_current_buf()
	local filename_incl_path = vim.api.nvim_buf_get_name(bufnr)
	if filename_incl_path == nil or string.sub(filename_incl_path, -3) ~= ".md" then
		return nil
	end

	if vim.fn.has("win32") then
		filename_incl_path = string.gsub(filename_incl_path, "\\", "/")
	end

	local path = vim.fn.fnamemodify(filename_incl_path, ":p:h")
	if not is_obsidian_vault(path) then
		return nil
	end

	return string.match(filename_incl_path, ".+/(.+)$")
end

local function on_buf_enter()
	local filename = get_active_buffer_obsidian_markdown_filename()
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
	if get_active_buffer_obsidian_markdown_filename() == nil then
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

function M.setup(user_config)
	configuration = config.get_final_config(user_config)
	local api_key = config.get_api_key()

	if api_key ~= nil then
		commands.register(configuration, api_key)
	end

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
