@tool
extends EditorExportPlugin

var editorPlugin:EditorPlugin

const uploadPopup=preload("res://addons/itchio_uploader/upload_progress/upload_progress.tscn")

func _get_export_options(platform: EditorExportPlatform) -> Array[Dictionary]:
	return [
		{
			"option":{"name":"Itch.io/Upload to Itch.io","type":Variant.Type.TYPE_BOOL},
			"default_value":true,
		},
		{
			"option":{"name":"Itch.io/Channel","type":Variant.Type.TYPE_STRING},
			"default_value":platform.get_os_name().to_lower(),
		},
		{
			"option":{"name":"Itch.io/Version/Use Godot project version","type":Variant.Type.TYPE_BOOL},
			"default_value":true,
		},
		{
			"option":{"name":"Itch.io/Version/Version file","type":Variant.Type.TYPE_STRING,"hint":PROPERTY_HINT_FILE},
			"default_value":"",
		}
	]

func _get_name()->String:
	return "Itch.io Uploader"

func _export_end() -> void:
	if get_option("Itch.io/Upload to Itch.io") and ItchSettings.areSettingsComplete():
		uploadToButler()

func uploadToButler():
	var path=ProjectSettings.globalize_path("res://"+get_export_preset().get_export_path())
	if path.get_extension()!='zip':
		path=path.get_base_dir()
	ItchSettings.loadSettingsFromFile()
	var args=["push",path,ItchSettings.username+"/"+ItchSettings.gameName+":"+get_option("Itch.io/Channel")]
	if get_option("Itch.io/Version/Use Godot project version"):
		args.append('--userversion')
		args.append(ProjectSettings.get_setting("application/config/version"))
	elif get_option("Itch.io/Version/Itch.io version file")!="":
		args.append("--userversion-file")
		args.append(get_option("Itch.io/Version/Itch.io version file"))
	var uploadPipe=OS.execute_with_pipe(ItchSettings.butlerPath,args)
	var popup=uploadPopup.instantiate()
	popup.uploadPipe=uploadPipe
	popup.channel=get_option("Itch.io/Channel")
	editorPlugin.add_child(popup)
