#include "include\fakeYou2.au3"
_Example()
Func _example()
	Local $aVoices = _FakeYouGetVoicesList()
	For $I = 0 to UBound($aVoices) -1
		MsgBox(0, "Voice", $aVoices[$I][6])
Next
	;_ArrayDisplay($aVoices)
	;Local $aVoicesCategories = _FakeYouGetVoicesCategoriesList()
	;_ArrayDisplay($aVoicesCategories)
EndFunc