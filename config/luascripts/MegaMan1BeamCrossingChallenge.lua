local coreFcn = require("core_functions")

-- Initialize variables
local start_Frame = nil
local instructions = { "Cross the Chasm!" }
local message_display_time = 200 -- Display message for 2 seconds (120 frames)
local message_timer = message_display_time
local ignore_start_for_frames = 60 -- Number of frames to ignore the Start button after reset
local saveStatePath = "../fcs/MegaMan1.challenge04.fcs"
local completion_time = nil
local set_magnet_power = false

function reset_challenge()

    -- Reset any challenge-specific variables then add the following:
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    set_magnet_power = false
    start_Frame = emu.framecount()  -- Initialize start_frame here
    message_timer = message_display_time
    
    completion_time = nil
end

function check_failiure()

    if memory.readbyte(0x00E0) == 0x0000 then

        reset_challenge()

    end
end


function check_victory()
    if memory.readbyte(0x001A) >= 0x0091 and memory.readbyte(0x001B) >= 0x000F then

        if completion_time == nil then
            completion_time = (emu.framecount() - start_Frame)  -- Convert frame count to seconds
        end

        -- Ensure start_frame is not nil before performing arithmetic
                  
            print("Challenge completed!")
            coreFcn.display_centered_message({
                "Congrats! You Crossed the Chasm!",
                "in " .. coreFcn.frames_to_time(completion_time) .. " seconds!"                  
            })            
        
        
    end
end

-- Main loop to continuously check the condition
while true do

    if set_magnet_power == false then
        memory.writebyte(0x006A, 0x001C) -- set his life to full as well.
		memory.writebyte(0x0071, 0x0008)
		set_magnet_power = true
    end
    
    -- Initialize start_frame if it is not set
    if start_Frame == nil then
        start_Frame = emu.framecount()
    end

    coreFcn.display_footer("MegaMan Challenge - Cross the Chasm!")
    
    -- Display Instructions
    if message_timer > 0 then
        coreFcn.display_centered_message(instructions)
        message_timer = message_timer - 1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    check_victory()
    check_failiure()

    emu.frameadvance() -- Advance to the next frame
end
