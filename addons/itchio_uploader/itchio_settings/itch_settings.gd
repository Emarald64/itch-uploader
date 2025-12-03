@tool
extends AcceptDialog
class_name ItchSettings

const settingsPath='res://addons/itchio_uploader/settings.txt'

static var username:=""
static var gameName:=""
static var butlerPath:=""

static func _static_init() -> void:
	loadSettingsFromFile()

func _ready() -> void:
	%Username.text=username
	%"Game Name".text=gameName
	%"Butler Path".text=butlerPath

static func loadSettingsFromFile()->void:
	# Read exising settings
	if FileAccess.file_exists(settingsPath):
		var file=FileAccess.open(settingsPath,FileAccess.READ)
		username=file.get_line()
		gameName=file.get_line()
		butlerPath=file.get_line()
		file.close()

static func saveSettingsToFile()->void:
	#Save settings to file
	var file=FileAccess.open(settingsPath,FileAccess.WRITE)
	file.store_line(username)
	file.store_line(gameName)
	file.store_line(butlerPath)
	file.close()

func pressedOK()->void:
	username=%Username.text
	gameName=%"Game Name".text
	butlerPath=%"Butler Path".text
	saveSettingsToFile()
