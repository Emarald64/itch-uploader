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
#func _enable_plugin() -> void:
	#pass
#
#func _disable_plugin() -> void:
	#pass

func _enter_tree() -> void:
	exportPlugin=preload("res://addons/itchio_uploader/export_plugin.gd").new()
	exportPlugin.editorPlugin=self
	add_export_plugin(exportPlugin)
	
	add_tool_menu_item("Log into itch.io",addInstance.bind(itchLoginPopup))
	add_tool_menu_item("Itch.io Project Settings",openSettings)
	add_tool_menu_item("Download Butler",addInstance.bind(butlerDownloadPopup))
	if not ItchSettings.username.is_empty() or not ItchSettings.gameName.is_empty():
		# Enable Statuses
		dock=preload('res://addons/itchio_uploader/itchio_statuses/itchio_statuses.tscn').instantiate()
		add_control_to_bottom_panel(dock,"Itch.io Statuses")

func openSettings()->void:
	var popup=itchSettingsPopup.instantiate()
	popup.settingsUpdated.connect(on_updated_itch_settings)
	add_child(popup)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_tool_menu_item("Log into itch.io")
	remove_tool_menu_item("Itch.io Project Settings")
	remove_tool_menu_item("Download Butler")
	remove_export_plugin(exportPlugin)
	if dock!=null:
		remove_control_from_bottom_panel(dock)
		dock.queue_free()


func on_updated_itch_settings()->void:
	print('updated settings')
	if ItchSettings.areSettingsComplete():
		# Enable Statuses
		dock=preload('res://addons/itchio_uploader/itchio_statuses/itchio_statuses.tscn').instantiate()
		add_control_to_bottom_panel(dock,"Itch.io Statuses")
	elif dock!=null:
		remove_control_from_bottom_panel(dock)

func addInstance(scene:PackedScene)->void:
	add_child(scene.instantiate())
	
