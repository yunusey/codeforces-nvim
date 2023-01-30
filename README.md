# codeforces-nvim
The neovim plugin for codeforces.


# Setup
1) From ```init.lua``` using ```packer.nvim```.

Add lines to your ```.config/nvim/init.lua```:
```lua
use 'yunusey/codeforces-nvim'
require('codeforces-nvim').setup({
    notify_nvim = true, -- If you have rcarriga/nvim-notify
    term_toggle = true, -- If you have 
    -- The other configuration options will be set to their defaults.
    -- For more, check lua/codeforces-nvim/setup.lua
    -- @ means ~/codeforces/contests/solutions/{contest_num}/{problem_name}
    -- So for cpp, for example, if you want to produce .out, you should put @.out instead of @. See examples:
    compile = {
        your_lang = {"compile", "@.lang", "@.exe"},
        cpp = {"g++", "@.cpp", "-o", "@.out"},
        py = {}
    },
    -- @ means the same while # means the test case. In bash, you can give file as an input using '<'. So you should write your run command and add '<', '#'. See examples:
    run = {
        your_lang = {"run", "@.exe", "<", "#"},
        cpp = {"@.out", "<", "#"},
        py = {"python3", "@.py", "<", "#"}
    }
})
```

2) From ```github.com```:
```bash
cd ~/.local/share/nvim/site/pack/packer/start/;
git clone https://github.com/yunusey/codeforces-nvim.git
```

# Using Commands
```
:EnterContest {contest number}
```
Downloads and sets up the environment for the {contest number} given.
___
```
:ExplorerCF
```
It will open your ```~/codeforces/contests/``` folder in default.
___
```
:ExplorerCFCurrent
```
Opens your ```~/codeforces/contests/test/{active contest number}```.
___
```
:QNext
```
Sets current problem to the next problem, and opens the file.
___
```
:TestCurrent
```
If your active language has any command in ```setup.compile[setup.extension]```, it does that first. If it doesn't compile it, it will notify you and open the error in a new buffer. If it compiles, it will run the command in your ```setup.run[setup.extension]``` for **all** the tests and notify you about the results. If there are any errors, it will open you up a new buffer, with the expected output and found output.
___
```
:RunCurrent
```
It opens a terminal, and runs ```setup.terminal_run[setup.extension]```. 

PS: For some reason I don't know, whenever I try to do this in python it doesn't work. It actually opens a terminal with the command I want but then I can't do ```:TestCurrent``` anymore.
___
```
:CreateTestCase
```
It will open up you a buffer that asks for input. It'll write the given input to a file named ```user_input.txt```. Then, it'll run the command in your ```setup.run[setup.extension]``` in a new terminal.

PS: For saving the test case, you should get in to the normal mode and press ```Enter```. 
___
```
:RetrieveLastTestCase
```
It runs the last given test case by the user using ```:CreateTestCase``` command. It basically does the same thing ```:CreateTestCase``` does, except the menu opens up for the user input.

# Customization
See ```codeforces-nvim/lua/codeforces-nvim/setup.lua```. I do recommend you to use the setup file, because you can see every single customization option.

# Errors
As I've mentioned before, right now, whenever I open the terminal, I can't make ```:TestCurrent``` work for python. For more details, see ```codeforces-nvim/lua/codeforces-nvim/commands.lua```. 

# Contribution
I'd very much appreciate any contribution. Even starring would be great!