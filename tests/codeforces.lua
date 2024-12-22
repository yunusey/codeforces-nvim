local codeforces = require('codeforces-nvim.codeforces')

describe('fetch_problems', function ()
	it('should fetch problems and save them', function ()
		local co = coroutine.running()
		local save_dir = '/tmp/test' -- TODO: find a better way
		codeforces.fetch_problems('1790', save_dir, function ()
			coroutine.resume(co, 0)
		end)

		local exit_code = coroutine.yield()
		assert(exit_code == 0)

		local problems = {}
		for i in vim.fs.dir(save_dir) do
			table.insert(problems, i)
		end
		assert.same({ 'A', 'B', 'C', 'D', 'E', 'F', 'G' }, problems)

		-- FIX: Find a better way
		vim.system { 'rm', '-rf', save_dir }
	end)
end)
