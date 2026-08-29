-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    -- match by panel description so it works whether NVIDIA (eDP-2) or
    -- Intel i915 (eDP-1) drives the panel (Secure Boot toggling switches GPU)
    output   = "desc:Samsung Display Corp. ATNA60HU01-0",
    mode     = "preferred",
    position = "0x0",
    scale    = 1.25,
})


------------------
---- AUTOSTART ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    hl.exec_cmd("fcitx5 -d")
    -- ly doesn't push the session env into systemd/D-Bus; do it here so
    -- D-Bus-activated services (xdg-desktop-portal & backends) see WAYLAND_DISPLAY.
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    -- Auto-restart loop: if waybar crashes it comes back in ~2s.
    -- stderr goes to a log file instead of the console (ly sends fd2 to tty1).
    hl.exec_cmd("sh -c 'while :; do waybar 2>>$HOME/.local/state/waybar.log; sleep 2; done &'")
    hl.exec_cmd("killall swaybg; swaybg -m fill -i /home/vedaru/.local/share/backgrounds/2026-07-21-23-44-26-138800451_p0.jpg &")
    hl.exec_cmd("xhost +si:localuser:root")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("cliphist wipe")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprctl plugin load ~/.local/lib/hyprland/plugins/libhyprcapture.so")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- hl.env("GTK_IM_MODULE", "fcitx")  -- Commented out: redundant on Wayland; fcitx5 uses native text-input protocol
hl.env("QT_IM_MODULE", "fcitx")
hl.env("QT_STYLE_OVERRIDE", "Breeze")  -- Qt6 dark theme for HyprCapture
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("GLFW_IM_MODULE", "fcitx")
hl.env("SDL_IM_MODULE", "fcitx")
-- NOTE: do NOT append :GNOME to XDG_CURRENT_DESKTOP here. hl.env leaks into
-- the systemd user manager → xdg-desktop-portal matches gnome.portal backends
-- (deprecated-UseIn warnings, 25s start timeouts, waybar's tray D-Bus call
-- times out and waybar dies). Helium (the app this line existed for) is gone;
-- if a Chromium/Electron app ever needs GNOME detection again, put
-- `env XDG_CURRENT_DESKTOP=Hyprland:GNOME` in that app's own .desktop Exec.


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 2,

        col = {
            -- Same tonal palette as waybar/rofi: primary tone for the
            -- active border (flat, so lightness is identical on all
            -- sides), surface-container-high for inactive windows.
            active_border   = "rgba(E0B25Bff)",
            inactive_border = "rgba(372B1Bff)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        no_focus_fallback = true,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 14,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 0.96,

        shadow = {
            enabled = false,
            range   = 18,
            render_power = 3,
            color   = "rgba(20170999)",
        },

        blur = {
            enabled   = true,
            size      = 6,
            passes    = 3,
            vibrancy  = 0.20,
            xray      = true,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })
hl.curve("ease-out-expo",  { type = "bezier", points = { {0.19, 1}, {0.22, 1} } })

