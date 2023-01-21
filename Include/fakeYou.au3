;Fakeyou UDF. UDF to support Fakeyou.com api.
;Original idea by Mateo Cedillo, and that written the first UDF version trying adapt a code from Python, but the result It was not nice.
;Modified and rewritten by @Danifirex, that adapted and added the functions in a more appropriate way. Thanks!.
#include <Array.au3>
#include <FileConstants.au3>
#include "Json.au3"
#include <WinAPICom.au3>

Global $Au3FakeyouVer = "0.5"

; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouWaitForAudioComplete
; Description ...: It waits until the audio has been generated, that is, until the request has been completed, before being able to access the final audio file result.
; Syntax ........: _FakeYouWaitForAudioComplete($sInferenceJobToken)
; Parameters ....: $sInferenceJobToken  - The job token to be processed with.
; Return values .: returns true if the job completed, or returns @error to 1, if the operation failed. 2, if multiple attempts have been made but the process has timed out.
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouWaitForAudioComplete($sInferenceJobToken)
	While 1
		Switch _FakeYouGetQueueStatus($sInferenceJobToken)
			Case "attempt_failed"
				; Keep waiting
			Case "complete_failure"
				SetError(1, 0, "")
				ExitLoop
			Case "complete_success"
				Return True
				ExitLoop
			Case "dead"
				SetError(2, 0, "")
				ExitLoop
		EndSwitch
		Sleep(1000)
	WEnd
EndFunc   ;==>_FakeYouWaitForAudioComplete

; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouGetAudioStatus
; Description ...: Obtains the JSON code where all the audio status information of the current job can be obtained.
; Syntax ........: _FakeYouGetAudioStatus($sInferenceJobToken)
; Parameters ....: $sInferenceJobToken  - the job token.
; Return values .: The JSON code
; Author ........: Danifirex, Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouGetAudioStatus($sInferenceJobToken)
	Return __HttpGet("https://api.fakeyou.com/tts/job/" & $sInferenceJobToken)
EndFunc   ;==>_FakeYouGetAudioStatus
; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYou_getDirectAudio
; Description ...: Does the process of creating a request, a job token, getting the status and the final result of the URL that contains the generated audio
; Syntax ........: _FakeYou_getDirectAudio($sText, $sModelToken)
; Parameters ....: $sText               - a string value containing the text to be read.
;                  $sModelToken         - The voice model token to use.
; Return values .: True returns the final URL of the audio, otherwise it returns @error.
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYou_getDirectAudio($sText, $sModelToken)
	Local $sJobToken = _FakeYouGenerateAudio($sText, $sModelToken)
	$bStatus = _FakeYouWaitForAudioComplete($sJobToken)
	If @error Then Return SetError(1, 0, "")
	If $bStatus Then
		Local $sFinalURL = _FakeYouGetAudioURL($sJobToken)
		Return $sFinalURL
	Else
		Return SetError(2, 0, "")
	EndIf
EndFunc   ;==>_FakeYou_getDirectAudio
; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouGetQueueStatus
; Description ...: Gets the current status of the requested audio, ie: pending, started, complete, etc.
; Syntax ........: _FakeYouGetQueueStatus($sInferenceJobToken)
; Parameters ....: $sInferenceJobToken  - The job token.
; Return values .: The queue status.
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouGetQueueStatus($sInferenceJobToken)
	$sData = _FakeYouGetAudioStatus($sInferenceJobToken)
	$oDecodeJson = Json_decode($sData)
	Return json_get($oDecodeJson, '["state"]["status"]')
EndFunc   ;==>_FakeYouGetQueueStatus

; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouGenerateAudio
; Description ...: Generate an audio with the inference text and the token of the desired voice model
; Syntax ........: _FakeYouGenerateAudio($sText, $sTTSModelToken[, $sUUID = Default])
; Parameters ....: $sText               - The text to be generated.
;                  $sTTSModelToken      - The voice model token (TTS).
;                  $sUUID               - [optional] If you want to set a specific UUID. Default is Default, This will generate a random UUID.
; Return values .: None
; Author ........: Danifirex, Mateo Cedillo
; Modified ......:
; Remarks .......: To know the tokens of the models, you can do it from: _FakeYouGetVoicesList()
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouGenerateAudio($sText, $sTTSModelToken, $sUUID = Default)
	If $sUUID = Default Then $sUUID = __GenerateUUID()
	ConsoleWrite("UUID: " & $sUUID & @CRLF)
	Local $oJson = Null
	Json_Put($oJson, ".tts_model_token", $sTTSModelToken)
	Json_Put($oJson, ".uuid_idempotency_token", $sUUID)
	Json_Put($oJson, ".inference_text", $sText)
	Local $sJson = Json_Encode($oJson)
	ConsoleWrite($sJson & @CRLF)
	Local $sJsonReturn = __HttpPost("https://api.fakeyou.com/tts/inference", $sJson)
	ConsoleWrite($sJsonReturn & @CRLF)
	$oJson = Json_Decode($sJsonReturn)
	If $sJsonReturn = "" Or Not __FakeYou_IsSuccess($oJson) Then Return SetError(1, 0, "")
	Return Json_Get($oJson, '["inference_job_token"]')
EndFunc   ;==>_FakeYouGenerateAudio

; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouGetAudioURL
; Description ...: Gets the final URL of the requested audio. To avoid problems, it is important that when you generate an audio, you first call to _FakeYouWaitForAudioComplete function to wait until the request completes, and after then call this function, because if you do this you will be able to get the URL without problems. Otherwise, you will get a result like "null" or something.
; Syntax ........: _FakeYouGetAudioURL($sToken)
; Parameters ....: $sToken              - The job token.
; Return values .: The final URL
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouGetAudioURL($sToken)
	$sStatus = _FakeYouGetAudioStatus($sToken)
	$oDecodeJson = Json_Decode($sStatus)
	$sAudioPath = Json_get($oDecodeJson, '["state"]["maybe_public_bucket_wav_audio_path"]')
	If Not StringLeft($sAudioPath, 21) = "/tts_inference_output" Then
		Return SetError(1, 0, "")
	Else
		Return "https://storage.googleapis.com/vocodes-public" & $sAudioPath
	EndIf
EndFunc   ;==>_FakeYouGetAudioURL

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GenerateUUID
; Description ...: Generates a random UUID.
; Syntax ........: __GenerateUUID()
; Parameters ....: None
; Return values .: None
; Author ........: Danifirex, Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __GenerateUUID()
	Return StringLower(StringReplace(StringReplace(_WinAPI_CreateGUID(), "{", ""), "}", ""))
EndFunc   ;==>__GenerateUUID

; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouGetLanguajes
; Description ...: Collect all available languages
; Syntax ........: _FakeYouGetLanguajes($aVoicesList)
; Parameters ....: $aVoicesList         - An array containing the list of voice models.
; Return values .: An array containing the collected languages
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouGetLanguajes($aVoicesList)
	If Not UBound($aVoicesList, 2) = 15 Then Return SetError(1, 0, "")
	Local $sLanguage = ""
	Local $aArray[1]
	For $I = 0 To UBound($aVoicesList, 1) - 1
		ReDim $aArray[UBound($aArray) + 1]
		$aArray[$I] = $aVoicesList[$I][7]
	Next
	_ArrayDelete($aArray, UBound($aArray) - 1)
	If Not IsArray($aArray) Then Return SetError(2, 0, "")
	_ArraySort($aArray)
	For $I = 0 To UBound($aArray) - 1
		If UBound($aArray) = $I + 1 Then ExitLoop
		If $aArray[$I] = $aArray[$I + 1] Then
			_ArrayDelete($aArray, $I)
			If @error Then
				ExitLoop
				Return SetError(@error + 2, 0, "")
			EndIf
			$I = $I - 1
		EndIf
	Next
	Return $aArray
EndFunc   ;==>_FakeYouGetLanguajes

; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouGetVoicesFromLanguage
; Description ...: Get all the available voices of a specific language
; Syntax ........: _FakeYouGetVoicesFromLanguage($aVoicesList[, $sLanguage = "en"])
; Parameters ....: $aVoicesList         - The array containing the list of voice models.
;                  $sLanguage           - [optional] string containing the language, for example: en, en-us, es, es-es. Default is "en".
; Return values .: An array containing only the available voices of the specified language
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouGetVoicesFromLanguage($aVoicesList, $sLanguage = "en")
	If Not UBound($aVoicesList, 2) = 15 Then Return SetError(1, 0, "")
	Local $bLangDetected = False, $aLanguages = _FakeYouGetLanguajes($aVoicesList)
	If Not IsArray($aLanguages) Or @error Then Return SetError(2, 0, "")
	For $I = 0 To UBound($aLanguages) - 1
		If $aLanguages[$I] = $sLanguage Then
			$bLangDetected = True
			ExitLoop
		EndIf
	Next
	If Not $bLangDetected Then Return SetError(3, 0, "")
	Local $aArray[1]
	For $I = 0 To UBound($aVoicesList, 1) - 1
		ReDim $aArray[UBound($aArray) + 1]
		If $aVoicesList[$I][7] = $sLanguage Then
			$aArray[$I] = $aVoicesList[$I][6]
			;Else
			;ContinueLoop
		EndIf
	Next
	__CleanArray($aArray)
	_ArraySort($aArray)
	Return $aArray
EndFunc   ;==>_FakeYouGetVoices

; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouGetVoiceModelToken
; Description ...: Gets the model token from the name of a voice.
; Syntax ........: _FakeYouGetVoiceModelToken($aVoicesList, $sVoiceName)
; Parameters ....: $aVoicesList         - The array containing the list of voice models.
;                  $sVoiceName          - Una cadena que contiene el nombre de la voz.
; Return values .: A string containing the model token
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......: The voice names can be obtained from _FakeYouGetVoicesFromLanguage, or alternatively, from _FakeYouGetVoicesList by specifying the parameters, then [$iVoiceNumber][6]
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouGetVoiceModelToken($aVoicesList, $sVoiceName)
	If Not UBound($aVoicesList, 2) = 15 Then Return SetError(1, 0, "")
	Local $sResult = ""
	For $I = 0 To UBound($aVoicesList, 1) - 1
		$sResult = $aVoicesList[$I][6]
		If $sResult = $sVoiceName Then
			Return $aVoicesList[$I][0]
		Else
			ContinueLoop
		EndIf
	Next
	Return SetError(2, 0, "")
EndFunc   ;==>_FakeYouGetVoiceModelToken

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __CleanArray
; Description ...: This function checks if there is an blank or empty element inside the array. If so, it deletes it.
; Syntax ........: __CleanArray(Byref $aArray)
; Parameters ....: $aArray              - [in/out] The array to be fixed.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __CleanArray(ByRef $aArray)
	If Not IsArray($aArray) Then Return SetError(1, 0, "")
	For $I = 0 To UBound($aArray) - 1
		If UBound($aArray) = $I + 1 Then ExitLoop
		If $aArray[$I] = "" Then
			_ArrayDelete($aArray, $I)
			If @error Then
				ExitLoop
				Return SetError(@error, 0, "")
			EndIf
			$I = $I - 1
		Else
			ContinueLoop
		EndIf
	Next
	_ArrayDelete($aArray, UBound($aArray) - 1)
EndFunc   ;==>__CleanArray

; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouGetVoicesCategoriesList
; Description ...: Get the available categories.
; Syntax ........: _FakeYouGetVoicesCategoriesList()
; Parameters ....: None
; Return values .: An array with the list of categories.
; Author ........: Danifirex, Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouGetVoicesCategoriesList()
	Local $sJson = __HttpGet("https://api.fakeyou.com/category/list/tts")
	ConsoleWrite($sJson & @CRLF)
	Local $oJson = Json_Decode($sJson)
	If $sJson = "" Or Not __FakeYou_IsSuccess($oJson) Then Return SetError(1, 0, "")
	Local $aoJson = Json_Get($oJson, '["categories"]')
	If Not IsArray($aoJson) Then Return SetError(2, 0, "")
	Local $aVoicesCategories[UBound($aoJson)][12]
	Local $aMembers[] = ["category_token", "model_type", "maybe_super_category_token", "can_directly_have_models", "can_have_subcategories", _
			"can_only_mods_apply", "name", "name_for_dropdown", "is_mod_approved", "created_at", _
			"updated_at", "deleted_at"]
	For $I = 0 To UBound($aoJson) - 1
		For $x = 0 To UBound($aMembers) - 1
			$aVoicesCategories[$I][$x] = Json_Get($aoJson[$I], '["' & $aMembers[$x] & '"]')
		Next
	Next
	Return $aVoicesCategories
