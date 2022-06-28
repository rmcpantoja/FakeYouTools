;Fakeyou UDF. UDF to support Fakeyou.com api.
;Original idea by Mateo Cedillo, and that written the first UDF version trying adapt a code from Python, but the result It was not nice.
;Modified and rewritten by @danifirex, that adapted and added the functions in a more appropriate way. Thanks!.
#include <Array.au3>
#include "Json.au3"
#include <WinAPICom.au3>

global $Au3FakeyouVer = "0.3"
Global Const $HTTP_STATUS_OK = 200
_TestFakeAPI()
Func _TestFakeAPI()
;Local $aVoices = _FakeYouGetVoicesList()
;_ArrayDisplay($aVoices)
;Local $aVoicesCategories = _FakeYouGetVoicesCategoriesList()
;_ArrayDisplay($aVoicesCategories)
Local $sJobToken = _FakeYouGenerateAudio("Hello World","TM:7wbtjphx8h8v")
ConsoleWrite("Result of the generated audio: " &$sJobToken & @CRLF)
ConsoleWrite("Waiting for audio complete..." &@crlf)
_FakeYouWaitForAudioComplete($sJobToken)

Local $sFinalURL =  _FakeYouGetAudioURL($sJobToken)
ConsoleWrite("Audio URL: " &$sFinalURL &@crlf)
EndFunc ;==>_TestFakeAPI
;New function (beta): It waits until the audio has been generated, that is, until the request has been completed, before being able to access the final audio file result.
Func _FakeYouWaitForAudioComplete($sInferenceJobToken)
while 1
msgbox(0, "Debug", _FakeYouGetQueueStatus($sInferenceJobToken))
if _FakeYouGetQueueStatus($sInferenceJobToken) = "complete_success" then
msgbox(0, "Done", "Complete. Enjoy.")
exitLoop
EndIf
sleep(1000)
WEnd
EndFunc


Func _FakeYouGetAudioStatus($sInferenceJobToken)
Return __HttpGet("https://api.fakeyou.com/tts/job/" & $sInferenceJobToken)
EndFunc
;New function(beta): Gets the current status of the requested audio, ie: pending, started, complete, etc.
Func _FakeYouGetQueueStatus($sInferenceJobToken)
$sData = _FakeYouGetAudioStatus($sInferenceJobToken)
$oDecodeJson = Json_decode($sData)
return json_get($oDecodeJson, '["status"]')
EndFunc

Func _FakeYouGenerateAudio($sText,$sTTSModelToken, $sUUID = Default)
If $sUUID = Default Then $sUUID = __GenerateUUID()
ConsoleWrite($sUUID & @CRLF)
Local $oJson=Null
Json_Put($oJson, ".tts_model_token", $sTTSModelToken)
Json_Put($oJson, ".uuid_idempotency_token", $sUUID)
Json_Put($oJson, ".inference_text", $sText)
Local $sJson=Json_Encode($oJson)
ConsoleWrite($sJson & @CRLF)
Local $sJsonReturn=__HttpPost("https://api.fakeyou.com/tts/inference",$sJson)
ConsoleWrite($sJsonReturn & @CRLF)
$oJson = Json_Decode($sJsonReturn)
If $sJsonReturn = "" Or Not __FakeYou_IsSuccess($oJson) Then Return SetError(1, 0, "")
Return Json_Get($oJson, '["inference_job_token"]')
EndFunc ;==>_FakeYouGenerateAudio
;New function: Gets the final URL of the requested audio. To avoid problems, it is important that when you generate an audio, you first call to _FakeYouWaitForAudioComplete function to wait until the request completes, and after then call this function, because if you do this you will be able to get the URL without problems. Otherwise, you will get a result like "null" or something.
func _FakeYouGetAudioURL($sToken)
$sStatus = _FakeYouGetAudioStatus($sToken)
msgbox(0, "Debug", $sStatus)
$oDecodeJson = Json_Decode($sStatus)
$sAudioPath = Json_get($oDecodeJson, '["maybe_public_bucket_wav_audio_path"]')
if not StringLeft($sAudioPath, 21) = "/tts_inference_output" then
Return SetError(1, 0, "")
Else
return "https://storage.googleapis.com/vocodes-public/" &$sAudioPath
EndIf
EndFunc

