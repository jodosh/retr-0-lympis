local coreFcn = require("core_functions")

local saveStatePath = "../fcs/KidIcarus11challenge.fcs"
local enddisplaytime = 0
local countdown_frames = 180 -- Number of frames for the countdown (180 = 3 seconds)
local message_countdown_timer = countdown_frames

local startFrame = nil
local final_time = nil
local completion_time = nil

local function reset_challenge()    
    enddisplaytime = 0
    message_countdown_timer = countdown_frames
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    startFrame = emu.framecount()
    final_time = nil
    completion_time = nil  -- Reset completion time
end

local function check_challenge_end()
    local memory_value = memory.readbyte(0x0135)
    return memory_value == 0x09
end

-- Main loop
while true do

    memory.writebyte(0x00A7, 0x12)
    -- Display Title 
    coreFcn.display_title({"Kid Icarus 1-1 Challenge"})

    -- Display Instructions and Countdown
    if message_countdown_timer >= 0 then
		coreFcn.message_and_countdown({"Beat 1-1 From here!"}, message_countdown_timer) -- Start the countdown
		
		--add the countdown frame to the startFrame so it doesn't affect the end result
		if startFrame ~= nil then
			startFrame = startFrame + 1
		end

		message_countdown_timer = message_countdown_timer - 1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    if startFrame == nil then
        startFrame = emu.framecount()
    end

    -- Check if the challenge is completed by directly comparing the memory value
    if memory.readbyte(0x000C) == 0x31 then
        if completion_time == nil then
            completion_time = (emu.framecount() - startFrame) / 60  -- Convert frame count to seconds
        end

        -- Optionally, pause the game or do something else here
        -- emu.pause()  -- Uncomment if you want to pause the game after completion

         gui.text(10, 20, "Challenge Completed!")
         gui.text(10, 30, "Hold Start and Press Select to Start Over!")
         coreFcn.display_centered_message({"Time: " .. string.format("%.2f", completion_time) .. " seconds"})
    end
    
    if memory.readbyte(0x0041) == 0xEA then
        -- Display a message for challenge failure
        enddisplaytime = enddisplaytime + 1
        coreFcn.display_centered_message({"Challenge Failed! Try Again!"})
      
        if enddisplaytime == 100 then
            reset_challenge()      
        end

        -- Optionally, pause the game or do something else here    
        -- Break out of the loop or wait for user input to restart
        -- break
    end

    emu.frameadvance() -- Advance to the next frame
end
