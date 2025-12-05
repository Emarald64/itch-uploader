@tool
extends Control
class_name itchStatus

static var uploadedGames:=Dictionary()

@onready var grid: GridContainer = %Grid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var base_color:Color=EditorInterface.get_editor_settings().get_setting('interface/theme/base_color')
	grid.theme.get_stylebox('panel','PanelContainer').bg_color=base_color
	%GridBackground.get_theme_stylebox("panel").bg_color=base_color.lightened(.2)
	if get_parent() is not SubViewport:
		refreshStatus()

func refreshStatus()->void:
	%Loading.show()
	var output:Array[String]=[]
	var thread=Thread.new()
	thread.start(OS.execute.bind(ItchSettings.butlerPath,['status',ItchSettings.username+'/'+ItchSettings.gameName],output))
	while thread.is_alive():
		await get_tree().process_frame
	thread.wait_to_finish()
	%Loading.hide()
	#print(output[0])
	for child in grid.get_children():
		child.free()
	var currentCol:=-1
	var currentRow:=0
	var currentChannel:String="none"
	for box in output[0].split("|").slice(1):
		if not box.begins_with('\n'):
			var formattedText:=box.strip_edges()
			currentCol+=1
			var icon:Texture2D
			match currentCol:
				0:
					if currentRow>0:
						currentChannel=formattedText
						icon=getChannelIcon(currentChannel)
				1:
					if currentRow>0:
						if uploadedGames.has(currentChannel):
							formattedText=Time.get_time_string_from_unix_time(uploadedGames.get(currentChannel))
						else:
							formattedText="unknown"
					else:
						formattedText="UPLOAD TIME"
				2:
					continue
				3:
					currentCol=-1
					currentRow+=1
			var panel=PanelContainer.new()
			panel.size_flags_horizontal=SIZE_EXPAND_FILL
			var container=HBoxContainer.new()
			panel.add_child(container)
			
			var label=Label.new()
			label.text=formattedText
			container.add_child(label)
			
			if icon!=null:
				var iconNode=TextureRect.new()
				iconNode.size.y=label.size.y
				iconNode.texture=icon
				iconNode.expand_mode=TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
				iconNode.modulate=Color.LIGHT_GRAY
				container.add_child(iconNode)
			
			grid.add_child(panel)

#static func formatTime(time:int) -> String:
	#return str(time/3600)+':'+str((time/60)%60).pad_zeros(2)+":"+str(time%60).pad_zeros(2)

static func getChannelIcon(channelName:String)->Texture2D:
	if "web" in channelName:
		return preload("res://addons/itchio_uploader/assets/html.svg")
	elif "win" in channelName:
		return preload("res://addons/itchio_uploader/assets/windows.svg")
	elif "mac" in channelName:
		return preload("res://addons/itchio_uploader/assets/macos.svg")
	elif "linux" in channelName:
		return preload("res://addons/itchio_uploader/assets/linux.svg")
	return null

func openGamePage() -> void:
	OS.shell_open("https://"+ItchSettings.username+".itch.io/"+ItchSettings.gameName)
