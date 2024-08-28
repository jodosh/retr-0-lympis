local coreFcn = require("core_functions")

-- Initialize variables
local start_Frame = nil
local instructions = { "Complete the Bomb Run 2!" }
local message_display_time = 200 -- Display message for 2 seconds (120 frames)
local message_timer = message_display_time
local ignore_start_for_frames = 60 -- Number of frames to ignore the Start button after reset
local saveStatePath = "../fcs/MegaMan1.challenge06.fcs"
local completion_time = nil

function reset_challenge()
    -- Reset any challenge-specific variables then add the following:
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    start_Frame = emu.framecount()  -- Initialize start_frame here
    message_timer = message_display_time
    
    completion_time = nil
end

function check_victory()
    if memory.readbyte(0x001A) >= 0x005F and memory.readbyte(0x001B) == 0x000B then

        if completion_time == nil then
            completion_time = (emu.framecount() - start_Frame)  -- Convert frame count to seconds
        end

        -- Ensure start_frame is not nil before performing arithmetic
                  
            print("Challenge completed!")
            coreFcn.display_centered_message({
                "Congrats! You completed the Bomb Run 2!",
                "in " .. coreFcn.frames_to_time(completion_time) .. " seconds!"                  
            })            
        
        
    end
end

function check_failiure()

    if memory.readbyte(0x00E0) == 0x0000 then

        reset_challenge()

    end
end


-- Main loop to continuously check the condition
while true do
    memory.writebyte(0x006A, 0x001C) -- set Mega Man's life to full.
    coreFcn.display_footer("MegaMan Challenge - Bomb Run 2!")    

    -- Initialize start_frame if it is not set
    if start_Frame == nil then
        start_Frame = emu.framecount()
    end

    -- Display Instructions
    if message_timer > 0 then
        coreFcn.display_centered_message(instructions)
        message_timer = message_timer - 1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end
    check_failiure()
    check_victory()

    emu.frameadvance() -- Advance to the next frame
end
