local codeforces = require("codeforces-nvim.codeforces")
local setup      = require("codeforces-nvim.setup")
local user_commands   = require("codeforces-nvim.user_commands")

local M = {}

-- Everything in setup should be in the returned object.
for i in pairs(setup) do
	M[i] = setup[i]
end

-- We don't need the setup objects, so we are taking only the ones we need.
M.user_commands     = user_commands.user_commands
M.enterContest      = codeforces.enterContest
M.getCurrentContest = codeforces.getCurrentContest
M.getTest           = codeforces.getTest

return M
