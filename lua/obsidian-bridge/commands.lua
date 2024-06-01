local network = require("obsidian-bridge.network")

local M = {}

M.register = function(configuration, api_key)
	function ObsidianBridgeDailyNote()
		network.execute_command(configuration, api_key, "daily-notes")
		-- would be neat if it also opened daily note
	end
	vim.cmd("command! ObsidianBridgeDailyNote lua ObsidianBridgeDailyNote()")
	function ObsidianBridgeTelescopeCommand()
		network.telescope_command(configuration, api_key)
	end
	vim.cmd("command! ObsidianBridgeTelescopeCommand lua ObsidianBridgeTelescopeCommand()")

	function ObsidianBridgeOpenGraph()
		network.execute_command(configuration, api_key, "graph:open")
	end
	vim.cmd("command! ObsidianBridgeOpenGraph lua ObsidianBridgeOpenGraph()")

	function ObsidianBridgeOpenVaultMenu()
		network.execute_command(configuration, api_key, "app:open-vault")
	end
	vim.cmd("command! ObsidianBridgeOpenVaultMenu lua ObsidianBridgeOpenVaultMenu()")
end

return M
