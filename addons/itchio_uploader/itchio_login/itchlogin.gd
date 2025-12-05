@tool
extends AcceptDialog

var butlerPath:="/home/agiller/Documents/butler-linux-amd64/butler"

@onready var status: Label = $VBoxContainer/Status
@onready var link: LinkButton = $VBoxContainer/Link

var butlerLoginPID:int

func _ready()->void:
	if get_parent() is SubViewport:
		return
	
	var butlerLoginPipe:Dictionary
	if OS.get_name()=="Windows":
		butlerLoginPipe=OS.execute_with_pipe(butlerPath,['login'])
	else:
		butlerLoginPipe=OS.execute_with_pipe('/usr/bin/script',['-c',butlerPath+' login','/dev/null'])
	butlerLoginPID=butlerLoginPipe['pid']
	$"Login check".start()
	await get_tree().create_timer(0.5).timeout
	var commandOutput:String=butlerLoginPipe['stdio'].get_as_text()
	var butlerOutput=commandOutput.substr(commandOutput.find('\n')+1)
	
	if butlerOutput.begins_with("Your local credentials are valid!"):
		status.text="Already loged into itch.io"
		
		print("Already loged into itch.io")
	else:
		var urlStartIndex=butlerOutput.find("https://itch.io/")
		var urlEndIndex=butlerOutput.find(' ',urlStartIndex)
		var url=butlerOutput.substr(urlStartIndex,urlEndIndex-urlStartIndex)
		if url=="":
			link.text='Error'
			status.text=butlerLoginPipe['stdio'].get_as_text()+butlerLoginPipe['stderr'].get_as_text()
		else:
			link.text='Link'
			link.url=url
			link.underline=LinkButton.UnderlineMode.UNDERLINE_MODE_ALWAYS

func checkLogin()->void:
	if not OS.is_process_running(butlerLoginPID):
		queue_free()
