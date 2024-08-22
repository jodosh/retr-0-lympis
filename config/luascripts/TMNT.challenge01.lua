local coreFcn = require("core_functions")

-- Initialize variables
local saveStatePath = "../fcs/TMNT.challenge01.fcs"
local startFrame = nil
local countdown_frames = 120 -- Number of frames for the countdown (180 = 2 seconds)
local message_countdown_timer = countdown_frames
local damnBeat = false
local playerDied = false
local challengeName = "Clear the underwater level"

-- Function to check if all the bombs have been difused
function checkVictory()
    local bombStatus = memory.readbyte(0x007d) -- Address for bombs difused (bitwise 8-bit)
    if bombStatus == 255 and not damnBeat then
        damnBeat = true
        local endFrame = emu.framecount()
        local timeTaken = endFrame - startFrame

        -- Display the result on the screen
        gui.text(10, 10, challengeName)
        gui.text(10, 30, "Time to clear level: " .. timeTaken .. " frames")

        -- Update the screen
        emu.frameadvance()

        -- Pause the emulation indefinitely
        while true do
            gui.text(10, 10, challengeName)
            gui.text(10, 30, "Time to clear level: " .. timeTaken .. " frames")
            emu.frameadvance()

            -- Wait for 5 seconds, then quit
            if emu.framecount() - endFrame >= 300 then
                emu.pause()
            end
        end
    end
end

local function reset_challenge()
    message_countdown_timer = countdown_frames
    start_frame = nil
    coreFcn.set_medal_times(15, 9, 4)
end



-- Main loop
while true do
    coreFcn.display_title({"TMNT - Difuse the bombs"})

    -- Display Instructions and Countdown (-120 so it keeps the message for an extra 2 seconds after countdown)
    if message_countdown_timer >= -120 then
		-- Do the Countdown
		if message_countdown_timer > 0 then 
			coreFcn.message_and_countdown({"Difuse the bombs"}, message_countdown_timer)
		elseif message_countdown_timer == 0 then
			local state = savestate.create(saveStatePath)
			savestate.load(state)
			startFrame = emu.framecount()
		else
			coreFcn.display_centered_message({"Difuse the bombs"})
		end
	
		message_countdown_timer = message_countdown_timer - 1
    end

    if startFrame == nil then
        startFrame = emu.framecount()
    end

    if coreFcn.restart_or_abort() then
        reset_challenge()
    end

    if not damnBeat then
        checkVictory()
    end

    emu.frameadvance() -- Advance to the next frame
end
