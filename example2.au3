#include "include\fakeYou.au3"
_Example()
Func _Example()
	;Local $aVoices = _FakeYouGetVoicesList()
	;_ArrayDisplay($aVoices)
	;Local $aVoicesCategories = _FakeYouGetVoicesCategoriesList()
	;_ArrayDisplay($aVoicesCategories)
	Local $sJobToken = _FakeYouGenerateAudio("Hello World", "TM:7wbtjphx8h8v")
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
	Else
		ConsoleWriteError("An error occurred in this job.")
	EndIf
EndFunc   ;==>_TestFakeAPI