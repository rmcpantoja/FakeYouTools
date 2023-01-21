#include <array.au3>
#include "include\fakeYou.au3"
_Example()
Func _example()
	Local $aVoices = _FakeYouGetVoicesList()
	;For $I = 0 to UBound($aVoices) -1
		;MsgBox(0, "Voice", $aVoices[$I][7])
	;Next
	_ArrayDisplay($aVoices)
	;$aLanguajes = _FakeYouGetLanguajes($aVoices)
	;if @error then MsgBox(16, "Error", @error)
	;_ArrayDisplay($aLanguajes)
	$aVoicesByLang = _FakeYouGetVoicesFromLanguage($aVoices, "es-mx")
	if @error then MsgBox(16, "Error", @error)
	_ArrayDisplay($aVoicesByLang)
	$sModel = _FakeYouGetVoiceModelToken($aVoices, $aVoicesByLang[0])
	if @error then MsgBox(16, "Error", @error)
	MsgBox(0, "Model", $sModel)
	;Local $aVoicesCategories = _FakeYouGetVoicesCategoriesList()
	;_ArrayDisplay($aVoicesCategories)
EndFunc