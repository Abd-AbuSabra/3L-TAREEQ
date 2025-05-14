import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:animated_background/animated_background.dart'; 

class Payment extends StatefulWidget {
  const Payment({super.key});

  @override
  State<StatefulWidget> createState() => PaymentState();
}

class PaymentState extends State<Payment> with TickerProviderStateMixin { 
  bool isLightTheme = false;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useFloatingAnimation = true;

  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      isLightTheme ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isLightTheme ? ThemeMode.light : ThemeMode.dark,
      theme: ThemeData(
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.black, fontSize: 18),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.black),
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: border,
          enabledBorder: border,
        ),
      ),
      darkTheme: ThemeData(
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.white, fontSize: 18),
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Colors.grey),
          focusedBorder: border,
          enabledBorder: border,
        ),
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: AnimatedBackground(
          vsync: this,
          behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
              spawnMaxRadius: 200,
              spawnMinRadius: 10,
              spawnMinSpeed: 10,
              spawnMaxSpeed: 15,
              particleCount: 4,
              spawnOpacity: 0.1,
              maxOpacity: 0.1,
              baseColor: const Color.fromARGB(255, 192, 228, 194),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 60, height: 60, child: logo()),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CreditCardWidget(
                    enableFloatingCard: useFloatingAnimation,
                    glassmorphismConfig: _getGlassmorphismConfig(),
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    bankName: 'ABC Bank',
                    frontCardBorder: useGlassMorphism ? null : Border.all(color: Colors.grey),
                    backCardBorder: useGlassMorphism ? null : Border.all(color: Colors.grey),
                    showBackView: isCvvFocused,
                    obscureCardNumber: true,
                    obscureCardCvv: true,
                    isHolderNameVisible: true,
                    cardBgColor: const Color(0xFF001F4D),
                    isSwipeGestureEnabled: true,
                    onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                    customCardTypeIcons: const <CustomCardTypeIcon>[],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        CreditCardForm(
                          formKey: formKey,
                          obscureCvv: true,
                          obscureNumber: true,
                          cardNumber: cardNumber,
                          cvvCode: cvvCode,
                          isHolderNameVisible: true,
                          isCardNumberVisible: true,
                          isExpiryDateVisible: true,
                          cardHolderName: cardHolderName,
                          expiryDate: expiryDate,
                          inputConfiguration: const InputConfiguration(
                            cardNumberDecoration: InputDecoration(
                              labelText: 'Number',
                              hintText: 'XXXX XXXX XXXX XXXX',
                            ),
                            expiryDateDecoration: InputDecoration(
                              labelText: 'Expired Date',
                              hintText: 'XX/XX',
                            ),
                            cvvCodeDecoration: InputDecoration(
                              labelText: 'CVV',
                              hintText: 'XXX',
                            ),
                            cardHolderDecoration: InputDecoration(
                              labelText: 'Card Holder',
                            ),
                          ),
                          onCreditCardModelChange: onCreditCardModelChange,
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 192, 228, 194),
                    padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Pay',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 55),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onValidate() {
    if (formKey.currentState?.validate() ?? false) {
      print('valid!');
    } else {
      print('invalid!');
    }
  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }

    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
    );

    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}
