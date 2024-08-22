local coreFcn = require("core_functions")

-- Boilerplate for core functions
local saveStatePath = "../fcs/SMBChallenge1.fcs"
local start_frame = nil
local final_time = nil
local countdown_frames = 120 -- Number of frames for the countdown (180 = 2 seconds)
local message_countdown_timer = countdown_frames


-- Initialize variables
local challengeName = "Get the first mushroom"

local function reset_challenge()    
    message_countdown_timer = countdown_frames
    final_time = nil
    start_frame = nil
    coreFcn.set_medal_times(15, 9, 4)
end

-- Function to check if Mario has picked up a mushroom
function checkMushroom()
    local powerupStatus = memory.readbyte(0x0756) -- Address for power-up status in SMB
    if powerupStatus == 1 then
        local endFrame = emu.framecount()
        final_time = endFrame - start_frame

        local medal_message = coreFcn.get_medal_message(final_time)
        coreFcn.display_centered_message({
            "Congrats! You completed challenge",
            "in " .. coreFcn.frames_to_time(final_time) .. " seconds",
            "",  -- Space between time and medal message
            medal_message[1],  -- First line of medal message
            medal_message[2]   -- Second line of medal message
        })
        emu.pause()
    end
end

-- Function to check if Mario has died
function checkPlayerDeath()
    local lives = memory.readbyte(0x075A) -- Address for Mario's lives in SMB
    if lives < 2 then
        reset_challenge()
    end
end

reset_challenge()
-- Main loop
while true do
    coreFcn.display_title({"SMB - Collect a mushroom"})
    if startFrame == nil then
        startFrame = emu.framecount()
    end

    -- Display Instructions and Countdown (-120 so it keeps the message for an extra 2 seconds after countdown)
    if message_countdown_timer >= -120 then
		-- Do the Countdown
		if message_countdown_timer > 0 then 
			coreFcn.message_and_countdown({"Collect a mushroom"}, message_countdown_timer)
		elseif message_countdown_timer == 0 then
			local state = savestate.create(saveStatePath)
			savestate.load(state)
			start_frame = emu.framecount()
		else
			coreFcn.display_centered_message({"Collect a mushroom"})
		end
	
		message_countdown_timer = message_countdown_timer - 1
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    checkMushroom()

    checkPlayerDeath()

    emu.frameadvance() -- Advance to the next frame
end
