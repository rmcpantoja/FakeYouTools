# FakeYou Dataset toolkit changelog

This is the dataset management UDF changelog for fakeYou.

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
	* added a fourth parameter, $bShowMSG. This means that messages or progress will be displayed in the console while the work is being done.
	* FileFind*file call removed
* Updated _AhoTtsDataset2Tacotron
	* Added a third parameter, $bShowMSG. This means that any messages or progress will be displayed in the console while the work is being done.
* updated _Dataset_checkStatus
	* added more rating values to get the status of the dataset.


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