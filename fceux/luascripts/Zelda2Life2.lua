-- Lua script for FCEUX

-- Define the path to your save state file
local saveStatePath = "../fcs/Z2Challenge4.fc0"

-- Memory addresses
local life_power_address = 0x0779
local transition_address = 0x600B

-- Variables to track time and state
local start_frame = nil
local life_leveled_up = false
local final_time = nil
local last_transition_value = nil
local message_display_time = 120 -- Display message for 2 seconds (120 frames)
local message_timer = 0
local exit_screen_message = false
local start_pressed_last_frame = false
local select_pressed_last_frame = false

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

-- Function to load the save state and reset the challenge
local function reset_challenge()
    local state = savestate.create(saveStatePath)
    savestate.load(state)
    start_frame = emu.framecount()
    life_leveled_up = false
    final_time = nil
    message_timer = message_display_time
    exit_screen_message = false -- Reset the exit screen message flag
end

-- ** Load the save state when the script starts **
reset_challenge()

-- Main loop
while true do
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

    -- Read the current life power and transition status from memory
    local current_life_power = memory.readbyte(life_power_address)
    local transition_value = memory.readbyte(transition_address)
    
    -- Start the timer when life power is 1
    if current_life_power == 1 and start_frame == nil then
        start_frame = emu.framecount()
    end
    
    -- Check if life power has increased to 2
    if current_life_power == 2 and not life_leveled_up then
        life_leveled_up = true
        if start_frame then
            final_time = emu.framecount() - start_frame
            local medal_message = get_medal_message(final_time)
            display_centered_message({
                "Congrats! You completed the Life 2 challenge",
                "in " .. frames_to_time(final_time) .. " seconds",
                "",  -- Space between time and medal message
                medal_message[1],  -- First line of medal message
                medal_message[2]   -- Second line of medal message
            })
            emu.pause()
        end
    end
    
    -- Check if the transition value indicates leaving the screen
    if transition_value == 124 and last_transition_value == 64 then
        reset_challenge()
        exit_screen_message = true -- Set the flag to display the "butt sniffer" message
    end
    
    -- Display the appropriate message after loading the save state
    if message_timer > 0 then
        if exit_screen_message then
            display_centered_message({
                "I said without exiting the screen",
                "butt sniffer"
            })
        else
            display_centered_message({
                "Life 2 Challenge",
                "Get Life 2 without leaving the screen"
            })
        end
        message_timer = message_timer - 1
    end

    -- Update the last transition value
    last_transition_value = transition_value

    -- Refresh the emulator screen
    emu.frameadvance()
end
