## Sttusline

A very lightweight statusline plugin for neovim written in lua.

This plugin lazy load all components and only update each component when needed.

Because this plugin aim to be fast and small as possible. I don't focus on
overriding default component. I focus on creating your custom component. So
maybe you need to know a little bit of lua to create your own component.

- ❓ [Features](#features)
- 👀 [Installation](#installation)
- 💻 [Configuration](#configuration)
- 😆 [Usage](#usage)
- 😁 [Contributing](#contributing)
- ✌️ [License](#license)

## A few words to say

🎉 As you can see, this plugin is very small and fast. But maybe it't not perfect
because I'm not a lua expert. So if you have any idea to improve this plugin,
please open an issue or pull request. I'm very happy to hear from you.

🍕 The default component is written for my personal use. So maybe you need to
create your own component. I'm very happy to see your component. So if you have
any idea to create a new component, please open an issue or pull request.

## Preview

![preview1](./docs/readme/preview1.png)

Copilot loading

https://github.com/sontungexpt/sttusline/assets/92097639/ec1a7150-0f05-4f55-9603-790edbd49863



## Features

🎉 Lightweight and super fast.

🛠️ Lazy load all components

🍕 Only update each component when needed, not update all statusline

🔥 Easy to create your component with lua

## Installation

```lua
    -- lazy
    {
        "sontungexpt/sttusline",
        branch = "table_version",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        event = { "BufEnter" },
        config = function(_, opts)
            require("sttusline").setup {
                on_attach = function(create_update_group) end

                -- the colors of statusline will be set follow the colors of the active buffer
                -- statusline_color = "#fdff00",
                statusline_color = "StatusLine",
                disabled = {
                    filetypes = {
                        -- "NvimTree",
                        -- "lazy",
                    },
                    buftypes = {
                        "terminal",
                    },
                },
                components = {
                    "mode",
                    "filename",
                    "git-branch",
                    "git-diff",
                    "%=",
                    "diagnostics",
                    "lsps-formatters",
                    "copilot",
                    "indent",
                    "encoding",
                    "pos-cursor",
                    "pos-cursor-progress",
                },
            }
        end,
    },
```

## Usage

### Laststatus

You should set `laststatus` by yourself. I recommend you set `laststatus` to `3` to be better.

```lua
vim.opt.laststatus = 3
```

### Components

We provide you some default component:

| **Component**         | **Description**                                        |
| --------------------- | ------------------------------------------------------ |
| `datetime`            | Show datetime                                          |
| `mode`                | Show current mode                                      |
| `filename`            | Show current filename                                  |
| `git-branch`          | Show git branch                                        |
| `git-diff`            | Show git diff                                          |
| `diagnostics`         | Show diagnostics                                       |
| `lsps-formatters`     | Show lsps, formatters(support for null-ls and conform) |
| `copilot`             | Show copilot status                                    |
| `indent`              | Show indent                                            |
| `encoding`            | Show encoding                                          |
| `pos-cursor`          | Show position of cursor                                |
| `pos-cursor-progress` | Show position of cursor with progress                  |

To use default component use should add name of component to components options
or you can add a table with the first value is the name of component and second
value is the table that you want to override default component

Use default component with default configs

```lua
    require("sttusline").setup {
        components = {
            "mode", -- use default component with default configs
        },
    }
```

Use default component and override default configs. I allow you to do any thing even the core of the component.

```lua
    require("sttusline").setup {
        components = {
            {
                "mode",
                -- override default component
                {
                    name = "component_name",
                    update_group = "group_name",
                    event = {}, -- The component will be update when the event is triggered
                    user_event = { "VeryLazy" },
                    -- timing = 200
                    timing = false, -- The component will be update every time interval
                    lazy = true,
                    space ={}
                    configs = {},
                    padding = 1, -- { left = 1, right = 1 }
                    colors = {}, -- { fg = colors.black, bg = colors.white }
                    init = function(config, space) end,
                    update = function(configs, space)return "" end,
                    condition = function(configs, space)return true end,
                    on_highlight= function(configs, space) end,
                }
            },
        },
    }
```

### Add the empty space between components

To add the empty space between components, you need to add `%=` to `components` option in `setup` function

```lua
    require("sttusline").setup {
        components = {
            -- ... your components
            "%=", -- add the empty space
            -- ... your components
        },
    }
```

#### Create new component

```lua
    require("sttusline").setup {
        components = {
            -- ...
            {
                -- new component
                name = "component_name",
                update_group = "group_name",
                event = {}, -- The component will be update when the event is triggered
                user_event = { "VeryLazy" },
                timing = false, -- The component will be update every time interval
                lazy = true,
                space ={}
                configs = {},
                padding = 1, -- { left = 1, right = 1 }
                colors = {}, -- { fg = colors.black, bg = colors.white }
                init = function(configs, space) end,
                update = function(configs, space)return "" end,
                condition = function(config, space)return true end,
                on_highlight= function(configs, space) end,
            }
        },
    }
```

| **Keys**                      | Type of args                          | **Description**                                                                                                                                                                           |
| ----------------------------- | ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [name](#name)                 | string                                | The name of component                                                                                                                                                                     |
| [update_group](#update_group) | string                                | The update group of component                                                                                                                                                             |
| [event](#event)               | table or string                       | The component will be update when the [event](https://neovim.io/doc/user/autocmd.html) is triggered                                                                                       |
| [user_event](#user_event)     | table or string                       | Same as event buf for [User](https://neovim.io/doc/user/autocmd.html) autocmd                                                                                                             |
| [timing](#timing)             | boolean or number                              | If set_timing(true), component will update after 1 second, If set to a number it will create a sub timer for that component |
| [padding](#padding)           | number or table                       | The number of spaces to add before and after the component                                                                                                                                |
| [lazy](#lazy)                 | boolean                               | Load component on startup(not recommended)                                                                                                                                                |
| [configs](#configs)           | table                                 | The configs of components, it will be pass to the first parameter of each function                                                                                                        |
| [space](#space)               | table or function                     | If space is the table it will be pass to the second parameter of each function, if it is a function the return value of that function will be pass to the second parameter of each function |
| [init](#init)                 | function                              | The function will call on the first time component load                                                                                                                                   |
| [colors](#colors)             | table                                 | Colors highlight                                                                                                                                                                          |
| [update](#update)             | function(must return string or table) | The function will return the value of the component to display on the statusline                                                                                                          |
| [condition](#condition)       | function(must return boolean)         | The function will return the condition to display the component when the component is update                                                                                              |
| [on_highlight](#on_highlight) | function                              | The function will call when the component is set highlight                                                                                                                                |

### Detail of each key

- <a name="name">`name`</a>: The name of component(optional). If you set it will be better for logging message. Default is `nil`

```lua
    {
        name = "form",
    }
```

- <a name="update_group">`update_group`</a>: The update group of component(optional). Default is `nil`

If you set it, then all the components in the same group will be update in the same time

NOTE: If group is set, then the event, user_event, timing will be ignored

Please make sure that you create group by using:

```lua
    require("sttusline").setup {
        on_attach = function(create_update_group)
            create_update_group("GROUP_NAME", {
                event = { "BufEnter" },
                user_event = { "VeryLazy" },
                timing = false,
            })
        end
    }
```

We provide you some default group:

| **Group**       | **Description**                                                                   |
| --------------- | --------------------------------------------------------------------------------- |
| `CURSOR_MOVING` | event = {"CursorMoved", "CursorMoveI"}, user_event = {"VeryLazy"}, timing = false |
| `BUF_WIN_ENTER` | event = {"BufEnter", "WinEnter"}, user_event = {"VeryLazy"}, timing = false       |

```lua
    {
        update_group = "CURSOR_MOVING",
    }
```

- <a name="event">`event`</a>: The component will be update when the event is triggered(optional). Default is `nil`

```lua
    {
        event = { "BufEnter" },
    }
    -- or
    {
        event = "BufEnter",
    }
```

- <a name="user_event">`user_event`</a>: Same as event buf for `User` autocmd(optional). You should set it
  to `VeryLazy` to load when open neovim if you use `lazy.nvim` plugin. Default is `nil`

```lua
    {
        user_event = { "VeryLazy" },
    }
    -- or
    {
        user_event = "VeryLazy",
    }
```

- <a name="timing">`timing`</a>: The component will be update every time interval(optional). Default is `nil`

```lua
    {
        timing = true,

        -- or

        timing = 200, -- 200ms

        -- This will create a sub timer for the component that will be update every 200ms
        -- Please make sure that you don't create too many sub timers because it will affect the performance

    }
```

- <a name="padding">`padding`</a>: The number of spaces to add before and after the component(optional). Default is 1

```lua
    {
        padding = 1, -- { left = 1, right = 1 }
    }
    -- or
    {
        padding = { left = 1, right = 1 },
    }
    -- or
    {
        padding = { left = 1 }, -- right = 1
    }
    -- or
    {
        padding = { right = 1 }, -- left = 1
    }
```

- <a name="lazy">`lazy`</a>: Load component on startup(not recommended). Default is false

```lua
    {
        lazy = true,
    }
```

<a name="configs">`configs`</a>: The configs of components, it will be pass to the first parameter of each function(optional). Default is nil

```lua
    {
        configs = {},
    }
```

- <a name="init">`init`</a>: The function will call on the first time component load(optional). Default is nil

  - configs is the [configs](#configs) table
  - space is the [space](#space) table

```lua
    {
        init = function(configs, space) end,
    }
```

- <a name="space">`space`</a>: The space is the table or function(optional) and will be pass to the second parameter of each function. Default is nil
  If it is a function the return value of that function will be pass to the second parameter of each function(optional).
  You should use it to add the algorithm function for your component or constant variables

  - configs is the [configs](#configs) table

```lua
    {
        space = {}
    }
    -- or
    {
        space = function(configs)
            return {}
        end,
    }
```

Example

```lua
    {
        name = "git-branch",
        event = { "BufEnter" }, -- The component will be update when the event is triggered
        user_event = { "VeryLazy", "GitSignsUpdate" },
        configs = {
            icon = "",
        },
        colors = { fg = colors.pink, bg = colors.bg }, -- { fg = colors.black, bg = colors.white }
        space = {
            get_branch = function()
                local git_dir = vim.fn.finddir(".git", ".;")
                if git_dir ~= "" then
                    local head_file = io.open(git_dir .. "/HEAD", "r")
                    if head_file then
                        local content = head_file:read("*all")
                        head_file:close()
                        return content:match("ref: refs/heads/(.-)%s*$")
                    end
                    return ""
                end
                return ""
            end,
        },
        update = function(configs, space)
            local branch = space.get_branch()
            return branch ~= "" and configs.icon .. " " .. branch or ""
        end,
        condition = function() return vim.api.nvim_buf_get_option(0, "buflisted") end,
    },

```

OR

```lua
    {
        name = "git-branch",
        event = { "BufEnter" }, -- The component will be update when the event is triggered
        user_event = { "VeryLazy", "GitSignsUpdate" },
        configs = {
            icon = "",
        },
        colors = { fg = colors.pink, bg = colors.bg }, -- { fg = colors.black, bg = colors.white }
        space = function(configs,colors)
            local get_branch = function()
                local git_dir = vim.fn.finddir(".git", ".;")
                if git_dir ~= "" then
                    local head_file = io.open(git_dir .. "/HEAD", "r")
                    if head_file then
                        local content = head_file:read("*all")
                        head_file:close()
                        return content:match("ref: refs/heads/(.-)%s*$")
                    end
                    return ""
                end
                return ""
            end,
            return {
                get_branch = get_branch,
            }
        end,
        update = function(configs, space)
            local branch = space.get_branch()
            return branch ~= "" and configs.icon .. " " .. branch or ""
        end,
        condition = function() return vim.api.nvim_buf_get_option(0, "buflisted") end,
    },

```

- <a name="update">`update`</a>: The function will return the value of the component to display on the statusline(required).
  Return value must be string or table

  - configs is the [configs](#configs) table
  - space is the [space](#space) table

Return string

```lua
    {
        update = function(configs, space)return "" end,
    }
```

Return the table with all values is string

```lua
    {
        update = function(configs, space)return { "string1", "string2" } end,
    }
```

If you return the table that contains the table with the first value is string and second value is the colors options or highlight name then
This element will be highlight with new colors options or highlight name when the component is update

```lua
    -- you can use the colors options
    {
        update = function(configs, space)return { { "string1", {fg = "#000000", bg ="#fdfdfd"} },  "string3", "string4"  } end,
    }
```

OR

```lua
    -- only use the foreground color of the DiagnosticsSignError highlight
    {
        update = function(configs, space)return { { "string1", {fg = "DiagnosticsSignError", bg ="#000000"} },  "string3", "string4"  } end,
    }
```

OR

```lua
    -- use same colors options of the DiagnosticsSignError highlight
    {
        update = function(configs, space)return { { "string1", "DiagnosticsSignError" },  "string3", "string4"  } end,
    }
```

- <a name="colors"> `colors`</a>: Colors highlight(optional). Default is `nil`
  Rely on the return value of the [update](#update) function, you have 3 ways to set the colors

If the return value is string

```lua
    {
        colors = { fg = colors.black, bg = colors.white },
    }
```

If the return value is table so each element will correspond to its color according to its position in the table

```lua
    {
        colors = {
            { fg = "#009900", bg = "#ffffff" },
            { fg = "#000000", bg = "#ffffff" }
        },

        -- so if the return value is { "string1", "string2" }
        -- then the string1 will be highlight with { fg = "#009900", bg = "#ffffff" }
        -- and the string2 will be highlight with { fg = "#000000", bg = "#ffffff" }

        -- if you don't want to add highlight for the string1  you can add a empty table in the first element
        {
            colors = {
                {},
                { fg = "#000000", bg = "#ffffff" }
            },
        }
    }
```

NOTE: The colors options can be the colors name or the colors options

```lua
    {
        colors = {
            { fg = "#009900", bg = "#ffffff" },
            "DiagnosticsSignError",
        },

        -- so if the return value is { "string1", "string2" }
        -- then the string1 will be highlight with { fg = "#009900", bg = "#ffffff" }
        -- and the string2 will be highlight with the colors options of the DiagnosticsSignError highlight

        -- or you can set the fg(bg) follow the colors options of the DiagnosticsSignError highlight
        {
            colors = {
                { fg = "DiagnosticsSignError", bg = "#ffffff" },
                "DiagnosticsSignError",
            },
        }
    }
```

- <a name="condition">`condition`</a>: The function will return the condition to display the component when the component is update(optional).
  Return value must be boolean

  - configs is the [configs](#configs) table
  - space is the [space](#space) table

```lua
    {
        condition = function(configs, space)return true end,
    }
```

- <a name="on_highlight">`on_highlight`</a>: The function will call when the component is set highlight(optional).

  - configs is the [configs](#configs) table
  - space is the [space](#space) table

```lua
    {
        on_highlight= function(configs, space) end,
    }
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
