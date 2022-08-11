#include "include\dataset.au3"
_DatasetFixList(@scriptDir &"\list.txt", "es")
if @error then
msgbox(16, "error", "Código: " &@error)
Else
msgbox(0, "éxito", "lista corregida")
EndIf