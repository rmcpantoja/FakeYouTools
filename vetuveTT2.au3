#include "include\bassfunctions.au3"
#include "include\fakeyou2.au3"
#include <GuiListBox.au3>
local $hUrl
sleep(1000)
Example()
Func example()
_Audio_init_start()
local $iOldCount = "", $iCount = ""
local $sText = ""
local $hWND = WinActivate("Chat en vivo")
$idList = ControlGetHandle($hWnd, "", "ListBox1")
while 1
$iOldCount = $iCount
$iCount = _GUICtrlListBox_GetCount($idList)
If $iCount <> $iOldCount Then
$sText = _GUICtrlListBox_GetText($idList, $iCount -1)
;magia:
$aText = StringSplit($sText, ": ", $STR_ENTIRESPLIT)
$sURL = _FakeYou_getDirectAudio($aText[2], "TM:xr77xbs565r0")
$hUrl = _Set_url($sURL)
		If @error then
			MsgBox(16, "Error", "Unable to load URL.")
			_Audio_stop($hUrl)
			_Audio_init_stop($hUrl)
		Else
			_Audio_play($hUrl)
		EndIF
else
ContinueLoop
EndIf
sleep(30)
WEnd
EndFunc