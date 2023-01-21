#include <array.au3>
#include <file.au3>
; #FUNCTION# ====================================================================================================================
; UDF for audio processing in a dataset
; Author: Mateo Cedillo
; Name ..........: _Dataset_Process_audios
; Description ...: Converts the dataset audio to the appropriate sample rate, normalizes and removes silence.
; Syntax ........: _Dataset_Process_audios([$sWavsPath = @ScriptDir &"\wavs"[, $sEnginesPath = @ScriptDir &"\engines"[,
;                  $bConsole = false]]])
; Parameters ....: $sWavsPath           - [optional] The path where the wavs are. Default is @ScriptDir &"\wavs".
;                  $sEnginesPath        - [optional] The path where the engines necessary to work are installed. Default is @ScriptDir &"\engines".
;                  $bConsole            - [optional] a boolean value that indicates if you want to show messages and progress in the console. Default is false.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _Dataset_Process_audios($sWavsPath = @ScriptDir & "\wavs", $sConvertedPath = @ScriptDir & "\processed wavs", $sEnginesPath = @ScriptDir & "\engines", $iFreq = 22050, $bConsole = False)
	Local $aFiles[]
	Local $sFfmpegFilename = "", $sSoxFilename = "sox\sox.exe"
	; check ffmpeg:
	If @OSArch = "X86" Then
		$sFfmpegFilename = "ffmpeg.exe"
	ElseIf @OSArch = "X64" Then
		$sFfmpegFilename = "ffmpeg64.exe"
	Else
		If $bConsole Then ConsoleWriteError('Error: Could not find the ffmpeg path for your architecture. Currently "X86" and " X64" are supported. See the ffmpeg website for more information.' & @CRLF)
		Return SetError(1, 0, "")
	EndIf
	; check if ffmpeg exists:
	If Not FileExists($sEnginesPath & "\" & $sFfmpegFilename) Then
		; todo: add ffmpeg and sox downloader:
		If $bConsole Then ConsoleWriteError("Error: You need to have ffmpeg for this function to work. Please download a binary version from the internet." & @CRLF)
	EndIf
	;browse files:
	$aFiles = _FileListToArrayRec($sWavsPath, "*.wav", 1, 0, 2)
	If @error Then
		If $bConsole Then ConsoleWriteError("An error occurred while browsing wavs." & @CRLF)
		Return SetError(2, 0, "")
	EndIf
	;start process:
	If $bConsole Then ConsoleWrite("processing " & $aFiles[0] & " audios..." & @CRLF)
	; remove $aFiles[0] which contains the number of files examined, we don't need this.
	_ArrayDelete($aFiles, 0)
	For $sFile In $aFiles
		If $bConsole Then ConsoleWrite("Processing: " & $sFile & "...")
		; todo: add a sample rate checker. If it is less than or greater than 22050, as well as if it is not 16 bit, it will homify that audio and process to the next.
		; convert:
		__RunFfmpeg($sEnginesPath & "\" & $sFfmpegFilename, '-y -i ' & $sWavsPath & '\' & $sFile & ' -ar ' &$iFreq &' ' & @ScriptDir & '\cache\srtmp.wav -loglevel error')
		If @error Then Return SetError(3, 0, "")
		; normalize audio:
		__RunSox($sEnginesPath & "\" & $sSoxFilename, @ScriptDir & '\cache\srtmp.wav  -c 1 ' & @ScriptDir & '\cache\ntmp.wav norm -0.1')
		If @error Then Return SetError(4, 0, "")
		; remove silences:
		__RunSox($sEnginesPath & "\" & $sSoxFilename, @ScriptDir & '\cache\ntmp.wav ' & @ScriptDir & '\cache\ctmp.wav silence 1 0.05 0.1% reverse silence 1 0.05 0.1% reverse')
		If @error Then Return SetError(5, 0, "")
		__RunFfmpeg($sEnginesPath & "\" & $sFfmpegFilename, '-y -i ' & @ScriptDir & '\cache\ctmp.wav -c copy -fflags +bitexact -flags:v +bitexact -flags:a +bitexact -ar ' &$iFreq &' ' & @ScriptDir & '\cache\poop.wav -loglevel error')
		If @error Then Return SetError(6, 0, "")
		FileDelete($sWavsPath & "\" & $sFile)
		FileMove(@ScriptDir & "\cache\poop.wav", $sWavsPath & "\" & $sFile)
		If $bConsole Then ConsoleWrite("Done." & @CRLF)
	Next
	FileDelete(@ScriptDir &"\cache\*.wav")
EndFunc   ;==>_Dataset_Process_audios

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __RunFfmpeg
; Description ...: Run ffmpeg.exe with the paths set next to a command you want to run.
; Syntax ........: __RunFfmpeg($sFfmpegPath, $sCommand)
; Parameters ....: $sFfmpegPath         - The path of where the ffmpeg executable is located.
;                  $sCommand            - command to run.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __RunFfmpeg($sFfmpegPath, $sCommand)
	Local $iPid
	If Not FileExists($sFfmpegPath) Then Return SetError(1, 0, "")
	$iPid = Run(@ComSpec & ' /C "' & $sFfmpegPath & '" ' & $sCommand, @ScriptDir, @SW_HIDE, 6)
	If @error Then
		Return SetError(2, 0, "")
	Else
		ProcessWaitClose($iPid)
		Return $iPid
	EndIf
EndFunc   ;==>__RunFfmpeg

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __RunSox
; Description ...: Run sox.exe with the paths set next to a command you want to run.
; Syntax ........: __RunSox($sSoxPath, $sCommand)
; Parameters ....: $sSoxPath            - The path of where the sox.exe executable is located.
;                  $sCommand            - Command to run.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __RunSox($sSoxPath, $sCommand)
	If Not FileExists($sSoxPath) Then Return SetError(1, 0, "")
	Local $iPid
	$iPid = Run(@ComSpec & ' /C "' & $sSoxPath & '" ' & $sCommand, @ScriptDir, @SW_HIDE, 6)
	If @error Then
		Return SetError(2, 0, "")
	Else
		ProcessWaitClose($iPid)
		Return $iPid
	EndIf
EndFunc   ;==>__RunSox
