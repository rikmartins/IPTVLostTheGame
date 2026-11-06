package com.iptvapp.lostthegame

import android.app.UiModeManager
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // VPN IKEv2: real na versão completa (src/full), vazio na da Play Store
    // (src/play).
    private val vpn = VpnBridge(this)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        vpn.attach(flutterEngine)
        // A versão da Play Store é um só pacote para telemóveis e TVs: a app
        // pergunta aqui, antes do runApp, se está numa TV.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sopro/device")
            .setMethodCallHandler { call, result ->
                if (call.method == "isTelevision") {
                    result.success(isTelevision())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun isTelevision(): Boolean {
        val uiMode = getSystemService(UiModeManager::class.java)
        return uiMode?.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION ||
            packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        vpn.onActivityResult(requestCode, resultCode)
    }
}
