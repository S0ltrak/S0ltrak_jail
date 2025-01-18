---[[
---Voici un script de TIG réalisé par S0ltrak pour DevHub's
---SUPPORT: https://discord.gg/3eSufdKtdH
---]]



ESX = exports["es_extended"]:getSharedObject()

local c, rt, i, blip = false, 0, 1, nil
local tasksLeft, reasonTIG, authorTIG
local locs = Config.Locations
local zoneCenter, zoneRadius = Config.ZoneCenter, Config.ZoneRadius
local DISTANCE_TASK = Config.DistanceTask
local TASK_DURATION = Config.TaskDuration

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(4000)
        CheckTIG()
    end
end)

AddEventHandler('esx:playerLoaded', function()
    Wait(4000)
    CheckTIG()
end)

function CheckTIG()
    ESX.TriggerServerCallback('s0ltrak:jail:getJail', function(data)
        if data and data.tasks and data.tasks > 0 then
            TriggerEvent('s0ltrak:jail:SendClientToJail', data)
        end
    end)
end

RegisterNetEvent('s0ltrak:jail:SendClientToJail', function(data)
    rt = data.tasks or 1
    reasonTIG = data.raison or "Inconnue"
    authorTIG = data.author or "Inconnu"
    tasksLeft = rt
    c = true
    i = 1
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, locs[1])
    SetEntityInvincible(playerPed, true)
    ESX.ShowNotification("🚨 TIG actif ~b~" .. rt .. "~s~ tâches")
    CreateOneBlip(locs[i])
end)

function CreateOneBlip(pos)
    RemoveOneBlip()
    blip = AddBlipForCoord(pos)
    SetBlipSprite(blip, 464)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 25)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("[~r~SANCTION~w~] TIG")
    EndTextCommandSetBlipName(blip)
end

function RemoveOneBlip()
    if blip then
        RemoveBlip(blip)
        blip = nil
    end
end

CreateThread(function()
    while true do
        local waitTime = 500
        if c then
            waitTime = 0
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            if #(coords - zoneCenter) > zoneRadius then
                SetEntityCoords(playerPed, zoneCenter)
                ESX.ShowNotification("🚨 Vous ne pouvez pas quitter la zone TIG.")
            end
            if locs[i] then
                DrawMarker(1, locs[i].x, locs[i].y, locs[i].z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                if #(coords - locs[i]) <= DISTANCE_TASK then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour travailler.")
                    if IsControlJustPressed(0, 38) then
                        DoTIGTask()
                    end
                end
            end
        else
            SetEntityInvincible(PlayerPedId(), false)
        end
        Wait(waitTime)
    end
end)

function DoTIGTask()
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_GARDENER_PLANT", 0, false)
    exports.rprogress:Start("Travail en cours...", TASK_DURATION)
    ClearPedTasksImmediately(playerPed)
    rt = rt - 1
    tasksLeft = rt
    TriggerServerEvent('s0ltrak:jail:updateCommunityService', rt)
    if rt <= 0 then
        TriggerServerEvent('s0ltrak:jail:finishjailTime')
        c = false
        ESX.ShowNotification(Config.NotifyEndTIG)
        RemoveOneBlip()
        SetEntityInvincible(playerPed, false)
    else
        ESX.ShowNotification("🚨 Il vous reste ~r~" .. rt .. " ~w~Tâches restantes")
        i = i + 1
        if i > #locs then i = 1 end
        CreateOneBlip(locs[i])
    end
end

RegisterNetEvent('s0ltrak:jail:finishjailTime', function()
    c = false
    local playerPed = PlayerPedId()
    RemoveOneBlip()
    SetEntityInvincible(playerPed, false)
    SetEntityCoords(playerPed, 242.03019714355, -765.00384521484, 30.800825119019)
    ESX.ShowNotification(Config.NotifyEndTimeJail)
end)


print("Script réalisé par ~r~S0ltrak~w~ pour ~g~DevHub's~w~")
