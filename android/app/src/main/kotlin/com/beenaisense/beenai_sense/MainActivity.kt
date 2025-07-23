package com.beenaisense.beenai_sense

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // For Android 12 and higher, disable the splash screen
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // For API level 31 (Android 12) and above
            splashScreen.setOnExitAnimationListener { splashScreenView ->
                splashScreenView.remove()
            }
        }
        super.onCreate(savedInstanceState)
    }
}
