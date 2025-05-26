/*import 'package:dio/dio.dart';
import 'package:flutter_application_33/Stripe/consttt.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService{

StripeService._();

static final StripeService instance=StripeService._();

Future<void> makePayment()async{

  try{

    String? PaymentIntentClientSecret=await _createPaymentIntent(10, "JD");

    if(PaymentIntentClientSecret==null)return;

    await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(

      paymentIntentClientSecret: PaymentIntentClientSecret,
      merchantDisplayName: "3l tareeq",
    ),
    
    
    );

    await _processPayment();

  }
  catch(e){

    print(e);
  }
}

Future<String?> _createPaymentIntent(int amount,String currency) async{

  try{

   final Dio dio=Dio();
   Map<String,dynamic> data={

    "amount":_calculateAmount(amount),
    "currency":currency
   };

   var response =await dio.post("https://api.stripe.com/v1/payment_intents",data: data
   ,options: Options(contentType: Headers.formUrlEncodedContentType
   ,headers: {
    "Authorization":"Bearer $stripeSecretKey",
    "Content-Type":"application/x-ww-form-urlencoded"
   }));

   if(response.data!=null){
    

    return response.data("client_secret");
   }return null;


  }catch(e){
    print(e);

  } return null;

}

Future<void> _processPayment()async{

  try{
 
 await Stripe.instance.presentPaymentSheet();

  }catch(e){
  print(e);

  }
}

String _calculateAmount(int amount){
  final calculatedAmount=amount*100;
  return _calculateAmount.toString();
}

}


*/