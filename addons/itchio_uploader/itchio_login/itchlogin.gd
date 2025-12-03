@tool
extends AcceptDialog

var butlerPath:="/home/agiller/Documents/butler-linux-amd64/butler"

var butlerLoginPID:int

func _ready()->void:
	var butlerLoginPipe:Dictionary
	if OS.get_name()=="Windows":
		butlerLoginPipe=OS.execute_with_pipe(butlerPath,['login'])
	else:
		butlerLoginPipe=OS.execute_with_pipe('/usr/bin/script',['-c',butlerPath+' login','/dev/null'])
	butlerLoginPID=butlerLoginPipe['pid']
	$"Login check".start()
	await get_tree().create_timer(0.5).timeout
	var butlerOutput=butlerLoginPipe['stdio'].get_as_text()
	var urlStartIndex=butlerOutput.find("https://itch.io/user/")
	var urlEndIndex=butlerOutput.find(' ',urlStartIndex)
	var url=butlerOutput.substr(urlStartIndex,urlEndIndex-urlStartIndex)
	if url=="":
		$VBoxContainer/LinkButton.text='Error'
	else:
		$VBoxContainer/LinkButton.text='Link'
		$VBoxContainer/LinkButton.url=url
		$VBoxContainer/LinkButton.underline=LinkButton.UnderlineMode.UNDERLINE_MODE_ALWAYS

func checkLogin()->void:
	if not OS.is_process_running(butlerLoginPID):
		queue_free()
