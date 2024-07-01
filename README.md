robinsr's hammerspoon
=====================

## Todos

- Startup errors related to executing shell commands. See [issues item 1](#item1)
- Add/Remove rules to/from yabai config
    - I want to stop yabai from managing an app's windows
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

### item1

Config errors on startup


```brew: command not found```

```
[ERROR] (shell) Shell result:{
  command = "brew services info sketchybar --json 2>&1",
  output = "sh: brew: command not found\n",
  status = 127
}
```

***




***

Scratch pad 

```
name: ApplePrivateInterfaceThemeChangedNotification
object: nil
userInfo: nil

2024-06-20 16:59:10: name: AppleInterfaceThemeChangedNotification
object: nil
userInfo: nil
```


```bash

# copy
https://img.icons8.com/ios/100/copy--v1.png
https://img.icons8.com/ios/100/cut.png

### Keys ###

# alphas
https://img.icons8.com/ios/100/a-key.png

# numbers
https://img.icons8.com/ios/100/1-key.png

# f-keys
https://img.icons8.com/ios/100/f6-key.png


# mods
https://img.icons8.com/ios/100/fn-key.png
https://img.icons8.com/ios/100/shift--v1.png
https://img.icons8.com/ios/100/shift--v2.png
https://img.icons8.com/ios/100/tab-key--v1.png
https://img.icons8.com/ios/100/ctrl.png
https://img.icons8.com/ios-filled/50/shift--v1.png


# space
https://img.icons8.com/ios/100/space-key.png

# forward-slash
https://img.icons8.com/ios/100/solidus-key.png 

# dot ('dor')
https://img.icons8.com/ios/100/dor-key.png

# others
https://img.icons8.com/ios/100/del-key.png

# plus
https://img.icons8.com/ios/100/plus-key.png

# minus
https://img.icons8.com/ios/100/minus-key.png

# backspace
https://img.icons8.com/ios/100/backspace.png

# equal-key
https://img.icons8.com/ios/100/equal-key

# right-angle-parentheses-key
https://img.icons8.com/ios/100/right-angle-parentheses-key.png

# left-angle-parentheses-key
https://img.icons8.com/ios/100/left-angle-parentheses-key.png

# asterisk-key--v1
https://img.icons8.com/ios/100/asterisk-key--v1.png

# asterisk-key--v2
https://img.icons8.com/ios/100/asterisk-key--v2.png

# toggle-off
https://img.icons8.com/ios/100/toggle-off.png
https://img.icons8.com/ios-filled/100/toggle-off.png

# toggle-on
https://img.icons8.com/ios/100/toggle-on.png
https://img.icons8.com/ios-filled/100/toggle-on.png


# close
https://img.icons8.com/ios-filled/100/close-window.png
```

