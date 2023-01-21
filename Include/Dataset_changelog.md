# FakeYou Dataset toolkit changelog

This is the dataset management UDF changelog for [fakeYou](https://fakeyou.com/).

## 0.6.0

Many changes and improvements have been made in this version:

* Added _dataset_open_transcription
	* Now, this is the function that will open the transcripts (lists) compatible with Tacotron 2 instead of FileRead or similar.
		* This is done to reduce code.
		* However, all functions that require opening a list must adapt to this new function.
	* The lists opened by the user with this function will be presented in a 2d array. It is what this function returns if there are no problems.
* added _Dataset_txt2Lab:
	* This function converts a transcript (tacotron 2) to lab files (label)
		* In this case, the path of the transcript should be assigned, but also the path of the converted lab files.
	* Warning: in some cases, the .lab files are required in the path where the wav files are, for this you must assign the path where the wavs are.
	* Warning 2: lab files will be created depending on the number of audios. Each .lab file has a single audio transcript.
* updated _changeDatasetOrder
	* Removed some unused variables
	* The geting transcripts has been changed to _dataset_open_transcription
* updated _AhoTtsDataset2Tacotron
	* Now it is detected if there are no audio files, to only convert the transcript.
	* FileFind*file call removed
	* Added @error to 4 when converting audios and transcripts do not match the number of items.
* updated _DatasetFixList:
	* Added parameter, $bConsole. This means that any messages or progress will be displayed in the console while the work is being done.
	* Changed the "es" value of $sLang to replace it with "old_es" and change "es" to the new Spanish symbol support.
		* Unlike the old one, the "ñ" are no longer changed to "ni"; however, "()" symbols are removed, as they are now supported.
	* Removed some unused variables
	* The geting transcripts has been changed to _dataset_open_transcription
	* Changed the way you save the converted file. Now you do it from _ArrayToString, remember that the transcript is now working on a 2d array.
* Updated _Dataset_get_WavsDuration:
	* Added new parameters
		* $sSecondRange: this is the range of seconds (minimum and maximum) that will be allowed. If an audio reaches the minimum or maximum, it warns you.
		* $bResults: a boolean to indicate if the function returns an array with the results, or if it is false, it only returns a string with the total time.
		* $bConsole: This means that messages or progress will be displayed in the console while the work is being done.
	* FileFind*file call removed
* updated _Dataset_CreateTranscription:
	* Added parameter, $bConsole. This means that any messages or progress will be displayed in the console while the work is being done.
* updated _dataset_matchList:
	* The geting transcripts has been changed to _dataset_open_transcription
	* Added support for tacotron 2 multispeaker transcripts
		* Therefore, the $bSpeaker parameter were added, this parameter is used to indicate that the list should support the speaker ID parameter.
		* Also added $nSpeaker (default 0) this is the speaker id used for transcrypts.

### internal
* Added new support for displaying progress bars in the console
	* This fixes a lot of bugs with functions that required $bConsole, progress was displayed with too many decimals. We use round() instead.
	* Functions that require $bConsole should use _PrintProgress
* Updated __Dataset_GetAudioDuration:
	* Added parameters:
		* $iMinSeconds: This will also identify the minimum duration that is allowed on each audio. If an audio is less than the minimum duration, it warns to the user.
		* $bConsole: This will display warnings on the console, such as duration reached

## 0.5.0

* Added _Dataset_Process_audios
	* This function will help a lot with the conversion, normalization and elimination of silences in the audios.
		* converts to 22khz 16 bit mono
		* Removes silence from the start and end of the audio.
	* Because of this new feature, libraries like [ffmpeg](https://ffmpeg.org) and [SoX](http://sox.sourceforge.net/) have been added
	* The code has been migrated. Credits to [Justin John](https://github.com/justinjohn0306/) who made the original version of this audio process shell script.
* added _dataset_matchList
	* This is to make other types of datasets compatible with the classic one.
* changed and updated _DatasetWavsDuration
	* renamed to _Dataset_get_WavsDuration.
	* Added two more parameters, $sListPath and $iMode. There are currently two modes, the first one is based on the wav files and the second one is getting the duration of the transcript.
* updated _DatasetFixList
	* fixed many bugs when saving the fixed list.
	* added more symbols to replace like ()
	* Added the ability to search for end punctuation. If it doesn't exist, it will add it.
* updated _changeDatasetOrder
	* added a fourth parameter, $bConsole. This means that messages or progress will be displayed in the console while the work is being done.
	* FileFind*file call removed
* Updated _AhoTtsDataset2Tacotron
	* Added $iMode parameter. There are two types of transcripts in AhoTts.
	* Added parameter, $bConsole. This means that any messages or progress will be displayed in the console while the work is being done.
* updated _Dataset_checkStatus
	* added more rating values to get the status of the dataset.
* updated _Dataset_CleanFiles
	* Added parameter, $bConsole. This means that any messages or progress will be displayed in the console while the work is being done.
	* Added two more modes:
		* 3 = unity (*.meta)
		* 4 = prosodylab files (*.lab files).

## 0.4.0

* added few examples for UDF helpfile.
* added _Dataset_checkStatus
	* This helps verify the state of audio material in a dataset based on time.
* added _Dataset_CleanFiles
	* This clean audio files that are not needed so as not to duplicate wavs to a dataset.
* added _Dataset_Set_listWavsNames
* added _Dataset_wav2npy and _Dataset_npy2wav
* added _ArraySortEx by @pixelsearch.
	* This helps a lot when wanting to do different types of sorts, as is the case with dataset wavs.
* fixed and improved _AhoTtsDataset2Tacotron
* _changeDatasetOrder was fixed too
	* speed improvements.
	* Fixed a very important bug with wavs file sorting.
* set error for _DatasetFixList

## 0.3.0

* UDF headers updated
* Added __SortList()
	* Thanks to this, _Dataset_CreateTranscription can now sort wavs file names correctly.

## 0.2.1

* Fixed important bug in _Dataset_CreateTranscription

## 0.2

* added _AhoTtsDataset2Tacotron
	* This converts an AhoTts or AhoMyTts Dataset to a tacotron compatible one.
* added _DatasetFixList
	* This will help remove special symbols that are not allowed in transcripts.
* added _DatasetWavsDuration and its internal function __Dataset_GetAudioDuration
* added _Dataset_CreateTranscription

## 0.1

Initial version