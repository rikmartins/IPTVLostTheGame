package com.iptvapp.lostthegame

import android.annotation.TargetApi
import android.app.Activity
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.Ikev2VpnProfile
import android.net.NetworkCapabilities
import android.net.VpnManager
import android.net.VpnProfileState
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * IKEv2 nativo do Android 11+ (VpnManager): utilizador e palavra-passe por
 * EAP-MSCHAPv2, sem motor VPN embutido na app. Canal "lostthegame/ikev2".
 *
 * A VPN cobre sempre todo o dispositivo (o sistema não permite escolher
 * apps num perfil de plataforma).
 */
class Ikev2Vpn(private val activity: Activity) {
    private var pendingConnect: MethodChannel.Result? = null

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        val supported = isSupported()
        when (call.method) {
            "isSupported" -> result.success(supported)
            "status" -> result.success(if (supported) status() else "disconnected")
            "connect" ->
                if (supported) connect(call, result)
                else result.error("unsupported", null, null)
            "disconnect" -> {
                if (supported) stop()
                result.success(null)
            }
            "forget" -> {
                if (supported) forget()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Resposta ao pedido de autorização do sistema (ver MainActivity). */
    fun onConsentResult(granted: Boolean) {
        val result = pendingConnect ?: return
        pendingConnect = null
        if (granted) start(result) else result.error("consent_denied", null, null)
    }

    private fun isSupported(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.R &&
            activity.packageManager.hasSystemFeature(PackageManager.FEATURE_IPSEC_TUNNELS)

    @TargetApi(Build.VERSION_CODES.R)
    private fun manager(): VpnManager = activity.getSystemService(VpnManager::class.java)

    @TargetApi(Build.VERSION_CODES.R)
    private fun connect(call: MethodCall, result: MethodChannel.Result) {
        val server = call.argument<String>("server")
        val username = call.argument<String>("username")
        val password = call.argument<String>("password")
        if (server.isNullOrBlank() || username.isNullOrBlank() || password.isNullOrEmpty()) {
            result.error("invalid", "missing fields", null)
            return
        }

        val profile = try {
            Ikev2VpnProfile.Builder(server, username)
                .setAuthUsernamePassword(username, password, null)
                .setBypassable(false)
                .setMetered(false)
                .build()
        } catch (e: IllegalArgumentException) {
            result.error("invalid", e.message, null)
            return
        }

        val consent = try {
            manager().provisionVpnProfile(profile)
        } catch (e: Exception) {
            result.error("error", e.message, null)
            return
        }
        if (consent == null) {
            start(result)
            return
        }
        // Primeira vez: o sistema pergunta se a app pode criar a VPN.
        pendingConnect?.error("cancelled", null, null)
        pendingConnect = result
        activity.startActivityForResult(consent, REQUEST_CONSENT)
    }

    @TargetApi(Build.VERSION_CODES.R)
    private fun start(result: MethodChannel.Result) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                manager().startProvisionedVpnProfileSession()
            } else {
                @Suppress("DEPRECATION")
                manager().startProvisionedVpnProfile()
            }
            result.success(null)
        } catch (e: SecurityException) {
            result.error("consent_denied", e.message, null)
        } catch (e: Exception) {
            result.error("error", e.message, null)
        }
    }

    @TargetApi(Build.VERSION_CODES.R)
    private fun stop() {
        manager().stopProvisionedVpnProfile()
    }

    @TargetApi(Build.VERSION_CODES.R)
    private fun forget() {
        manager().stopProvisionedVpnProfile()
        manager().deleteProvisionedVpnProfile()
    }

    @TargetApi(Build.VERSION_CODES.R)
    private fun status(): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val profileState = manager().provisionedVpnProfileState ?: return "disconnected"
            return when (profileState.state) {
                VpnProfileState.STATE_CONNECTED -> "connected"
                VpnProfileState.STATE_CONNECTING -> "connecting"
                VpnProfileState.STATE_FAILED -> "failed"
                else -> "disconnected"
            }
        }
        // Android 11 e 12 não dizem o estado do perfil: basta haver uma rede
        // VPN (a app só liga um tipo de VPN de cada vez).
        val connectivity = activity.getSystemService(ConnectivityManager::class.java)
        @Suppress("DEPRECATION")
        val vpnUp = connectivity.allNetworks.any { network ->
            connectivity.getNetworkCapabilities(network)
                ?.hasTransport(NetworkCapabilities.TRANSPORT_VPN) == true
        }
        return if (vpnUp) "connected" else "disconnected"
    }

    companion object {
        const val REQUEST_CONSENT = 4711
    }
}
