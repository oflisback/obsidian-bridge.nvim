local M = {}
local config = require("obsidian-bridge.config")
local curl = require("plenary.curl")
local uri = require("obsidian-bridge.uri")

local make_api_call = function(final_config, api_key, path, json_body)
	local url = final_config.obsidian_server_address .. path
	local body = json_body and vim.fn.json_encode(json_body) or nil

	curl.post(url, {
		body = body,
		callback = function(out)
			vim.schedule(function()
				if vim.fn.json_decode(out.body).errorCode == 40101 then
					vim.api.nvim_err_writeln(
						"Error: authentication error, please check your " .. config.api_key_env_var_name .. " value."
					)
				end
			end)
		end,
		on_error = function(res)
			-- Ignore other errors for now, for instance if we can't contact obsidian server it's
			-- not running, that's often times probably intentional.
			print(res.message)
		end,
		headers = {
			content_type = "application/json",
			Authorization = "Bearer " .. api_key,
		},
	})
end

M.scroll_into_view = function(line, final_config, api_key)
	local json_body = {
		center = true,
		range = {
			from = { ch = 0, line = line },
			to = { ch = 0, line = line },
		},
	}

	local path = uri.EncodeURI("/editor/scroll-into-view")
	make_api_call(final_config, api_key, path, json_body)
end

M.execute_command = function(final_config, api_key, command)
	local path = uri.EncodeURI("/commands/" .. command)
	make_api_call(final_config, api_key, path)
end

M.open_in_obsidian = function(filename, final_config, api_key)
	local path = uri.EncodeURI("/open/" .. filename)
	make_api_call(final_config, api_key, path)
end

return M
