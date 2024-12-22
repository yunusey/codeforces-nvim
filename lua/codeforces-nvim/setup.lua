local M = {
	options = {
		--- @type string
		--- The path to the Codeforces directory
		cf_path = vim.fs.joinpath(vim.fn.getenv("HOME"), "codeforces"),

		--- @type string
		--- The path to the Codeforces extractor directory (default: `codeforces-extractor`)
		--- You don't need to modify this if it is on your `PATH`
		extractor_path = 'codeforces-extractor',

		--- @type string
		--- The extension of the language you would like to use
		extension = 'cpp',

		--- @type table
		--- When opened a new tab with the current problem, it will place your cursor
		--- at this line - useful if you have a ton of functions above your main method
		lines = {
			cpp = 6,
			py = 3
		},

		--- @type integer
		--- The timeout for the run command (in milliseconds)
		timeout = 15000,

		--- @type table
		--- The commands to compile and run the given problem
		--- You can use `@` as a placeholder for the current problem
		compiler = {
			py = {},
			cpp = { "g++", "@.cpp", "-o", "@" }
		},

		--- @type table
		--- The run command to run for each language. It will treat `@` symbols
		--- as placeholders for the current problem. The program will pass in the
		--- input file as stdin - don't worry about it :D
		run = {
			py = { "python3", "@.py" },
			cpp = { "@" }
		},

		--- @type boolean
		--- Whether to use [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim)
		--- Highly recommended
		use_term_toggle = true,
		--- @param title string
		--- @param message string | nil
		--- @param type "success" | "error"
		--- Notification function. Uses `vim.print` and sets log level to
		--- `vim.log.levels.WARN` for "success" and `vim.log.levels.ERROR` for "error"
		--- I recommend using [nvim-notify](https://github.com/rcarriga/nvim-notify)
		--- and maybe use a function like this:
		--- ```lua
		--- function (title, message, type)
		---		if message == nil then
		---			vim.notify(title, type, {
		---				render = "minimal",
		---			})
		---		else
		---			vim.notify(message, type, {
		---				title = title,
		---			})
		---		end
		--- end
		--- ```
		notify = function(title, message, type)
			local log_level = type == "success" and vim.log.levels.WARN or vim.log.levels.ERROR
			message = title .. (message ~= nil and "\n" .. message or "")
			vim.notify(message, log_level)
		end,
	},
	paths = {
		contests = nil,
		tests = nil,
		solutions = nil,
		templates = nil
	},
}

--- @param cf_path string | nil
--- Sets the paths. If no path provided as `cf_path`, it will use the default path (`$HOME/codeforces/contests`)
local setup_paths = function(cf_path)
	M.paths.contests = vim.fs.joinpath(cf_path, "contests")
	M.paths.tests = vim.fs.joinpath(M.paths.contests, "test")
	M.paths.solutions = vim.fs.joinpath(M.paths.contests, "solutions")
	M.paths.templates = vim.fs.joinpath(M.paths.contests, "templates")

	vim.fn.mkdir(cf_path, "p")
	vim.fn.mkdir(M.paths.contests, "p")
	vim.fn.mkdir(M.paths.tests, "p")
	vim.fn.mkdir(M.paths.solutions, "p")
	vim.fn.mkdir(M.paths.templates, "p")
end

--- @param config table
--- Setup function
M.setup = function(config)
	M.options = vim.tbl_deep_extend("force", M.options, config or {})

	if M.options.extractor_path == nil or vim.fn.executable(M.options.extractor_path) == 0 then
		M.options.notify(
			"Codeforces Extractor",
			"Hi! It looks like you didn't install codeforces-extractor. Please follow the installation instructions here: https://github.com/yunusey/codeforces-extractor",
			"error"
		)
	end

	setup_paths(M.options.cf_path)
end

return M
