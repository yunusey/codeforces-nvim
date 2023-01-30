local setup       = require('codeforces-nvim.setup')
local codeforces  = require('codeforces-nvim.codeforces')
local commands    = require('codeforces-nvim.commands')

local M = {}

for i in pairs(setup) do
	M[i] = setup[i]
end

M.enterContest = codeforces.enterContest

M.openExplorer = function (contest)
	if contest == nil or contest == '' then
		vim.fn.jobstart({"explorer.exe", '"' .. M.linux_cf_path .. '"'})
	else
		vim.fn.jobstart({"explorer.exe", '"' .. M.linux_test_path .. '\\' .. contest .. '"'})
	end
end

M.nextQuestion = function (jump)
	codeforces.current_problem = codeforces.current_problem % #codeforces.problems + jump % #codeforces.problems
	vim.cmd(":tabnew" .. codeforces.getFile(codeforces.problems[codeforces.current_problem]))
	vim.cmd(":" .. setup.line)
end

M.user_commands = function ()
	-- Main command 
	vim.api.nvim_create_user_command("EnterContest", function (args)
		local contest = args["args"]
		M.enterContest(contest)
	end, {nargs = "?"})
	-- Explorer commands 
	vim.api.nvim_create_user_command("ExplorerCF", function (args)
		local contest = args["args"]
		M.openExplorer(contest)
	end, {nargs = "?"})
	vim.api.nvim_create_user_command("ExplorerCFForCurrent", function ()
		local current_contest = codeforces.getCurrentContest()
		if current_contest == nil then
			print("You haven't created a contest yet! Run \":EnterContest\"")
		else
			M.openExplorer(current_contest)
		end
	end, {})
	-- Question commands
	vim.api.nvim_create_user_command("QNext", function (args)
		local jump = args["args"]
		if jump == nil or jump == "" then
			M.nextQuestion(1)
		else
			M.nextQuestion(jump)
		end
	end, {nargs = "?"})
	-- Test commands
	vim.api.nvim_create_user_command("TestCurrent", function ()
		commands.testProblem(codeforces.problems[codeforces.current_problem])
	end, {})
	vim.api.nvim_create_user_command("RunCurrent", function ()
		commands.runNormally(codeforces.problems[codeforces.current_problem])
	end, {})
	vim.api.nvim_create_user_command("CreateTestCase", function ()
		commands.createTestCase(codeforces.problems[codeforces.current_problem])
	end, {})
	vim.api.nvim_create_user_command("RetrieveLastTestCase", function ()
		commands.retrieveLastTestCase(codeforces.problems[codeforces.current_problem])
	end, {})

end

return M
