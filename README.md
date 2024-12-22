# codeforces-nvim

<div align="center"><p>
    <a href="https://github.com/yunusey/codeforces-nvim/pulse">
      <img alt="Last commit" src="https://img.shields.io/github/last-commit/yunusey/codeforces-nvim?style=for-the-badge&logo=aiqfome&color=8bd5ca&logoColor=D9E0EE&labelColor=302D41"/>
    </a>
    <a href="https://github.com/yunusey/codeforces-nvim/blob/main/LICENSE">
      <img alt="License" src="https://img.shields.io/github/license/yunusey/codeforces-nvim?style=for-the-badge&logo=academia&color=ee999f&logoColor=D9E0EE&labelColor=302D41" />
    </a>
    <a href="https://github.com/yunusey/codeforces-nvim/stargazers">
      <img alt="Stars" src="https://img.shields.io/github/stars/yunusey/codeforces-nvim?style=for-the-badge&logo=adafruit&color=c69ff5&logoColor=D9E0EE&labelColor=302D41" />
    </a>
</div>


https://github.com/user-attachments/assets/5d40ebe9-784f-4755-9af8-6de668ae0a52


## Installation 📦
You can install `codeforces-nvim` using different package managers.

---

### [Lazy](https://github.com/folke/lazy.nvim) 💤
```lua
local spec = {
    "yunusey/codeforces-nvim",
    dependencies = { "nvim-lua/plenary.nvim" } -- optional, used for testing
}

spec.config = function()
    require('codeforces-nvim').setup {
        use_term_toggle = true,
        cf_path = "/path/to/desired/codeforces/folder",
        timeout = 15000,
        compiler = {
            cpp = { "g++", "@.cpp", "-o", "@" },
            py = {}
        },
        run = {
            cpp = { "@" },
            py = { "python3", "@.py" }
        },
        notify = function(title, message, type)
            local notify = require('notify')
            if message == nil then
                notify(title, type, {
                    render = "minimal",
                })
            else
                notify(message, type, {
                    title = title,
                })
            end
        end
    }
end

return spec
```

### [Packer](https://github.com/wbthomason/packer.nvim) 📦
```lua
use {
    "yunusey/codeforces-nvim",
    config = function()
        require('codeforces-nvim').setup {
            use_term_toggle = true,
            cf_path = "/path/to/desired/codeforces/folder",
            compiler = {
                cpp = { "g++", "@.cpp", "-o", "@" },
                py = {}
            },
            run = {
                cpp = { "@" },
                py = { "python3", "@.py" }
            },
            notify = function(title, message, type)
                local notify = require('notify')
                if message == nil then
                    notify(title, type, {
                        render = "minimal",
                    })
                else
                    notify(message, type, {
                        title = title,
                    })
                end
            end
        }
    end
}
```


## Usage 📝
Using this plugin is very easy, you just need to follow these steps:

### Installing [codeforces-extractor](https://github.com/yunusey/codeforces-extractor/) 🌻
This tool is used to extract problem information from codeforces. It is written in Rust and is working pretty fast. You can use it as a separate tool and probably as a library with some modifications if you have other ideas. Anyway, for Neovim purposes, you just need to install the tool to your path. You can do this by running:
```bash
cargo install --git https://github.com/yunusey/codeforces-extractor
```
If you are able to run `codeforces-extractor --help` without any errors, you are good to go (the plugin will check if `codeforces-extractor` is on your `PATH`). If you have done a local installation, you need to pass `extractor_path = /path/to/codeforces/extractor` to `setup` function you've seen above.

### Setting up Templates 🎨
This step is very important! the `cf_path` you provided in `setup` will be used to check if you have any templates on `cf_path/contests/templates` directory. If you set your `extension` to be `cpp`, for instance, you need to have a file at `cf_path/contests/templates/template.cpp`. You can place multiple templates for different languages here if you are writing in many different languages and switching between them very often.

