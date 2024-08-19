local coreFcn = require("core_functions")

local saveStatePath = "../fcs/SuperDodgeTomMustDieChallenge.fcs"
local enddisplaytime = 0
local message_display_time = 120 -- Display message for 2 seconds (120 frames)
local message_timer = message_display_time
local ignore_start_for_frames = 60 -- Number of frames to ignore the Start button after reset
local setNewHP = false
local startFrame = nil
local final_time = nil
local completion_time = nil
local hpCheckFrames = 200 -- after 200 frames set new HP

local function reset_challenge()   
    setNewHP = false
    enddisplaytime = 0
    message_timer = 200
    hpCheckFrames = 200
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    startFrame = emu.framecount()
    final_time = nil
    completion_time = nil  -- Reset completion time

    -- Manually advance the emulator to avoid game pausing
    for i = 1, ignore_start_for_frames do
        joypad.set(1, { start = false })  -- Force Start to be unpressed
        emu.frameadvance()
    end
end

-- Main loop
while true do

    hpCheckFrames = hpCheckFrames + 1

    if hpCheckFrames > 200 then
        if not setNewHP then
            memory.writebyte(0x03CB, 0x01)
            memory.writebyte(0x043B, 0x01)
            memory.writebyte(0x0403, 0x16)
            setNewHP = true
        end 
    end

    -- Display Title 
    coreFcn.display_title({"Super Dodge Ball - Tom Must Die Challenge"})

    -- Display Instructions
    if message_timer > 0 then
        coreFcn.display_centered_message({"Tom MUST DIE!!"})
        message_timer = message_timer - 1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    if startFrame == nil then
        startFrame = emu.framecount()
    end

    -- Check if the challenge is completed
    if memory.readbyte(0x0403) == 0x00 then
        
     if completion_time == nil then
            completion_time = (emu.framecount() - startFrame) / 60  -- Convert frame count to seconds
        end

            gui.text(10, 40, "Challenge Completed!")    
            gui.text(10, 50, "Hold Start and Press Select to Start Over!")

            -- Display a message for challenge completion            
            coreFcn.display_centered_message({"Time: " .. string.format("%.2f", completion_time) .. " seconds"})
        
    end

    if memory.readbyte(0x0041) == 0xEA then
        -- Display a message for challenge failure
        enddisplaytime = enddisplaytime + 1

        coreFcn.display_centered_message({"Challenge Failed! Try Again!"})
      
        if enddisplaytime == 100 then
            reset_challenge()      
        end       
    end

    emu.frameadvance() -- Advance to the next frame
end
