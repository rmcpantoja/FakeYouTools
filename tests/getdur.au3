;#include <array.au3>
#include "include\dataset.au3"
;#INCLUDE <FILE.AU3>
$sDuration = _Dataset_get_WavsDuration(default, @ScriptDir &"\transcript.txt", 2)
if @error then
msgbox(16, "Ha ocurrido un error", "Código: " &@error)
Else
MsgBox(0, "éxito", "La duración total del dataset es: " &$sDuration)
EndIf