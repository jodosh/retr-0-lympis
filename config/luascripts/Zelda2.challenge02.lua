local coreFcn = require("core_functions")

-- Initialize variables
local challengeName = "Beat Horse Head"
local saveStatePath = "../fcs/Z2HorseHeadChallenge.fcs"
local enemyHealthAddress = 0x00C7 -- Enemy 1 Health
local linkHealthAddress = 0x0774 -- Link's Health
local maxLinkHealth = 0xA0 -- Full health value for Link
local startFrame = nil
local bossSpawned = false
local bossDefeated = false
local linkDefeated = false
local countdownFrames = 0
local timeTaken = 0
local selectPressedLastFrame = false -- Track the Select button press
local message_display_time = 120 -- Display message for 2 seconds (120 frames)
local message_timer = 0
local final_time = nil

-- Function to convert frames to time in seconds and milliseconds
local function frames_to_time(frames)
    local fps = 60.0988
    local seconds = frames / fps
    local millis = (seconds - math.floor(seconds)) * 1000
    return string.format("%d.%03d", math.floor(seconds), math.floor(millis))
end

-- Function to wrap text to fit within a specified width
local function wrap_text(text, max_width)
    local wrapped_lines = {}
    local current_line = ""
    local words = {}
    for word in text:gmatch("%S+") do
        table.insert(words, word)
    end
    for _, word in ipairs(words) do
        local test_line = current_line .. (current_line == "" and "" or " ") .. word
        if #test_line * 4 <= max_width then
            current_line = test_line
        else
            table.insert(wrapped_lines, current_line)
            current_line = word
        end
    end
    if #current_line > 0 then
        table.insert(wrapped_lines, current_line)
    end
    return wrapped_lines
end

-- Function to display a centered message with wrapping and spacing
local function display_centered_message(lines)
    local screen_width = 256  -- NES screen width
    local screen_height = 240  -- NES screen height
    local line_height = 8  -- Height of a single line of text
    local line_spacing = 2  -- Space between lines
    local max_line_width = screen_width / 1.2  -- Maximum width of a line of text

    local total_lines = 0
    for _, message in ipairs(lines) do
        local wrapped_lines = wrap_text(message, max_line_width)
        total_lines = total_lines + #wrapped_lines
    end
    
    local start_y = (screen_height * .3) - ((total_lines / 2) * (line_height + line_spacing))
    
    for _, message in ipairs(lines) do
        local wrapped_lines = wrap_text(message, max_line_width)
        for i, wrapped_line in ipairs(wrapped_lines) do
            local text_width = #wrapped_line * 4
            local x = (screen_width - text_width) / 2.4
            local y = start_y + (i - 1) * (line_height + line_spacing)
            gui.text(x, y, wrapped_line, "white", "black")
        end
        start_y = start_y + (#wrapped_lines * (line_height + line_spacing))
    end
end

-- Function to get medal message based on final time
local function get_medal_message(final_time)
    local time_in_seconds = final_time / 60.0988
    if time_in_seconds > 120 then
        return {
            "You earned a bronze medal!",
            "MattD would be impressed"
        }
    elseif time_in_seconds > 30 then
        return {
            "You earned a silver medal!",
            "Jodosh would be impressed"
        }
    elseif time_in_seconds > 12 then
        return {
            "You earned a gold medal!",
            "Frosted Pears would be impressed"
        }
    else
        return {
            "You earned a platinum medal!",
            "Slack would be impressed"
        }
    end
end

-- Function to reset and set Link's health to full and reload save state
function resetChallenge()
    -- Reload the save state
    local state = savestate.create(saveStatePath)
    savestate.load(state)

    -- Set Link's health to full
    memory.writebyte(linkHealthAddress, maxLinkHealth)

    -- Reset variables
    startFrame = nil
    bossSpawned = false
    bossDefeated = false
    linkDefeated = false
    countdownFrames = 0
    timeTaken = 0
    final_time = nil
end

-- Function to check and display health
function checkHealth()
    local enemyHealth1 = memory.readbyte(enemyHealthAddress)
    local linkHealth = memory.readbyte(linkHealthAddress)

    -- Check if the boss has spawned (health > 0)
    if enemyHealth1 > 0 and not bossSpawned then
        bossSpawned = true
        startFrame = emu.framecount()
    end

    -- Check if Link's health is 0 (Link is defeated)
    if linkHealth == 0 and not linkDefeated then
        linkDefeated = true
        challengeName = "Challenge Failed - Link Defeated"
        countdownFrames = 300
    end

    -- Monitor the boss's health only if Link is still alive
    if bossSpawned and not linkDefeated then
        -- Check if the boss is defeated (health == 0)
        if enemyHealth1 == 0 and not bossDefeated then
            bossDefeated = true
            local endFrame = emu.framecount()
            timeTaken = endFrame - startFrame

            -- Calculate final time
            final_time = timeTaken

            -- Display the medal message
            local medal_message = get_medal_message(final_time)
            display_centered_message({
                "Congrats! You completed the challenge",
                "in " .. frames_to_time(final_time) .. " seconds",
                "",  -- Space between time and medal message
                medal_message[1],  -- First line of medal message
                medal_message[2]   -- Second line of medal message
            })

            -- Start the countdown
            countdownFrames = 300
            emu.pause()
        end
    end

    -- Display results and countdown
    if bossDefeated or linkDefeated then
        -- Countdown before quitting
        if countdownFrames > 0 then
            countdownFrames = countdownFrames - 1
        else
            emu.exit()
        end
    end
end

-- Main loop
while true do
    -- Check if the player pressed Select (mapped to P1's Select button)
    gui.text(10, 10, challengeName)
    -- Set Link's health to full
    memory.writebyte(linkHealthAddress, maxLinkHealth)

    if coreFcn.restart_or_abort() then
        resetChallenge()
    end

    selectPressedLastFrame = selectPressed

    checkHealth()
    emu.frameadvance() -- Advance to the next frame
end
