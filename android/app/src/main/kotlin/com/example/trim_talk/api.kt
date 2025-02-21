package com.example.trim_talk


import NativePigeonApi
import NativeResult
import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.android.FlutterActivity
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream

// https://medium.com/@kezo495/exploring-flutters-pigeon-package-simplifying-native-communication-f31523fe9bce
// https://docs.flutter.dev/platform-integration/platform-channels#pigeon

class PigeonApiImpl(private val context: Context) : NativePigeonApi {
    private val scope =
        CoroutineScope(Dispatchers.IO) // Use the IO dispatcher for disk and network IO


    // https://developer.android.com/training/basics/intents/result
    // https://stackoverflow.com/questions/76020007/how-to-use-registerforactivityresult-in-flutters-mainactivity
    override fun pickFolder(callback: (Result<String?>) -> Unit) {
        pickFolderCallback = callback

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        // inital uri supported only after android 26
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val initialUri =
                DocumentsContract.buildDocumentUri(
                    "com.android.externalstorage.documents",
                    "primary:Android/media/com.whatsappAndroid/media/com.whatsapp/WhatsApp/Media/WhatsApp Voice Notes"
                ) // THIS WORKS - maybe later use higher dir
            intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, initialUri)
        }
        if (context is Activity) { // this is true since flutter activity extends activity
            context.startActivityForResult(intent, REQUEST_CODE_PICK_FOLDER)
        }
    }

    override fun getPersistedUrisPermissions(): List<String> {
        val persistedUris = context.contentResolver.persistedUriPermissions
        return persistedUris.map { it.uri.toString() }
    }

    override fun readFileBytes(uri: String): ByteArray? {
        val contentResolver: ContentResolver = context.contentResolver

        return contentResolver.openInputStream(Uri.parse(uri))?.use { inputStream ->
            ByteArrayOutputStream().use { outputStream ->
                inputStream.copyTo(outputStream)
                outputStream.toByteArray()
            }
        }
    }

    override fun listAfter(
        folderId: String,
        timeMilis: Long,
        callback: (Result<List<NativeResult>>) -> Unit
    ) {
        scope.launch {
            val res = listAfterRaw(folderId, timeMilis)
            withContext(Dispatchers.Main) {
                callback(Result.success(res))
            }
        }
    }


    private fun incrementWeek(yearWeek: String): String {
        // Extract year and week
        val year = yearWeek.substring(0, 4).toInt()
        var week = yearWeek.substring(4).toInt()

        // Increment the week number
        week += 1

        // Handle week overflow
        if (week > 52) {
            week = 1
        }

        // Rebuild the string with the new week number, padded with zero if necessary
        val weekStr = week.toString().padStart(2, '0')

        return "$year$weekStr"
    }

    private fun getCorrectDocument(folderId: String): DocumentFile? {

        fun buildUri(id: String): Uri {
            return Uri.parse("content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2FWhatsApp%20Voice%20Notes/document/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2FWhatsApp%20Voice%20Notes%2F$id")
        }
        //        notes dir : content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2FWhatsApp%20Voice%20Notes
//
//        subdir content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2FWhatsApp%20Voice%20Notes/document/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2FWhatsApp%20Voice%20Notes%2F202438
//
//        file in subdir : content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2FWhatsApp%20Voice%20Notes/document/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2FWhatsApp%20Voice%20Notes%2F202438%2FPTT-20240915-WA0000.opus

        // first try to get next week (if id is too low somehow)
        val nextWeek = incrementWeek(folderId)

        val nextWeekDir = buildUri(nextWeek)

        try {
            val doc0 = DocumentFile.fromTreeUri(context, nextWeekDir)
            if (doc0 != null && doc0.exists() && doc0.isDirectory) return doc0 // here calling exist is mandatory !! (returns null on older device)
        } catch (e: Exception) {
            println("next week ($nextWeek) doesn't exist yet, fallback to current week ")
            // e.printStackTrace()
        }

        try {
            val thisWeekDir = buildUri(folderId)
            val doc1 = DocumentFile.fromTreeUri(context, thisWeekDir)
            if (doc1 != null && doc1.exists() && doc1.isDirectory) return doc1
        }catch (e: Exception) {
            println("failed to get current week $folderId")
            e.printStackTrace()
        }


        return null
    }

    private fun listAfterRaw(folderId: String, timeMilis: Long): List<NativeResult> {


        val weekDir: DocumentFile = getCorrectDocument(folderId) ?: return emptyList()


        // each file has: path, date, duration
        val res = mutableListOf<NativeResult>()

        val files = weekDir.listFiles()

        // this block takes about 1.5 sec
        for (file in files) {
            val name = file.name
            if (name == null || !name.startsWith("PTT-")) continue

            val date = file.lastModified()
            if (file.isFile && date > timeMilis) {

                val uri = file.uri.toString()

                val duration = getAudioFileDuration(uri)
                if (duration != null) {
                    res.add(
                        NativeResult(
                            path = uri,
                            dateMs = date,
                            durationMs = duration,
                            name = name
                        )
                    )

                }
            }
        }

        // Sort the list by the "date" key in ascending order
        return res.sortedBy { it.dateMs }
    }

    /// this assumes its an audio file
    private fun getAudioFileDuration(uriString: String): Long? {
        val uri: Uri = Uri.parse(uriString)
        val retriever = MediaMetadataRetriever()

        return try {
            retriever.setDataSource(context, uri)
            val durationString =
                retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            return durationString?.toLong()

        } catch (e: Exception) {
            e.printStackTrace()
            null // Error occurred
        } finally {
            retriever.release()
        }
    }


}