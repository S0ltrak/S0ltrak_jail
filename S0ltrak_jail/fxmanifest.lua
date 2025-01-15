fx_version "cerulean"
game "gta5" 

shared_scripts {
    "config.lua",
}


server_scripts {
    "@oxmysql/lib/MySQL.lua",

    "sv_jail.lua",
}


client_scripts {
    "cl_jail.lua",
}