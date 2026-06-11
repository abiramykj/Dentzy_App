package com.example.dentzy

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "dentzy/notification_diagnostics"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"isIgnoringBatteryOptimizations" -> {
						val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
						result.success(
							if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && powerManager != null) {
								powerManager.isIgnoringBatteryOptimizations(packageName)
							} else {
								true
							}
						)
					}

					"openBatteryOptimizationSettings" -> {
						try {
							val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
								addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
							}
							startActivity(intent)
							result.success(true)
						} catch (error: Exception) {
							result.error("battery_settings_error", error.message, null)
						}
					}

					"getAndroidManufacturer" -> result.success(Build.MANUFACTURER)

					else -> result.notImplemented()
				}
			}
	}
}
