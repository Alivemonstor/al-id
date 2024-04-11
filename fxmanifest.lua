fx_version 'cerulean'
game 'gta5'

description 'QB-Scoreboard'
version '1.2.1'

ui_page 'html/ui.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}
client_script 'client.lua'
server_script 'server.lua'

files {
    'html/*'
}

lua54 'yes'
