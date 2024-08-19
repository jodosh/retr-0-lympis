-- Initialize variables
local startFrame = nil
local mushroomPicked = false
local playerDied = false
local challengeName = "Get the first mushroom"

-- Function to check if Mario has picked up a mushroom
function checkMushroom()
    local powerupStatus = memory.readbyte(0x0756) -- Address for power-up status in SMB
    if powerupStatus == 1 and not mushroomPicked then
        mushroomPicked = true
        local endFrame = emu.framecount()
        local timeTaken = endFrame - startFrame

        -- Display the result on the screen
        gui.text(10, 10, challengeName)
        gui.text(10, 30, "Time to get mushroom: " .. timeTaken .. " frames")

        -- Update the screen
        emu.frameadvance()

        -- Pause the emulation indefinitely
        while true do
            gui.text(10, 10, challengeName)
            gui.text(10, 30, "Time to get mushroom: " .. timeTaken .. " frames")
            emu.frameadvance()

            -- Wait for 5 seconds, then quit
            if emu.framecount() - endFrame >= 300 then
                emu.exit()
            end
        end
    end
end

-- Function to check if Mario has died
function checkPlayerDeath()
    local lives = memory.readbyte(0x075A) -- Address for Mario's lives in SMB
    if lives < 2 and not playerDied then
        playerDied = true
        local endFrame = emu.framecount()

        -- Display death message
        gui.text(10, 10, "Challenge Failed: Mario Died!")
        emu.frameadvance()

        -- Pause for 5 seconds (300 frames) and then quit
        while true do
            gui.text(10, 10, "Challenge Failed: Mario Died!")
            emu.frameadvance()

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

    if not mushroomPicked then
        checkMushroom()
    end

    if not playerDied then
        checkPlayerDeath()
    end

    emu.frameadvance() -- Advance to the next frame
end
