shared_script "@bt_defender/module/shared.lua"



lua54 'yes'

fx_version 'adamant'

game 'gta5'

description 'SLOT MACHINE '

version '1.0.0'

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	'config.lua',
	'server.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'function.lua',
	'client.lua',
	
}
ui_page('ui/ui.html')

files {
    'ui/ui.html',
    'ui/*.js',
	'ui/*.png',
	'ui/img/*.png',
    'ui/style.css',
	'ui/*.ttf',
	'ui/sound/*.*'
	
}



