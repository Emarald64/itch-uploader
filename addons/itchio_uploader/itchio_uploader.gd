@tool
extends EditorPlugin
#var username:="Xanderath"
#var gameName:="test"

var exportPlugin:EditorExportPlugin
var dock:Control

#var butlerPath:="/home/agiller/Documents/butler-linux-amd64/butler"

const itchLoginPopup=preload("res://addons/itchio_uploader/itchio_login/itchlogin.tscn")
const itchSettingsPopup=preload("res://addons/itchio_uploader/itchio_settings/itch_settings.tscn")
const butlerDownloadPopup=preload('res://addons/itchio_uploader/butler_downloader/butler_downloader.tscn')
const statusDock=preload('uid://ckb8dsahbr7w0')
#func _enable_plugin() -> void:
	#pass
#
#func _disable_plugin() -> void:
	#pass

func _enter_tree() -> void:
	ItchSettings.loadSettingsFromFile()
	exportPlugin=preload("res://addons/itchio_uploader/export_plugin.gd").new()
	exportPlugin.editorPlugin=self
	add_export_plugin(exportPlugin)
	
	add_tool_menu_item("Log into itch.io",addInstance.bind(itchLoginPopup))
	add_tool_menu_item("Itch.io Project Settings",openSettings)
	add_tool_menu_item("Download Butler",addInstance.bind(butlerDownloadPopup))
	if not ItchSettings.username.is_empty() or not ItchSettings.gameName.is_empty():
		# Enable Statuses
		itchStatus.loadChannels()
		dock=statusDock.instantiate()
		add_control_to_bottom_panel(dock,"Itch.io Statuses")

func openSettings()->void:
	var popup=itchSettingsPopup.instantiate()
	popup.settingsUpdated.connect(on_updated_itch_settings)
	add_child(popup)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	ItchSettings.saveSettingsToFile()
	remove_tool_menu_item("Log into itch.io")
	remove_tool_menu_item("Itch.io Project Settings")
	remove_tool_menu_item("Download Butler")
	remove_export_plugin(exportPlugin)
	if dock!=null:
		itchStatus.saveChannels()
		remove_control_from_bottom_panel(dock)
		dock.queue_free()


func on_updated_itch_settings()->void:
	print('updated settings')
	if ItchSettings.areSettingsComplete():
		# Enable Statuses
		dock=statusDock.instantiate()
		add_control_to_bottom_panel(dock,"Itch.io Statuses")
	elif dock!=null:
		remove_control_from_bottom_panel(dock)

func addInstance(scene:PackedScene)->void:
	add_child(scene.instantiate())
	
func _get_plugin_name() -> String:
	return "Itch.io Uploader"

func _get_plugin_icon() -> Texture2D:
	return preload("uid://btib8xi7csxop")
