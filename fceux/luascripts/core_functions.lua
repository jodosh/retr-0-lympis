-- Variables to track time and state
local message_display_time = 120 -- Display message for 2 seconds (120 frames)
local message_timer = 0
local start_pressed_last_frame = false
local select_pressed_last_frame = false
local down_pressed_last_frame = false
local silver_time
local gold_time
local platinum_time

-- Function to convert frames to time in seconds and milliseconds
local function frames_to_time(frames)
    local fps = 60.0988
    local seconds = frames / fps
    local millis = (seconds - math.floor(seconds)) * 1000
    return string.format("%d.%03d", math.floor(seconds), math.floor(millis))
end

local function display_title(text)
    local title = text[1]
    local x = 10
    local y = 10
    gui.text(x, y, title, "white", "black")
end

local function set_medal_times(time_to_silver, time_to_gold, time_to_platinum)
    silver_time = time_to_silver
    gold_time = time_to_gold
    platinum_time = time_to_platinum
end

-- Function to get medal message based on final time
local function get_medal_message(final_time)
    local time_in_seconds = final_time / 60.0988
    if time_in_seconds > silver_time then
        return {
            "You earned a bronze medal!",
            "MattD would be impressed"
        }
    elseif time_in_seconds > gold_time then
        return {
            "You earned a silver medal!",
            "Jodosh would be impressed"
        }
    elseif time_in_seconds > platinum_time then
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

-- Function to display a message and countdown to start
local function message_and_countdown(lines, current_countdown_frame)
	if current_countdown_frame > 0 then 
		joypad.set(1, { start = false, select = false, up = false, down = false, left = false, right = false, A = false, B = false })  -- Lock any button during countdown
	
		local seconds_remaining = math.ceil(current_countdown_frame / 60)	-- calculate the quotient (seconds remaining) on the countdown
		
		table.insert(lines, "Starting in " .. seconds_remaining) -- Add the Starting in X seconds to the centered message.

		display_centered_message(lines)
	end
end

--Function to check if we should reset
local function restart_or_abort()
-- Check if the player pressed Select or Start (mapped to P1's Select and Start buttons)
    local input_state = joypad.get(1)
    local select_pressed = input_state["select"] or false
    local start_pressed = input_state["start"] or false
    local down_pressed = input_state["down"] or false

    -- Check if Start is held down and Select is pressed for restarting the challenge
    if start_pressed and not select_pressed_last_frame and not down_pressed_last_frame and select_pressed then
        return true
    end

    -- Check if Select is held down and Start is pressed to close_emulator
    if select_pressed and down_pressed and not start_pressed_last_frame and start_pressed then
        emu.exit()
    end

    -- Update last frame button states
    start_pressed_last_frame = start_pressed
    select_pressed_last_frame = select_pressed
    down_pressed_last_frame = down_pressed
    return false
end

return {
    display_centered_message = display_centered_message,
    message_and_countdown = message_and_countdown,
    frames_to_time = frames_to_time,
    restart_or_abort = restart_or_abort,
    display_title = display_title,
    set_medal_times = set_medal_times,
    get_medal_message = get_medal_message
}
