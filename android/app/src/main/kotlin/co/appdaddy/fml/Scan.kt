package co.appdaddy.fml

import org.json.JSONObject;

class Scan(val barcode: String, val format: String, val date: String)
{
    fun toJson(): String{
        return JSONObject(mapOf(
            "barcode" to this.barcode,
            "format"  to this.format,
            "date"    to this.date
        )).toString();
    }
}

