#include <array.au3>
#include "fakeYou.au3"

_example()
Func _example()
	;Local $aVoicesCategories = _FakeYouGetVoicesCategoriesList()
	If @error Then
		Switch @error
			Case 1
				MsgBox(16, "Error", "The JSON code was not obtained or the request was not successful.")
			Case 2
				MsgBox(16, "Error", "Failed to get list of categories because the object that was created is not an array")
		EndSwitch
		Exit
	EndIf
	;_ArrayDisplay($aVoicesCategories)
EndFunc   ;==>_example
