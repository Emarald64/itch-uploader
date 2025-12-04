@tool
extends Node
 
var butlerDownload:HTTPRequest
var extracting:=false
var thread:Thread
var numFilesExtracted:=0

const butlerFolder='res://addons/itchio_uploader/butler/'

func _process(delta: float) -> void:
	if thread!=null:
		if not thread.is_alive():
			thread.wait_to_finish()
			if OS.get_name()!='Windows':
				FileAccess.set_unix_permissions(butlerFolder+'butler',FileAccess.UNIX_EXECUTE_OWNER)
			queue_free()
	if butlerDownload!=null and not extracting:
		%ProgressBar.max_value=butlerDownload.get_body_size()
		%ProgressBar.value=butlerDownload.get_downloaded_bytes()
		%Progress.text=String.humanize_size(butlerDownload.get_downloaded_bytes())+'/'+String.humanize_size(butlerDownload.get_body_size())

func _ready()->void:
	startDownload()

func startDownload()->void:
	const baseURL='https://broth.itch.zone/butler/{0}/LATEST/archive/default'
	var osURLName:String
	match OS.get_name():
		"Windows":
			# screw it, assume 64-bits :,(
			osURLName='windows-amd64'
		"MacOS":
			osURLName='darwin-amd64'
		"Linux":
			osURLName="linux-amd64"
	var url=baseURL.format([osURLName])
	print(url)
	var request=HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(linkDownloaded)
	var error=request.request(url)
	if error!=OK:
		print("An error occured finding where to download butler")

func linkDownloaded(result, response_code, headers, body:PackedByteArray)->void:
	print(headers)
	headers[6]
	#var responce=body.get_string_from_utf8()
	#print(responce)
	var urlStart=headers[6].find("http")
	#var urlEnd=headers[6].find("\"",urlStart+1)
	var url=headers[6].substr(urlStart)
	%"Current Step".text="Downloading Butler"
	butlerDownload=HTTPRequest.new()
	add_child(butlerDownload)
	butlerDownload.request_completed.connect(downloadFinished)
	var error=butlerDownload.request(url)
	if error!=OK:
		print("An error occured downloading butler")

func downloadFinished(result, response_code, headers, body)->void:
	print('downloaded butler')
	const zipFilePath=butlerFolder+'butler.zip'
	if not DirAccess.dir_exists_absolute(butlerFolder):
		DirAccess.make_dir_absolute(butlerFolder)
	%"Current Step".text="Writing File"
	extracting=true
	# write file
	var file=FileAccess.open(zipFilePath,FileAccess.WRITE)
	file.store_buffer(body)
	file.close()
	%"Current Step".text="Extracting File"
	
	thread=Thread.new()
	
	thread.start(extractionThread.bind(zipFilePath,%ProgressBar))
	
	var butlerFile:String
	if OS.get_name()!='Windows':
		butlerFile='butler'
		FileAccess.set_unix_permissions(butlerFolder+'butler',FileAccess.UNIX_EXECUTE_OWNER)
	else:
		butlerFile='butler.exe'
	#Store butler path
	ItchSettings.butlerPath=ProjectSettings.globalize_path(butlerFolder+butlerFile)
	ItchSettings.saveSettingsToFile()

func extractionThread(zipFilePath:String,progressBar:ProgressBar)->void:
	var zipReader:=ZIPReader.new()
	zipReader.open(zipFilePath)

	progressBar.set_deferred("max_value",len(zipReader.get_files()))
	
	for zipFile in zipReader.get_files():
		var currFile=FileAccess.open(butlerFolder+zipFile,FileAccess.WRITE)
		currFile.store_buffer(zipReader.read_file(zipFile))
		currFile.close()
		print('extracted '+zipFile)
		call_deferred('increaseProgressBar')
	zipReader.close()
	

func increaseProgressBar()->void:
	%ProgressBar.value+=1

func _on_close_requested() -> void:
	if butlerDownload!=null:
		butlerDownload.cancel_request()
	queue_free()
