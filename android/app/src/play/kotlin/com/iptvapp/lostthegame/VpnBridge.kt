package com.iptvapp.lostthegame

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Versão da Play Store: sem VPN (a Google só a aceita em apps cuja função
 * principal é ser uma VPN). Nenhum canal fica registado e a app não mostra
 * a secção da VPN.
 */
@Suppress("UNUSED_PARAMETER")
class VpnBridge(activity: Activity) {
    fun attach(engine: FlutterEngine) {}

    fun onActivityResult(requestCode: Int, resultCode: Int) {}
}
