local coreFcn = require("core_functions")

-- Initialize variables
local saveStatePath = "../fcs/3-D Battles of World Runner.challenge01.fc0"
local start_frame = nil
local final_time = nil
local countdown_frames = 120 -- Number of frames for the countdown (180 = 2 seconds)
local message_countdown_timer = countdown_frames

-- Function to check if Mario has picked up a mushroom
function checkVictory()
    local levelStatus = memory.readbyte(0x00EE) -- Address for world
    if levelStatus == 1 then
        final_time = emu.framecount() - start_frame
        
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

local function reset_challenge()
    message_countdown_timer = countdown_frames
    final_time = nil
    start_frame = nil
    coreFcn.set_medal_times(20, 10, 5)
end

reset_challenge()
-- Main loop
while true do    
    coreFcn.display_title({"3D World Runner Boss Challenge"})

    -- Display Instructions and Countdown (-120 so it keeps the message for an extra 2 seconds after countdown)
    if message_countdown_timer >= -120 then
		-- Do the Countdown
		if message_countdown_timer > 0 then 
			coreFcn.message_and_countdown({"Beat the boss!"}, message_countdown_timer)
		elseif message_countdown_timer == 0 then
			local state = savestate.create(saveStatePath)
			savestate.load(state)
			start_frame = emu.framecount()
		else
			coreFcn.display_centered_message({"Beat the boss!"})
		end
	
		message_countdown_timer = message_countdown_timer - 1
    end

    if start_frame == nil then
        start_frame = emu.framecount()
    end

    checkVictory()

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    emu.frameadvance() -- Advance to the next frame
end
