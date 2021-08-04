-- Config
local Config = {
	x = 0.175,
	y = 0.94,
    scale = 0.35,

    WhisperDistance = 1.0,
    NormalDistance = 10.0,
    ShoutingDistance = 30.0,

    -- https://docs.fivem.net/docs/game-references/controls/
    Keybind = 20
}
-- Don't change anything below the config unless you know what you're doing. For support join the discord: https://discord.gg/eKFb5QM3YF

-- Variables
local InputWhisper = false
local InputNormal = true
local InputShouting = false
local isTalking = false
local CurrentDistance = Config.NormalDistance

-- Text function
function InputText(text, scale)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextOutline()
	SetTextJustification(0)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(Config.x, Config.y)
end

-- change voice
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)

        if IsControlJustPressed(0, Config.Keybind) then
            if InputWhisper == true then
                MumbleSetAudioInputDistance(Config.NormalDistance)
                -- MumbleSetAudioOutputDistance(Config.NormalDistance)
                CurrentDistance = Config.NormalDistance
                InputWhisper = false
                InputNormal = true
                InputShouting = false
            elseif InputNormal == true then
                MumbleSetAudioInputDistance(Config.ShoutingDistance)
                -- MumbleSetAudioOutputDistance(Config.ShoutingDistance)
                CurrentDistance = Config.ShoutingDistance
                InputWhisper = false
                InputNormal = false
                InputShouting = true
            elseif InputShouting == true then
                MumbleSetAudioInputDistance(Config.WhisperDistance)
                -- MumbleSetAudioOutputDistance(Config.WhisperDistance)
                CurrentDistance = Config.WhisperDistance
                InputWhisper = true
                InputNormal = false
                InputShouting = false
            end
        end
        if IsControlPressed(1, Config.Keybind) then
            local pedCoords = GetEntityCoords(PlayerPedId())
            DrawMarker(1, pedCoords.x, pedCoords.y, pedCoords.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, CurrentDistance * 2.0, CurrentDistance * 2.0, 1.0, 40, 140, 255, 150, false, false, 2, false, nil, nil, false)
        end
    end
end)

-- Check if player is speaking
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(50)

        if isTalking == false then
            if NetworkIsPlayerTalking(PlayerId()) then
                isTalking = true
            end
        else
            if NetworkIsPlayerTalking(PlayerId()) == false then
                isTalking = false
            end
        end
	end
end)

-- HUD
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if InputWhisper == true and isTalking == false then
            InputText("🔈", Config.scale)
        elseif InputNormal == true and isTalking == false then
            InputText("🔉", Config.scale)
        elseif InputShouting == true and isTalking == false then
            InputText("🔊", Config.scale)
        elseif InputWhisper == true and isTalking == true then
            InputText("🔈", Config.scale / 1.2)
        elseif InputNormal == true and isTalking == true then
            InputText("🔉", Config.scale / 1.2)
        elseif InputShouting == true and isTalking == true then
            InputText("🔊", Config.scale / 1.2)
        end
    end
end)