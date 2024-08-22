package expo.modules.scanny

import android.R
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.Promise
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import expo.modules.kotlin.views.ExpoView
import expo.modules.scany.ui.theme.ScanyexampleTheme


class ScannyModule : Module() {

  override fun definition() = ModuleDefinition {
    Name("Scanny")

    AsyncFunction("openCamera") { promise: Promise ->
      val current: Activity = appContext.currentActivity!!
      current.runOnUiThread {
        current.addContentView(
          ComposeView(current).apply {
            setContent {
              ScanyexampleTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                  Greeting(
                    name = "Android",
                    modifier = Modifier.padding(innerPadding)
                  )
                }
              }
            }
          },
          LayoutParams(
            LayoutParams.MATCH_PARENT,
            LayoutParams.MATCH_PARENT
          )
        )
        promise.resolve("resolved")
      }
    }
  }
}
