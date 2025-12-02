@tool
extends EditorExportPlugin

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

func _get_export_option_visibility(platform: EditorExportPlatform, option: String) -> bool:
	#print('checked visibility')
	#if option=='Channel':
		#print('channel '+str(get_option("Upload to Itch.io")))
		#return get_option("Upload to Itch.io")
	return true

func _should_update_export_options(platform: EditorExportPlatform) -> bool:
	if channelVisible!=_get_export_option_visibility(platform,"Channel"):
		channelVisible=_get_export_option_visibility(platform,"Channel")
		return true
	return false 

func changeOptions()->void:
	print('options should change')
	shouldChangeOptions=true

func _get_name()->String:
	return "Itch.io Uploader"

func _export_end() -> void:
	print('export path: '+get_export_preset().get_export_path())
	print("channel:"+str(get_option("Channel")))
	threadedUploadToButler(get_option("Channel"),get_export_preset().get_export_path())

func uploadToButler(channel:String,path:String):
	OS.execute("butler",["push",path,username+"/"+gameName+":"+channel],[],false,true)

func threadedUploadToButler(channel:String,path:String):
	if path.get_extension()!='zip':
		path=path.get_base_dir()
	var thread=Thread.new()
	thread.start(uploadToButler.bind(channel,path))
