local coreFcn = require("core_functions")

-- Boilerplate for core functions
local message_display_time = 120 -- Display message for 2 seconds (120 frames)
local message_timer = message_display_time
local ignore_start_for_frames = 60 --60 Number of frames to ignore the Start button after reset
local saveStatePath = "../fcs/SMB.Challenge01.fcs"
local start_pressed_last_frame = false
local select_pressed_last_frame = false

-- Initialize variables
local startFrame = nil
local mushroomPicked = false
local playerDied = false
local challengeName = "Get the first mushroom"

local function reset_challenge()    
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    startFrame = emu.framecount()
    final_time = nil
    message_timer = message_display_time

    -- Manually advance the emulator to avoid game pausing
    for i = 1, ignore_start_for_frames do
        joypad.set(1, { start = false })  -- Force Start to be unpressed
        emu.frameadvance()
    end
end

-- Function to check if Mario has picked up a mushroom
function checkMushroom()
    local powerupStatus = memory.readbyte(0x0756) -- Address for power-up status in SMB
    if powerupStatus == 1 and not mushroomPicked then
        mushroomPicked = true
        local endFrame = emu.framecount()
        local timeTaken = endFrame - startFrame

        -- Display the result on the screen
        gui.text(10, 10, challengeName)
        gui.text(10, 30, "Time to get mushroom: " .. timeTaken .. " frames")

        -- Update the screen
        emu.frameadvance()

        -- Pause the emulation indefinitely
        while true do
            gui.text(10, 10, challengeName)
            gui.text(10, 30, "Time to get mushroom: " .. timeTaken .. " frames")
            emu.frameadvance()
            emu.pause()
        end
    end
end

-- Function to check if Mario has died
function checkPlayerDeath()
    local lives = memory.readbyte(0x075A) -- Address for Mario's lives in SMB
    if lives < 2 and not playerDied then
        playerDied = true
        local endFrame = emu.framecount()

        -- Display death message
        gui.text(10, 10, "Challenge Failed: Mario Died!")
        emu.frameadvance()

        -- Pause for 5 seconds (300 frames) and then quit
        while true do
            gui.text(10, 10, "Challenge Failed: Mario Died!")
            emu.frameadvance()

            if emu.framecount() - endFrame >= 300 then
                reset_challenge()
            end
        end
    end
end

reset_challenge()
-- Main loop
while true do
    if startFrame == nil then
        startFrame = emu.framecount()
    end

    --Display Instructions
    if message_timer > 0 then
        coreFcn.display_centered_message({"Get the first mushroom","Hold start and then press select to restart"})
        message_timer = message_timer -1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    if not mushroomPicked then
        checkMushroom()
    end

    if not playerDied then
        checkPlayerDeath()
    end

    emu.frameadvance() -- Advance to the next frame
end
