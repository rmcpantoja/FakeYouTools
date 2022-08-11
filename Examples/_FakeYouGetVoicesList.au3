#include <array.au3>
#include "fakeYou.au3"

_example()
Func _example()
	Local $aVoices = _FakeYouGetVoicesList() ; No cache.
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
	_ArrayDisplay($aVoices)
EndFunc   ;==>_example
