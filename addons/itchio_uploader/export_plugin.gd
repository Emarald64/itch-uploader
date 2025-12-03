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
			"option":{'name':'Itch.io',"usage":PropertyUsageFlags.PROPERTY_USAGE_CATEGORY,"type":Variant.Type.TYPE_NIL},
			"default_value":null
		},
		{
			"option":{"name":"Upload to Itch.io","type":Variant.Type.TYPE_BOOL},
			"default_value":false,
		},
		{
			"option":{"name":"Channel","type":Variant.Type.TYPE_STRING},
			"default_value":platform.get_os_name().to_lower(),
		}
	]

func _get_name()->String:
	return "Itch.io Uploader"

func _export_end() -> void:
	#print('export path: '+get_export_preset().get_export_path())
	#print("channel:"+str(get_option("Channel")))
	if get_option("Upload to Itch.io"):
		threadedUploadToButler(get_option("Channel"),ProjectSettings.globalize_path("res://"+get_export_preset().get_export_path()))

func uploadToButler(path:String,username:String,gameName:String,channel:String,output:Array):
	print(butlerPath)
	print(path)
	print(username+"/"+gameName+":"+channel)
	OS.execute(butlerPath,["push",path,username+"/"+gameName+":"+channel],output)

func threadedUploadToButler(channel:String,path:String):
	if path.get_extension()!='zip':
		path=path.get_base_dir()
	#print(path)
	#read settings
	var file=FileAccess.open('res://addons/itchio_uploader/settings',FileAccess.READ)
	var username=file.get_line()
	var gameName=file.get_line()
	file.close()
	var output=[]
	var thread=Thread.new()
	thread.start(uploadToButler.bind(path,username,gameName,channel,output))
	thread.wait_to_finish()
