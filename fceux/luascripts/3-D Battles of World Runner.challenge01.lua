-- Initialize variables
local startFrame = nil
local bossBeat = false
local challengeName = "Beat Boss 1"

-- Function to check if Mario has picked up a mushroom
function checkMushroom()
    local powerupStatus = memory.readbyte(0x00EE) -- Address for world
    if powerupStatus == 1 and not bossBeat then
        bossBeat = true
        local endFrame = emu.framecount()
        local timeTaken = endFrame - startFrame

        -- Display the result on the screen
        gui.text(10, 10, challengeName)
        gui.text(10, 30, "Beat Boss 1: " .. timeTaken .. " frames")

        -- Update the screen
        emu.frameadvance()

        local file = io.open("3Dworld.txt", "a")

        -- Pause the emulation indefinitely
        while true do
            gui.text(10, 10, challengeName)
            gui.text(10, 30, "Beat Boss 1: " .. timeTaken .. " frames")
            emu.frameadvance()

            -- Wait for 5 seconds, then quit
            if emu.framecount() - endFrame >= 300 then
                -- Write the timeTaken to the file
                file:write(timeTaken .. "\n")
                emu.exit()
            end
        end
    end
end

-- Main loop
while true do
    if startFrame == nil then
        startFrame = emu.framecount()
    end

    if not mushroomPicked then
        checkMushroom()
    end

    emu.frameadvance() -- Advance to the next frame
end
