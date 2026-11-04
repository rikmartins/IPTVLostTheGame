package com.iptvapp.lostthegame

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var ikev2: Ikev2Vpn? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val vpn = Ikev2Vpn(this)
        ikev2 = vpn
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lostthegame/ikev2")
            .setMethodCallHandler { call, result -> vpn.handle(call, result) }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == Ikev2Vpn.REQUEST_CONSENT) {
            ikev2?.onConsentResult(resultCode == RESULT_OK)
        }
    }
}
