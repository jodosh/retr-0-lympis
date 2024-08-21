local coreFcn = require("core_functions")

-- Initialize variables
local start_frame = nil
local instructions = {"Beat Rocksteady","You only get Craphael"}
local message_display_time = 120 -- Display message for 2 seconds (120 frames)
local message_timer = message_display_time
local ignore_start_for_frames = 60 --60 Number of frames to ignore the Start button after reset
local saveStatePath = "../fcs/TMNT.challenge02.fcs"

-- Challenge Speciffic variables

-- #region Functions --
function check_victory()
    --todo
    local victoryStatus = memory.readbyte(0x0565) -- Address for rocksteady health
    if victoryStatus < 1 then
        final_time = emu.framecount() - start_frame
        local medal_message = coreFcn.get_medal_message(final_time)
        coreFcn.display_centered_message({
            "Congrats! You completed the Raph challenge",
            "in " .. coreFcn.frames_to_time(final_time) .. " seconds",
            "",  -- Space between time and medal message
            medal_message[1],  -- First line of medal message
            medal_message[2]   -- Second line of medal message
        })
        emu.pause()
    end
end

local function reset_challenge()
    --todo
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    start_frame = emu.framecount()
    message_timer = message_display_time
    coreFcn.set_medal_times(40, 25, 15)

    -- Manually advance the emulator to avoid game pausing
    for i = 1, ignore_start_for_frames do
        joypad.set(1, { start = false })  -- Force Start to be unpressed
        emu.frameadvance()
    end
end
-- #endregion --

--setup single run steps
reset_challenge()


-- Main loop
while true do
    --Display Instructions
    if message_timer > 0 then
        coreFcn.display_centered_message(instructions)
        message_timer = message_timer -1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    check_victory()

    emu.frameadvance() -- Advance to the next frame
end