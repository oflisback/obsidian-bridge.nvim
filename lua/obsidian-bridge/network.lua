local M = {}
local config = require("obsidian-bridge.config")
local curl = require("plenary.curl")
local uri = require("obsidian-bridge.uri")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local telescope_conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local make_api_call = function(final_config, api_key, path, json_body)
	local url = final_config.obsidian_server_address .. path
	local body = json_body and vim.fn.json_encode(json_body) or nil

	curl.post(url, {
		body = body,
		callback = function(res)
			vim.schedule(function()
				if res.body and res.body ~= "" then
					local decoded = vim.fn.json_decode(res.body)
					if decoded and decoded.errorCode == 40101 then
						vim.api.nvim_err_writeln(
							"Error: authentication error, please check your "
								.. config.api_key_env_var_name
								.. " value."
						)
					end
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

M.telescope_command = function(final_config, api_key)
	local commands = M.execute_command(final_config, api_key, "GET", "")
	if commands == nil or commands.commands == nil then
		vim.notify("Get commands list failed")
		return
	end
	commands = commands.commands
	local command_name_id_map = {}
	local command_names = {}
	for _, command in pairs(commands) do
		command_name_id_map[command.name] = command.id
		table.insert(command_names, command.name)
	end

	local obsidian_commands = function(opts)
		opts = opts or {}
		pickers
			.new(opts, {
				prompt_title = "Obsidian Commands",
				finder = finders.new_table({
					results = command_names,
				}),
				sorter = telescope_conf.generic_sorter(opts),
				attach_mappings = function(prompt_bufnr, map)
					actions.select_default:replace(function()
						actions.close(prompt_bufnr)
						local selection = action_state.get_selected_entry()
						M.execute_command(final_config, api_key, "POST", command_name_id_map[selection[1]])
					end)
					return true
				end,
			})
			:find()
	end
	obsidian_commands(require("telescope.themes").get_dropdown({}))
end

M.open_in_obsidian = function(filename, final_config, api_key)
	local path = uri.EncodeURI("/open/" .. filename)
	make_api_call(final_config, api_key, path)
end

return M
