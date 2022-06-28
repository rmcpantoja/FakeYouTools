#include "json.au3"
;API for FakeYou.com in Autoit (work in progress).
;Original API writen in pithon at: https://github.com/mmattDonk/AI-TTS-Donations/blob/main/API/fakeyou.py
func _get_job($sText, $sVoice_Name)
#cs
Get the FakeYou Voice job.
param $sText: The text to be spoken.
param $sVoice_name: The name of the voice to be used.
return: The job.
#ce
;Alternative for this? (python)
;uuid_str = str(uuid4())
;autoit:
$uuid_str = "uuid4"
local $hObj, $sParams, $uuid, $detail
$hObj = __POSTObjCreate()
If $hObj = -1 Then Return 0
$hObj.Open("POST", "https://api.fakeyou.com/tts/inference", False)
$hObj.WaitForResponse()
$sParams = 'json={"inference_text": ' &$sText &',' &@lf & _
'"tts_model_token": ' &$sVoice_name &',' &@lf & _
'"uuid_idempotency_token": ' &$uuid_str &',' &@lf & _
"},"
$uuid = false
$detail = false
$detail = _JSON_Get($sParams, "success")
if $detail = False then
$detail = "That voice does not exist"
EndIf
$uuid = _JSON_Get($sParams, "inference_job_token"]
$hObj.Send($sParams)
$hObj.WaitForResponse()
$Response = $hObj.ResponseText
msgbox(0, "Debug", $Response)
return '{"detail": ' &$detail &',' &@lf & _
'"uuid": ' &$uuid &',' &@lf & _
"}"
EndFunc
;Get winHttp object:
Func __POSTObjCreate()
Local $o_lHTTP = ObjCreate("winhttp.winhttprequest.5.1")
Return SetError(@error, 0, ((IsObj($o_lHTTP) = 1) ? $o_lHTTP : -1))
EndFunc   ;==>__POSTObjCreate