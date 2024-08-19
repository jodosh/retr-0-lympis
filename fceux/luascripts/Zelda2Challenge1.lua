-- Initialize variables
local startFrame = nil
local challengeName = "Magic in the Dark"
local magicJarCollected = false
local countdownFrames = 0
local timeTaken = 0
local saveStateFile = "fceux/fcs/Zelda 2 - The Adventure of Link.fc0" -- Specify the save state file

-- Function to restart the challenge
function restartChallenge()
    -- Reload the specified save state file
    savestate.load(saveStateFile)

    -- Reset variables
    startFrame = nil
    magicJarCollected = false
    countdownFrames = 0
    timeTaken = 0
end

-- Function to check if Link has collected the magic jar
function checkMagicJar()
    local magicContainerStatus = memory.readbyte(0x0616) -- Monitor the magic container status
    if magicContainerStatus == 0xFE and not magicJarCollected then
        magicJarCollected = true
        countdownFrames = 300 -- Start the countdown after jar is collected

        local endFrame = emu.framecount()
        timeTaken = endFrame - startFrame

        -- Write the result to a file
        local file = io.open("Zelda2Challenge1.txt", "w")
        file:write(challengeName .. "\n")
        file:write("Time to collect magic jar: " .. timeTaken .. " frames\n")
        file:close()
    end

    -- Display the title on the screen
    gui.text(10, 10, challengeName)

    -- Display the result after the jar is collected
    if magicJarCollected then
        gui.text(10, 30, "Time to collect magic jar: " .. timeTaken .. " frames")
    end

    -- If countdown has started, display it and count down
    if countdownFrames > 0 then
        gui.text(10, 50, "Closing Challenge in: " .. countdownFrames .. " frames remaining")
        countdownFrames = countdownFrames - 1

        -- If countdown reaches 0, quit the emulator
        if countdownFrames == 0 then
            emu.exit()
        end
    end
end

-- Main loop
while true do
    if startFrame == nil then
        startFrame = emu.framecount()
    end

    -- Check for the "R" key press to restart the challenge
    if input.get()["R"] then
        restartChallenge()
    end

    checkMagicJar()
    emu.frameadvance() -- Advance to the next frame
end
