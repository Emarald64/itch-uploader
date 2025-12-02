@tool
extends EditorExportPlugin

var username:String
var gameName:String

func _get_export_options(platform: EditorExportPlatform) -> Array[Dictionary]:
	return [
		{
			"option":{"name":"Channel","type":Variant.Type.TYPE_STRING},
			"default_value":platform.get_os_name().to_lower(),
			"update_visibility":false,
		}
	]

func _get_name()->String:
	return "Itch.io Uploader"

func _export_end() -> void:
	print('export path: '+get_export_preset().get_export_path())
	print("channel:"+str(get_option("Channel")))

func uploadToButler(channel:String,path:String):
	OS.execute("butler",["push",path,username+"/"+gameName+":"+channel],[],false,true)

func threadedUploadToButler(channel:String,path:String):
	if path.get_extension()!='zip':
		path=path.get_base_dir()
	var thread=Thread.new()
	thread.start(uploadToButler.bind(channel,path))
