local coreFcn = require("core_functions")

local saveStatePath = "../fcs/CV1CheatDeathChallenge.fcs"
local enddisplaytime = 0
local enddisplaytime2 = 0
local message_display_time = 320 -- Display message for 2 seconds (120 frames)
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

    if hpCheckFrames > 100 then
        if not setNewHP then            
            memory.writebyte(0x0044, 0x40)
            memory.writebyte(0x0045, 0x40)
            setNewHP = true
        end
    end

    -- Display Title 
    coreFcn.display_title({"Castlevania - Surive Death!"})

    -- Keep Death Alive 
     memory.writebyte(0x01A9, 0x40 );
     memory.writebyte(0x01AA, 0x40 );
    -- Keep Timer Alive
     memory.writebyte(0x0042, 0x99 );
     memory.writebyte(0x0043, 0x99 );

    -- Display Instructions
    if message_timer > 0 then
        coreFcn.display_centered_message({"Cheat Death - Surive! "})
        message_timer = message_timer - 1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    if startFrame == nil then
        startFrame = emu.framecount()
    end

    -- Check if the challenge is completed by directly comparing the memory value
    if memory.readbyte(0x0045) == 0x00  then
        if completion_time == nil then
            completion_time = (emu.framecount() - startFrame) / 60  -- Convert frame count to seconds
        end

        -- Optionally, pause the game or do something else here
        -- emu.pause()  -- Uncomment if you want to pause the game after completion        
        
         gui.text(10, 40, "Challenge Completed!")
         gui.text(10, 50, "Hold Start and Press Select to Start Over!")
         coreFcn.display_centered_message({"Survived Time: " .. string.format("%.2f", completion_time) .. " seconds"})
    end
    
    emu.frameadvance() -- Advance to the next frame
end
