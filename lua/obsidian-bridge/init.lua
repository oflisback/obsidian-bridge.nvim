local api = vim.api
local commands = require("obsidian-bridge.commands")
local config = require("obsidian-bridge.config")
local event_handlers = require("obsidian-bridge.event_handlers")

local M = {}

api.nvim_create_augroup("obsidian-bridge.nvim", {
	clear = true,
})

function M.setup(user_config)
	config.create_final_config(user_config)
	local api_key = config.get_api_key()

	if api_key ~= nil then
		commands.register(config.final_config, api_key)
	end

	api.nvim_create_autocmd("BufEnter", {
		callback = event_handlers.on_buf_enter,
		pattern = "*",
		group = "obsidian-bridge.nvim",
	})

	if config.final_config.scroll_sync then
		api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			callback = event_handlers.on_cursor_moved,
			pattern = "*",
			group = "obsidian-bridge.nvim",
		})
	end

	return M
end

return M
