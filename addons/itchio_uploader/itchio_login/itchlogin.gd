@tool
extends AcceptDialog

@onready var status: Label = $VBoxContainer/Status
@onready var link: LinkButton = $VBoxContainer/Link

var butlerLoginPID:int

func _ready()->void:
	if get_parent() is SubViewport:
		return
	
	var butlerLoginPipe:Dictionary
	match OS.get_name():
		"Windows":
			butlerLoginPipe=OS.execute_with_pipe(ItchSettings.butlerPath,['login'])
		"Linux":
			butlerLoginPipe=OS.execute_with_pipe('script',['-c',ItchSettings.butlerPath+' login','/dev/null'])
		"macOS":
			print("Log in from Godot does not work on macOS, open a terminal and enter \n\n"+ItchSettings.butlerPath+" login")
			queue_free()
			return
	butlerLoginPID=butlerLoginPipe['pid']
	#$"Login check".start()
	await get_tree().create_timer(0.5).timeout
	var commandOutput:String=butlerLoginPipe['stdio'].get_as_text()
	var butlerOutput=commandOutput.substr(commandOutput.find('\n')+1)
	
	if butlerOutput.begins_with("Your local credentials are valid!"):
		status.text="Already loged into itch.io"
		var logoutButton=Button.new()
		logoutButton.text="Log Out"
		logoutButton.pressed.connect($LogOutConfirm.show)
		$VBoxContainer.add_child(logoutButton)
		link.queue_free()
		print("Already loged into itch.io")
	else:
		var urlStartIndex=butlerOutput.find("https://itch.io/")
		var urlEndIndex=butlerOutput.find(' ',urlStartIndex)
		var url=butlerOutput.substr(urlStartIndex,urlEndIndex-urlStartIndex)
		if url=="":
			print(commandOutput)
			link.text='Error'
			status.text=butlerLoginPipe['stdio'].get_as_text()+butlerLoginPipe['stderr'].get_as_text()
		else:
			status.text="A page should have opened in your browser to log into itch.io. If it hasn't, click the link below"
			link.text='Link'
			link.uri=url
			link.underline=LinkButton.UnderlineMode.UNDERLINE_MODE_ALWAYS

func logout()->void:
	var output=[]
	OS.execute(ItchSettings.butlerPath,['logout','--assume-yes'],output)
	print(output)
	queue_free()

func checkLogin()->void:
	if not OS.is_process_running(butlerLoginPID):
		queue_free()
