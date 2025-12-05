@tool
extends ConfirmationDialog

var uploadPipe:Dictionary
@onready var output: Label = $VBoxContainer/Output
var done:=false
var isError:=false
var channel:String

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not uploadPipe.is_empty() and not done:
		if not visible and OS.is_process_running(uploadPipe['pid']):
			print('closed progress')
			queue_free()
		var newtext:String=uploadPipe['stdio'].get_as_text()
		#if not newtext.is_empty(): prints(newtext)
		output.text+=newtext
		var error:String=uploadPipe['stderr'].get_as_text()
		if not error.is_empty():
			if not $VBoxContainer.has_node("Error"):
				isError=true
				var errorLabel=Label.new()
				errorLabel.name='Error'
				errorLabel.add_theme_color_override("font_color",Color.DARK_RED)
				$VBoxContainer.add_child(errorLabel)
			$VBoxContainer/Error.text+=error
		if not OS.is_process_running(uploadPipe['pid']):
			# upload finished
			get_cancel_button().hide()
			done=true
			if not isError:
				if len(itchStatus.uploadedGames.get(channel))>1:
					itchStatus.uploadedGames.get(channel).set(1,Time.get_datetime_string_from_system())
				else:
					itchStatus.uploadedGames.get(channel).append(Time.get_datetime_string_from_system())
	elif done and not visible:
		queue_free()
func _on_canceled() -> void:
	if uploadPipe!=null:
		OS.kill(uploadPipe['pid'])
	queue_free()
	print('closed progress')