hl.animation({ leaf = "global",        enabled = false })
hl.animation({ leaf = "border",        enabled = false })
hl.animation({ leaf = "borderangle",   enabled = false })
hl.animation({ leaf = "windows",       enabled = false })
hl.animation({ leaf = "windowsIn",     enabled = false })
hl.animation({ leaf = "windowsOut",    enabled = false })
hl.animation({ leaf = "fadeIn",        enabled = false })
hl.animation({ leaf = "fadeOut",       enabled = false })
hl.animation({ leaf = "fade",          enabled = false })
hl.animation({ leaf = "layers",        enabled = false })
hl.animation({ leaf = "layersIn",      enabled = false })
hl.animation({ leaf = "layersOut",     enabled = false })
hl.animation({ leaf = "fadeLayersIn",  enabled = false })
hl.animation({ leaf = "fadeLayersOut", enabled = false })
hl.animation({ leaf = "workspaces",    enabled = false })
hl.animation({ leaf = "workspacesIn",  enabled = false })
hl.animation({ leaf = "workspacesOut", enabled = false })
hl.animation({ leaf = "zoomFactor",    enabled = false })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
        initial_workspace_tracking = 0,
    },

    render = {
        direct_scanout = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
            -- Hyprctl reports raw scroll factor -1.0 for this touchpad, which
            -- makes SUPER+drag-resize (and window-edge drag) jump erratically.
            -- Map 1.0 device units -> 1.0 logical pixel for predictable motion.
            scroll_factor = 1.0,
            -- Enables tap-and-drag so a single tap followed by a finger drag
            -- acts as a held left click + drag. With drag_lock = 2, the
            -- button stays held after the finger lifts; a second tap releases.
            tap_and_drag = true,
            -- Keeps the drag active after the finger lifts; tap again to
            -- release. 0 = disabled, 1 = single-tap timeout, 2 = drag lock.
            drag_lock = 2,
            -- Softbutton mode: 2-finger tap can produce a real held right
            -- click for drag. (clickfinger mode classifies 2-finger motion
            -- as scroll, which would prevent the right mouse resize bind
            -- from ever firing.)
            clickfinger_behavior = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- ELAN touchpad: override scroll factor so SUPER+drag-resize doesn't jump.
-- hyprctl shows the raw factor as -1.0 for this device, which makes
-- touchpad-driven resize unusable. Keeping it consistent with the global
-- touchpad block above.
hl.device({
    name         = "elan06fa:00-04f3:327e-touchpad",
    scroll_factor = 1.0,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Apps
hl.bind(mainMod .. " + Q",       hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + Z",       hl.dsp.window.fullscreen_state({ internal = 2, client = 1, action = "toggle" }))
hl.bind(mainMod .. " + E",       hl.dsp.exec_cmd("pcmanfm"))
hl.bind(mainMod .. " + S",       hl.dsp.exec_cmd("/home/vedaru/.local/opt/helium/helium"))

hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd("pgrep hyprcapture-ui >/dev/null || (killall rofi || rofi -show drun -disable-history)"), { release = true })
hl.bind("ALT + Tab", hl.dsp.exec_cmd("~/.local/bin/WindowSwitcher"))

-- Window control
hl.bind(mainMod .. " + C",       hl.dsp.window.close())
hl.bind(mainMod .. " + J",       hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F",       hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + B",       hl.dsp.exec_cmd("pgrep -x waybar >/dev/null && pkill -USR1 waybar || waybar"))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Vim-style resize (SUPER + SHIFT + hjkl).
-- Works on both floating and tiled windows.
-- RESIZE_STEP = px per key press.
local RESIZE_STEP = 100

local function resize_window(dx, dy)
    hl.dispatch(hl.dsp.window.resize({ x = dx, y = dy, relative = true }))
end

hl.bind(mainMod .. " + SHIFT + H", function() resize_window(-RESIZE_STEP, 0) end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + L", function() resize_window( RESIZE_STEP, 0) end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", function() resize_window(0, -RESIZE_STEP) end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", function() resize_window(0,  RESIZE_STEP) end, { repeating = true })

-- Misc
hl.bind(mainMod .. " + L",            hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + V",            hl.dsp.exec_cmd("killall wofi || cliphist list | wofi --dmenu | cliphist decode | wl-copy"), { release = true })
hl.bind(mainMod .. " + SHIFT + E",    hl.dsp.exec_cmd("wofi-emoji"))
hl.bind(mainMod .. " + SHIFT + C",    hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind(mainMod .. " + escape",       hl.dsp.exec_cmd("pkill -x -USR2 waybar; killall swaybg; swaybg -m fill -i /home/vedaru/.local/share/backgrounds/2026-07-21-23-44-26-138800451_p0.jpg &"))

-- Screenshots & Screen Recording (HyprCapture)
hl.bind(mainMod .. " + SHIFT + S", function() hl.plugin.hyprcapture.open() end)
hl.bind(mainMod .. " + SHIFT + W", function() hl.plugin.hyprcapture.open("window") end)
hl.bind(mainMod .. " + SHIFT + F", function() hl.plugin.hyprcapture.open("fullscreen") end)

-- Volume controls
hl.bind("XF86AudioRaiseVolume",         hl.dsp.exec_cmd("pamixer -i 2"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",         hl.dsp.exec_cmd("pamixer -d 2"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",                hl.dsp.exec_cmd("pamixer -t"),  { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 2"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 2"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioMute",        hl.dsp.exec_cmd("pamixer -t"),  { locked = true, repeating = true })

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
-- Move silently with mainMod + CTRL + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,              hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,      hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. key,       hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + A",              hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + A",      hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + CTRL + A",       hl.dsp.window.move({ workspace = "special:magic", follow = false }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from native Wayland apps. XWayland games need
    -- real maximize/fullscreen events, so leave them alone.
    name  = "suppress-maximize-events",
    match = { class = ".*", xwayland = false },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

local suppressFullscreenRule = hl.window_rule({
    -- Fullscreen geometry still applies (Super+Z fills the screen), but the
    -- app never learns it's fullscreen — browsers keep their tabs visible.
    -- XWayland games need real fullscreen, so leave them alone.
    name  = "suppress-fullscreen-events",
    match = { class = ".*", xwayland = false },

    suppress_event = "fullscreen",
})
-- suppressFullscreenRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Fix GTK4 popup menus appearing as decorated panels (the "panel inside panel" issue)
-- GTK4 popups are separate Wayland surfaces that get decorated individually
hl.window_rule({
    name     = "gtk4-popup-fix",
    match    = {
        class = "^$",
        title = "^$",
        float  = true,
    },
    no_blur       = true,
    no_shadow     = true,
    rounding      = 0,
    border_size   = 0,
})

hl.window_rule({
    name     = "gtk4-popup-fix-2",
    match    = { title = "^(.*popup.*)$" },
    no_blur       = true,
    no_shadow     = true,
    rounding      = 0,
    border_size   = 0,
})

-- Games under Wine/Proton (Faugus/umu) are XWayland windows. umu wraps the
-- main game in `steam_app_default`; helper/child windows keep their own `.exe`
-- class (e.g. `KRSDKExternal.exe`). Float all of them so they're never tiled
-- (the old `games-tile` rule broke WuWa's mouse capture by forcing tile). The
-- main game requests fullscreen on its own; we don't suppress it (the global
-- suppress rules exempt XWayland), so the game fullscreens naturally and the
-- mouse is captured. Sub-windows (notifications, dialogs) stay floating.
hl.window_rule({
    name    = "games-steam-app-float",
    match   = { class = "^steam_app_default$", xwayland = true, fullscreen = false },
    float   = true,
    center  = true,
    decorate = false,
    no_blur  = true,
    no_shadow = true,
})

hl.window_rule({
    name    = "games-exe-float",
    match   = { class = "(?i).*\\.exe$", xwayland = true, fullscreen = false },
    float   = true,
    center  = true,
    decorate = false,
    no_blur  = true,
    no_shadow = true,
})


-- First-launch fix + keep-main-fullscreen: on the first run after a reboot
-- the game opens as a floating windowed surface (the game only requests
-- fullscreen on the *second* run, when GameUserSettings.ini is already
-- saved). Wine's raw-mouse grab fails in windowed mode, so the cursor
-- floats and camera look doesn't respond. Fullscreen the first
-- `steam_app_default` window on open, and re-fullscreen it if a subwindow
-- popping up causes the main window to drop back to floating. The flag
-- tracks whether we've already claimed the main window so notifications
-- (which also have `class = steam_app_default`) aren't fullscreened.
-- Reset on close so the next game launch works the same way.
local gameMainFullscreened = false

local function fullscreenActiveGame()
    if not gameMainFullscreened then return end
    hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 2, client = 1, action = "set" }))
end

hl.on("window.open", function(w)
    if not w then return end
    if w.class ~= "steam_app_default" then return end
    if not w.xwayland then return end
    if w.modal then return end
    if gameMainFullscreened then return end
    gameMainFullscreened = true
    fullscreenActiveGame()
end)

hl.on("window.fullscreen", function(w)
    -- If the main game window drops out of fullscreen while it's still
    -- open (caused by a subwindow being mapped), re-fullscreen it.
    if not w then return end
    if w.class ~= "steam_app_default" then return end
    if not w.xwayland then return end
    if w.modal then return end
    if not gameMainFullscreened then return end
    if w.fullscreen == 0 then
        fullscreenActiveGame()
    end
end)

hl.on("window.close", function(w)
    if w and w.class == "steam_app_default" and gameMainFullscreened then
        gameMainFullscreened = false
    end
end)


-- Float XWayland modal dialogs (Wine/Proton game pop-ups like Wuthering Waves
-- exit confirmation). Only float non-fullscreen modals so the main game window
-- isn't affected.
hl.window_rule({
    name     = "xwayland-modal-float",
    match    = { xwayland = true, modal = true, fullscreen = false },
    float    = true,
    center   = true,
    decorate = false,
    no_blur  = true,
    no_shadow = true,
})

-- WeMeet: disable animations to prevent wobble on internal resize
hl.window_rule({
    name     = "wemeet-noanim",
    match    = { class = "wemeetapp" },
    no_anim  = true,
})

-- Internal-fullscreen windows (Super+Z zoom mode) must not keep rounded corners
hl.window_rule({
    name     = "fullscreen-no-rounding",
    match    = { fullscreen_state_internal = 2 },
    rounding = 0,
})

-- Helium opens in "zoom" mode: internal fullscreen geometry (edge-to-edge,
-- no gaps) + client maximize (the app keeps its tabs visible).
-- Super+Z toggles back out.
-- (helium-zoom-on-open rule removed 2026-08-17: forced fullscreen+maximize
-- on every Helium launch, which the user experienced as "maximizes on every
-- open" and which re-poisoned Chromium's saved window state.)
