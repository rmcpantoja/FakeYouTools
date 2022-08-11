#include "fakeYou.au3"

_example()
Func _example()
	Local $aVoices = _FakeYouGetVoicesList(), $sModel
	If @error Then
		Switch @error
			Case 1
				MsgBox(16, "Error", "You must save the cache to use it.")
			Case 2
				MsgBox(16, "error", "Couldn't open cache file")
			Case 3
				MsgBox(16, "Error", "Failed to write cache file")
			Case 4
				MsgBox(16, "Error", "Failed to get JSON code or operation did not complete successfully")
			Case 5
				MsgBox(16, "Error", "Failed to get list of voices because the object that was created is not an array")
		EndSwitch
		Exit
	EndIf
	$sModel = _FakeYouGetVoiceModelToken($aVoices, $aVoices[0][6])
	If @error Then
		Switch @error
			Case 1
				MsgBox(16, "Error", "This list is invalid")
			Case 2
				MsgBox(16, "Error", "The token for this voice could not be found. Does not exist")
		EndSwitch
		Exit
	EndIf
	MsgBox(0, "_FakeYouGetVoiceModelToken", $sModel)
EndFunc   ;==>_example
