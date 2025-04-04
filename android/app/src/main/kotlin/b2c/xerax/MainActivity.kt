package b2c.xerax

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register your native ad factory using the expected type.
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "adFactoryExample",
            NativeAdFactory(applicationContext)
        )
    }

    override fun cleanUpFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "adFactoryExample")
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
