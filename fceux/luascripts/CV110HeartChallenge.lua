-- Path to save state
local saveStatePath = "../fcs/CV1Get10Hearts.fcs"

-- Global variables to store the message to be displayed and the number of frames to display it
local displayMessage = nil
local displayFrames = 0
local pauseAfterFrames = false -- Flag to indicate that we should pause after displaying the message
local challengeCompleted = false -- Flag to indicate that the challenge has been completed

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

-- Function to initialize the player with 0 hearts
local function initializePlayer()
    memory.writebyte(0x0071, 0)   -- Set hearts to 0 at the start of the challenge
end

-- Function to reset the challenge if the player presses Select
local function resetChallenge()
    loadSaveState()
    initializePlayer()
    displayMessage = {"Collect 10 Hearts to Win!", "Good Luck!"}
    displayFrames = 300
    pauseAfterFrames = false -- Ensure we don't pause after reset
    challengeCompleted = false -- Reset challenge completion status
end

-- Function to check if the player has 10 hearts
local function has10Hearts()
    local hearts = memory.readbyte(0x0071)
    return hearts >= 10
end

-- Function to display medal message
local function displayMedal(final_time)
    displayMessage = get_medal_message(final_time)
    displayFrames = 200
    pauseAfterFrames = true -- Set the flag to pause after the frames are displayed
end

-- Initialize the challenge
loadSaveState()
initializePlayer()

local startFrame = emu.framecount()

while true do
    -- Display the current message if there is one
    if displayMessage and displayFrames > 0 then
        gui.text(50, 50, displayMessage[1])
        gui.text(50, 60, displayMessage[2] or "")
        gui.text(50, 70, displayMessage[3] or "")
        displayFrames = displayFrames - 1
    elseif pauseAfterFrames then
        emu.pause() -- Pause the emulation after displaying the message
        pauseAfterFrames = false -- Reset the flag after pausing to avoid random pauses
    end

    -- Check for if Select is pressed to reload the challenge
    local input_state = joypad.get(1)
    local selectPressed = input_state["select"]
    
    if selectPressed then
        resetChallenge()
        startFrame = emu.framecount() -- Reset the start frame after reloading
    end

    -- Check if player has reached 10 hearts
    if has10Hearts() and not challengeCompleted then
        local endFrame = emu.framecount()
        local final_time = endFrame - startFrame

        -- Display medal message for 200 frames, then pause
        displayMedal(final_time)
        challengeCompleted = true -- Mark the challenge as completed
    end

    -- Advance the frame
    emu.frameadvance()
end
