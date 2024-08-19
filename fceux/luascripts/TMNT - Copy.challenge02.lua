local coreFcn = require("core_functions")

-- Initialize variables
local start_frame = nil
local levelBeat = false
local playerDied = false
local challengeName = "Beat Rocksteady with Raph"
local message_display_time = 120 -- Display message for 2 seconds (120 frames)
local message_timer = message_display_time
local ignore_start_for_frames = 60 --60 Number of frames to ignore the Start button after reset

-- Define the path to your save state file
local saveStatePath = "../fcs/TMNT.challenge02.fcs"
local start_pressed_last_frame = false
local select_pressed_last_frame = false

-- Function to check if you have beat Rocksteady
function checkVictory()
    local victoryStatus = memory.readbyte(0x0565) -- Address for rocksteady health
    if victoryStatus < 1 and not levelBeat then
        levelBeat = true

        final_time = emu.framecount() - start_frame
            local medal_message = coreFcn.get_medal_message(final_time)
            display_centered_message({
                "Congrats! You completed the Raph challenge",
                "in " .. frames_to_time(final_time) .. " seconds",
                "",  -- Space between time and medal message
                medal_message[1],  -- First line of medal message
                medal_message[2]   -- Second line of medal message
            })
            emu.pause()
    end
end

local function reset_challenge()    
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    start_frame = emu.framecount()
    final_time = nil
    message_timer = message_display_time
    coreFcn.set_medal_times(60, 45, 30)

    -- Manually advance the emulator to avoid game pausing
    for i = 1, ignore_start_for_frames do
        joypad.set(1, { start = false })  -- Force Start to be unpressed
        emu.frameadvance()
    end
end

function checkDeath()
    local raphLife = memory.readbyte(0x0078)
    if raphLife == 0 and not playerDied then
        playerDied = true
        local endFrame = emu.framecount()

        -- Display death message
        gui.text(10, 10, "Challenge Failed: Raph Died!")
        emu.frameadvance()

        -- Pause for 5 seconds (300 frames) and then quit
        while true do
            gui.text(10, 10, "Challenge Failed: Raph Died!")
            emu.frameadvance()

            if emu.framecount() - endFrame >= 300 then
                reset_challenge()
            end
        end
    end
end

-- ** Load the save state when the script starts **
reset_challenge()


-- Main loop
while true do
    --Display Instructions
    if message_timer > 0 then
        coreFcn.display_centered_message({"Beat Rocksteady","You only get Craphael"})
        message_timer = message_timer -1
    end


    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    if startFrame == nil then
        startFrame = emu.framecount()
    end

    if not levelBeat then
        checkVictory()
    end

    if not playerDied then
        checkDeath()
    end

    emu.frameadvance() -- Advance to the next frame
end
