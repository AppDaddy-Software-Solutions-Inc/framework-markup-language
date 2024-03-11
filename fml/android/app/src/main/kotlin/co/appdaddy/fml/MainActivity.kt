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
                val arguments = JSONObject(call.arguments.toString())
                val command:   String = arguments.get("command") as String
                val parameter: String = arguments.get("parameter") as String

                if (command == "com.symbol.datawedge.api.CREATEPROFILE")
                    createDataWedgeProfile(parameter)
                else dwInterface.sendCommandString(applicationContext, command, parameter)
            }
            else result.notImplemented()
        }
    }

    private fun createDataWedgeBroadcastReceiver(events: EventSink?): BroadcastReceiver? {
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

    private fun createDataWedgeProfile(profileName: String)
    {
        //  create and configure the DataWedge profile associated with this application
        dwInterface.sendCommandString(this, DWInterface.DATAWEDGE_SEND_CREATE_PROFILE, profileName)

        // configure the DataWedge profile
        val dwProfile = Bundle()
        dwProfile.putString("PROFILE_NAME", profileName)
        dwProfile.putString("PROFILE_ENABLED", "true") //  These are all strings
        dwProfile.putString("CONFIG_MODE", "UPDATE")

        //  associate the profile with this app
        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", packageName)
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        dwProfile.putParcelableArray("APP_LIST", arrayOf(appConfig))

        // build plugins
        val plugins: ArrayList<Bundle> = ArrayList<Bundle>()

        // intent plugin
        val intentPluginProperyties = Bundle()
        intentPluginProperyties.putString("intent_output_enabled", "true")
        intentPluginProperyties.putString("intent_action", PROFILE_INTENT_ACTION)
        intentPluginProperyties.putString("intent_delivery", PROFILE_INTENT_BROADCAST)

        val intentPlugin = Bundle()
        intentPlugin.putString("PLUGIN_NAME", "INTENT")
        intentPlugin.putString("RESET_CONFIG", "true")
        intentPlugin.putBundle("PARAM_LIST", intentPluginProperyties)
        plugins.add(intentPlugin)

        // barcode plugin
        val barcodePluginProperties = Bundle()
        barcodePluginProperties.putString("scanner_input_enabled", "true")
        barcodePluginProperties.putString("scanner_selection", "auto")

        val barcodePlugin = Bundle()
        barcodePlugin.putString("PLUGIN_NAME", "BARCODE")
        barcodePlugin.putString("RESET_CONFIG", "true")
        barcodePlugin.putBundle("PARAM_LIST", barcodePluginProperties)
        plugins.add(barcodePlugin)

        // rfid plugin
        val rfidPluginProperties = Bundle()
        rfidPluginProperties.putString("rfid_input_enabled", "true")
        rfidPluginProperties.putString("rfid_beeper_enable", "true")
        rfidPluginProperties.putString("rfid_led_enable", "true")
        rfidPluginProperties.putString("rfid_antenna_transmit_power", "30")
        rfidPluginProperties.putString("rfid_memory_bank", "0")
        rfidPluginProperties.putString("rfid_session", "1")
        rfidPluginProperties.putString("rfid_trigger_mode", "0")
        rfidPluginProperties.putString("rfid_filter_duplicate_tags", "true")
        rfidPluginProperties.putString("rfid_hardware_trigger_enabled", "true")
        rfidPluginProperties.putString("rfid_tag_read_duration", "1000")
        rfidPluginProperties.putString("rfid_link_profile", "0")
        rfidPluginProperties.putString("rfid_pre_filter_enable", "false")
        rfidPluginProperties.putString("rfid_post_filter_enable", "false")

        val rfidPlugin = Bundle()
        rfidPlugin.putString("PLUGIN_NAME", "RFID")
        rfidPlugin.putString("RESET_CONFIG", "true")
        rfidPlugin.putBundle("PARAM_LIST", rfidPluginProperties)
        plugins.add(rfidPlugin)

        // keystroke plugin
        val keystrokePluginProperties = Bundle()
        keystrokePluginProperties.putString("keystroke_output_enabled", "false")

        val keystrokePlugin = Bundle()
        keystrokePlugin.putString("PLUGIN_NAME", "KEYSTROKE")
        keystrokePlugin.putString("RESET_CONFIG", "true")
        keystrokePlugin.putBundle("PARAM_LIST", keystrokePluginProperties)
        plugins.add(keystrokePlugin)

        // add plugins to the profile
        dwProfile.putParcelableArrayList("PLUGIN_CONFIG", plugins);

        // update the profile
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, dwProfile)

        // this enables the scanner
        // hack to fix scanner not enabled
        dwInterface.sendCommandString(this, DWInterface.DATAWEDGE_SEND_SCANNER_COMMAND, "ENABLE_PLUGIN")
    }
}
