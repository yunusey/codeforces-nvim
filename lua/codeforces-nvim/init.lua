local codeforces    = require("codeforces-nvim.codeforces")
local setup         = require("codeforces-nvim.setup")
local user_commands = require("codeforces-nvim.user_commands")

local M = {
	user_commands = user_commands.user_commands,
	enter_contest = codeforces.enter_contest,
	get_current_contest = codeforces.get_current_contest,
	get_test = codeforces.get_test
}

for _, i in ipairs(setup) do
	M[i] = setup[i]
end
M.setup = setup.setup

return M
