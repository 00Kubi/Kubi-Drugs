fx_version 'cerulean'
game 'gta5'

author 'Kubi'
description 'System narkotyków dla QBCore z zabezpieczeniami serwerowymi'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/pl.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/menus.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/security.lua'
}

lua54 'yes' 