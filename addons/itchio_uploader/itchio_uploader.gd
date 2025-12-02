@tool
extends EditorPlugin

var username:="Xanderath"
var gameName:="test"

var exportPlugin:EditorExportPlugin

func _enable_plugin() -> void:
	# Add autoloads here.
	#print('enabled plugin')
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	exportPlugin=preload("res://addons/itchio_uploader/export_plugin.gd").new()
	add_export_plugin(exportPlugin)
	
	#add_tool_menu_item("Log into itch.io",itchIoLogin)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	#remove_tool_menu_item("Log into itch.io")
	remove_export_plugin(exportPlugin)

#func getItchLoginLink()->String:
	#print('opening butler')
	#var butlerLoginStdio=OS.execute_with_pipe('/home/agiller/Documents/butler-linux-amd64/butler',['login'])['stdio']
	#await get_tree().create_timer(0.5).timeout
	#var butlerOutput=butlerLoginStdio.get_as_text()
	#print(butlerOutput)
	#var urlStartIndex=butlerOutput.find("https://itch.io/user/")
	#var urlEndIndex=butlerOutput.find(' ',urlStartIndex)
	#var url=butlerOutput.substr(urlStartIndex,urlEndIndex-urlStartIndex)
	#print(url)
	#return url
#
#func itchIoLogin()->void:
	#print(await getItchLoginLink())
	#print('run butler')
	#OS.execute('',['login'],[],false,true)
	#print('logged in')
