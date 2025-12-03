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
	
func downloadButler()->void:
	const baseURL='https://broth.itch.zone/butler/{1}/LATEST/archive/default'
	var osURLName:String
	match OS.get_name():
		"Windows":
			# screw it, assume 64-bits :,(
			osURLName='windows-amd64'
		"MacOS":
			osURLName='darwin-amd64'
		"Linux":
			osURLName="linux-amd64"
	var url=baseURL.format([osURLName])
	var request=HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(downloadFinished)
	var error=request.request(url)
	if error!=OK:
		print("An error occured downloading butler")

func downloadFinished(result, response_code, headers, body)->void:
	const butlerFolder='res://addons/itchio_uploader/butler/'
	const zipFilePath=butlerFolder+'butler.zip'
	# write file
	var file=FileAccess.open(zipFilePath,FileAccess.WRITE)
	file.store_buffer(body)
	file.close()
	
	var zipReader=ZIPReader.new()
	zipReader.open(zipFilePath)
	
	for zipFile in zipReader.get_files():
		var currFile=FileAccess.open(butlerFolder+zipFile,FileAccess.WRITE)
		currFile.store_buffer(zipReader.read_file(zipFile))
		currFile.close()

	var butlerFile:String
	if OS.get_name()!='Windows':
		butlerFile='butler'
		FileAccess.set_unix_permissions(butlerFolder+'butler',FileAccess.UNIX_EXECUTE_OWNER)
	else:
		butlerFile='butler.exe'
	#Store butler path
	ItchSettings.setSetting(3,butlerFolder+butlerFolder)
