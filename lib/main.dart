import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pay/pay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Inicializamos AdMob
  MobileAds.instance.initialize();
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

/// --- PANTALLA DE LOGIN CON GOOGLE ---
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
      // If the user canceled the sign-in, handle it here
      return null;
    }

    // Obtain the Google account’s authentication details (tokens)
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential for Firebase with the tokens
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
        child: _isSigningIn
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
      ),
    );
  }
}

/// --- PANTALLA PRINCIPAL CON ANUNCIOS DE ADMOB ---
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-6028945278255259/4039606333', // Reemplaza con tu ID de AdMob para Rewarded
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          setState(() {
            _isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          setState(() {
            _isRewardedAdReady = false;
          });
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('Usuario ganó: ${reward.amount} ${reward.type}');
        },
      );
      _rewardedAd = null;
      setState(() {
        _isRewardedAdReady = false;
      });
      _loadRewardedAd();
    }
  }

  // Componente que muestra un anuncio nativo de prueba
  Widget _nativeAdWidget() {
    return Container(
      height: 100,
      color: Colors.grey[300],
      child: const Center(
        child: Text('Aquí se muestra un anuncio nativo de prueba'),
      ),
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla AdMob'),
        actions: [
          // Botón para ir a la pantalla de pagos en el AppBar (opcional)
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
            // 1. Botón para mostrar el Rewarded Ad
            ElevatedButton(
              child: const Text('Mostrar Reward Ad'),
              onPressed: _isRewardedAdReady ? _showRewardedAd : null,
            ),
            const SizedBox(height: 20),
            // 2. Componente que muestra un anuncio nativo de prueba
            _nativeAdWidget(),
            const SizedBox(height: 20),
            // 3. Botón adicional para ir a la pantalla de pagos
            ElevatedButton(
              child: const Text('Ir a Pantalla de Pagos'),
              onPressed: () {
                Navigator.pushNamed(context, '/payment');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentTestScreen extends StatelessWidget {
  // Define some payment items for testing (e.g., a $1.00 transaction)
  final List<PaymentItem> _paymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '1.00',
      status: PaymentItemStatus.final_price,
    ),
  ];

  // Test configuration for Google Pay using dummy keys
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

  // Test configuration for Apple Pay using a dummy sandbox merchant identifier
  static const String applePayConfig = '''
{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "merchant.com.example.test",
    "displayName": "Example Store",
    "merchantCapabilities": ["3DS", "EMV", "Credit", "Debit"],
    "supportedCountries": ["US"],
    "supportedNetworks": ["visa", "masterCard", "amex"]
  }
}
''';

  void onGooglePayResult(Map<String, dynamic> paymentResult) {
    // Handle the Google Pay result here
    print('Google Pay Payment Result: $paymentResult');
  }

  void onApplePayResult(Map<String, dynamic> paymentResult) {
    // Handle the Apple Pay result here
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
            // Google Pay Payment Button using the test configuration
            GooglePayButton(
              paymentConfiguration: PaymentConfiguration.fromJsonString(googlePayConfig),
              paymentItems: _paymentItems,
              onPaymentResult: onGooglePayResult,
              loadingIndicator: const CircularProgressIndicator(),
            ),
            const SizedBox(height: 20),
            // Apple Pay Payment Button using the test configuration
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