@tool
extends AcceptDialog

const settingsPath='res://addons/itchio_uploader/settings'

func _ready() -> void:
	# Read exising settings
	var file=FileAccess.open(settingsPath,FileAccess.READ)
	%Username.text=file.get_line()
	%"Project Name".text=file.get_line()

func pressedOK()->void:
	#Save settings to file
	var file=FileAccess.open(settingsPath,FileAccess.WRITE)
	file.store_line(%Username.text)
	file.store_line(%"Project Name".text)
	file.close()
