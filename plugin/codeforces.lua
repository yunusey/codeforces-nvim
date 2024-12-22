--- This file just loads the plugin - executed by Lazy, Packer, etc.

local codeforces = require('codeforces-nvim')
codeforces.user_commands() -- load the user commands (`EnterContest`, etc.)
