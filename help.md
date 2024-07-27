hammerspoon help
================

## Using the CLI

- Read the HammerspoonCLI man page

`man /Applications/Hammerspoon.app/Contents/Resources/man/hs.man`

- Start in "interactive mode"

`hs -i`

Interactive mode is similar/same to what is in the GUI console. Features include:

- Get concise documentation on various hammerspoon APIs
  - `hs.help([string])`
  - `hs.help('hs.console')`
- Get globals in current HS instance
  - `hs.inspect(_G.myGlobalVar)`
- 