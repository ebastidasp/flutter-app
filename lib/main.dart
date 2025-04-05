import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pay/pay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Firebase & AdMob',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      routes: {
        '/home': (_) => HomeScreen(),
        '/payment': (_) => PaymentTestScreen(),
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;

  Future<User?> signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    setState(() {
      _isSigningIn = false;
    });

    return userCredential.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login con Google')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _isSigningIn
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    child: const Text('Iniciar sesión con Google'),
                    onPressed: () async {
                      User? user = await signInWithGoogle();
                      if (user != null) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;
  Future<NativeAd>? _nativeAdFuture; // Future for loading native ad
  bool _adFlag = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
    _nativeAdFuture = _loadNativeAd();
    _nativeAdFuture = _loadNativeAd();
  }

  void _loadRewardedAd() {

    final String rewardUnitId = Platform.isAndroid
      ? 'ca-app-pub-6028945278255259/4039606333'
      : Platform.isIOS
          ? 'ca-app-pub-6028945278255259/8676855341'
          : throw UnsupportedError('Unsupported platform');

    RewardedAd.load(
      adUnitId: rewardUnitId, // Replace with your Rewarded ad unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          if (mounted) {
            setState(() {
              _isRewardedAdReady = true;
            });
          }
          if (mounted) {
            setState(() {
              _isRewardedAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          if (mounted) {
            setState(() {
              _isRewardedAdReady = false;
            });
          }
          if (mounted) {
            setState(() {
              _isRewardedAdReady = false;
            });
          }
        },
      ),
    );
  }

  // Load the native ad and return it as a Future.
  Future<NativeAd> _loadNativeAd() async {

    final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : Platform.isIOS
          ? 'ca-app-pub-6028945278255259/7592805166'
          : throw UnsupportedError('Unsupported platform');

    final NativeAd nativeAd = NativeAd(
      adUnitId: adUnitId, // Replace with your native ad unit ID
      factoryId: 'adFactoryExample', // Must match the registered factoryId on the native side
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _adFlag = true;
          print('Native ad loaded.');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Native ad failed to load: $error');
          throw Exception('Native ad failed to load: $error');
        },
      ),
    );

    await nativeAd.load();
    return nativeAd;
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('User earned: ${reward.amount} ${reward.type}');
          print('User earned: ${reward.amount} ${reward.type}');
        },
      );
      _rewardedAd = null;
      if (mounted) {
        setState(() {
          _isRewardedAdReady = false;
        });
      }
      if (mounted) {
        setState(() {
          _isRewardedAdReady = false;
        });
      }
      _loadRewardedAd();
    }
  }

  @override
  void dispose() {
    // Set the flag to false so that the ad isn't shown after the page is closed.
    _adFlag = false;
    // Set the flag to false so that the ad isn't shown after the page is closed.
    _adFlag = false;
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla AdMob'),
        actions: [
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: () {
              Navigator.pushNamed(context, '/payment');
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Mostrar Reward Ad'),
              onPressed: _isRewardedAdReady ? _showRewardedAd : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Ir a Pantalla de Pagos'),
              onPressed: () {
                Navigator.pushNamed(context, '/payment');
              },
            ),
          ],
        ),
      ),
      // Use the _adFlag to decide whether to display the native ad.
      bottomNavigationBar: _adFlag
          ? FutureBuilder<NativeAd>(
              future: _nativeAdFuture,
              builder: (BuildContext context, AsyncSnapshot<NativeAd> snapshot) {
                if (!_adFlag) return const SizedBox.shrink();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 70,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasData) {
                  return SizedBox(
                    height: 70,
                    child: AdWidget(ad: snapshot.data!),
                  );
                } else {
                  print('Native ad error: ${snapshot.error}');
                  return SizedBox(
                    height: 70,
                    child: Center(
                        child: Text('Ad failed to load: ${snapshot.error}')),
                  );
                }
              },
            )
          : const SizedBox.shrink(),
    );
  }
}

class PaymentTestScreen extends StatelessWidget {
  final List<PaymentItem> _paymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '1.00',
      status: PaymentItemStatus.final_price,
    ),
  ];

  static const String googlePayConfig = '''
{
  "provider": "google_pay",
  "data": {
    "environment": "TEST",
    "apiVersion": 2,
    "apiVersionMinor": 0,
    "allowedPaymentMethods": [
      {
        "type": "CARD",
        "parameters": {
          "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
          "allowedCardNetworks": ["AMEX", "DISCOVER", "JCB", "MASTERCARD", "VISA"]
        },
        "tokenizationSpecification": {
          "type": "PAYMENT_GATEWAY",
          "parameters": {
            "gateway": "example",
            "gatewayMerchantId": "exampleGatewayMerchantId"
          }
        }
      }
    ],
    "transactionInfo": {
      "totalPriceStatus": "FINAL",
      "totalPrice": "1.00",
      "currencyCode": "USD"
    }
  }
}
''';

  static const String applePayConfig = '''
{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "merchant.com.example.test",
    "displayName": "Example Store",
    "merchantCapabilities": ["3DS", "EMV", "Credit", "Debit"],
    "supportedCountries": ["US"],
    "supportedNetworks": ["visa", "masterCard", "amex"],
    "countryCode": "US",
    "currencyCode": "USD"
  }
}
''';

  void onGooglePayResult(Map<String, dynamic> paymentResult) {
    print('Google Pay Payment Result: $paymentResult');
  }

  void onApplePayResult(Map<String, dynamic> paymentResult) {
    print('Apple Pay Payment Result: $paymentResult');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prueba de Pagos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GooglePayButton(
              paymentConfiguration: PaymentConfiguration.fromJsonString(googlePayConfig),
              paymentItems: _paymentItems,
              onPaymentResult: onGooglePayResult,
              loadingIndicator: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 20),
            ApplePayButton(
              paymentConfiguration: PaymentConfiguration.fromJsonString(applePayConfig),
              paymentItems: _paymentItems,
              onPaymentResult: onApplePayResult,
              loadingIndicator: const CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}