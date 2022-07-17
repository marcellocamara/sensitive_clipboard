package marcello.dev.sensitive_clipboard

import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.content.Context.CLIPBOARD_SERVICE
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

            val text = call.argument("text") ?: ""
            val shouldHide = call.argument("hideContent") ?: false

            val clipBoardManager = context.getSystemService(CLIPBOARD_SERVICE) as ClipboardManager
            val clipData = ClipData.newPlainText("text", text)

            var isAboveOrEqualsAPI33 = false

            clipData.apply {
                // The doc says that all apps should do this, regardless of the targeted API level
                // But that's not true, because to set extras need to be, at least, at API >= 24 (android N)
                // See the doc here https://developer.android.com/about/versions/13/behavior-changes-all#copy-sensitive-content
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    if (Build.VERSION.SDK_INT >= 33) {
                        isAboveOrEqualsAPI33 = true
                        description.extras = PersistableBundle().apply {
                            putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, shouldHide)
                        }
                    } else {
                        description.extras = PersistableBundle().apply {
                            putBoolean("android.content.extra.IS_SENSITIVE", shouldHide)
                        }
                    }
                }
            }

            clipBoardManager.setPrimaryClip(clipData)

            result.success(isAboveOrEqualsAPI33)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
