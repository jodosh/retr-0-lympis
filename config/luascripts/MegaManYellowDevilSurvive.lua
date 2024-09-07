local coreFcn = require("core_functions")

-- Initialize variables
local start_Frame = nil
local instructions = { "Survive!" }
local message_display_time = 200 -- Display message for 2 seconds (120 frames)
local message_timer = message_display_time
local ignore_start_for_frames = 60 -- Number of frames to ignore the Start button after reset
local saveStatePath = "../fcs/Mega Man.yellow devil.fcs"
local completion_time = nil


function reset_challenge()
    -- Reset any challenge-specific variables then add the following:
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    start_Frame = emu.framecount()  -- Initialize start_frame here
    message_timer = message_display_time   
    completion_time = nil

    --TODO set MM heath 0x006A to 1
    memory.writebyte(0x006A, 0x01 ); --one hit kills
    memory.writebyte(0x00A6, 0x00 ); --one life
end

function check_death()
    if memory.readbyte(0x006A) <= 0x0000 then --mm is dead
        if completion_time == nil then
            completion_time = (emu.framecount() - start_Frame) / 60  -- Convert frame count to seconds
        end

        -- Optionally, pause the game or do something else here
        -- emu.pause()  -- Uncomment if you want to pause the game after completion        
        
         gui.text(10, 40, "Challenge Completed!")
         gui.text(10, 50, "Hold Start and Press Select to Start Over!")
         coreFcn.display_centered_message({"Survived Time: " .. string.format("%.2f", completion_time) .. " seconds"})
    end
end

function check_victory()
    if memory.readbyte(0x06C1) <= 0x0000 then

        if completion_time == nil then
            completion_time = (emu.framecount() - start_Frame)  -- Convert frame count to seconds
        end

        -- Ensure start_frame is not nil before performing arithmetic
                  
            print("Challenge completed!")
            coreFcn.display_centered_message({
                "Congrats! You completed Ice Man!",
                "in " .. coreFcn.frames_to_time(completion_time) .. " seconds!"                  
            })            
        
        
    end
end

reset_challenge()
-- Main loop to continuously check the condition
while true do
    
    -- Initialize start_frame if it is not set
    if start_Frame == nil then
        start_Frame = emu.framecount()
    end

    coreFcn.display_footer("MegaMan Challenge - Survive!")

    -- Display Instructions
    if message_timer > 0 then
        coreFcn.display_centered_message(instructions)
        message_timer = message_timer - 1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    check_death()

    if memory.readbyte(0x06C1) <= 0x001C then
        memory.writebyte(0x06C1, 0x001C) --you can't kill the boss
    end
    
    emu.frameadvance() -- Advance to the next frame
end
