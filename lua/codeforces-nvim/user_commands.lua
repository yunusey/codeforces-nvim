local codeforces = require("codeforces-nvim.codeforces")
local commands = require("codeforces-nvim.commands")

local M = {}

--- @param jump integer
--- Jumps to the next `jump`-th question - most of the time, jump = 1 (if called `:QNext`)
M.next_question = function(jump)
    -- Lua is 1-indexed :D
    codeforces.current_problem = (codeforces.current_problem + jump - 1) % #codeforces.problems + 1
    local solution_file = codeforces.get_solution_file(
        codeforces.problems[codeforces.current_problem],
        codeforces.options.extension
    )
    vim.cmd(":tabnew" .. solution_file)
    vim.api.nvim_win_set_cursor(0, { codeforces.options.lines[codeforces.options.extension], 0 })
end

--- Creates all the user commands used by the plugin
M.user_commands = function()
    vim.api.nvim_create_user_command("EnterContest", function(args)
        local contest = args["args"]
        codeforces.enter_contest(contest)
    end, { nargs = "?" })
    vim.api.nvim_create_user_command("QNext", function(args)
        local jump = args["args"]
        if jump == nil or jump == "" then
            M.next_question(1)
        else
            M.next_question(jump)
        end
    end, { nargs = "?" })
    vim.api.nvim_create_user_command("TestCurrent", function()
        commands.test_problem(codeforces.problems[codeforces.current_problem])
    end, {})
    vim.api.nvim_create_user_command("RunCurrent", function()
        commands.run_normally(codeforces.problems[codeforces.current_problem])
    end, {})
    vim.api.nvim_create_user_command("CreateTestCase", function()
        commands.create_custom_test_case(codeforces.problems[codeforces.current_problem])
    end, {})
    vim.api.nvim_create_user_command("RetrieveLastTestCase", function()
        commands.run_custom_test(codeforces.problems[codeforces.current_problem])
    end, {})
end

return M
