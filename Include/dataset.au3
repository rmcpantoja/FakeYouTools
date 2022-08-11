; Dataset manager for FakeYou (Tacotron 2).
;Author: Mateo Cedillo
; Fixes and suggests by @Subz and @pixelsearch
#include <Array.au3>
#include "dataset\audioProcessing.au3"
#include <File.au3>
#include <sound.au3>
$sFakeYouDatasetManager_Ver = "0.5.0"
; #FUNCTION# ====================================================================================================================
; Name ..........: _changeDatasetOrder
; Description ...: changes the order of wavs and transcripts in the dataset
; Syntax ........: _changeDatasetOrder($sPath, $sListFileName, $nNum)
; Parameters ....: $sPath               - The dataset path.
;                  $sListFileName       - The path containing the list of transcripts.
;                  $nNum                - The number from where the order will be changed.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _changeDatasetOrder($sPath, $sListFileName, $nNum, $bShowMSG = false)
	Local $aFilesList = _FileListToArrayRec($sPath &"\wavs", "*.wav", 1, 0, 2)
	If @error Then Return SetError(1, 0, "")
	$aFile = FileReadToArray($sPath & "\" & $sListFileName)
	$iLines = @extended
	If @error Then Return SetError(2, 0, "")
	Local $sFileName = "", $iResult = 0
	Local $aTexts[]
	if $bShowMSG then ConsoleWrite("Phase 1: split the transcript.")
	For $i = 0 To $iLines - 1
		$aTexts[$i] = StringSplit($aFile[$i], "|")[2]
		if $bShowMSG then ConsoleWrite($i+1 /$iLines *100 &"%  " &$I+1 &"/" &$iLines)
	Next
	$hFileOpen = FileOpen($sPath & "\" & StringTrimRight($sListFileName, 4) & "_converted.txt", 1)
	If $hFileOpen = -1 Then Return SetError(3, 0, "")
	Local $nItem = 0
	_ArraySortEx($aFileslist, Default, 1, Default, Default, 1)
	If @error Then Return SetError(4, 0, "")
	if $bShowMSG then ConsoleWrite("Phase 2: rename files and change list.")
	For $IProcess = 1 To $aFileslist[0]
	if $bShowMSG then ConsoleWrite($iProcess /$aFileslist[0] *100 &"%  " &$iProcess &"/" &$aFileslist[0])
		FileMove($sPath & "\wavs\" & $aFileslist[$IProcess], $sPath & "\wavs\" & $nNum & ".wav", $FC_OVERWRITE)
		FileWriteLine($hFileOpen, "wavs/" & $nNum & ".wav|" & $aTexts[$nItem])
		$nItem = $nItem + 1
		$nNum = $nNum + 1
		Sleep(10)
	Next
	FileClose($hFileOpen)
	Return 1
EndFunc   ;==>_changeDatasetOrder
; #FUNCTION# ====================================================================================================================
; Name ..........: _AhoTtsDataset2Tacotron
; Description ...: Convert an AhoTts dataset to a dataset compatible for training with Tacotron 2.
; Syntax ........: _AhoTtsDataset2Tacotron($sPath[, $sListFileName = "list.txt"])
; Parameters ....: $sPath               - The dataset folder.
;                  $sListFileName       - [optional] The name of the file that contains the list of transcripts. Default is "list.txt".
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _AhoTtsDataset2Tacotron($sPath, $sListFileName = "list.txt", $bShowMSG = false)
	$hFiles = FileFindFirstFile($sPath & "\*.wav")
	If $hFiles = -1 Then
		Return SetError(1, 0, "")
	ElseIf Not FileExists($sListFileName) Then
		Return SetError(2, 0, "")
	EndIf
	$aFile = FileReadToArray($sListFileName)
	If @error Then Return SetError(3, 0, "")
	$iLines = @extended
	$hFileOpen = FileOpen($sPath & "\" & StringTrimRight($sListFileName, 4) & "_converted.txt", 1)
	If $hFileOpen = -1 Then Return SetError(4, 0, "")
	Local $nNum = 1
	Local $sFilesList = ""
	While 1
		$sFileName = FileFindNextFile($hFiles)
		If @error Then ExitLoop
		$sFilesList &= $sFileName & "|"
		Sleep(10)
	WEnd
	$sFilesList = StringTrimRight($sFilesList, 1)
	$aFileslist = StringSplit($sFilesList, "|")
	If Not FileExists($sPath & "\wavs") Then DirCreate($sPath & "\wavs")
	For $IProcess = 1 To $aFileslist[0]
		if $bShowMSG then ConsoleWrite($IProcess / $aFileslist[0] * 100 &"%  " &$iProcess &"/" &$aFileslist[0])
		FileMove($sPath & "\" & $aFileslist[$IProcess], $sPath & "\wavs\" & $nNum & ".wav", $FC_OVERWRITE)
		FileWriteLine($hFileOpen, "wavs/" & $nNum & ".wav|" & $aFile[$IProcess - 1])
		$nNum = $nNum + 1
		Sleep(10)
	Next
	FileClose($hFileOpen)
	Return 1
EndFunc   ;==>_AhoTtsDataset2Tacotron
; #FUNCTION# ====================================================================================================================
; Name ..........: _DatasetFixList
; Description ...: Fix certain symbols that are in the transcript so that we can train without problems.
; Syntax ........: _DatasetFixList($sListPath[, $sLang = "en"])
; Parameters ....: $sListPath           - The path of the transcript file.
;                  $sLang               - [optional] The language in which the transcript is written. Default is "en" (english).
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _DatasetFixList($sListPath, $sLang = "en")
	local $aFile, $aWavList[]
	local $aSplit[]
	local $bPunctuation = false
	local $iCount = 0
	Local $sReplacements = 0, $sText = ""
	Switch $sLang
		Case "en"
			local $aSimbols[][2] = [["ñ", "n"], ["1", "one"], ["2", "two"], ["3", "three"], ["4", "four"], ["5", "five"], ["6", "six"], ["7", "seven"], ["8", "eight"], ["9", "nine"], ["0", "zero"], ["...", ","], ["(", ","], [")", "."]]
		Case "es"
			local $aSimbols[][2] = [["ñ", "ni"], ["1", "uno"], ["2", "dos"], ["3", "tres"], ["4", "cuatro"], ["5", "cinco"], ["6", "seis"], ["7", "siete"], ["8", "ocho"], ["9", "nueve"], ["0", "cero"], ["...", ","], ["(", ","], [")", "."]]
	EndSwitch
	If Not FileExists($sListPath) Then Return SetError(1, 0, "")
	$aFile = FileReadToArray($sListPath)
	If @error Then Return SetError(2, 0, "")
	$iCount = @extended
	Local $i = 0
	$hFileOpen = FileOpen(StringTrimRight($sListPath, 4) & "_fixed.txt", 1)
	If $hFileOpen = -1 Then Return SetError(3, 0, "")
	While $i <= $iCount - 1
		$aWavList[$i] = StringSplit($aFile[$i], "|")[1]
		$sText = StringSplit($aFile[$i], "|")[2]
		For $iStart = 0 To UBound($aSimbols, 1) - 1
			If StringInStr($sText, $aSimbols[$iStart][0]) Then
				$sText = StringReplace($sText, $aSimbols[$iStart][0], $aSimbols[$iStart][1])
				$sReplacements = $sReplacements + @extended
				ConsoleWrite("a match was found in line " &$I &" of " &$iCount &". Simbol: " &$aSimbols[$iStart][0] &" = " &$aSimbols[$iStart][1] &"." &@crlf)
			Else
				ContinueLoop
			EndIf
			Sleep(10)
		Next
		; check if there is end punctuation.
		local $aPuncs[] = [",", ".", "-", "¡", "!", "¿", "?", ";", ":"]
		for $iPunc = 0 to uBound($aPuncs) -1
			if StringRight($sText, 1) = $aPuncs[$iPunc] then
				$bPunctuation = true
				exitLoop
			Else
				$bPunctuation = false
			EndIf
		Next
		if not $bPunctuation then
			ConsoleWrite("Warning: " &$sText &" It has no end punctuation. Adding end punctuation..." &@crlf)
			$sText &= "."
			$bPunctuation = true
		EndIf
		FileWriteLine($hFileOpen, $aWavList[$i] & "|" & $sText)
		$i = $i + 1
	WEnd
	FileClose($hFileOpen)
	SetError(Null, $sReplacements)
EndFunc   ;==>_DatasetFixList
; #FUNCTION# ====================================================================================================================
; Name ..........: _Dataset_get_WavsDuration
; Description ...: Gets the total duration of the dataset.
; Syntax ........: _Dataset_get_WavsDuration([$sWavsPath = @ScriptDir & "\wavs"])
; Parameters ....: $sWavsPath           - [optional] The audios path (wavs). Default is @ScriptDir & "\wavs".
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dataset_get_WavsDuration($sWavsPath = @ScriptDir & "\wavs", $sListPath = @ScriptDir & "\list.txt", $iMode = 1)
	Local $aList, $aSplit, $aSound
	Local $sFileName = "", $iResult = 0, $iLines = 0
	Local $iSecs, $iHours, $iMins, $iSecs2
	If $iMode = 1 Then
		If Not FileExists($sWavsPath) Then Return SetError(1, 0, "")
		$hWavs = FileFindFirstFile($sWavsPath & "\*.wav")
		If $hWavs = -1 Then Return SetError(2, 0, "")
		While 1
			$sFileName = FileFindNextFile($hWavs)
			If @error Then ExitLoop
			$iResult = $iResult + __Dataset_GetAudioDuration($sWavsPath & "\" & $sFileName)
			If @error Then
				Return SetError(3, 0, "")
				ExitLoop
			EndIf
			Sleep(10)
		WEnd
	ElseIf $iMode = 2 Then
		If $sWavsPath = Default Then $sWavsPath = "none" ; It is not necessary in this mode.
		If Not FileExists($sListPath) Then Return SetError(1, 0, "")
		$aList = FileReadToArray($sListPath)
		If @error Then Return SetError(2, 0, "")
		$iLines = @extended
		For $i = 0 To $iLines - 1
			$aSplit = StringSplit($aList[$i], "|")
			$iResult = $iResult + $aSplit[4]
		Next
	EndIf
	If $iMode = 1 Then
		$iSecs = Int($iResult / 1000)
	Else
		$iSecs = $iResult
	EndIf
	$iHours = Int($iSecs / 3600)
	$iSecs = Mod($iSecs, 3600)
	$iMins = Int($iSecs / 60)
	$iSecs2 = Round(Mod($iSecs, 60))
	Return $iHours & ":" & $iMins & ":" & $iSecs2
EndFunc   ;==>_Dataset_get_WavsDuration
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Dataset_GetAudioDuration
; Description ...: Function that helps to obtain the audio duration.
; Syntax ........: __Dataset_GetAudioDuration($sFile[, $iMaxSeconds = 20])
; Parameters ....: $sFile               - The name of the audio file to examine.
;                  $iMaxSeconds         - [optional] an integer value that contains the maximum number of seconds allowed. Default is 20.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Dataset_GetAudioDuration($sFile, $iMaxSeconds = 20)
	$aSound = _SoundOpen($sFile)
	If @error Then Return SetError(1, 0, "")
	$sLenght = _SoundLength($aSound, 2)
	$aLenghtFormat = StringSplit(_SoundLength($aSound, 1), ":")
	If $aLenghtFormat[3] >= $iMaxSeconds Then ConsoleWrite("Warning: the duration of " & $sFile & " It lasts longer than " & $aLenghtFormat[3] & @CRLF)
	Return $sLenght
EndFunc   ;==>__Dataset_GetAudioDuration
; #FUNCTION# ====================================================================================================================
; Name ..........: _Dataset_CreateTranscription
; Description ...: Create a transcript (blank list) either based on a maximum number of items or by detecting the wavs.
; Syntax ........: _Dataset_CreateTranscription($sFileName, $iMaxItems[, $sWavsPath = @ScriptDir & "\wavs"])
; Parameters ....: $sFileName           - The filename of the new filelist to create.
;                  $iMaxItems           - an integer value containing the maximum n[umber of elements to create.
;                  $sWavsPath           - [optional] A string containing the path of the wavs. Default is @ScriptDir & "\wavs".
; Return values .: None
; Author ........: Mateo Cedillo, fixes by Subz and pixelsearch
; Modified ......:
; Remarks .......: To create a blank transcript by detecting wavs, simply pass "FW" (from wavs) to the $iMaxItems parameter.
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/208426-the-_array-functions-do-not-work-in-these-cases/
; Example .......: Yes
; ===============================================================================================================================
Func _Dataset_CreateTranscription($sFileName, $iMaxItems, $sWavsPath = @ScriptDir & "\wavs")
	If FileExists($sFileName) Then Return SetError(1, 0, "") ;The transcript file already exists.
	Local $hFile = FileOpen($sFileName, 2)
	If $hFile = -1 Then Return SetError(2, 0, "") ;the transcription file could not be created.
	If $iMaxItems = "FW" Then
		$iMaxItems = 0
		Local $aFileList = _FileListToArrayRec($sWavsPath, "*.wav", 1, 0, 2)
		If @error Then Return SetError(3, 0, "")
		__SortList($aFileList)
		If @error Then Return SetError(4, 0, "")
		FileWrite($hFile, "wavs/" & _ArrayToString($aFileList, "|" & @CRLF & "wavs/", 1, -1, "|" & @CRLF & "wavs/", 0, 0) & "|" & @CRLF)
		FileClose($hFile)
	Else
		If Not IsInt($iMaxItems) Then Return SetError(5, 0, "") ;The maximum number of elements is not an integer.
		For $i = 1 To $iMaxItems
			FileWriteLine($hFile, "wavs/" & $i & ".wav|")
		Next
		FileClose($hFile)
	EndIf
	Return True
EndFunc   ;==>_Dataset_CreateTranscription
; #FUNCTION# ====================================================================================================================
; Name ..........: _Dataset_CleanFiles
; Description ...:
; Syntax ........: _Dataset_CleanFiles($sWavsPath, $iMode[, $sSearch = "HP2-4BAND-3090_4band_arch-500m_1|HP2-4BAND-3090_4band_arch-500m_1_DeepExtraction"[,
;                  $BRemoveVocals = false]])
; Parameters ....: $sWavsPath           - a string value.
;                  $iMode               - an integer value.
;                  $sSearch             - [optional] a string value. Default is "HP2-4BAND-3090_4band_arch-500m_1|HP2-4BAND-3090_4band_arch-500m_1_DeepExtraction".
;                  $BRemoveVocals       - [optional] an unknown value. Default is false.
; Return values .: None
; Author ........: MAteo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dataset_CleanFiles($sWavsPath, $iMode, $sSearch = "HP2-4BAND-3090_4band_arch-500m_1|HP2-4BAND-3090_4band_arch-500m_1_DeepExtraction", $BRemoveVocals = False)
	Local $aSearches, $bMultiSearch = False
	Local $aVRTipes[2] = ["instruments", "vocals"]
	Local $aFileList = _FileListToArrayRec($sWavsPath, "*.wav", 1, 0, 2)
	If @error Then Return SetError(1, 0, "")
	If StringInStr($sSearch, "|") Then $bMultiSearch = True
	;__SortList($aFileList)
	;If @error Then Return SetError(2, 0, "")
	Local $sFileName = "", $sOldName = "", $sNewName = "", $aFileParts[]
	If $bMultiSearch Then $aSearches = StringSplit($sSearch, "|")
	For $i = 1 To $aFileList[0]
		Switch $iMode
			Case 1 ; melodyne
				$aFileParts = StringSplit($aFileList[$i], ".")
				$sNewName = $aFileParts[1] & $aFileParts[3]
				;if FileExists($sPath & "\" &$sNewName) then FileDelete($sPath & "\wavs\" &$sNewName)
				FileMove($sWavsPath & "\" & $aFileList[$i], $sWavsPath & "\" & $sNewName, $FC_OVERWRITE)
			Case 2 ; vocal remover
				If FileExists($sWavsPath & "\.gitkeep") Then FileDelete($sWavsPath & "\.gitkeep")
				$aFileParts = StringSplit($aFileList[$i], "_")
				If $aFileParts[0] = 7 Then
					If $bMultiSearch Then
						If Not IsArray($aSearches) Then Return SetError(2, 0, "")
						For $I2 = 1 To $aSearches[0]
							If $BRemoveVocals Then
								$sOldName = $sWavsPath & "\" & $aFileParts[1] & "_" & $aSearches[1] & "_" & $aVRTipes[1] & ".wav"
								If FileExists($sOldName) Then FileDelete($sOldName)
							Else
								$sOldName = $sWavsPath & "\" & $aFileParts[1] & "_" & $aSearches[$I2] & "_" & $aVRTipes[0] & ".wav"
								If FileExists($sOldName) Then FileDelete($sOldName)
							EndIf
						Next
					Else
						$sOldName = $sWavsPath & "\" & $aFileParts[1] & "_" & $sSearch & "_" & $aVRTipes[0] & ".wav"
						If FileExists($sOldName) Then FileDelete($sOldName)
					EndIf
				EndIf
		EndSwitch
	Next
	Return 1
EndFunc   ;==>_Dataset_CleanFiles
; #FUNCTION# ====================================================================================================================
; Name ..........: _Dataset_Set_listWavsNames
; Description ...:
; Syntax ........: _Dataset_Set_listWavsNames($sWavsPath[, $iMode = 1[, $sDelim = "_"]])
; Parameters ....: $sWavsPath           - a string value.
;                  $iMode               - [optional] an integer value. Default is 1.
;                  $sDelim              - [optional] a string value. Default is "_".
; Return values .: None
; Author ........: MAteo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dataset_Set_listWavsNames($sWavsPath, $iMode = 1, $sDelim = "_")
	Local $aFiles = _FileListToArrayRec($sWavsPath, "*.wav", 1, 0, 2)
	If @error Then Return SetError(1, 0, "")
	Local $aFileParts, $sOldName = ""
	_ArraySortEx($aFiles, Default, 1, Default, Default, 1)
	If @error Then Return SetError(2, 0, "")
	For $i = 1 To $aFiles[0]
		Switch $iMode
			Case 1
				FileMove($sWavsPath & "\" & $aFiles[$i], $sWavsPath & "\" & $i & ".wav", $FC_OVERWRITE)
			Case 2
				$aFileParts = StringSplit($aFiles[$i], $sDelim)
				FileMove($sWavsPath & "\" & $aFiles[$i], $sWavsPath & "\" & $aFileParts[1] & ".wav", $FC_OVERWRITE)
		EndSwitch
	Next
	Return 1
EndFunc   ;==>_Dataset_Set_listWavsNames
; #FUNCTION# ====================================================================================================================
; Name ..........: _Dataset_wav2npy
; Description ...:
; Syntax ........: _Dataset_wav2npy($sFilePath)
; Parameters ....: $sFilePath           - a string value.
; Return values .: None
; Author ........: MAteo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dataset_wav2npy($sFilePath)
	Local $nRepl = 0
	Local $hFile = FileOpen($sFilePath, $FO_READ)
	If $hFile = -1 Then Return SetError(0, 0, "")
	Local $sData = FileRead($hFile)
	FileClose($hFile)
	If StringInStr($sData, ".wav") Then
		$sData = StringReplace($sData, ".wav", ".npy")
		$nRepl = $nRepl + @extended
	EndIf
	Local $hFile = FileOpen($sFilePath, $FO_OVERWRITE)
	If $hFile = -1 Then Return SetError(2, 0, "")
	FileWrite($hFile, $sData)
	FileClose($hFile)
	Return $nRepl
EndFunc   ;==>_Dataset_wav2npy
; #FUNCTION# ====================================================================================================================
; Name ..........: _Dataset_npy2wav
; Description ...:
; Syntax ........: _Dataset_npy2wav($sFilePath)
; Parameters ....: $sFilePath           - a string value.
; Return values .: None
; Author ........: MAteo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dataset_npy2wav($sFilePath)
	Local $nRepl = 0
	Local $hFile = FileOpen($sFilePath, $FO_READ)
	If $hFile = -1 Then Return SetError(0, 0, "")
	Local $sData = FileRead($hFile)
	FileClose($hFile)
	If StringInStr($sData, ".npy") Then
		$sData = StringReplace($sData, ".npy", ".wav")
		$nRepl = $nRepl + @extended
	EndIf
	Local $hFile = FileOpen($sFilePath, $FO_OVERWRITE)
	If $hFile = -1 Then Return SetError(2, 0, "")
	FileWrite($hFile, $sData)
	FileClose($hFile)
	Return $nRepl
EndFunc   ;==>_Dataset_npy2wav
; #FUNCTION# ====================================================================================================================
; Name ..........: _Dataset_checkStatus
; Description ...:
; Syntax ........: _Dataset_checkStatus($sPath)
; Parameters ....: $sPath               - a string value.
; Return values .: None
; Author ........: MAteo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dataset_checkStatus($sPath)
	Local $aTime[]
	$sStatus = _Dataset_Get_WavsDuration($sPath & "\wavs")
	If @error Then Return SetError(1, 0, "")
	$aTime = StringSplit($sStatus, ":")
	If $aTime[1] = 0 Then
		Switch $aTime[2]
			Case 2 To 4
				Return 1
			Case 5 To 9
				Return 2
			Case 10 To 15
				Return 3
			Case 16 To 29
				Return 4
			Case 30 To 45
				Return 5
			Case 46 To 59
				Return 6
		EndSwitch
	ElseIf $aTime[1] = 1 or $aTime[1] = 2 or $aTime[1] = 3 or $aTime[1] = 4 or $aTime[1] = 5 Then
		Return 7
	ElseIf $aTime[1] >= 6 Then
		Return 8
	EndIf
EndFunc   ;==>_Dataset_checkStatus
; #FUNCTION# ====================================================================================================================
; Name ..........: _dataset_matchList
; Description ...: makes a transcribed document compatible with a tacotron 2 compatible transcript for training.
; Syntax ........: _dataset_matchList([$sListPath = @ScriptDir &"\list.txt"])
; Parameters ....: $sListPath           - [optional] a string value containing the path of the transcript file. Default is @ScriptDir &"\list.txt".
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _dataset_matchList($sListPath = @ScriptDir & "\list.txt")
	;declarar:
	Local $aList, $aSplit, $hFile
	If Not FileExists($sListPath) Then Return SetError(1, 0, "")
	;abrir list:
	$aList = FileReadToArray($sListPath)
	If @error Then Return SetError(2, 0, "")
	;obteniendo número de líneas, aunque también se puede hacer con uBound.
	$iLines = @extended
	$hFile = FileOpen(StringTrimRight($sListPath, 4) & "_converted.txt", $FO_APPEND)
	If $hFile = -1 Then Return SetError(3, 0, "")
	For $i = 0 To $iLines - 1
		;split columns:
		$aSplit = StringSplit($aList[$i], "|")
		; Example of splitted text:
		; $aSplit[1]: bailen/bailen_0000.wav
		; $aSplit[2]: Inés, confusa y ruborosa, no contestó nada, cuando el diplomático se fue derecho a ella llevando de la mano a D. Diego, y le dijo:
		; $aSplit[3]: Inés, confusa y ruborosa, no contestó nada, cuando el diplomático se fue derecho a ella llevando de la mano a Don Diego, y le dijo:
		; $aSplit[4]: 7.71
		; solo necesitamos el 1 y el 3, entonces hacemos lo siguiente:
		FileWriteLine($hFile, $aSplit[1] & "|" & $aSplit[3])
	Next
	FileClose($hFile)
	Return 1
EndFunc   ;==>_dataset_matchList
; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __SortList
; Description ...: Function used to sort the audio files for transcription or filelist.
; Syntax ........: __SortList(Byref $_aSortList)
; Parameters ....: $_aSortList          - [in/out] The array containing the filenames of the wavs.
; Return values .: None
; Author ........: Subz, Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.autoitscript.com/forum/topic/208426-the-_array-functions-do-not-work-in-these-cases/
; Example .......: No
; ===============================================================================================================================
Func __SortList(ByRef $_aSortList)
	_ArrayColInsert($_aSortList, 1)
	If @error Then SetError(1, 0, "")
	For $i = 1 To $_aSortList[0][0]
		$_aSortList[$i][1] = Number(StringReplace($_aSortList[$i][0], ".wav", ""))
	Next
	_ArraySort($_aSortList, 0, 1, 0, 1)
	If @error Then SetError(2, 0, "")
EndFunc   ;==>__SortList

Func _ArraySortEx(ByRef $aArray, $iDescending = 0, $iStart = 0, $iEnd = 0, $iSubItem = 0, $iType = 2)
	If $iDescending = Default Then $iDescending = 0
	If $iStart = Default Then $iStart = 0
	If $iEnd = Default Then $iEnd = 0
	If $iSubItem = Default Then $iSubItem = 0
	If $iType = Default Then $iType = 2 ; 0 = string sort, 1 = numeric sort, 2 = natural sort

	If Not IsArray($aArray) Then Return SetError(1, 0, 0)

	Local $iDims = UBound($aArray, $UBOUND_DIMENSIONS)
	If $iDims < 1 Or $iDims > 2 Then Return SetError(4, 0, 0)

	Local $iRows = UBound($aArray, $UBOUND_ROWS)
	If $iRows = 0 Then Return SetError(5, 0, 0)

	Local $iCols = UBound($aArray, $UBOUND_COLUMNS) ; always 0 for 1D array
	If $iDims = 2 And $iSubItem > $iCols - 1 Then Return SetError(3, 0, 0)

	If $iType < 0 Or $iType > 2 Then Return SetError(6, 0, 0)

	; Bounds checking
	If $iStart < 0 Then $iStart = 0
	If $iEnd <= 0 Or $iEnd > $iRows - 1 Then $iEnd = $iRows - 1
	If $iStart > $iEnd Then Return SetError(2, 0, 0)

	Local $tIndex = DllStructCreate("uint[" & ($iEnd - $iStart + 1) & "]")
	Local $pIndex = DllStructGetPtr($tIndex)
	Local $hDll = DllOpen("kernel32.dll")
	Local $hDllComp = DllOpen("shlwapi.dll")
	Local $lo, $hi, $mi, $r, $nVal1, $nVal2

	For $i = 1 To $iEnd - $iStart
		$lo = 0
		$hi = $i - 1
		If $iDims = 1 Then ; 1D
			Do
				$mi = Int(($lo + $hi) / 2)
				Switch $iType
					Case 2 ; Natural Sort
						$r = DllCall($hDllComp, 'int', 'StrCmpLogicalW', 'wstr', String($aArray[$i + $iStart]), _
								'wstr', String($aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart]))[0]
					Case 1 ; Numeric Sort
						$nVal1 = Number($aArray[$i + $iStart])
						$nVal2 = Number($aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart])
						$r = $nVal1 < $nVal2 ? -1 : $nVal1 > $nVal2 ? 1 : 0
					Case Else ; 0 = String Sort
						$r = StringCompare($aArray[$i + $iStart], $aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart])
				EndSwitch

				Switch $r
					Case -1
						$hi = $mi - 1
					Case 1
						$lo = $mi + 1
					Case 0
						ExitLoop
				EndSwitch
			Until $lo > $hi
		Else ; 2D
			Do
				$mi = Int(($lo + $hi) / 2)
				Switch $iType
					Case 2 ; Natural Sort
						$r = DllCall($hDllComp, 'int', 'StrCmpLogicalW', 'wstr', String($aArray[$i + $iStart][$iSubItem]), _
								'wstr', String($aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart][$iSubItem]))[0]
					Case 1 ; Numeric Sort
						$nVal1 = Number($aArray[$i + $iStart][$iSubItem])
						$nVal2 = Number($aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart][$iSubItem])
						$r = $nVal1 < $nVal2 ? -1 : $nVal1 > $nVal2 ? 1 : 0
					Case Else ; 0 = String Sort
						$r = StringCompare($aArray[$i + $iStart][$iSubItem], _
								$aArray[DllStructGetData($tIndex, 1, $mi + 1) + $iStart][$iSubItem])
				EndSwitch

				Switch $r
					Case -1
						$hi = $mi - 1
					Case 1
						$lo = $mi + 1
					Case 0
						ExitLoop
				EndSwitch
			Until $lo > $hi
		EndIf

		DllCall($hDll, "none", "RtlMoveMemory", "struct*", $pIndex + ($mi + 1) * 4, _
				"struct*", $pIndex + $mi * 4, "ulong_ptr", ($i - $mi) * 4)
		DllStructSetData($tIndex, 1, $i, $mi + 1 + ($lo = $mi + 1))
	Next

	Local $aBackup = $aArray

	If $iDims = 1 Then ; 1D
		If Not $iDescending Then
			For $i = 0 To $iEnd - $iStart
				$aArray[$i + $iStart] = $aBackup[DllStructGetData($tIndex, 1, $i + 1) + $iStart]
			Next
		Else ; descending
			For $i = 0 To $iEnd - $iStart
				$aArray[$iEnd - $i] = $aBackup[DllStructGetData($tIndex, 1, $i + 1) + $iStart]
			Next
		EndIf
	Else ; 2D
		Local $iIndex
		If Not $iDescending Then
			For $i = 0 To $iEnd - $iStart
				$iIndex = DllStructGetData($tIndex, 1, $i + 1) + $iStart
				For $j = 0 To $iCols - 1
					$aArray[$i + $iStart][$j] = $aBackup[$iIndex][$j]
				Next
			Next
		Else ; descending
			For $i = 0 To $iEnd - $iStart
				$iIndex = DllStructGetData($tIndex, 1, $i + 1) + $iStart
				For $j = 0 To $iCols - 1
					$aArray[$iEnd - $i][$j] = $aBackup[$iIndex][$j]
				Next
			Next
		EndIf
	EndIf

	$tIndex = 0
	DllClose($hDll)
	DllClose($hDllComp)

	Return 1
EndFunc   ;==>_ArraySortEx
