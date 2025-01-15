---[[
---Voici un script de TIG réalisé par S0ltrak pour DevHub's
---SUPPORT: https://discord.gg/3eSufdKtdH
---]]

Config = {}

Config.WebhookURL = "https://discord.com/api/webhooks/1317512652808785920/aXj06oE4w452clgQ7pOGV9ShGHB0PCi7iV5eABoNCsd0BpUcoCa7bN6oJ5UtmGqvWRkR" -- Webhook URL

Config.Locations = {
    vector3(3467.8217773438, 2572.7722167969, 15.390962600708),     -- Coordonnées des points de la zone
    vector3(3497.71875, 2607.4392089844, 13.161828041077),  -- Coordonnées des points de la zone
    vector3(3552.2849121094, 2588.5166015625, 8.4810571670532)  -- Coordonnées des points de la zone
}

Config.ZoneCenter = vector3(3493.341796875, 2583.1315917969, 13.646040916443)   -- Centre de la zone
Config.ZoneRadius = 100.0   -- Rayon de la zone
Config.DistanceTask = 2.0 -- Distance pour valider la tâche
Config.TaskDuration = 10000 -- Durée de la tâche en ms
 
Config.endTimeJail = "242.03019714355, -765.00384521484, 30.800825119019" -- Coordonnées de la sortie de la jail

Config.Unjail = "unjail" ---- Commande pour unjail le joueur 
Config.Jail = "jail" ---- Commande pour jail le joueur



Config.NotifyEndTimeJail = "✅ Vous êtes libéré de la jail"     -- Notification à la fin de la jail
Config.NotifyEndTIG = "✅ Vous avez fini votre TIG"     -- Notification à la fin du TIG
