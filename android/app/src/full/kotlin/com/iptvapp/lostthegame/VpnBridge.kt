package com.iptvapp.lostthegame

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Canal da VPN IKEv2 da versão completa (variantes "mobile" e "tv"). A
 * versão da Play Store usa o VpnBridge vazio de src/play.
 */
class VpnBridge(private val activity: Activity) {
    private var ikev2: Ikev2Vpn? = null

    fun attach(engine: FlutterEngine) {
        val vpn = Ikev2Vpn(activity)
        ikev2 = vpn
        MethodChannel(engine.dartExecutor.binaryMessenger, "lostthegame/ikev2")
            .setMethodCallHandler { call, result -> vpn.handle(call, result) }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int) {
        if (requestCode == Ikev2Vpn.REQUEST_CONSENT) {
            ikev2?.onConsentResult(resultCode == Activity.RESULT_OK)
        }
    }
}
