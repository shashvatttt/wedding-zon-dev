package com.example.weddingzon

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.weddingzon/notification"
    private var notificationData: Map<String, String>? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleNotificationIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleNotificationIntent(intent)
    }

    private fun handleNotificationIntent(intent: Intent?) {
        println("[NOTIFICATION] Android: handleNotificationIntent called")
        println("[NOTIFICATION] Android: Intent: $intent")
        println("[NOTIFICATION] Android: Intent action: ${intent?.action}")
        println("[NOTIFICATION] Android: Intent data: ${intent?.data}")
        println("[NOTIFICATION] Android: Intent extras: ${intent?.extras}")
        println("[NOTIFICATION] Android: Intent categories: ${intent?.categories}")
        
        // Check if this is a notification intent
        val isFromNotification = intent?.action == "android.intent.action.MAIN" && 
                                intent.hasCategory("android.intent.category.LAUNCHER")
        println("[NOTIFICATION] Android: Is from notification: $isFromNotification")
        
        intent?.extras?.let { bundle ->
            val map = mutableMapOf<String, String>()
            
            // Log all bundle keys for debugging
            println("[NOTIFICATION] Android: Bundle keys: ${bundle.keySet()}")
            
            for (key in bundle.keySet()) {
                val value = bundle.get(key)
                println("[NOTIFICATION] Android: Key: $key, Value: $value, Type: ${value?.javaClass?.simpleName}")
                
                // Convert various types to string
                when (value) {
                    is String -> map[key] = value
                    is Int -> map[key] = value.toString()
                    is Long -> map[key] = value.toString()
                    is Boolean -> map[key] = value.toString()
                    is Double -> map[key] = value.toString()
                    is Float -> map[key] = value.toString()
                    else -> value?.toString()?.let { map[key] = it }
                }
            }
            
            // Check for Firebase notification data keys - both FCM and local notification formats
            val firebaseKeys = listOf(
                "gcm.notification.title", "gcm.notification.body", 
                "type", "senderName", "google.message_id",
                "google.c.a.c_id", "google.c.a.c_l", "google.c.a.e", "google.c.a.ts", "google.c.a.udt",
                "google.delivered_priority", "google.sent_time", "google.ttl", "from"
            )
            val hasFirebaseData = firebaseKeys.any { bundle.containsKey(it) }
            println("[NOTIFICATION] Android: Has Firebase data: $hasFirebaseData")
            
            // Special handling for Firebase data format
            if (hasFirebaseData || map.containsKey("type")) {
                // Extract notification data from Firebase format
                val notificationMap = mutableMapOf<String, String>()
                
                // Direct data fields
                map["type"]?.let { notificationMap["type"] = it }
                map["senderName"]?.let { notificationMap["senderName"] = it }
                map["username"]?.let { notificationMap["username"] = it }
                map["userId"]?.let { notificationMap["userId"] = it }
                
                // Firebase notification fields
                map["gcm.notification.title"]?.let { notificationMap["title"] = it }
                map["gcm.notification.body"]?.let { notificationMap["body"] = it }
                
                // If we have any notification data, store it
                if (notificationMap.isNotEmpty()) {
                    notificationData = notificationMap
                    println("[NOTIFICATION] Android: Stored Firebase notification data: $notificationMap")
                } else if (map.isNotEmpty()) {
                    // Fallback: store all data if we can't parse Firebase format
                    notificationData = map
                    println("[NOTIFICATION] Android: Stored raw notification data: $map")
                }
            } else if (map.isNotEmpty()) {
                notificationData = map
                println("[NOTIFICATION] Android: Stored notification data: $map")
            } else {
                println("[NOTIFICATION] Android: No valid notification data found")
            }
        } ?: run {
            println("[NOTIFICATION] Android: No extras in intent")
        }
        
        // Also check for notification data in intent data URI
        intent?.data?.let { uri ->
            println("[NOTIFICATION] Android: Intent data URI: $uri")
            uri.queryParameterNames?.forEach { param ->
                val value = uri.getQueryParameter(param)
                println("[NOTIFICATION] Android: URI param: $param = $value")
            }
        }
        
        // Additional check: look for Firebase RemoteMessage data
        // This handles the case where Firebase passes data differently
        if (notificationData == null || notificationData!!.isEmpty()) {
            println("[NOTIFICATION] Android: Checking for alternative Firebase data sources...")
            
            // Check if there are any string extras that might contain JSON
            intent?.extras?.let { bundle ->
                for (key in bundle.keySet()) {
                    val value = bundle.getString(key)
                    if (value != null && (value.startsWith("{") || key.contains("firebase") || key.contains("fcm"))) {
                        println("[NOTIFICATION] Android: Found potential JSON data in key '$key': $value")
                        try {
                            // Try to parse as JSON if it looks like JSON
                            if (value.startsWith("{")) {
                                // For now, just log it - we could parse JSON here if needed
                                println("[NOTIFICATION] Android: JSON-like data found but not parsed")
                            }
                        } catch (e: Exception) {
                            println("[NOTIFICATION] Android: Error parsing JSON: $e")
                        }
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getNotificationData" -> {
                    println("[NOTIFICATION] Android: getNotificationData called, returning: $notificationData")
                    result.success(notificationData)
                    // Clear the data after returning it
                    notificationData = null
                }
                "simulateNotification" -> {
                    // For testing purposes - simulate notification data
                    val type = call.argument<String>("type") ?: "connection_request"
                    val senderName = call.argument<String>("senderName") ?: "Test User"
                    
                    val testData = mapOf(
                        "type" to type,
                        "senderName" to senderName,
                        "debug" to "true"
                    )
                    
                    notificationData = testData
                    println("[NOTIFICATION] Android: Simulated notification data: $testData")
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
