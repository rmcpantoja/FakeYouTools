#include <array.au3>
#include "include\dataset.au3"
#INCLUDE <FILE.AU3>
_dataset_matchList(@ScriptDir &"\list2.txt", false, null, true)
if @error then
msgbox(16, "Ha ocurrido un error", "Código: " &@error)
Else
MsgBox(0, "éxito", "La lista ha sido arreglada satisfactoriamente.")
EndIf