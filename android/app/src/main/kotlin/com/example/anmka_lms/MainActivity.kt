package com.anmka.anmkalms

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.webkit.WebView

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable WebView debugging for development
        WebView.setWebContentsDebuggingEnabled(true)
    }
}
