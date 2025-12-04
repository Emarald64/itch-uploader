@tool
extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Game Page".uri="https://"+ItchSettings.username+".itch.io/"+ItchSettings.gameName
	var base_color:Color=EditorInterface.get_editor_settings().get_setting('interface/theme/base_color')
	%Grid.theme.get_stylebox('panel','PanelContainer').bg_color=base_color
	$PanelContainer.get_theme_stylebox("panel").bg_color=base_color.lightened(.2)
	refreshStatus()

func refreshStatus()->void:
	var output:Array[String]=[]
	var thread=Thread.new()
	thread.start(OS.execute.bind(ItchSettings.butlerPath,['status',ItchSettings.username+'/'+ItchSettings.gameName],output))
	while thread.is_alive():
		await get_tree().process_frame
	thread.wait_to_finish()
	for child in %Grid.get_children():
		child.free()
	for box in output[0].split("|").slice(1):
		if not box.begins_with('\n'):
			var label=Label.new()
			label.text=box.strip_edges()
			var container=PanelContainer.new()
			container.size_flags_horizontal=SIZE_EXPAND_FILL
			container.add_child(label)
			%Grid.add_child(container)
