local config = require("obsidian-bridge.config")
local network = require("obsidian-bridge.network")
local utils = require("obsidian-bridge.utils")

local M = {}

function escape_lua_pattern(s)
	return s:gsub("(%W)", "%%%1")
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

	local path = vim.fn.fnamemodify(filename_incl_path, ":p")
	local vault_name = utils.getVaultName(path)
	if not vault_name then
		return nil
	end

	return filename_incl_path:match(".*/" .. escape_lua_pattern(vault_name) .. "/(.*)")
end

function M.on_buf_enter()
	if not config.on then
		return
	end

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
		network.open_in_obsidian(filename, config.final_config, api_key)
	end
end

function M.on_cursor_moved()
	if not config.on then
		return
	end

	if get_active_buffer_obsidian_markdown_filename() == nil then
		return
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local line = cursor[1]

	if vim.b.prev_line == nil or line ~= vim.b.prev_line then
		local api_key = config.get_api_key()
		if api_key ~= nil then
			network.scroll_into_view(line, config.final_config, api_key)
			vim.b.prev_line = line
		end
	end
end

return M
