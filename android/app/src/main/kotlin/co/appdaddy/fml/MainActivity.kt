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
        //  Create and configure the DataWedge profile associated with this application
        //  For readability's sake, I have not defined each of the keys in the DWInterface file
        dwInterface.sendCommandString(this, DWInterface.DATAWEDGE_SEND_CREATE_PROFILE, profileName)

        // create the device profile
        val profile = Bundle()
        profile.putString("PROFILE_NAME", profileName)
        profile.putString("PROFILE_ENABLED", "true") //  These are all strings
        profile.putString("CONFIG_MODE", "UPDATE")

        //  associate the profile with this app
        val appConfig = Bundle()
        appConfig.putString("PACKAGE_NAME", packageName)
        appConfig.putStringArray("ACTIVITY_LIST", arrayOf("*"))
        profile.putParcelableArray("APP_LIST", arrayOf(appConfig))

        // update the profile
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profile)

        // create barcode plugin
        val barcodePlugin = Bundle()
        barcodePlugin.putString("PLUGIN_NAME", "BARCODE")
        barcodePlugin.putString("RESET_CONFIG", "true") //  This is the default but never hurts to specify

        // configure barcode plugin properties
        val barcodePluginProperties = Bundle()

        // add properties to the plugin
        barcodePlugin.putBundle("PARAM_LIST", barcodePluginProperties)

        // add plugin to the profile
        profile.putBundle("PLUGIN_CONFIG", barcodePlugin)

        //  You can only configure one plugin at a time in some versions of DW
        profile.remove("PLUGIN_CONFIG")

        // create rfid plugin
        val rfidPlugin = Bundle()
        rfidPlugin.putString("PLUGIN_NAME", "RFID")
        rfidPlugin.putString("RESET_CONFIG", "true")

        // configure rfid plugin properties
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

        // pre-filter properties
        rfidPluginProperties.putString("rfid_pre_filter_enable", "false")
        //rfidProps.putString("rfid_pre_filter_tag_pattern", "3EC")
        //rfidProps.putString("rfid_pre_filter_target", "2")
        //rfidProps.putString("rfid_pre_filter_memory_bank", "2")
        //rfidProps.putString("rfid_pre_filter_offset", "2")
        //rfidProps.putString("rfid_pre_filter_action", "2")

        // post-filter properties
        rfidPluginProperties.putString("rfid_post_filter_enable", "false")
        //rfidProps.putString("rfid_post_filter_no_of_tags_to_read", "2")
        //rfidProps.putString("rfid_post_filter_rssi", "-54")

        // add properties to the plugin
        rfidPlugin.putBundle("PARAM_LIST", rfidPluginProperties)

        // add plugin to the profile
        profile.putBundle("PLUGIN_CONFIG", rfidPlugin)

        // update the profile
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profile)

        //  You can only configure one plugin at a time in some versions of DW
        profile.remove("PLUGIN_CONFIG")

        // create intent plugin
        val intentPlugin = Bundle()
        intentPlugin.putString("PLUGIN_NAME", "INTENT")
        intentPlugin.putString("RESET_CONFIG", "true")

        // configure intent plugin properties
        val intentPluginProperyties = Bundle()
        intentPluginProperyties.putString("intent_output_enabled", "true")
        intentPluginProperyties.putString("intent_action", PROFILE_INTENT_ACTION)
        intentPluginProperyties.putString("intent_delivery", PROFILE_INTENT_BROADCAST)  //  "2"

        // add properties to the plugin
        intentPlugin.putBundle("PARAM_LIST", intentPluginProperyties)

        // add plugin to the profile
        profile.putBundle("PLUGIN_CONFIG", intentPlugin)

        // update the profile
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profile)

        //  You can only configure one plugin at a time in some versions of DW
        profile.remove("PLUGIN_CONFIG")

        // create keystroke plugin
        val keystrokePlugin = Bundle()
        keystrokePlugin.putString("PLUGIN_NAME", "KEYSTROKE")
        keystrokePlugin.putString("RESET_CONFIG", "true")

        // configure keystroke plugin properties
        val keystrokePluginProperties = Bundle()
        keystrokePluginProperties.putString("keystroke_output_enabled", "false")

        // add properties to the plugin
        keystrokePlugin.putBundle("PARAM_LIST", keystrokePluginProperties)

        // add plugin to the profile
        profile.putBundle("PLUGIN_CONFIG", keystrokePlugin)

        // update the profile
        dwInterface.sendCommandBundle(this, DWInterface.DATAWEDGE_SEND_SET_CONFIG, profile)
    }
}
