package com.example.trim_talk

import NativePigeonApi
import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine


var pickFolderCallback: ((Result<String?>) -> Unit)? = null
 const val REQUEST_CODE_PICK_FOLDER = 1
 const val SHARED_PREF_NAME = "defaultUriStorage"
 const val SHARED_PREF_KEY = "tree_uri"


class MainActivity : FlutterActivity() {

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    NativePigeonApi.setUp(flutterEngine.dartExecutor.binaryMessenger, PigeonApiImpl(this))
  }

  // Handle the result when the user picks a directory
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)

    if (requestCode == REQUEST_CODE_PICK_FOLDER && resultCode == Activity.RESULT_OK) {
      data?.data?.let { uri ->
        // Persist access permissions
        contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
        )
        // send uri to dart side
        pickFolderCallback?.let { callback ->
          callback(Result.success(uri.toString()))
        }

        // Save the Uri for future use
        val prefs = getSharedPreferences(SHARED_PREF_NAME, MODE_PRIVATE)
        with(prefs.edit()) {
          putString(SHARED_PREF_KEY, uri.toString())
          apply()
        }
      }
    }
  }



}
