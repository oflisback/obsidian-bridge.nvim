local M = {}
local config = require("obsidian-bridge.config")
local uri = require("obsidian-bridge.uri")
local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local telescope_conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"


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
            else
                return decoded
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

M.execute_command = function(final_config, api_key, method, command)
	local server_address = final_config.obsidian_server_address
	local url = uri.EncodeURI(server_address .. "/commands/" .. command)
	local authToken = "Bearer " .. api_key
	return M.make_api_call(
		'curl -s -X ' .. method..' -H "Content-Type: application/json" -H "Authorization: ' .. authToken .. '" ' .. url
	)
end

M.telescope_command = function(final_config, api_key)
	local server_address = final_config.obsidian_server_address
	local url = uri.EncodeURI(server_address .. "/commands/")
	local authToken = "Bearer " .. api_key
	local commands = M.make_api_call(
		'curl -s -X GET -H "Content-Type: application/json" -H "Authorization: ' .. authToken .. '" ' .. url
	)
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
        pickers.new(opts, {
            prompt_title = "colors",
            finder = finders.new_table {
                results = command_names
            },
            sorter = telescope_conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()
                    url = url..command_name_id_map[selection[1]]
                    M.make_api_call(
                    'curl -s -X POST -H "Content-Type: application/json" -H "Authorization: ' .. authToken .. '" ' .. url
                    )
                end)
                return true
            end,
        }):find()
    end
    obsidian_commands(require("telescope.themes").get_dropdown{})
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
