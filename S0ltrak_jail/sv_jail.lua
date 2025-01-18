---[[
---Voici un script de TIG réalisé par S0ltrak pour DevHub's
---SUPPORT: https://discord.gg/3eSufdKtdH
---]]


ESX = exports["es_extended"]:getSharedObject()

local jailData, antispam = {}, {}

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        Wait(1000)
        LoadJail()
    end
end)

function LoadJail()
    MySQL.Async.fetchAll("SELECT * FROM jail", {}, function(rows)
        jailData = {}
        for _, v in ipairs(rows) do
            jailData[v.identifier] = {
                identifier = v.identifier,
                tasks = v.tasks,
                raison = v.raison or "",
                date = v.date or ""
            }
        end
    end)
end

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    local licenseID
    for _, id in pairs(GetPlayerIdentifiers(playerId)) do
        if string.sub(id, 1, 8) == "license:" then
            licenseID = id
            break
        end
    end
    if licenseID then
        xPlayer.identifier = licenseID
    end
end)

function SendToDiscord(title, description)
    PerformHttpRequest(Config.WebhookURL, function() end, 'POST', json.encode({
        username = "TIG",
        embeds = {{
            title = title,
            description = description,
            color = 16711680
        }}
    }), {['Content-Type'] = 'application/json'})
end

ESX.RegisterServerCallback('s0ltrak:jail:getJail', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        cb({tasks = 0, raison = ""})
        return
    end
    local identifier = xPlayer.identifier
    if jailData[identifier] then
        cb({tasks = jailData[identifier].tasks, raison = jailData[identifier].raison})
    else
        cb({tasks = 0, raison = ""})
    end
end)

RegisterNetEvent('s0ltrak:jail:updateCommunityService', function(tasksLeft)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local identifier = xPlayer.identifier
    if jailData[identifier] then
        if antispam[src] then
            DropPlayer(src, "Cheat: spam update")
            return
        end
        antispam[src] = true
        Citizen.SetTimeout(3000, function() antispam[src] = nil end)
        local oldTasks = jailData[identifier].tasks
        if tasksLeft < 0 or tasksLeft < (oldTasks - 2) then
            DropPlayer(src, "Cheat: tasks incohérent")
            return
        end
        jailData[identifier].tasks = tasksLeft
        MySQL.Async.execute("UPDATE jail SET tasks=@tasks WHERE identifier=@id", {
            ["@tasks"] = tasksLeft,
            ["@id"] = identifier
        })
    else
        DropPlayer(src, "Cheat: update alors que pas en TIG")
    end
end)

RegisterNetEvent('s0ltrak:jail:finishjailTime', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local identifier = xPlayer.identifier
    if jailData[identifier] then
        jailData[identifier] = nil
        MySQL.Async.execute("DELETE FROM jail WHERE identifier=@id", {["@id"] = identifier})
        TriggerClientEvent('s0ltrak:jail:finishjailTime', src)
        SendToDiscord("TIG terminé", "Identifier: " .. identifier)
    end
end)

RegisterCommand(Config.Jail, function(source, args)
    local xAdmin = ESX.GetPlayerFromId(source)
    if not xAdmin and source ~= 0 then return end
    local targetId = tonumber(args[1])
    local nbTasks = tonumber(args[2])
    local raison = table.concat(args, " ", 3)
    if not targetId or not nbTasks or nbTasks <= 0 then
        if source ~= 0 then
            TriggerClientEvent('esx:showNotification', source, "🚨 La commande est : /jail [id] [nbTIG] [raison]")
        end
        return
    end
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        if source ~= 0 then
            TriggerClientEvent('esx:showNotification', source, "🚨 Le joueur n'est pas connecté")
        end
        return
    end
    if source ~= 0 then
        local group = xAdmin.getGroup()
        if group ~= "admin" and group ~= "superadmin" then
            TriggerClientEvent('esx:showNotification', source, "🚨 Vous n'avez pas la permission")
            return
        end
    end
    if not raison or raison == "" then
        raison = "Aucune raison"
    end
    local identifier = xTarget.identifier
    if jailData[identifier] then
        if source ~= 0 then
            TriggerClientEvent("esx:showNotification", source, '🚨 Le joueur est déjà en TIG')
        end
        return
    end
    local dateNow = os.date("%d/%m/%Y %H:%M:%S")
    MySQL.Async.execute("INSERT INTO jail(identifier, tasks, raison, date) VALUES(@id, @tasks, @r, @d) ON DUPLICATE KEY UPDATE tasks=@tasks, raison=@r, date=@d", {
        ['@id'] = identifier,
        ['@tasks'] = nbTasks,
        ['@r'] = raison,
        ['@d'] = dateNow
    })
    jailData[identifier] = {identifier = identifier, tasks = nbTasks, raison = raison, date = dateNow}
    TriggerClientEvent('s0ltrak:jail:SendClientToJail', targetId, jailData[identifier])
    if source ~= 0 then
        TriggerClientEvent("esx:showNotification",source, "🚨 Joueur en TIG pour " .. nbTasks .. " tâches")
    end
    SendToDiscord("Mise en TIG", "Staff: " .. (source == 0 and "Console" or xAdmin.identifier) .. " -> " .. identifier .. "\nTâches:" .. nbTasks .. "\nRaison:" .. raison)
end)

RegisterCommand(Config.Unjail, function(source, args)
    if not args[1] then
        if source ~= 0 then
            TriggerClientEvent('esx:showNotification', source, "🚨 La commande est : /unjail [id]")
        end
        return
    end
    local xAdmin = ESX.GetPlayerFromId(source)
    local targetId = tonumber(args[1])
    local xTarget = ESX.GetPlayerFromId(targetId)
    if not xTarget then
        if source ~= 0 then
            TriggerClientEvent('esx:showNotification', source, "🚨 Le joueur n'est pas connecté")
        end
        return
    end
    if source ~= 0 then
        local group = xAdmin and xAdmin.getGroup() or "user"
        if group ~= "admin" and group ~= "superadmin" then
            TriggerClientEvent('esx:showNotification', source, "🚨 Vous n'avez pas la permission")
            return
        end
    end
    local identifier = xTarget.identifier
    if jailData[identifier] then
        jailData[identifier] = nil
        MySQL.Async.execute("DELETE FROM jail WHERE identifier=@id", {["@id"] = identifier})
        TriggerClientEvent('s0ltrak:jail:finishjailTime', targetId)
        if source ~= 0 then
            TriggerClientEvent('esx:showNotification', source, "✅ Le joueur a été unjail")
        end
        TriggerClientEvent('esx:showNotification', targetId, "✅ Vous avez été libéré de la jail")
        SendToDiscord("UnJail", "Staff:" .. (source == 0 and "Console" or xAdmin.identifier) .. " => " .. identifier)
    else
        if source ~= 0 then
            TriggerClientEvent('esx:showNotification', source, "🚨 Le joueur n'est pas en TIG")
        end
    end
end)


print("Script réalisé par ^1S0ltrak^7 pour ^2DevHub's^7")
