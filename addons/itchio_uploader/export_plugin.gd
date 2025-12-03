@tool
extends EditorExportPlugin

var butlerPath:String

var shouldChangeOptions:=true

var channelVisible:=false

var username:String
var gameName:String

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
			"option":{"name":"Itch.io/Version/Version file","type":Variant.Type.TYPE_STRING,"hint":PROPERTY_HINT_FILE_PATH},
			"default_value":"",
		}
	]

func _get_name()->String:
	return "Itch.io Uploader"

#func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	#print(get_option("Itch.io/Itch.io version file"))

func _export_end() -> void:
	#print('export path: '+get_export_preset().get_export_path())
	#print("channel:"+str(get_option("Channel")))
	if get_option("Itch.io/Upload to Itch.io"):
		threadedUploadToButler()

func uploadToButler(path:String,username:String,gameName:String,channel:String,version:="",versionPath:=""):
	print(butlerPath)
	print(path)
	print(username+"/"+gameName+":"+channel)
	var args=["push",path,username+"/"+gameName+":"+channel]
	if version!=null:
		args.append('--userversion')
		args.append(version)
	elif versionPath!="":
		args.append("--userversion-file")
		args.append(versionPath)
	OS.execute(butlerPath,args)

func threadedUploadToButler():
	var path=ProjectSettings.globalize_path("res://"+get_export_preset().get_export_path())
	if path.get_extension()!='zip':
		path=path.get_base_dir()
	ItchSettings.loadSettingsFromFile()
	#var output=[]
	var thread=Thread.new()
	thread.start(uploadToButler.bind(
		path,
		ItchSettings.username,
		ItchSettings.gameName,
		get_option("Itch.io/Channel"),
		ProjectSettings.get_setting("application/config/version") if get_option("Itch.io/Version/Use Godot project version") else "",
		get_option("Itch.io/Version/Itch.io version file")
		))