EndFunc   ;==>_FakeYouGetVoicesCategoriesList

; #FUNCTION# ====================================================================================================================
; Name ..........: _FakeYouGetVoicesList
; Description ...: Get the list of voices.
; Syntax ........: _FakeYouGetVoicesList([$bUseCache = False[, $bSabeCache = False]])
; Parameters ....: $bUseCache           - [optional] A boolean value to set whether to use the cache instead of internet. Default is False (don't use cache).
;                  $bSabeCache          - [optional] A boolean value that is used to establish if we want to save the cache. Default is False (don't save).
; Return values .: A 2d array with the info. of the available voices.
; Author ........: Danifirex, Mateo Cedillo
; Modified ......: Yes
; Remarks .......: If we want to use the cache, we must first save it by passing the use parameter to the default (false). The use and saving of the cache is up to you and how you want to use it. It is recommended to use the cache to increase the speed of getting voices, and to save in case new voice models become available.
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _FakeYouGetVoicesList($bUseCache = False, $bSabeCache = False)
	If Not $bUseCache Then
		Local $sJson = __HttpGet("https://api.fakeyou.com/tts/list")
	Else
		Local $hFile = FileOpen(@ScriptDir & "\cache\Voicelist.dat", $fo_read)
		If Not FileExists(@ScriptDir & "\cache\Voicelist.dat") Then
			Return SetError(1, 0, "") ;You must save the cache to use it.
		ElseIf $hFile = -1 Then
			Return SetError(2, 0, "") ;error opening cache file.
		EndIf
		Local $sJson = FileRead($hFile)
		FileClose($hFile)
	EndIf
	If $bSabeCache Then
		$hFile = FileOpen(@ScriptDir & "\cache\Voicelist.dat", $FO_OVERWRITE + $FO_CREATEPATH)
		If @error Then Return SetError(3, 0, "") ;The file cannot be written.
		FileWrite($hFile, $sJson)
		FileClose($hFile)
	EndIf
	;ConsoleWrite($sJson & @CRLF)
	Local $oJson = Json_Decode($sJson)
	If $sJson = "" Or Not __FakeYou_IsSuccess($oJson) Then Return SetError(4, 0, "")
	Local $aoJson = Json_Get($oJson, '["models"]')
	If Not IsArray($aoJson) Then Return SetError(5, 0, "")
	Local $aVoices[UBound($aoJson)][15]
	Local $aMembers[] = ["model_token", "tts_model_type", "creator_user_token", "creator_username", "creator_display_name", _
			"creator_gravatar_hash", "title", "ietf_language_tag", "ietf_primary_language_subtag", "is_front_page_featured", _
			"is_twitch_featured", "maybe_suggested_unique_bot_command", "category_tokens", "created_at", "updated_at"]
	Local $sMemberValue = ""
	For $I = 0 To UBound($aoJson) - 1
		For $x = 0 To UBound($aMembers) - 1
			$sMemberValue = Json_Get($aoJson[$I], '["' & $aMembers[$x] & '"]')
			If $aMembers[$x] = "category_tokens" Then
				For $n = 0 To UBound($sMemberValue) - 1
					$aVoices[$I][$x] &= Json_Get($sMemberValue, '[' & $n & ']') & (($n < UBound($sMemberValue) - 1) ? "|" : "")
				Next
			Else
				$aVoices[$I][$x] = $sMemberValue
			EndIf
		Next
	Next
	Return $aVoices
EndFunc   ;==>_FakeYouGetVoicesList

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __FakeYou_IsSuccess
; Description ...: (internal) Checks if the call completed successfully.
; Syntax ........: __FakeYou_IsSuccess(Byref $oJson)
; Parameters ....: $oJson               - [JSON] object.
; Return values .: None
; Author ........: Danifirex, Mateo Cedillo
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __FakeYou_IsSuccess(ByRef $oJson)
	Return Json_ObjExists($oJson, 'success')
EndFunc   ;==>__FakeYou_IsSuccess
