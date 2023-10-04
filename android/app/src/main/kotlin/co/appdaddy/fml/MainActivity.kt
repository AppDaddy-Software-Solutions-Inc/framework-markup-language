package co.appdaddy.fml

import android.content.*
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant;
import androidx.annotation.NonNull;
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*
import android.util.*
import java.util.ArrayList
import android.util.Log


//  This sample implementation is heavily based on the flutter demo at
//  https://github.com/flutter/flutter/blob/master/examples/platform_channel/android/app/src/main/java/com/example/platformchannel/MainActivity.java

class MainActivity: FlutterActivity() {
    private val COMMAND_CHANNEL = "co.appdaddy.fml/command"
    private val SCAN_CHANNEL = "co.appdaddy.fml/scan"
    private val PROFILE_INTENT_ACTION = "co.appdaddy.fml.SCAN"
    private val PROFILE_INTENT_BROADCAST = "2"

    private val dwInterface = DWInterface()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        EventChannel(flutterEngine.dartExecutor, SCAN_CHANNEL).setStreamHandler(
                object : StreamHandler {
                    private var dataWedgeBroadcastReceiver: BroadcastReceiver? = null
                    override fun onListen(arguments: Any?, events: EventSink?) {
                        dataWedgeBroadcastReceiver = createDataWedgeBroadcastReceiver(events)
                        val intentFilter = IntentFilter()
                        intentFilter.addAction(PROFILE_INTENT_ACTION)
                        intentFilter.addAction(DWInterface.DATAWEDGE_RETURN_ACTION)
                        intentFilter.addCategory(DWInterface.DATAWEDGE_RETURN_CATEGORY)
                        registerReceiver(
                                dataWedgeBroadcastReceiver, intentFilter)
                    }

                    override fun onCancel(arguments: Any?) {
                        unregisterReceiver(dataWedgeBroadcastReceiver)
                        dataWedgeBroadcastReceiver = null
                    }
                }
        )

