local config = require("obsidian-bridge.config")
local event_handlers = require("obsidian-bridge.event_handlers")
local network = require("obsidian-bridge.network")
local utils = require("obsidian-bridge.utils")

local M = {}

local function echo_status(status)
	vim.api.nvim_echo({ { status, "InfoMsg" } }, false, {})
end

M.register = function(configuration, api_key)
	local function execute_if_active(fn)
		if config.on then
			fn()
		else
			echo_status("obsidian-bridge is turned off, activate with :ObsidianBridgeOn")
		end
	end

	function ObsidianBridgeDailyNote()
		execute_if_active(function()
			network.execute_command(configuration, api_key, "POST", "daily-notes")
			vim.cmd(":ObsidianBridgeOpenCurrentActiveFile")
		end)
		-- would be neat if it also opened daily note
	end

	vim.cmd("command! ObsidianBridgeDailyNote lua ObsidianBridgeDailyNote()")

	function ObsidianBridgePickCommand()
		execute_if_active(function()
			network.pick_command(configuration, api_key)
		end)
	end

	vim.cmd("command! ObsidianBridgePickCommand lua ObsidianBridgePickCommand()")

	function ObsidianBridgeOpenGraph()
		execute_if_active(function()
			network.execute_command(configuration, api_key, "POST", "graph:open")
		end)
	end

	vim.cmd("command! ObsidianBridgeOpenGraph lua ObsidianBridgeOpenGraph()")

	function ObsidianBridgeOpenVaultMenu()
		execute_if_active(function()
			network.execute_command(configuration, api_key, "POST", "app:open-vault")
		end)
	end

	vim.cmd("command! ObsidianBridgeOpenVaultMenu lua ObsidianBridgeOpenVaultMenu()")

	function ObsidianBridgeOn()
		if not config.on then
			echo_status("obsidian-bridge activated")
			config.on = true
			event_handlers.on_buf_enter()
		end
	end

	vim.cmd("command! ObsidianBridgeOn lua ObsidianBridgeOn()")

	function ObsidianBridgeOff()
		if config.on then
			echo_status("obsidian-bridge deactivated")
			config.on = false
		end
	end

	vim.cmd("command! ObsidianBridgeOff lua ObsidianBridgeOff()")

	function ObsidianBridgeToggle()
		if config.on then
			ObsidianBridgeOff()
		else
			ObsidianBridgeOn()
		end
	end

	vim.cmd("command! ObsidianBridgeToggle lua ObsidianBridgeToggle()")

	function ObsidianBridgeOpenCurrentActiveFile()
		execute_if_active(function()
			local headers = network.make_api_call_get_request_headers(configuration, api_key, "HEAD", "/active/")
			local contentLocation = headers["Content-Location"] and headers["Content-Location"][1]
			if not contentLocation then
				vim.notify("Content-Location header not found", vim.log.levels.ERROR)
				return
			end

			local decodedLocation = utils.DecodeURI(contentLocation)
			local joinedPathToOpen = utils.pathJoin(utils.getVaultPath(), decodedLocation)

			if not (vim.uv or vim.loop).fs_stat(joinedPathToOpen) then
				vim.notify("File does not exist: " .. joinedPathToOpen, vim.log.levels.ERROR)
				return
			end

			vim.cmd("e " .. vim.fn.fnameescape(joinedPathToOpen))
		end)
	end

	vim.cmd("command! ObsidianBridgeOpenCurrentActiveFile lua ObsidianBridgeOpenCurrentActiveFile()")
end

return M
