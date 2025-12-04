@tool
extends AcceptDialog
class_name ItchSettings

const settingsPath='res://addons/itchio_uploader/settings.txt'

static var username:=""
static var gameName:=""
static var butlerPath:=""

signal settingsUpdated

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

static func areSettingsComplete()->bool:
	return not username.is_empty() and not gameName.is_empty() and validateButlerPath()

static func validateButlerPath()->bool:
	if butlerPath.is_empty():
		push_warning("Butler path is not set. Press the install butler button in the tools menu or set the path to butler in the Itch.io project settings")
	elif not FileAccess.file_exists(butlerPath):
		push_warning("There is no file at the path for Butler. Press the install butler button in the tools menu or set the path to butler in the Itch.io project settings")
	elif OS.get_name()!="Windows" and FileAccess.get_unix_permissions(butlerPath)&(FileAccess.UNIX_EXECUTE_OWNER+FileAccess.UNIX_EXECUTE_GROUP+FileAccess.UNIX_EXECUTE_OTHER)==0:
		push_warning("You do not have permission to execute butler. Run `chmod +x "+butlerPath+"`")
	else:
		return true
	return false

func pressedOK()->void:
	username=%Username.text
	gameName=%"Game Name".text
	butlerPath=%"Butler Path".text
	saveSettingsToFile()
	settingsUpdated.emit()