        MethodChannel(flutterEngine.dartExecutor.getBinaryMessenger(), COMMAND_CHANNEL)
            .setMethodCallHandler { call, result ->
            if (call.method == "ZEBRA")
            {
                Log.d("FML","TEST");
                val arguments = JSONObject(call.arguments.toString())
                val command:   String = arguments.get("command") as String
                val parameter: String = arguments.get("parameter") as String

                if (command == "com.symbol.datawedge.api.CREATE_PROFILE")
                    createBCDataWedgeProfile(parameter)
                else dwInterface.sendCommandString(applicationContext, command, parameter)
            } else if (call.method == "ZEBRARF")
            {
                val arguments = JSONObject(call.arguments.toString())
                val command:   String = arguments.get("command") as String
                val parameter: String = arguments.get("parameter") as String

                if (command == "com.symbol.datawedge.api.CREATE_PROFILE")
                    createRFDataWedgeProfile(parameter)
                else dwInterface.sendCommandString(applicationContext, command, parameter)
            }
            else result.notImplemented()
        }
    }

    private fun createDataWedgeBroadcastReceiver(events: EventSink?): BroadcastReceiver?
    {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action.equals(PROFILE_INTENT_ACTION))
                {
                    //  A barcode has been scanned
                    var source  = intent.getStringExtra(DWInterface.DATAWEDGE_SCAN_EXTRA_SOURCE).toString()
                    var barcode = intent.getStringExtra(DWInterface.DATAWEDGE_SCAN_EXTRA_DATA_STRING).toString()
                    var format  = intent.getStringExtra(DWInterface.DATAWEDGE_SCAN_EXTRA_LABEL_TYPE).toString()

                    var date    = Calendar.getInstance().getTime()
                    var df      = SimpleDateFormat("dd/MM/yyyy HH:mm:ss")
                    var dateTimeString = df.format(date)

                    var currentScan = Scan(source, barcode, format, dateTimeString);
                    var data = currentScan.toJson();

                    // send the result
                    events?.success(data)
                }
            }
        }
    }

    private fun createBCDataWedgeProfile(profileName: String)
    {
        //  Create and configure the DataWedge profile associated with this application
        //  For readability's sake, I have not defined each of the keys in the DWInterface file
        dwInterface.sendCommandString(this, DWInterface.DATAWEDGE_SEND_CREATE_PROFILE, profileName)

        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", profileName)
        profileConfig.putString("PROFILE_ENABLED", "true") //  These are all strings
        profileConfig.putString("CONFIG_MODE", "UPDATE")

        val barcodeConfig = Bundle()
        barcodeConfig.putString("PLUGIN_NAME", "BARCODE")
        barcodeConfig.putString("RESET_CONFIG", "true") //  This is the default but never hurts to specify

        val barcodeProps = Bundle()
        barcodeConfig.putBundle("PARAM_LIST", barcodeProps)
        profileConfig.putBundle("PLUGIN_CONFIG", barcodeConfig)

        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", packageName)      //  Associate the profile with this app
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profileConfig.putParcelableArray("APP_LIST", arrayOf(appConfig))
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)

        //  You can only configure one plugin at a time in some versions of DW, now do the intent output
        profileConfig.remove("PLUGIN_CONFIG")

        val intentConfig = Bundle()
        intentConfig.putString("PLUGIN_NAME", "INTENT")
        intentConfig.putString("RESET_CONFIG", "true")

        val intentProps = Bundle()
        intentProps.putString("intent_output_enabled", "true")
        intentProps.putString("intent_action", PROFILE_INTENT_ACTION)
        intentProps.putString("intent_delivery", PROFILE_INTENT_BROADCAST)  //  "2"
        intentConfig.putBundle("PARAM_LIST", intentProps)
        profileConfig.putBundle("PLUGIN_CONFIG", intentConfig)
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)

        //  You can only configure one plugin at a time in some versions of DW, now do the intent output
        profileConfig.remove("PLUGIN_CONFIG")

        val keystrokeConfig = Bundle()
        keystrokeConfig.putString("PLUGIN_NAME", "KEYSTROKE")
        keystrokeConfig.putString("RESET_CONFIG", "true")

        val keystrokeProps = Bundle()
        keystrokeProps.putString("keystroke_output_enabled", "false")
        keystrokeConfig.putBundle("PARAM_LIST", keystrokeProps)
        profileConfig.putBundle("PLUGIN_CONFIG", keystrokeConfig)
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)
    }

    private fun createRFDataWedgeProfile(profileName: String)
    {
        //  Create and configure the DataWedge profile associated with this application
        //  For readability's sake, I have not defined each of the keys in the DWInterface file
        dwInterface.sendCommandString(this, DWInterface.DATAWEDGE_SEND_CREATE_PROFILE, profileName)

        val profileConfig = Bundle()
        profileConfig.putString("PROFILE_NAME", profileName)
        profileConfig.putString("PROFILE_ENABLED", "true") //  These are all strings
        profileConfig.putString("CONFIG_MODE", "UPDATE")
        profileConfig.putString("RESET_CONFIG", "true")

        val rfidConfig = Bundle()
        rfidConfig.putString("PLUGIN_NAME", "RFID")
        rfidConfig.putString("RESET_CONFIG", "true") //  This is the default but never hurts to specify

        val rfidProps = Bundle()
        rfidProps.putString("rfid_input_enabled", "true")
        rfidProps.putString("rfid_beeper_enable", "true")
        rfidProps.putString("rfid_led_enable", "true")
        rfidProps.putString("rfid_antenna_transmit_power", "30")
        rfidProps.putString("rfid_memory_bank", "0")
        rfidProps.putString("rfid_session", "1")
        rfidProps.putString("rfid_trigger_mode", "0")
        rfidProps.putString("rfid_filter_duplicate_tags", "true")
        rfidProps.putString("rfid_hardware_trigger_enabled", "true")
        rfidProps.putString("rfid_tag_read_duration", "1000")
        rfidProps.putString("rfid_link_profile", "0")

        // Pre-filter
        rfidProps.putString("rfid_pre_filter_enable", "false")
        //rfidProps.putString("rfid_pre_filter_tag_pattern", "3EC")
        //rfidProps.putString("rfid_pre_filter_target", "2")
        //rfidProps.putString("rfid_pre_filter_memory_bank", "2")
        //rfidProps.putString("rfid_pre_filter_offset", "2")
        //rfidProps.putString("rfid_pre_filter_action", "2")

        // Post-filter
        rfidProps.putString("rfid_post_filter_enable", "false")
        //rfidProps.putString("rfid_post_filter_no_of_tags_to_read", "2")
        //rfidProps.putString("rfid_post_filter_rssi", "-54")

        rfidConfig.putBundle("PARAM_LIST", rfidProps)
        profileConfig.putBundle("PLUGIN_CONFIG", rfidConfig)

        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", packageName)      //  Associate the profile with this app
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profileConfig.putParcelableArray("APP_LIST", arrayOf(appConfig))
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)

        //  You can only configure one plugin at a time in some versions of DW, now do the intent output
        profileConfig.remove("PLUGIN_CONFIG")

        val intentConfig = Bundle()
        intentConfig.putString("PLUGIN_NAME", "INTENT")
        intentConfig.putString("RESET_CONFIG", "true")

        val intentProps = Bundle()
        intentProps.putString("intent_output_enabled", "true")
        intentProps.putString("intent_action", PROFILE_INTENT_ACTION)
        intentProps.putString("intent_delivery", PROFILE_INTENT_BROADCAST)  //  "2"
        intentConfig.putBundle("PARAM_LIST", intentProps)
        profileConfig.putBundle("PLUGIN_CONFIG", intentConfig)
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)

        //  You can only configure one plugin at a time in some versions of DW, now do the intent output
        profileConfig.remove("PLUGIN_CONFIG")

        val keystrokeConfig = Bundle()
        keystrokeConfig.putString("PLUGIN_NAME", "KEYSTROKE")
        keystrokeConfig.putString("RESET_CONFIG", "true")

        val keystrokeProps = Bundle()
        keystrokeProps.putString("keystroke_output_enabled", "false")
        keystrokeConfig.putBundle("PARAM_LIST", keystrokeProps)
        profileConfig.putBundle("PLUGIN_CONFIG", keystrokeConfig)
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profileConfig)

        Log.d("WEDGE", "RFID PROFILE CREATED")
    }
}
