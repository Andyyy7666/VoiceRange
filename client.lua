local config = {
    x = 0.175,
    y = 0.94,
    scale = 0.35,

    Keybind = 20, -- https://docs.fivem.net/docs/game-references/controls/
    customKeybind = true, -- if you enable this then players can bind the key through their settings and not the Keybind above.

    enableBlueCircle = true, -- this will enable the blue circle to show you the distance you're voice can reach.
    makeHudSmallerWhileSpeaking = true, -- This will make the hud a little bit smaller when you're speaking.

    changeSpeakingDistance = true, -- This will change your voice distance based on what you've chosen. This is not recommended to be off unless you also want to turn off hearing and use this whole script only as a hud.
    changeHearingDistance = false, -- This will change your hearing distance based on what you've chosen. This is recommended to be off.

    ranges = {
        {distance = 2.0, name = "🔈"},
        {distance = 10.0, name = "🔉"},
        {distance = 30.0, name = "🔊"}
    }
}

-- Don't change anything below the config unless you know what you're doing. For support join the discord: https://discord.gg/eKFb5QM3YF
local keybindUsed = false
local isTalking = false
local CurrentChosenDistance = 2
local CurrentDistanceValue = config.ranges[CurrentChosenDistance].distance
local CurrentDistanceName = config.ranges[CurrentChosenDistance].name

function text(text, scale)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextOutline()
    SetTextJustification(0)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(config.x, config.y)
end

if config.customKeybind then
    RegisterCommand("+voiceDistance", function()
        keybindUsed = true
        keybindUsed = false
    end, false)
    RegisterCommand("-voiceDistance", function()
        keybindUsed = false
    end, false)
    RegisterKeyMapping("+voiceDistance", "Change Voice Proximity", "keyboard", "z")
end

-- Check if player is speaking
if config.makeHudSmallerWhileSpeaking then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(50)
            if NetworkIsPlayerTalking(PlayerId()) then
                isTalking = true
            else
                isTalking = false
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- change voice
        if IsControlJustPressed(0, config.Keybind) or keybindUsed then
            if CurrentChosenDistance == #config.ranges then
                CurrentChosenDistance = 1
            else
                CurrentChosenDistance = CurrentChosenDistance + 1
            end
            CurrentDistanceValue = config.ranges[CurrentChosenDistance].distance
            CurrentDistanceName = config.ranges[CurrentChosenDistance].name
            if config.changeSpeakingDistance then
                MumbleSetAudioInputDistance(CurrentDistanceValue)
            end
            if config.changeHearingDistance then
                MumbleSetAudioOutputDistance(CurrentDistanceValue)
            end
        end

        -- Blue circle
        if config.enableBlueCircle then
            if IsControlPressed(1, config.Keybind) or keybindUsed then
                local pedCoords = GetEntityCoords(PlayerPedId())
                DrawMarker(1, pedCoords.x, pedCoords.y, pedCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, CurrentDistanceValue * 2.0, CurrentDistanceValue * 2.0, 1.0, 40, 140, 255, 150, false, false, 2, false, nil, nil, false)
            end
        end

        -- HUD
        if config.makeHudSmallerWhileSpeaking and isTalking then
            text(CurrentDistanceName, config.scale / 1.2)
        else
            text(CurrentDistanceName, config.scale)
        end
    end
end)
