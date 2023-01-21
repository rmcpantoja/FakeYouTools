#include "include\bassfunctions.au3"
#include "include\fakeYou.au3"
local $hUrl
_Example()
Func _Example()
	_Audio_init_start()
	;Local $aVoices = _FakeYouGetVoicesList()
	;_ArrayDisplay($aVoices)
	;Local $aVoicesCategories = _FakeYouGetVoicesCategoriesList()
	;_ArrayDisplay($aVoicesCategories)
	Local $sJobToken = _FakeYouGenerateAudio("Hola mundillo.", "TM:jgv6d8br5jdr")
	ConsoleWrite("Result of the generated audio: " & $sJobToken & @CRLF)
	ConsoleWrite("Waiting for audio complete..." & @CRLF)
	$bStatus = _FakeYouWaitForAudioComplete($sJobToken)
	if @error then
		Switch @error
			case 1
				ConsoleWriteError("This job has failed")
			case 2
				ConsoleWriteError("We have retried to process this job, but it has timed out. Please try again later.")
		EndSwitch
	EndIf
	if $bStatus then
		Local $sFinalURL = _FakeYouGetAudioURL($sJobToken)
		ConsoleWrite("Audio URL: " & $sFinalURL & @CRLF)
		$hUrl = _Set_url($sFinalURL)
		If @error then
			MsgBox(16, "Error", "Unable to load URL.")
			_Audio_stop($hUrl)
			_Audio_init_stop($hUrl)
		Else
			_Audio_play($hUrl)
			sleep(11000)
		EndIF
	Else
		ConsoleWriteError("An error occurred in this job.")
	EndIf
EndFunc   ;==>_TestFakeAPI