### Setting up the Plugin 🎉
We are almost done! As you can also agree, you need to let the plugin know what command to run for compilation and running. By default, for `cpp`, which is the language most competitive programmers use, it will use the following compile command:
```lua
{ "g++", "@.cpp", "-o", "@" }
```
Here, `@` acts as the current problem (e.g. a, b, c1, c3, etc.). The default run command for `cpp` is:
```lua
{ "@" }
```
If you have custom languages that you would like to use, hopefully not Java `:)`, you can follow this example above to write similar compile and run commands.

### Ready to Go! 🚀
Okay, you are ready to go! You need to start your journey by running `:EnterContest <contest-id>`. Here, `<contest-id>` refers to `https://codeforces.com/contest/<contest-id>/problems`. For `https://codeforces.com/contest/1790/problems`, you need to run `:EnterContest 1790` for example. If everything goes nicely, this will fetch problems using `codeforces-extractor` to `cf_path/contests/tests/<contest-id>`, copy your template to `cf_path/contests/solutions/<contest-id>` for each problem and open up the first problem for you in your terminal.

#### Testing your code 🧪
There are three different ways to test your code.

##### Using the tests from codeforces
You just need to run `:TestCurrent`. This will compile your code, run it by passing each of the inputs fetched from codeforces, and compare your output with the expected output. If they are not the same, it will open your output and expected output in `diff` mode in Neovim.

##### Using your own tests
I added this feature so that if you have a custom test you want to run, you can do this one time and run it again and again. You need to run `:CreateTestCase` and it will open up a buffer. There, you need to type in your input and once you are done, you need to switch to normal mode and press enter. This will save your input to `cf_path/solutions/<contest-id>/custom-<problem>.in` and run it on terminal. There, you can check your output.

##### Run directly on terminal
Maybe you want to *freestyle* your input like you would've done normally. Then, you just need to run `:RunCurrent`. This will compile your code, and run it directly on your terminal. There, you can type in your input and check your output.

## Using [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) ⚙️
I enjoy using toggleterm myself and would recommend to anyone interested. By default, the plugin will try running it using `:TermExec` but if you don't want this feature and want to run it directly on terminal, you need to set `use_term_toggle = false` on your setup.

## Using [notify.nvim](https://github.com/rcarriga/nvim-notify) 📢
If you would like some fancy notifications from `codeforces-nvim`, you can use notify. To do that, you need to first install the plugin of course and then, you can copy my setup above, specifically this part:
```lua
notify = function(title, message, type)
    local notify = require('notify')
    if message == nil then
        notify(title, type, {
            render = "minimal",
        })
    else
        notify(message, type, {
            title = title,
        })
    end
end
```
There is a default `notify` function `codeforces-nvim` defines using `vim.notify`, though. So, this is completely up to you to decide which one you would prefer. Though, I strongly suggest using [notify.nvim](https://github.com/rcarriga/nvim-notify).

## Timeout for Running Code 🕒
There is a `timeout` parameter you can override in your `setup` function. This is passed directly to your `run` command. I think this can be useful especially when you expect more input than there actually is supposed to be. This value is set to `15000` milliseconds by default. If you think this is too much, I think so, you can most definitely change this to a more reasonable value like `5000` milliseconds.

## Thanks! ✨
Thanks for reading! If you liked the plugin, you can consider leaving a star. If you encounter any issues or have a good idea to enhance the plugin, make sure to [open up an issue](https://github.com/yunusey/codeforces-nvim/issues).

## Acknowledgements 🏆
I've recently seen that there is a new plugin that is getting popular. I think you should most definitely check it out as well - I didn't really get a chance to check it in detail, but it looks like it supports codeforces as well: [assistant.nvim](https://github.com/A7Lavinraj/assistant.nvim)

## Credits 🎖️
- [codeforces-extractor](https://github.com/yunusey/codeforces-extractor/)
- [notify.nvim](https://github.com/rcarriga/nvim-notify/)
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim/)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [packer.nvim](https://github.com/wbthomason/packer.nvim)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
- [assistant.nvim](https://github.com/A7Lavinraj/assistant.nvim)
- [Neovim](https://neovim.io/)
- [Lua](https://www.lua.org/)
- [Codeforces](https://codeforces.com/)
