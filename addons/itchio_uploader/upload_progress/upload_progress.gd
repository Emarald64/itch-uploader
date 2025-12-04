@tool
extends ConfirmationDialog

var uploadPipe:Dictionary

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#print('created progress popup')
	#print(get_parent().name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not uploadPipe.is_empty():
		if not visible and OS.is_process_running(uploadPipe['pid']):
			print('closed progress')
			queue_free()
		var newtext:String=uploadPipe['stdio'].get_as_text()
		#if not newtext.is_empty(): prints(newtext)
		$VBoxContainer/Label.text+=newtext
		var error:String=uploadPipe['stderr'].get_as_text()
		if not error.is_empty():
			if not $VBoxContainer.has_node("Error"):
				var errorLabel=Label.new()
				errorLabel.name='Error'
				errorLabel.add_theme_color_override("font_color",Color.DARK_RED)
				$VBoxContainer.add_child(errorLabel)
		$VBoxContainer/Errors.text+=uploadPipe['stderr'].get_as_text()
		if not OS.is_process_running(uploadPipe['pid']):
			get_cancel_button().hide()


func _on_canceled() -> void:
	if uploadPipe!=null:
		OS.kill(uploadPipe['pid'])
	queue_free()
	print('closed progress')
