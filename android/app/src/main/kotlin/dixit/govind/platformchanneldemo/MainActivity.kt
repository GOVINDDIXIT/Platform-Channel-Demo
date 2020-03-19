package dixit.govind.platformchanneldemo

import android.Manifest
import android.annotation.TargetApi
import android.content.*
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result


class MainActivity : FlutterActivity() {

    companion object {
        const val METHOD_CHANNEL: String = "dixit.govind.platformchanneldemo/methodChannel"
        const val ORIENTATION_EVENT_CHANNEL: String = "dixit.govind.platformchanneldemo/orientationEventChannel"
        const val CHARGING_EVENT_CHANNEL: String = "dixit.govind.platformchanneldemo/chargingEventChannel"
        const val CHARGING_CHANNEL = "beingRD.flutter.io/charging";

        const val CALL_REQUEST_CODE = 101
    }

    private lateinit var mSensorManager: SensorManager
    private lateinit var mAccelerometer: Sensor

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mSensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        mAccelerometer = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)

        MethodChannel(flutterView, METHOD_CHANNEL).setMethodCallHandler { methodCall, result ->
            when {
                methodCall.method == "getOSVersion" -> getOSVersion(result)
                methodCall.method == "isCameraAvailable" -> isCameraAvailable(result)
                methodCall.method == "callNumber" -> callNumber(methodCall.argument("number"))
                methodCall.method == "getBatteryLevel" -> getBatteryLevel(result)
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterView, CHARGING_CHANNEL).setStreamHandler(
                object : StreamHandler {
                    private var chargingStateChangeReceiver: BroadcastReceiver? = null
                    override fun onListen(arguments: Any, events: EventSink) {
                        chargingStateChangeReceiver = createChargingStateChangeReceiver(events)
                        registerReceiver(
                                chargingStateChangeReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                    }

                    override fun onCancel(arguments: Any) {
                        unregisterReceiver(chargingStateChangeReceiver)
                        chargingStateChangeReceiver = null
                    }
                }
        )

//        EventChannel(flutterView, CHARGING_EVENT_CHANNEL).setStreamHandler(
//                object : StreamHandler {
//                    private var chargingStateChangeReceiver: BroadcastReceiver? = null
//                    override fun onListen(arguments: Any, events: EventSink) {
//                        chargingStateChangeReceiver = createChargingStateChangeReceiver(events)
//                        registerReceiver(
//                                chargingStateChangeReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
//                    }
//
//                    override fun onCancel(arguments: Any) {
//                        unregisterReceiver(chargingStateChangeReceiver)
//                        chargingStateChangeReceiver = null
//                    }
//                }
//        )
//
//        EventChannel(flutterView, ORIENTATION_EVENT_CHANNEL).setStreamHandler(object : StreamHandler {
//            override fun onListen(
//                    arguments: Any?,
//                    events: EventSink?
//            ) {
//                emitDeviceOrientation(events)
//            }
//
//            override fun onCancel(arguments: Any?) {
//
//            }
//        })
    }

    private fun getOSVersion(result: Result) {
        val version = VERSION.RELEASE
        if (!version.isNullOrEmpty()) {
            result.success(version)
        } else {
            result.error("UNAVAILABLE", "Version is not available.", null)
        }
    }

    private fun isCameraAvailable(result: Result) {
        if (packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA)) {
            result.success(mapOf("status" to "Camera is available"))
        } else {
            result.error("UNAVAILABLE", "No camera hardware", null)
        }
    }

    private fun getBatteryLevel(result: Result) {
        val batteryLevel = if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        if (batteryLevel != -1) {
            result.success(batteryLevel)
        } else {
            result.error("UNAVAILABLE", "Battery level not available.", null)
        }
    }

    private fun emitDeviceOrientation(events: EventSink?) {
        mSensorManager.registerListener(object : SensorEventListener {
            override fun onSensorChanged(sensorEvent: SensorEvent?) {
                if (sensorEvent?.sensor?.type == Sensor.TYPE_ACCELEROMETER) {
                    if (Math.abs(sensorEvent.values[1]) > Math.abs(sensorEvent.values[0])) {
                        //Mainly portrait
                        if (sensorEvent.values[1] > 0.75) {
                            events?.success("Portrait")
                        } else if (sensorEvent.values[1] < -0.75) {
                            events?.success("Portrait Upside down")
                        }
                    } else {
                        //Mainly landscape
                        if (sensorEvent.values[0] > 0.75) {
                            events?.success("Landscape Right")
                        } else if (sensorEvent.values[0] < -0.75) {
                            events?.success("Landscape Left")
                        }
                    }
                }
            }

            override fun onAccuracyChanged(
                    sensor: Sensor?,
                    accuracy: Int
            ) {

            }
        }, mAccelerometer, SensorManager.SENSOR_DELAY_NORMAL)
    }

    private fun createChargingStateChangeReceiver(events: EventSink): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)

                if (status == BatteryManager.BATTERY_STATUS_UNKNOWN) {
                    events.error("UNAVAILABLE", "Charging status unavailable", null)
                } else {
                    val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
                    events.success(if (isCharging) "charging" else "discharging")
                }
            }
        }
    }

    private fun callNumber(phoneNumber: String?) {
        if (VERSION.SDK_INT < VERSION_CODES.M) {
            makeCall(phoneNumber)
        } else {
            if (checkSelfPermission(Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED) {
                makeRequest()
            } else {
                makeCall(phoneNumber)
            }
        }
    }

    private fun makeCall(phoneNumber: String?) {
        val callIntent = Intent(Intent.ACTION_CALL)
        callIntent.data = Uri.parse("tel:$phoneNumber")
        startActivity(callIntent)
    }

    @TargetApi(VERSION_CODES.M)
    private fun setupPermissions() {
        val permission = checkSelfPermission(Manifest.permission.CALL_PHONE)
        if (permission != PackageManager.PERMISSION_GRANTED) {
            makeRequest()
        }
    }

    @TargetApi(VERSION_CODES.M)
    private fun makeRequest() {
        requestPermissions(
                arrayOf(Manifest.permission.CALL_PHONE),
                CALL_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<String>,
            grantResults: IntArray
    ) {
        when (requestCode) {
            CALL_REQUEST_CODE -> {

                if (grantResults.isEmpty() || grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                    //Permission denied
                } else {
                    //Permission granted
                }
            }
        }
    }
}
