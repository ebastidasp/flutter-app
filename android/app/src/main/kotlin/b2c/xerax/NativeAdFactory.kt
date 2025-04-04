package b2c.xerax

import android.content.Context
import android.view.LayoutInflater
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class NativeAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: Map<String, Any>?
    ): NativeAdView {
        // Inflate your native ad layout
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.native_ad_layout, null) as NativeAdView

        // Bind views from the layout
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)

        // Assign the views to the NativeAdView properties
        adView.headlineView = headlineView
        adView.mediaView = mediaView
        adView.bodyView = bodyView

        // Populate the views with ad content
        headlineView.text = nativeAd.headline ?: ""
        bodyView.text = nativeAd.body ?: ""

        // Attach the native ad object to the view
        adView.setNativeAd(nativeAd)

        return adView
    }
}
