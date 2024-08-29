-- Function to write a command to a text file
function trigger_sound_event()
    local filename = "event.txt"  -- Define the filename to use for communication
    local file = io.open(filename, "w")  -- Open the file in write mode
    
    if file then
        file:write("play_sound")  -- Write the command to the file
        file:close()  -- Close the file
        print("Sound event triggered. Command written to file.")
    else
        print("Error: Unable to open file for writing.")
    end
end

-- Simulate a game loop
while true do
    -- Example condition to trigger the sound event
    -- Replace this with actual game logic (e.g., checking player position, score, etc.)
    local eventConditionMet = math.random(0, 100) > 50  -- Randomly simulate an event (5% chance)

    if eventConditionMet then
        trigger_sound_event()  -- Call the function to trigger the sound
        break  -- Exit the loop after triggering the event
    end

    -- Simulate a delay to mimic a game frame (e.g., 16 ms for 60 FPS)
    emu.frameadvance()
end

print("Game loop exited.")
