@tool
extends AcceptDialog
class_name ItchSettings

const settingsPath='res://addons/itchio_uploader/settings'

func _ready() -> void:
	# Read exising settings
	var file=FileAccess.open(settingsPath,FileAccess.READ)
	%Username.text=file.get_line()
	%"Project Name".text=file.get_line()
	%"Butler Path".text=file.get_line()

func pressedOK()->void:
	#Save settings to file
	var file=FileAccess.open(settingsPath,FileAccess.WRITE)
	file.store_line(%Username.text)
	file.store_line(%"Project Name".text)
	file.store_line(%"Butler Path".text)
	file.close()

static func setSetting(index:int,value:String):
	var file=FileAccess.open(settingsPath,FileAccess.READ)
	var settings=file.get_as_text().split('\n')
	settings[index]=value
	file.close()
	file=FileAccess.open(settingsPath,FileAccess.WRITE)
	for setting in settings:
		file.store_line(setting)
