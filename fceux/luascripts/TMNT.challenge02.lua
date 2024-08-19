-- Initialize variables
local startFrame = nil
local levelBeat = false
local playerDied = false
local challengeName = "Beat Rocksteady with Raph"
local message_display_time = 120 -- Display message for 2 seconds (120 frames)
local message_timer = message_display_time

-- Define the path to your save state file
local saveStatePath = "../fcs/TMNT.challenge02.fcs"
local start_pressed_last_frame = false
local select_pressed_last_frame = false

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

-- Function to check if you have beat Rocksteady
function checkVictory()
    local victoryStatus = memory.readbyte(0x0565) -- Address for rocksteady health
    if victoryStatus < 1 and not levelBeat then
        levelBeat = true
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

            -- Wait for 2 seconds, then quit
            if emu.framecount() - endFrame >= 120 then
                emu.pause()
            end
        end
    end
end

local function reset_challenge()    
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    startFrame = emu.framecount()
    final_time = nil
    message_timer = message_display_time
end

function checkDeath()
    local raphLife = memory.readbyte(0x0078)
    if raphLife == 0 and not playerDied then
        playerDied = true
        local endFrame = emu.framecount()

        -- Display death message
        gui.text(10, 10, "Challenge Failed: Raph Died!")
        emu.frameadvance()

        -- Pause for 5 seconds (300 frames) and then quit
        while true do
            gui.text(10, 10, "Challenge Failed: Raph Died!")
            emu.frameadvance()

            if emu.framecount() - endFrame >= 300 then
                reset_challenge()
            end
        end
    end
end

-- ** Load the save state when the script starts **
reset_challenge()


-- Main loop
while true do
    --Display Instructions
    if message_timer > 0 then
        display_centered_message({"Beat Rocksteady","You only get Craphael"})
        message_timer = message_timer -1
    end


    -- Check if the player pressed Select or Start (mapped to P1's Select and Start buttons)
    local input_state = joypad.get(1)
    local select_pressed = input_state["select"] or false
    local start_pressed = input_state["start"] or false

    -- Check if Start is held down and Select is pressed for restarting the challenge
    if start_pressed and not select_pressed_last_frame and select_pressed then
        reset_challenge()
    end

    -- Check if Select is held down and Start is pressed to close_emulator
    if select_pressed and not start_pressed_last_frame and start_pressed then
        emu.exit()
    end

    -- Update last frame button states
    start_pressed_last_frame = start_pressed
    select_pressed_last_frame = select_pressed

    if startFrame == nil then
        startFrame = emu.framecount()
    end

    if not levelBeat then
        checkVictory()
    end

    if not playerDied then
        checkDeath()
    end

    emu.frameadvance() -- Advance to the next frame
end
