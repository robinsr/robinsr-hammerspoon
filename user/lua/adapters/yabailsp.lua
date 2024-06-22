---@alias Yabai.Selector.Dir
---| 'north'
---| 'east'
---| 'south'
---| 'west'


---@alias Yabai.Selector.Space
---| Yabai.Selector.Dir
---| 'prev' 
---| 'next' 
---| 'first' 
---| 'last' 
---| 'recent' 
---| 'mouse' 
---| string 
---| number


---@class Yabai.Space
---@field display number
---@field first-window number
---@field has-focus boolean
---@field id number
---@field index number
---@field is-native-fullscreen boolean
---@field is-visible boolean
---@field label string
---@field last-window number
---@field type string The layout type
---@field uuid string
---@field windows number[]


---@alias Yabai.Selector.Window
---| Yabai.Selector.Dir
---| 'prev' 
---| 'next' 
---| 'first' 
---| 'last' 
---| 'recent' 
---| 'mouse' 
---| 'largest' 
---| 'smallest' 
---| 'sibling' 
---| 'first_nephew' 
---| 'second_nephew' 
---| 'uncle' 
---| 'first_cousin' 
---| 'second_cousin'


---@class Yabai.Window
---@field app string
---@field can-move boolean
---@field can-resize boolean
---@field display integer
---@field frame Yabai.Frame
---@field has-ax-reference boolean
---@field has-focus boolean
---@field has-fullscreen-zoom boolean
---@field has-parent-zoom boolean
---@field has-shadow boolean
---@field id integer,
---@field is-floating boolean
---@field is-grabbed boolean
---@field is-hidden boolean
---@field is-minimized boolean
---@field is-native-fullscreen boolean
---@field is-sticky boolean
---@field is-visible boolean
---@field layer string
---@field level integer
---@field opacity number
---@field pid integer
---@field role Yabai.Window.AccessRole
---@field root-window boolean
---@field scratchpad string
---@field space integer
---@field split-child string
---@field split-type string
---@field stack-index integer
---@field sub-layer string
---@field sub-level integer
---@field subrole Yabai.Window.AccessSubrole
---@field title string


---@alias Yabai.Window.AccessRole 'AXWindow'|'idk'


---@alias Yabai.Window.AccessSubrole 'AXStandardWindow'|'idk'


---@class Yabai.Frame
---@field x number
---@field y number
---@field w number
---@field h number


---@alias Yabai.Window.toggles
---| 'zoom-fullscreen'
---| 'float'
---| 'sticky'
---| 'pip'
---| 'shadow'
---| 'split'
---| 'zoom-parent'
---| 'zoom-fullscreen'
---| 'native-fullscreen'
---| 'expose'


---@alias Yabai.Selector.Display
---| Yabai.Selector.Dir
---| 'prev' 
---| 'next' 
---| 'first' 
---| 'last' 
---| 'recent' 
---| 'mouse' 
---| string 
---| number


---@class Yabai.Display
---@field id integer
---@field uuid string
---@field index integer
---@field label string
---@field frame Yabai.Frame
---@field spaces integer[]
---@field has-focus boolean



---@class Yabai.Rule
---@field app string
---@field display integer
---@field flags string
---@field follow_space boolean
---@field grid string
---@field index integer
---@field label string
---@field manage boolean
---@field mouse_follows_focus boolean
---@field native-fullscreen boolean
---@field one-shot boolean
---@field opacity integer
---@field role string
---@field scratchpad string
---@field space integer
---@field sticky boolean
---@field sub-layer string
---@field subrole string
---@field title string


---@alias YabaiEvent
---| '"application_launched"'' # $YABAI_PROCESS_ID
---| '"application_terminated"'' # $YABAI_PROCESS_ID
---| '"application_front_switched"'' # $YABAI_PROCESS_ID $YABAI_RECENT_PROCESS_ID
---| '"application_activated"'' # $YABAI_PROCESS_ID
---| '"application_deactivated"'' # $YABAI_PROCESS_ID
---| '"application_visible"'' # $YABAI_PROCESS_ID
---| '"application_hidden"'' # $YABAI_PROCESS_ID
---| '"window_created"'' # $YABAI_WINDOW_ID
---| '"window_destroyed"'' # $YABAI_WINDOW_ID
---| '"window_focused"'' # $YABAI_WINDOW_ID
---| '"window_moved"'' # $YABAI_WINDOW_ID
---| '"window_resized"'' # $YABAI_WINDOW_ID
---| '"window_minimized"'' # $YABAI_WINDOW_ID
---| '"window_deminimized"'' # $YABAI_WINDOW_ID
---| '"window_title_changed"'' # $YABAI_WINDOW_ID
---| '"space_created"'' # $YABAI_SPACE_ID
---| '"space_destroyed"'' # $YABAI_SPACE_ID
---| '"space_changed"'' # $YABAI_SPACE_ID $YABAI_RECENT_SPACE_ID
---| '"display_added"'' # $YABAI_DISPLAY_ID
---| '"display_removed"'' # $YABAI_DISPLAY_ID
---| '"display_moved"'' # $YABAI_DISPLAY_ID
---| '"display_resized"'' # $YABAI_DISPLAY_ID
---| '"display_changed"'' # $YABAI_DISPLAY_ID $YABAI_RECENT_DISPLAY_ID
---| '"mission_control_enter"'' # $YABAI_MISSION_CONTROL_MODE
---| '"mission_control_exit"'' # $YABAI_MISSION_CONTROL_MODE
---| '"dock_did_change_pref"''
---| '"dock_did_restart"''
---| '"menu_bar_hidden_changed"''
---| '"system_woke"''


return {}