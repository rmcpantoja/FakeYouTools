; Dataset manager for FakeYou (Tacotron 2).
;Author: Mateo Cedillo
; Fixes and suggests by @Subz and @pixelsearch
#include <Array.au3>
#include "dataset\audioProcessing.au3"
#include "ConsoleProgress.au3"
#include <File.au3>
#include <sound.au3>
$sFakeYouDatasetManager_Ver = "0.6.0"
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
Func _changeDatasetOrder($sPath, $sListFileName, $nNum, $bConsole = False)
	Local $aFilesList, $aFile, $aTexts[]
	Local $iLines, $iResult = 0
	Local $sFileName = ""
	$aFilesList = _FileListToArrayRec($sPath & "\wavs", "*.wav", 1, 0, 2)
	If @error Then Return SetError(1, 0, "")
	$aFile = _dataset_open_transcription($sListFileName)
	$iLines = UBound($aFile, 1)
	If @error Then Return SetError(2, 0, "")
	If $bConsole Then ConsoleWrite("Phase 1: split the transcript." & @CRLF)
	For $i = 0 To $iLines - 1
		$aTexts[$i] = $aFile[$i][1]
		If $bConsole Then _PrintProgress($i + 1, $iLines)
	Next
	$hFileOpen = FileOpen(StringTrimRight($sListFileName, 4) & "_converted.txt", 1)
	If $hFileOpen = -1 Then Return SetError(3, 0, "")
	Local $nItem = 0
	_ArraySortEx($aFilesList, Default, 1, Default, Default, 1)
	If @error Then Return SetError(4, 0, "")
	If $bConsole Then ConsoleWrite("Phase 2: rename files and change list." & @CRLF)
	For $IProcess = 1 To $aFilesList[0]
		If $bConsole Then _PrintProgress($IProcess, $aFilesList[0])
		FileMove($sPath & "\wavs\" & $aFilesList[$IProcess], $sPath & "\wavs\" & $nNum & ".wav", $FC_OVERWRITE)
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
Func _AhoTtsDataset2Tacotron($sPath, $sListFileName = "list.txt", $iMode = 1, $bConsole = False)
	Local $aFilesList[]
	Local $bListOnly = False
	Local $sFilesList = "", $sText = ""
	$aFilesList = _FileListToArrayRec($sPath, "*.wav", 1, 0, 2)
	If @error Then
		$bListOnly = True
	ElseIf Not FileExists($sListFileName) Then
		Return SetError(1, 0, "")
	EndIf
	$aFile = FileReadToArray($sListFileName)
	If @error Then Return SetError(2, 0, "")
	$iLines = @extended
	$hFileOpen = FileOpen($sPath & "\" & StringTrimRight($sListFileName, 4) & "_converted.txt", 1)
	If $hFileOpen = -1 Then Return SetError(3, 0, "")
	Local $nNum = 1
	If Not $bListOnly Then
		If Not FileExists($sPath & "\wavs") Then DirCreate($sPath & "\wavs")
		If Not $aFilesList[0] = $iLines Then Return SetError(4, 0, "")
	EndIf
	For $IProcess = 1 To $aFilesList[0]
		If $bConsole Then _PrintProgress($IProcess, $aFilesList[0])
		If $iMode = 1 Then
			$sText = $aFile[$IProcess - 1]
		ElseIf $iMode = 2 Then
			$sText = StringSplit($aFile[$IProcess - 1], @TAB)[2]
		EndIf
		If Not $bListOnly Then FileMove($sPath & "\" & $aFilesList[$IProcess], $sPath & "\wavs\" & $nNum & ".wav", $FC_OVERWRITE)
		FileWriteLine($hFileOpen, "wavs/" & $nNum & ".wav|" & $sText)
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
Func _DatasetFixList($sListPath, $sLang = "en", $bConsole = False)
	Local $aFile, $aPuncs[] = [",", ".", "¡", "!", "¿", "?", ";", ":"]
	Local $bPunctuation = False
	Local $iCount = 0
	Local $sReplacements = 0, $sText = ""
	Switch $sLang
		Case "en"
			Local $aSimbols[][2] = [["ñ", "n"], ["1", "one"], ["2", "two"], ["3", "three"], ["4", "four"], ["5", "five"], ["6", "six"], ["7", "seven"], ["8", "eight"], ["9", "nine"], ["0", "zero"], ["...", ","], ["(", ","], [")", "."]]
		Case "old_es"
			Local $aSimbols[][2] = [["ñ", "ni"], ["1", "uno"], ["2", "dos"], ["3", "tres"], ["4", "cuatro"], ["5", "cinco"], ["6", "seis"], ["7", "siete"], ["8", "ocho"], ["9", "nueve"], ["0", "cero"], ["...", ","], ["(", ","], [")", "."]]
		Case "es"
			Local $aSimbols[][2] = [["1", "uno"], ["2", "dos"], ["3", "tres"], ["4", "cuatro"], ["5", "cinco"], ["6", "seis"], ["7", "siete"], ["8", "ocho"], ["9", "nueve"], ["0", "cero"], ["...", ","]]
	EndSwitch
	If Not FileExists($sListPath) Then Return SetError(1, 0, "")
	$aFile = _dataset_open_transcription($sListPath)
	If @error Then Return SetError(2, 0, "")
	$hFileOpen = FileOpen(StringTrimRight($sListPath, 4) & "_fixed.txt", 1)
	If $hFileOpen = -1 Then Return SetError(3, 0, "")
	$iCount = UBound($aFile, $UBOUND_ROWS)
	For $i = 0 To UBound($aFile, $UBOUND_ROWS) - 1
		If $bConsole Then _PrintProgress($i + 1, $iCount)
		$sText = $aFile[$i][1]
		For $iStart = 0 To UBound($aSimbols, 1) - 1
			If StringInStr($sText, $aSimbols[$iStart][0]) Then
				$sText = StringReplace($sText, $aSimbols[$iStart][0], $aSimbols[$iStart][1])
				$sReplacements = $sReplacements + @extended
				If $bConsole Then ConsoleWrite("a match was found in line " & $i & " of " & $iCount & ". Simbol: " & $aSimbols[$iStart][0] & " = " & $aSimbols[$iStart][1] & "." & @CRLF)
			Else
				ContinueLoop
			EndIf
			Sleep(10)
		Next
		; check if there is end punctuation.
		For $iPunc = 0 To UBound($aPuncs) - 1
			If StringRight($sText, 1) = $aPuncs[$iPunc] Then
				$bPunctuation = True
				ExitLoop
			Else
				$bPunctuation = False
			EndIf
		Next
		If Not $bPunctuation Then
			If $bConsole Then ConsoleWrite("Warning: " & $aFile[$i][1] & " It has no end punctuation. Adding end punctuation..." & @CRLF)
			$sText &= "."
			$bPunctuation = True
		EndIf
		$aFile[$i][1] = $sText
	Next
	FileWrite($hFileOpen, _ArrayToString($aFile, "|"))
	FileClose($hFileOpen)
	SetExtended($sReplacements)
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
Func _Dataset_get_WavsDuration($sWavsPath = @ScriptDir & "\wavs", $sListPath = @ScriptDir & "\list.txt", $iMode = 1, $sSecondRange = "5-15", $bResults = True, $bConsole = False)
	Local $aList, $aFilesList, $aDurations, $aRange
	Local $iResult = 0, $iLines = 0, $iSecs, $iHours, $iMins, $iSecs2
	Local $sFileName = ""
	If $iMode = 1 Then
		If Not FileExists($sWavsPath) Then Return SetError(1, 0, "")
		$aFilesList = _FileListToArrayRec($sWavsPath, "*.wav", 1, 0, 2)
		If @error Then Return SetError(2, 0, "")
		$aRange = StringSplit($sSecondRange, "-")
		For $i = 1 To $aFilesList[0]
			If $bConsole Then ConsoleWrite("Checking " & $aFilesList[$i] & "... ")
			$aDurations[$i - 1] = __Dataset_GetAudioDuration($sWavsPath & "\" & $aFilesList[$i], $aRange[1], $aRange[2], $bConsole)
			$iResult = $iResult + $aDurations[$i - 1]
			If @error Then
				Return SetError(3, 0, "")
				ExitLoop
			EndIf
			If $bConsole Then ConsoleWrite("Done." & @CRLF)
			Sleep(10)
		Next
	ElseIf $iMode = 2 Then
		If $sWavsPath = Default Then $sWavsPath = "none" ; It is not necessary in this mode.
		If Not FileExists($sListPath) Then Return SetError(1, 0, "")
		$aList = _dataset_open_transcription($sListPath)
		If @error Then Return SetError(2, 0, "")
		$iLines = UBound($aList, 1)
		For $i = 0 To $iLines - 1
			$iResult = $iResult + $aList[$i][3]
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
	If Not $bResults Then
		Return $iHours & ":" & $iMins & ":" & $iSecs2
	Else
		Local $aResults[3] = [$iHours & ":" & $iMins & ":" & $iSecs2, _ArrayMin($aDurations, 0, 1), _ArrayMax($aDurations, 0, 1)]
	EndIf
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
Func __Dataset_GetAudioDuration($sFile, $iMinSeconds = 2, $iMaxSeconds = 20, $bConsole = False)
	Local $aSound
	$aSound = _SoundOpen($sFile)
	If @error Then Return SetError(1, 0, "")
	$sLenght = _SoundLength($aSound, 2)
	$aLenghtFormat = StringSplit(_SoundLength($aSound, 1), ":")
	If $aLenghtFormat[3] <= $iMinSeconds Then
		If $bConsole Then ConsoleWrite("Warning: the duration of " & $sFile & " It lasts smaller than " & $aLenghtFormat[3] & @CRLF)
	ElseIf $aLenghtFormat[3] >= $iMaxSeconds Then
		If $bConsole Then ConsoleWrite("Warning: the duration of " & $sFile & " It lasts longer than " & $aLenghtFormat[3] & @CRLF)
	EndIf
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
Func _Dataset_CreateTranscription($sFileName, $iMaxItems, $sWavsPath = @ScriptDir & "\wavs", $bConsole = False)
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
			If $bConsole Then _PrintProgress($i + 1, $iMaxItems)
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
Func _Dataset_CleanFiles($sWavsPath, $iMode, $sSearch = "HP2-4BAND-3090_4band_arch-500m_1|HP2-4BAND-3090_4band_arch-500m_1_DeepExtraction", $BRemoveVocals = False, $bConsole = False)
	Local $aSearches, $bMultiSearch = False
	Local $aVRTipes[2] = ["instruments", "vocals"]
	Local $aFileList = _FileListToArrayRec($sWavsPath, "*.wav", 1, 0, 2)
	If @error Then Return SetError(1, 0, "")
	If StringInStr($sSearch, "|") Then $bMultiSearch = True
	;__SortList($aFileList)
	;If @error Then Return SetError(2, 0, "")
	Local $sFileName = "", $sOldName = "", $sNewName = "", $aFileParts[]
	If $bMultiSearch Then $aSearches = StringSplit($sSearch, "|")
	If $bConsole Then ConsoleWrite("Cleaning files..." & @CRLF)
	For $i = 1 To $aFileList[0]
		Switch $iMode
			Case 1 ; melodyne
				$aFileParts = StringSplit($aFileList[$i], ".")
				$sNewName = $aFileParts[1] & $aFileParts[3]
				;if FileExists($sWavsPath & "\" &$sNewName) then FileDelete($sWavsPath & "\wavs\" &$sNewName)
				If $bConsole Then ConsoleWrite("replace original file " & $sWavsPath & "\" & $aFileList[$i] & " to " & $sWavsPath & "\" & $sNewName & @CRLF)
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
			Case 3 ; unity:
				$sMetaFileName = $sWavsPath & "\" & $aFileList[$i] & ".meta"
				If FileExists($sMetaFileName) Then
					If $bConsole Then ConsoleWrite("deleting: " & $sMetaFileName & @CRLF)
					FileDelete($sMetaFileName)
				EndIf
			Case 4 ; prosodylab:
				$sMetaFileName = $sWavsPath & "\" & StringTrimRight($aFileList[$i], 4) & ".lab"
				If FileExists($sMetaFileName) Then
					If $bConsole Then ConsoleWrite("deleting: " & $sMetaFileName & @CRLF)
					FileDelete($sMetaFileName)
				EndIf
		EndSwitch
	Next
	Return 1
EndFunc   ;==>_Dataset_CleanFiles
; #FUNCTION# ====================================================================================================================
; Name ..........: _dataset_open_transcription
; Description ...:
; Syntax ........: _dataset_open_transcription($sListPath)
; Parameters ....: $sListPath           - a string value.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _dataset_open_transcription($sListPath)
	Local $aFile
	If Not FileExists($sListPath) Then Return SetError(1, 0, "")
	$aFile = FileReadToArray($sListPath)
	If @error Then Return SetError(2, 0, "")
	$iColumns = StringSplit($aFile[0], "|")[0]
	If Not $iColumns > 2 Then Return SetError(3, 0, "")
	Local $aSplit[UBound($aFile)][$iColumns]
	For $i = 0 To UBound($aFile) - 1
		For $j = 0 To $iColumns - 1
			$aSplit[$i][$j] = StringSplit($aFile[$i], "|")[$j + 1]
		Next
	Next
	Return $aSplit
EndFunc   ;==>_dataset_open_transcription
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
; Name ..........: _Dataset_txt2Lab
; Description ...:
; Syntax ........: _Dataset_txt2Lab($sListPath, $sConvertedPath)
; Parameters ....: $sListPath           - a string value.
;                  $sConvertedPath      - a string value.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _Dataset_txt2Lab($sListPath, $sConvertedPath)
	If Not FileExists($sListPath) Then Return SetError(1, 0, "")
	$aList = FileReadToArray($sListPath)
	If @error Then Return SetError(2, 0, "")
	$iLines = @extended
	If Not FileExists($sConvertedPath) Then DirCreate($sConvertedPath)
	For $i = 0 To $iLines - 1
		$hFile = FileOpen($sConvertedPath & "\" & $i + 1 & ".lab", $FO_APPEND)
		If $hFile = -1 Then Return SetError(3, 0, "")
		FileWrite($hFile, StringSplit($aList[$i], "|")[2])
		FileClose($hFile)
	Next
	Return 1
EndFunc   ;==>_Dataset_txt2Lab
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
	$sStatus = _Dataset_get_WavsDuration($sPath & "\wavs")
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
	ElseIf $aTime[1] = 1 Or $aTime[1] = 2 Or $aTime[1] = 3 Or $aTime[1] = 4 Or $aTime[1] = 5 Then
		Return 7
	ElseIf $aTime[1] = 6 Or $aTime[1] = 7 Or $aTime[1] = 8 Then
		Return 8
	ElseIf $aTime[1] = 9 Or $aTime[1] = 10 Or $aTime[1] = 11 Or $aTime[1] = 12 Then
		Return 9
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
Func _dataset_matchList($sListPath = @ScriptDir & "\list.txt", $bSpeaker = False, $nSpeaker = 0, $bConsole = False)
	;declare:
	Local $aList
	Local $hFile
	Local $iLines, $iColumns
	Local $sFinalTranscription
	If Not FileExists($sListPath) Then Return SetError(1, 0, "")
	; open list:
	$aList = _dataset_open_transcription($sListPath)
	If @error Then Return SetError(2, 0, "")
	; getting number of lines.
	$iLines = UBound($aList, 1)
	$iColumns = UBound($aList, 2)
	$hFile = FileOpen(StringTrimRight($sListPath, 4) & "_converted.txt", $FO_APPEND)
	If $hFile = -1 Then Return SetError(3, 0, "")
	For $i = 0 To $iLines - 1
		If $bConsole Then _PrintProgress($i + 1, $iLines)
		; Example of splitted text:
		; $aList[0][0]: bailen/bailen_0000.wav
		; $aList[0][1]: Inés, confusa y ruborosa, no contestó nada, cuando el diplomático se fue derecho a ella llevando de la mano a D. Diego, y le dijo:
		; $aList[0][2]: Inés, confusa y ruborosa, no contestó nada, cuando el diplomático se fue derecho a ella llevando de la mano a Don Diego, y le dijo:
		; $aList[0][3]: 7.71
		; we only need the 0 and 2, so we do the following:
		If Not $bSpeaker Then
			$sFinalTranscription = $aList[$i][0] & "|" & $aList[$i][2]
		Else
			If IsNumber($nSpeaker) Then
				If $iColumns = 2 Then
					$sFinalTranscription = $aList[$i][0] & "|" & $aList[$i][1] & "|" & $nSpeaker
				ElseIf $iColumns = 4 Then
					$sFinalTranscription = $aList[$i][0] & "|" & $aList[$i][2] & "|" & $nSpeaker
				Else
					Return SetError(4, 0, "")
				EndIf
			Else
				Return SetError(5, 0, "")
			EndIf
		EndIf
		FileWriteLine($hFile, $sFinalTranscription)
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

; #FUNCTION# ====================================================================================================================
; Name ..........: _ArraySortEx
; Description ...:
; Syntax ........: _ArraySortEx(Byref $aArray[, $iDescending = 0[, $iStart = 0[, $iEnd = 0[, $iSubItem = 0[, $iType = 2]]]]])
; Parameters ....: $aArray              - [in/out] an array of unknowns.
;                  $iDescending         - [optional] an integer value. Default is 0.
;                  $iStart              - [optional] an integer value. Default is 0.
;                  $iEnd                - [optional] an integer value. Default is 0.
;                  $iSubItem            - [optional] an integer value. Default is 0.
;                  $iType               - [optional] an integer value. Default is 2.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
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
