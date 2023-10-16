package co.appdaddy.fml

import org.json.JSONObject;

class Scan(val source: String, val barcode: String, val format: String, val date: String)
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

