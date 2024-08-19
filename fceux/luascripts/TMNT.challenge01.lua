-- Initialize variables
local startFrame = nil
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

    if not damnBeat then
        checkVictory()
    end

    emu.frameadvance() -- Advance to the next frame
end
