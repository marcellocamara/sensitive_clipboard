package marcello.dev.sensitive_clipboard

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.PersistableBundle
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** SensitiveClipboardPlugin */
class SensitiveClipboardPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sensitive_clipboard")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "copy") {
            val text = call.argument<String>("text") ?: ""
            val shouldHide = call.argument<Boolean>("hideContent") ?: false

            val clipboardManager =
                context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
            val clipData = ClipData.newPlainText("text", text)

            // The property extras is only available from API 24 (Nougat)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                clipData.description.extras = PersistableBundle().apply {
                    // On Android 13+ (Tiramisu/API 33) we use the official constant
                    // For previous versions (24-32), we use the literal string which is backward compatible
                    val key = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ClipDescription.EXTRA_IS_SENSITIVE
                    } else {
                        "android.content.extra.IS_SENSITIVE"
                    }
                    putBoolean(key, shouldHide)
                }
            }

            clipboardManager.setPrimaryClip(clipData)

            // Returns true only if official API 33+ is supported
            result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
