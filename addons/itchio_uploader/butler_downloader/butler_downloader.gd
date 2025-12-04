@tool
extends Node
 
func downloadButler()->void:
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
	print(urlStart)
	var url=headers[6].substr(urlStart)
	print(url)
	var request=HTTPRequest.new()
	add_child(request)
	request.request_completed.connect(downloadFinished)
	var error=request.request(url)
	if error!=OK:
		print("An error occured downloading butler")

func downloadFinished(result, response_code, headers, body)->void:
	print('downloaded butler')
	const butlerFolder='res://addons/itchio_uploader/butler/'
	const zipFilePath=butlerFolder+'butler.zip'
	if not DirAccess.dir_exists_absolute(butlerFolder):
		DirAccess.make_dir_absolute(butlerFolder)
	# write file
	var file=FileAccess.open(zipFilePath,FileAccess.WRITE)
	file.store_buffer(body)
	file.close()
	
	var zipReader:=ZIPReader.new()
	zipReader.open(zipFilePath)
	
	for zipFile in zipReader.get_files():
		var currFile=FileAccess.open(butlerFolder+zipFile,FileAccess.WRITE)
		currFile.store_buffer(zipReader.read_file(zipFile))
		currFile.close()
		print('extracted '+zipFile)
	
	zipReader.close()
	
	var butlerFile:String
	if OS.get_name()!='Windows':
		butlerFile='butler'
		FileAccess.set_unix_permissions(butlerFolder+'butler',FileAccess.UNIX_EXECUTE_OWNER)
	else:
		butlerFile='butler.exe'
	#Store butler path
	ItchSettings.butlerPath=ProjectSettings.globalize_path(butlerFolder+butlerFile)
	ItchSettings.saveSettingsToFile()
