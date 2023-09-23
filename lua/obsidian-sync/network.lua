local M = {}
local config = require("obsidian-sync.config")
local uri = require("obsidian-sync.uri")

M.make_api_call = function(request)
	local handle = io.popen(request)
	if handle ~= nil then
		local result = handle:read("*a")
		handle:close()
		if result ~= nil and result ~= "" then
			local decoded = vim.json.decode(result)
			-- Ignore other errors for now, for instance if we can't contact obsidian server it's
			-- not running, that's often times probably intentional.
			if decoded.errorCode == 40101 then
				vim.api.nvim_err_writeln(
					"Error: authentication error, please check your " .. config.api_key_env_var_name .. " value."
				)
			end
		end
	end
end

M.scroll_into_view = function(line, final_config, api_key)
	local server_address = final_config.obsidian_server_address
	local url = server_address .. "/editor/scroll-into-view"
	local authToken = "Bearer " .. api_key

	local data = '--data \'{ "center": '
		.. "true"
		.. ', "range": { "from": { "ch": 0, "line": '
		.. line
		.. ' }, "to": { "ch": 0, "line": '
		.. line
		.. " }}}' "

	local request = 'curl -s -X POST -H "Content-Type: application/json" -H "Authorization: '
		.. authToken
		.. '" '
		.. data
		.. url

	M.make_api_call(request)
end

M.open_in_obsidian = function(filename, final_config, api_key)
	local server_address = final_config.obsidian_server_address
	local url = uri.EncodeURI(server_address .. "/open/" .. filename)
	local authToken = "Bearer " .. api_key
	M.make_api_call(
		'curl -s -X POST -H "Content-Type: application/json" -H "Authorization: ' .. authToken .. '" ' .. url
	)
end

return M
