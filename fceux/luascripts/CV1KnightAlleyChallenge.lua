local coreFcn = require("core_functions")

local saveStatePath = "../fcs/CV1KnightAlley.fcs"
local enddisplaytime = 0
local enddisplaytime2 = 0
local message_display_time = 120 -- Display message for 2 seconds (120 frames)
local message_timer = message_display_time
local ignore_start_for_frames = 60 -- Number of frames to ignore the Start button after reset
local hpCheckFrames = 200 -- after 200 frames set new HP
local setNewHP = false
local startFrame = nil
local final_time = nil
local completion_time = nil

local function reset_challenge()        
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    startFrame = emu.framecount()
    final_time = nil
    enddisplaytime2 = 0
    enddisplaytime = 0
    setNewHP = false
    message_timer = 200
    hpCheckFrames = 200    

    completion_time = nil  -- Reset completion time

    -- Manually advance the emulator to avoid game pausing
    for i = 1, ignore_start_for_frames do
        joypad.set(1, { start = false })  -- Force Start to be unpressed
        emu.frameadvance()
    end
end

-- Main loop
while true do
    gui.box(0, 0, 280, 22, "black", "black")  -- Draws a white box with a black border

    hpCheckFrames = hpCheckFrames + 1

    -- Keep Simon Alive 
     memory.writebyte(0x0045, 0x40 );
     memory.writebyte(0x0071, 0x40 );
    -- Keep Timer Alive
     memory.writebyte(0x0042, 0x99 );
     memory.writebyte(0x0043, 0x99 );


     -- Display Title 
    coreFcn.display_title({"Castlevania - Complete Knight Alley - Find Death!"})

    -- Display Instructions
    if message_timer > 0 then
        coreFcn.display_centered_message({"Complete Knight Alley - Find Death! "})
        message_timer = message_timer - 1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    if startFrame == nil then
        startFrame = emu.framecount()
    end

    -- Check if the challenge is completed by directly comparing the memory value
    if memory.readbyte(0x0048) == 0x01  then
        if completion_time == nil then
            completion_time = (emu.framecount() - startFrame) / 60  -- Convert frame count to seconds
        end

        -- Optionally, pause the game or do something else here
        -- emu.pause()  -- Uncomment if you want to pause the game after completion        
        
         gui.text(10, 40, "Challenge Completed!")
         gui.text(10, 50, "Hold Start and Press Select to Start Over!")
         coreFcn.display_centered_message({"Time: " .. string.format("%.2f", completion_time) .. " seconds"})
    end

    if memory.readbyte(0x001D ) == 0x20 then
        -- Display a message for challenge failure
        enddisplaytime2 = enddisplaytime2 + 1
        coreFcn.display_centered_message({"Challenge Failed! Try Again!"})
      
        if enddisplaytime2 > 50 then
            reset_challenge()
        end      
    end
    
    if memory.readbyte(0x0045 ) == 0x00 then
        -- Display a message for challenge failure
        enddisplaytime = enddisplaytime + 1
        coreFcn.display_centered_message({"Challenge Failed! Try Again!"})
      
        if enddisplaytime > 200 then
            reset_challenge()      
        end       
    end

    emu.frameadvance() -- Advance to the next frame
end
