@tool
extends EditorPlugin

var username:="Xanderath"
var gameName:="test"

var exportPlugin:EditorExportPlugin

const itchLoginPopup=preload("res://addons/itchio_uploader/itchlogin.tscn")
const itchSettingsPopup=preload("res://addons/itchio_uploader/itch_settings.tscn")

func _enter_tree() -> void:
	exportPlugin=preload("res://addons/itchio_uploader/export_plugin.gd").new()
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
