--[[

# n3thr4-lang Button Manager

A clean and flexible GuiButton management system for Roblox.

Supported interaction types:
- single_press     (normal click)
- hold             (while holding down)
- toggle           (on/off switch)
- long_press       (press and hold for a duration)

+ Extra hooks: enter, leave, down, up

## Features
- Manage multiple buttons with custom keys
- Automatic cleanup when button is destroyed
- Safe disconnection of events & threads
- Easy activation, disabling, removal, full termination

## Quick Setup
local ButtonManager = require(game.ReplicatedStorage.ButtonManager)
local bm = ButtonManager.new_button_list()

bm:add_button(script.Parent.PlayButton, "Play")
bm:add_button(script.Parent.HoldBtn,    "HoldSkill")
bm:add_button(script.Parent.ToggleBtn,  "Music")
bm:add_button(script.Parent.ChargeBtn,  "Ultimate")

## Management Methods
bm:toggle_visibility(false, "Ultimate")   -- hide one button
bm:toggle_visibility(true)                -- show all

bm:disable_button("Music")                -- disconnect events of one button
bm:disable_button()                       -- disconnect everything

bm:remove_button("HoldSkill")             -- remove & hide one button
bm:remove_button()                        -- remove all

bm:TERMINATE_EVERYTHING()                 -- full cleanup (great for UI reset)

Notes:
- Always :add_button() first, then :Activate_button()
- If config.visible is nil → keeps current visibility
- Auto-cleans connections on :Destroy()

Made with ♡ by nethra • 2026

]]

-- ====================== REAL USAGE EXAMPLES ======================
-- These are executable code — you can leave them here for reference
-- or remove/comment them out in production

-- SINGLE PRESS (normal button click)
bm:Activate_button("Play", {
    fire = function(button)
        print("Game Started!")
        -- game:GetService("ReplicatedStorage").StartGame:FireServer()
    end
}, {
    button_type = "single_press",
    visible = true
})

-- HOLD (while mouse button is down)
bm:Activate_button("HoldSkill", {
    hold = function(isHolding, button)
        if isHolding then
            print("Charging skill...")
            button.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        end
    end,
    
    release = function(isHolding, button)
        print("Skill released!")
        button.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    end
}, {
    button_type = "hold",
    visible = true
})

-- TOGGLE (on/off switch)
local musicEnabled = true

bm:Activate_button("Music", {
    toggle = function(state, button)
        musicEnabled = state
        
        if state then
            print("Music turned ON")
            button.Text = "Music: ON"
            button.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        else
            print("Music turned OFF")
            button.Text = "Music: OFF"
            button.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        end
    end
}, {
    button_type = "toggle",
    state = true,           -- initial state (true = on)
    visible = true
})

-- LONG PRESS (hold for a set duration)
bm:Activate_button("Ultimate", {
    start_pressing = function(button)
        print("Charging ultimate...")
        button.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
    end,
    
    finished = function(button)
        print("ULTIMATE READY! → BOOM!")
        button.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    end,
    
    cancelling = function(button)
        print("Charge cancelled (released too early)")
        button.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    end,
    
    stopped_pressing = function(button)
        print("Released")
    end
}, {
    button_type = "long_press",
    time_take = 1.5,          -- hold time required (seconds)
    visible = true
})

-- BONUS: Hover effect (combine with any type)
bm:Activate_button("Play", {
    -- you can keep the fire function from single_press above
    
    enter = function(button)
        button.BackgroundTransparency = 0.2
        button:TweenSize(UDim2.new(1.1,0,1.1,0), "Out", "Quad", 0.18, true)
    end,
    
    leave = function(button)
        button.BackgroundTransparency = 0
        button:TweenSize(UDim2.new(1,0,1,0), "Out", "Quad", 0.18, true)
    end
}, {
    button_type = "single_press"   -- or any other type
})