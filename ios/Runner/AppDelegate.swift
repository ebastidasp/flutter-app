import google_mobile_ads

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // TODO: Register ListTileNativeAdFactory
    let listTileFactory = ListTileNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "adFactoryExample", nativeAdFactory: listTileFactory)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
