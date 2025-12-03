@tool
extends EditorPlugin

var username:="Xanderath"
var gameName:="test"

var exportPlugin:EditorExportPlugin

var butlerPath:="/home/agiller/Documents/butler-linux-amd64/butler"

const itchLoginPopup=preload("res://addons/itchio_uploader/itchio_login/itchlogin.tscn")
const itchSettingsPopup=preload("res://addons/itchio_uploader/itchio_settings/itch_settings.tscn")

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	exportPlugin=preload("res://addons/itchio_uploader/export_plugin.gd").new()
	
	exportPlugin.butlerPath = butlerPath
	add_export_plugin(exportPlugin)
	
	add_tool_menu_item("Log into itch.io",itchIoLogin)
	add_tool_menu_item("Itch.io Project Settings",openSettings)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_tool_menu_item("Log into itch.io")
	remove_tool_menu_item("Itch.io Project Settings")
	remove_export_plugin(exportPlugin)

func itchIoLogin()->void:
	var popup=itchLoginPopup.instantiate()
	add_child(popup)
	#popup.get_node("VBoxContainer/LinkButton").uri=await getItchLoginLink()
	#popup.get_node("VBoxContainer/LinkButton").text='Link'
	
func openSettings()->void:
	var popup=itchSettingsPopup.instantiate()
	add_child(popup)
