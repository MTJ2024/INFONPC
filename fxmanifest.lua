fx_version 'cerulean'
game 'gta5'

author 'MTJ2024'
description 'Sichere serverseitige NPC-Resource mit clientseitiger Animation/Interaktion'
version '2.1.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

shared_scripts {
    'config.lua'
}