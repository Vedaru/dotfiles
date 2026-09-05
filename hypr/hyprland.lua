-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "desc:Samsung Display Corp. ATNA60HU01-0",
    mode     = "preferred",
    position = "0x0",
    scale    = 1.25,
})

------------------
---- AUTOSTART ----
------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("sh -c 'while ! [ -S \"$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY\" ]; do sleep 0.5; done; while :; do waybar 2>>$HOME/.local/state/waybar.log; sleep 2; done &'")
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

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("QT_STYLE_OVERRIDE", "Breeze")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("GLFW_IM_MODULE", "fcitx")
hl.env("SDL_IM_MODULE", "fcitx")

-----------------------
----- PERMISSIONS -----
-----------------------

-- (unchanged, still commented out)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 0,
        gaps_out = 0,
        border_size = 2,
        col = {
            active_border   = "rgba(E0B25Bff)",
            inactive_border = "rgba(372B1Bff)",
        },
        resize_on_border = true,
        allow_tearing = false,
        no_focus_fallback = true,
        layout = "dwindle",
    },

    decoration = {
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

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
            xray      = false,  -- CHANGED: was true. xray blur bypasses normal
                                 -- opacity/stacking rules and is a known cause of
                                 -- blur bleed/gap artifacts around new popups
                                 -- and tooltips (XWayland ones especially).
        },
    },

    animations = {
        enabled = true,
    },
})

-- (curves/animations block unchanged)
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
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

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

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
        direct_scanout = false,  -- CHANGED: was true. Direct scanout forces a
                                  -- mode switch when a popup/tooltip surface
                                  -- appears over the scanned-out window, which
                                  -- is a documented source of transient visual
                                  -- artifacts right where the new surface
                                  -- appears. Worth testing back to true later
                                  -- once the popup issue is confirmed fixed,
                                  -- to see if it was actually the cause.
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
        sensitivity = 0,

        touchpad = {
            natural_scroll = true,
            scroll_factor = 1.0,
            tap_and_drag = true,
            drag_lock = 2,
            clickfinger_behavior = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

hl.device({
    name         = "elan06fa:00-04f3:327e-touchpad",
    scroll_factor = 1.0,
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + Q",       hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + Z",       hl.dsp.window.fullscreen_state({ internal = 2, client = 1, action = "toggle" }))
hl.bind(mainMod .. " + E",       hl.dsp.exec_cmd("ghostty -e bash -ic \"n\""))
hl.bind(mainMod .. " + S",       hl.dsp.exec_cmd("/home/vedaru/.local/opt/helium/helium"))

hl.bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd("pgrep hyprcapture-ui >/dev/null || (killall rofi || rofi -show drun -disable-history)"), { release = true })
hl.bind("ALT + Tab", hl.dsp.exec_cmd("~/.local/bin/WindowSwitcher"))

hl.bind(mainMod .. " + C",       hl.dsp.window.close())
hl.bind(mainMod .. " + J",       hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + F",       hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + B",       hl.dsp.exec_cmd("pgrep -x waybar >/dev/null && pkill -USR1 waybar || waybar"))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

local RESIZE_STEP = 100

local function resize_window(dx, dy)
    hl.dispatch(hl.dsp.window.resize({ x = dx, y = dy, relative = true }))
end

hl.bind(mainMod .. " + SHIFT + H", function() resize_window(-RESIZE_STEP, 0) end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + L", function() resize_window( RESIZE_STEP, 0) end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + K", function() resize_window(0, -RESIZE_STEP) end, { repeating = true })
hl.bind(mainMod .. " + SHIFT + J", function() resize_window(0,  RESIZE_STEP) end, { repeating = true })

hl.bind(mainMod .. " + L",            hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + X",            hl.dsp.exec_cmd("pgrep -x wlogout >/dev/null && pkill -x wlogout || wlogout -b 5"))
hl.bind(mainMod .. " + V",            hl.dsp.exec_cmd("killall wofi || cliphist list | wofi --dmenu | cliphist decode | wl-copy"), { release = true })
hl.bind(mainMod .. " + SHIFT + E",    hl.dsp.exec_cmd("wofi-emoji"))
hl.bind(mainMod .. " + SHIFT + C",    hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind(mainMod .. " + escape",       hl.dsp.exec_cmd("pkill -x -USR2 waybar; killall swaybg; swaybg -m fill -i /home/vedaru/.local/share/backgrounds/2026-07-21-23-44-26-138800451_p0.jpg &"))

hl.bind(mainMod .. " + SHIFT + S", function() hl.plugin.hyprcapture.open() end)
hl.bind(mainMod .. " + SHIFT + W", function() hl.plugin.hyprcapture.open("window") end)
hl.bind(mainMod .. " + SHIFT + F", function() hl.plugin.hyprcapture.open("fullscreen") end)

hl.bind("XF86AudioRaiseVolume",         hl.dsp.exec_cmd("pamixer -i 2"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",         hl.dsp.exec_cmd("pamixer -d 2"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",                hl.dsp.exec_cmd("pamixer -t"),  { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 2"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 2"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioMute",        hl.dsp.exec_cmd("pamixer -t"),  { locked = true, repeating = true })

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,              hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,      hl.dsp.window.move({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. key,       hl.dsp.window.move({ workspace = i, follow = false }))
end

hl.bind(mainMod .. " + A",              hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + A",      hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + CTRL + A",       hl.dsp.window.move({ workspace = "special:magic", follow = false }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*", xwayland = false },
    suppress_event = "maximize",
})

local suppressFullscreenRule = hl.window_rule({
    name  = "suppress-fullscreen-events",
    match = { class = ".*", xwayland = false },
    suppress_event = "fullscreen",
})

hl.window_rule({
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

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- ADDED: strip decoration from ANY XWayland floating surface, not just ones
-- with empty class/title. ONLYOFFICE tooltips/popups report class "ONLYOFFICE",
-- so the two rules above never matched them. This is the direct fix for the
-- "background gap around popup" symptom.
hl.window_rule({
    name        = "xwayland-popup-fix",
    match       = { xwayland = true, float = true },
    no_blur     = true,
    no_shadow   = true,
    rounding    = 0,
    border_size = 0,
})

hl.window_rule({
    name     = "xwayland-modal-float",
    match    = { xwayland = true, modal = true, fullscreen = false },
    float    = true,
    center   = true,
    decorate = false,
    no_blur  = true,
    no_shadow = true,
})

hl.window_rule({
    name     = "fullscreen-no-rounding",
    match    = { fullscreen_state_internal = 2 },
    rounding = 0,
})
