package com.quilt.quilt

import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.quilt/communication"
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        android.util.Log.d("TAG", "onCreate: ")
    }
    override fun onDestroy() {
        super.onDestroy()
        kotlin.io.print("onDestroy")
        android.util.Log.d("TAG", "onDestroy: ")
      // flutterEngine?.dartExecutor?.binaryMessenger?.let { MethodChannel(it, CHANNEL).invokeMethod("onAppDestroy", null) }

    }

}
