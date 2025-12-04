@tool
extends Window

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
		if not newtext.is_empty(): print(newtext)
		$VBoxContainer/Label.text+=newtext
		$VBoxContainer/Errors.text+=uploadPipe['stderr'].get_as_text()


func _on_canceled() -> void:
	if uploadPipe!=null:
		OS.kill(uploadPipe['pid'])
	queue_free()
	print('closed progress')
