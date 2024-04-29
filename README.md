robinsr's hammerspoon
=====================


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



