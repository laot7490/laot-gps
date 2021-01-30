fx_version "bodacious"

game "gta5"
author "laot"

client_scripts {
    "@laot-core/locale.lua",
    "locales/tr.lua",
    "config.lua",
    "warmenu.lua",
    "client/main.lua"
}

server_scripts {
    "@laot-core/locale.lua",
    "locales/tr.lua",
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server/main.lua"
}

dependency "laot-core"