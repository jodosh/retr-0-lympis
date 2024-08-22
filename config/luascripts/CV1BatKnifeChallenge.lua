local coreFcn = require("core_functions")

-- Path to save state
local saveStatePath = "../fcs/CV1KillTheBat.fcs"
local start_frame = nil
local final_time = nil
local countdown_frames = 120 -- Number of frames for the countdown (180 = 3 seconds)
local message_countdown_timer = countdown_frames
coreFcn.set_medal_times(120, 30, 12)

-- Function to load the save state
local function loadSaveState()
    local state = savestate.create(saveStatePath)
    savestate.load(state)
end

-- Function to give the player the Dagger Sub Weapon and 60 hearts
local function initializePlayer()
    memory.writebyte(0x015B, 0x08) -- Give the Dagger Sub Weapon
    memory.writebyte(0x0071, 60)   -- Set hearts to 60
    memory.writebyte(0x01A9, 32)   -- Reset bat health (if needed)
end

-- Function to check if the player used the whip
local function checkWhipUsage()
    local whipStatus = memory.readbyte(0x1434)
    if whipStatus == 1 or whipStatus == 3 then
        return true
    end
    return false
end

-- Function to reset the challenge if the player cheated or pressed Select
local function resetChallenge()
    loadSaveState()
    initializePlayer()
    message_countdown_timer = countdown_frames
    final_time = nil
    start_frame = nil
end

-- Function to check if the bat is defeated
local function isBatDefeated()
    local batHP = memory.readbyte(0x01A9)
    return batHP == 0
end

-- Function to display medal message
local function displayMedal(final_time)
    local medal_message = coreFcn.get_medal_message(final_time)
        coreFcn.display_centered_message({
            "Congrats! You completed challenge",
            "in " .. coreFcn.frames_to_time(final_time) .. " seconds",
            "",  -- Space between time and medal message
            medal_message[1],  -- First line of medal message
            medal_message[2]   -- Second line of medal message
        })
end

-- Initialize the challenge
loadSaveState()
initializePlayer()

local start_frame = emu.framecount()
local batDefeated = false

while true do
    coreFcn.display_title({"Castlevania - Beat the bat"})

    -- Ensure the player has the Dagger Sub Weapon and 60 hearts
    memory.writebyte(0x015B, 0x08) -- Give the Dagger Sub Weapon
    memory.writebyte(0x0071, 60)   -- Set hearts to 60

    -- Display Instructions and Countdown (-120 so it keeps the message for an extra 2 seconds after countdown)
    if message_countdown_timer >= -120 then
		-- Do the Countdown
		if message_countdown_timer > 0 then 
			coreFcn.message_and_countdown({"Beat the bat"}, message_countdown_timer)
		elseif message_countdown_timer == 0 then
			local state = savestate.create(saveStatePath)
			savestate.load(state)
			start_frame = emu.framecount()
		else
			coreFcn.display_centered_message({"Beat the bat"})
		end
	
		message_countdown_timer = message_countdown_timer - 1
    end
    
    if checkWhipUsage() then
        resetChallenge()
    end

    -- Check if bat is defeated
    if isBatDefeated() then
        local endFrame = emu.framecount()
        local final_time = endFrame - start_frame
        
        -- Display medal message for 200 frames, then pause
        displayMedal(final_time)
        emu.pause()        
    end

    if coreFcn.restart_or_abort() then
        resetChallenge()
    end

    -- Advance the frame
    emu.frameadvance()
end
