package dev.fml.zebra

import android.content.Context
import android.content.Intent
import android.os.Bundle
import org.json.JSONObject;

class ZebraInterface() {
    companion object {
        const val DATAWEDGE_SEND_ACTION = "com.symbol.datawedge.api.ACTION"
        const val DATAWEDGE_RETURN_ACTION = "com.symbol.datawedge.api.RESULT_ACTION"
        const val DATAWEDGE_RETURN_CATEGORY = "android.intent.category.DEFAULT"
        const val DATAWEDGE_EXTRA_SEND_RESULT = "SEND_RESULT"
        const val DATAWEDGE_SCAN_EXTRA_DATA_STRING = "com.symbol.datawedge.data_string"
        const val DATAWEDGE_SCAN_EXTRA_SOURCE = "com.symbol.datawedge.source"
        const val DATAWEDGE_SCAN_EXTRA_LABEL_TYPE = "com.symbol.datawedge.label_type"
        const val DATAWEDGE_SEND_CREATE_PROFILE = "com.symbol.datawedge.api.CREATE_PROFILE"
        const val DATAWEDGE_SEND_SET_CONFIG = "com.symbol.datawedge.api.SET_CONFIG"
        const val DATAWEDGE_SEND_SCANNER_COMMAND = "com.symbol.datawedge.api.SCANNER_INPUT_PLUGIN"
    }

    fun sendCommandString(context: Context, command: String, parameter: String, sendResult: Boolean = false) {
        val dwIntent = Intent()
        dwIntent.action = DATAWEDGE_SEND_ACTION
        dwIntent.putExtra(command, parameter)
        if (sendResult)
            dwIntent.putExtra(DATAWEDGE_EXTRA_SEND_RESULT, "true")
        context.sendBroadcast(dwIntent)
    }

    fun sendCommandBundle(context: Context, command: String, parameter: Bundle) {
        val dwIntent = Intent()
        dwIntent.action = DATAWEDGE_SEND_ACTION
        dwIntent.putExtra(command, parameter)
        context.sendBroadcast(dwIntent)
    }
}

class ZebraScan(val source: String, val barcode: String, val format: String, val date: String)
{
    fun toJson(): String{
        return JSONObject(mapOf(
            "source"  to this.source,
            "barcode" to this.barcode,
            "format"  to this.format,
            "date"    to this.date
        )).toString();
    }
}