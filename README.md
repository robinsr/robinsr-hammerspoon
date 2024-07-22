robinsr's hammerspoon
=====================

## Todos

- [x] Startup errors related to executing shell commands. See [issues item 1](#item1)
- Add/Remove rules to/from yabai config
    - Add command - "always ignore current app"
    - I don't know this until the app is running
    - Stopping to add a rule to the yabai config is a pain so I usually dont
    - This results in annoying window issues
    - Add a command 'Yabai: Ignore current app'
    - Items to add
        - TextEdit
        - Various preference panes - AltTab, Bartender,
        - Most Finder Windows.
            - I just dont want a single gigantic finder window. So if window is a finder, and no others window in space, ignore window
            - If the space type is "stack" (all big windows), ignore finder
- 



## Organization

```
~/.hammerspoon
├── adapters/       - App-level integration/ops; All shell programs and background daemons/services atm
├── init_d/         - ... Note 1
├── interface/      — Sys-level integration/operations; Inputs (events, hs urls, menubar), Outputs (only alerts atm)
├── model/          — ... Note 2
├── modules/        — High-level functionality; coordinate all the pieces
├── ui/             - Low-level details; could be moved under interface
├── util/           - Mostly reusable bits, Lua-related polyfil-type things, etc
├── init.lua        — Runtime entry-point
├── commands.lua    — Command dictionary
└── state.lua       - Global state
```

### "Module" organization

- Realizing I'm overloading the term "module"
- It's all of the *what* and *why* and little to none of the *how*


```
~/.hammerspoon/modules
└── example
    ├── init.lua       - entry-point "example module" 
    └── exmp-lib.lua   - additional support module for "example module"
```


### Note 1 - init_d

- Work-in-progress, maybe half-baked
- I think I was trying to make something like an IOC container (like Spring Framework), that would hold references to all the singleton instances needed in various places in code.
- And like Spring, I wanted it to some sort of "component scan", eg search the project for modules declaring themselves as container tenents 


### Note 2 - model

- Work-in-progress, definitely half-baked
- IIRC it was gonna model the state of the desktop (running apps, app windows, active window, mouse location, etc)
- and provide some level of abstraction to the HS windows API
- forgot what prompted that idea...


## Generating docs

Install lua-language-server 

```
brew install lua-language-server
```

Generate docs with `--docs` path, `--doc_out_path` path, and the entry point


```
/opt/homebrew/bin/lua-language-server --doc ./user/lua --doc_out_path ~/Desktop init.lua
```


## Issues




***

## Scratch pad 

```
name: ApplePrivateInterfaceThemeChangedNotification
object: nil
userInfo: nil

2024-06-20 16:59:10: name: AppleInterfaceThemeChangedNotification
object: nil
userInfo: nil
```

***


IDEA for later

```lua
seqx(cmds).prop('id'):pass(section_glob)
lists(cmds):filter()
local function seqx(items)
  local self = {}
  local ops = {
    _prop = 'function to select a table property from sequence items for further ops',
    prop = function(prop_name)
    end,
    _pass = 'predicate function which sequenec items must pass',
  }
  return proto.setProtoOf(ops, self)
end
```


***


**HS to WebviewJS connection?**

(Example webview callback data)


```lua
{
  body = "popopopo",
  frameInfo = {
    mainFrame = true,
    request = {
      HTTPHeaderFields = {},
      HTTPMethod = "GET",
      HTTPShouldHandleCookies = true,
      HTTPShouldUsePipelining = false,
      URL = {
        __luaSkinType = "NSURL",
        url = "about:blank"
      },
      cachePolicy = "protocolCachePolicy",
      networkServiceType = "default",
      timeoutInterval = 60.0
    },
    securityOrigin = {
      host = "",
      port = 0,
      protocol = ""
    }
  },
  name = "kittysupreme",
  webView = <userdata 1> -- hs.webview: KittySupreme Hotkeys (0x6000002abbf8)
}
```