Func __GenerateUUID()
Return StringLower(StringReplace(StringReplace(_WinAPI_CreateGUID(), "{", ""), "}", ""))
EndFunc ;==>__GenerateUUID

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
For $i = 0 To UBound($aoJson) - 1
For $x = 0 To UBound($aMembers) - 1
$aVoicesCategories[$i][$x] = Json_Get($aoJson[$i], '["' & $aMembers[$x] & '"]')
Next
Next
Return $aVoicesCategories
EndFunc ;==>_FakeYouGetVoicesCategoriesList

Func _FakeYouGetVoicesList()
Local $sJson = __HttpGet("https://api.fakeyou.com/tts/list")
ConsoleWrite($sJson & @CRLF)
Local $oJson = Json_Decode($sJson)
If $sJson = "" Or Not __FakeYou_IsSuccess($oJson) Then Return SetError(1, 0, "")
Local $aoJson = Json_Get($oJson, '["models"]')
If Not IsArray($aoJson) Then Return SetError(2, 0, "")
Local $aVoices[UBound($aoJson)][15]
Local $aMembers[] = ["model_token", "tts_model_type", "creator_user_token", "creator_username", "creator_display_name", _
"creator_gravatar_hash", "title", "ietf_language_tag", "ietf_primary_language_subtag", "is_front_page_featured", _
"is_twitch_featured", "maybe_suggested_unique_bot_command", "category_tokens", "created_at", "updated_at"]
Local $sMemberValue = ""
For $i = 0 To UBound($aoJson) - 1
For $x = 0 To UBound($aMembers) - 1
$sMemberValue = Json_Get($aoJson[$i], '["' & $aMembers[$x] & '"]')
If $aMembers[$x] = "category_tokens" Then
For $n = 0 To UBound($sMemberValue) - 1
$aVoices[$i][$x] &= Json_Get($sMemberValue, '[' & $n & ']') & (($n < UBound($sMemberValue) - 1) ? "|" : "")
Next
Else
$aVoices[$i][$x] = $sMemberValue
EndIf
Next
Next
Return $aVoices
EndFunc ;==>_FakeYouGetVoicesList

Func __FakeYou_IsSuccess(ByRef $oJson)
Return Json_ObjExists($oJson, 'success')
EndFunc ;==>__FakeYou_IsSuccess


Func __HttpGet($sURL, $sData = "")
Local $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc")
Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
$oHTTP.Open("GET", $sURL & "?" & $sData, False)
If (@error) Then Return SetError(1, 0, 0)
$oHTTP.SetRequestHeader("Content-Type", "application/json")
$oHTTP.Send()
If (@error) Then Return SetError(2, 0, 0)
If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)
Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc ;==>__HttpGet

Func __HttpPost($sURL, $sData = "")
Local $oErrorHandler = ObjEvent("AutoIt.Error", "_ErrFunc")
Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")
$oHTTP.Open("POST", $sURL, False)
If (@error) Then Return SetError(1, 0, 0)
$oHTTP.SetRequestHeader("Content-Type", "application/json")
$oHTTP.Send($sData)
If (@error) Then Return SetError(2, 0, 0)
If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)
Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc ;==>__HttpPost

; User's COM error function. Will be called if COM error occurs
Func _ErrFunc($oError)
; Do anything here.
ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
@TAB & "err.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
@TAB & "err.windescription:" & @TAB & $oError.windescription & @CRLF & _
@TAB & "err.description is: " & @TAB & $oError.description & @CRLF & _
@TAB & "err.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
@TAB & "err.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
@TAB & "err.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
@TAB & "err.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
@TAB & "err.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
@TAB & "err.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc ;==>_ErrFunc