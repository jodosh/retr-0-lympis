-- Path to save state
local saveStatePath = "../fcs/CV1KillTheBat.fcs"

-- Function to determine the medal earned and display the time taken
local function get_medal_message(final_time)
    local time_in_seconds = final_time / 60.0988
    local time_message = string.format("Time: %.2f seconds", time_in_seconds)
    
    if time_in_seconds > 120 then
        return {
            "You earned a bronze medal!",
            "MattD would be impressed",
            time_message
        }
    elseif time_in_seconds > 30 then
        return {
            "You earned a silver medal!",
            "Jodosh would be impressed",
            time_message
        }
    elseif time_in_seconds > 12 then
        return {
            "You earned a gold medal!",
            "Frosted Pears would be impressed",
            time_message
        }
    else
        return {
            "You earned a platinum medal!",
            "Slack would be impressed",
            time_message
        }
    end
end

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
    for i = 1, 300 do
        gui.text(50, 50, "Dagger Only! Pro Tip: Just hold UP!")
        emu.frameadvance()
    end    
end

-- Function to check if the bat is defeated
local function isBatDefeated()
    local batHP = memory.readbyte(0x01A9)
    return batHP == 0
end

-- Function to display medal message
local function displayMedal(final_time)
    local message = get_medal_message(final_time)
    for i = 1, 200 do
        gui.text(50, 50, message[1])
        gui.text(50, 60, message[2])
        gui.text(50, 70, message[3]) -- Display the time taken
        emu.frameadvance()
    end
    emu.pause() -- Pause the emulation after displaying the message
end

-- Initialize the challenge
loadSaveState()
initializePlayer()

local startFrame = emu.framecount()
local batDefeated = false

while true do
    -- Ensure the player has the Dagger Sub Weapon and 60 hearts
    memory.writebyte(0x015B, 0x08) -- Give the Dagger Sub Weapon
    memory.writebyte(0x0071, 60)   -- Set hearts to 60

    -- Check for whip usage or if Select is pressed
    local input_state = joypad.get(1)
    local selectPressed = input_state["select"] or false
    
    if checkWhipUsage() or selectPressed then
        resetChallenge()
        startFrame = emu.framecount() -- Reset the start frame after reloading
    end

    -- Check if bat is defeated
    if isBatDefeated() then
        if not batDefeated then
            batDefeated = true -- Mark the bat as defeated
            local endFrame = emu.framecount()
            local final_time = endFrame - startFrame

            -- Display medal message for 200 frames, then pause
            displayMedal(final_time)
            break
        end
    else
        batDefeated = false -- Reset if bat health goes above 0 again
    end

    -- Advance the frame
    emu.frameadvance()
end
