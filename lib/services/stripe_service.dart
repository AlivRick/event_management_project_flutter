import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';

import '../models/transaction_model.dart';
import 'transaction_service.dart';
import 'wallet_service.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  // Publishable Key - Thiết lập trực tiếp ở đây
  final String publishableKey = "pk_test_51QeI5mRq4X9sEHeUANrX4eM3miki91rRgQfKnCjoe7QctxmlU7poiuJUAihEmMlvoZQhrpCrWocPYokM7KkU2rsO00mu7bJpfk";

  Future<bool> makePayment(int amount, String userId) async {
    try {
      // Thiết lập Stripe publishableKey trực tiếp ở đây
      Stripe.publishableKey = publishableKey;

      // Step 1: Create PaymentIntent with the specified amount
      String? paymentIntentClientSecret = await _createPaymentIntent(amount, "vnd");
      if (paymentIntentClientSecret == null) {
        print("Failed to create PaymentIntent.");
        return false;
      } else {
        print("PaymentIntent created successfully: $paymentIntentClientSecret");
      }

      // Step 2: Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: "Ticket Bờ rồ",
        ),
      );

      print("Payment Sheet initialized successfully");

      // Step 3: Present the Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // Step 4: Handle Successful Payment
      print("Payment successful");

      // Cập nhật số dư ví của người dùng trong Firebase
      WalletService walletService = WalletService();
      await walletService.updateWallet(userId, amount.toDouble());

      print("Wallet updated successfully");

      TransactionService transactionService = TransactionService();
      UserTransaction transaction = UserTransaction(
        id: '', // ID sẽ được gán tự động khi tạo
        userId: userId,
        type: 'DEPOSIT',
        amount: amount.toDouble(),
        date: DateTime.now(),
      );
      String transactionId = await transactionService.createTransaction(transaction);
      print("Transaction created successfully: $transactionId");


      return true; // Payment was successful
    } catch (e) {
      print("Error during payment: $e");
      if (e is StripeException) {
        print("Stripe error: ${e.error.localizedMessage}");
      }
      return false; // Payment failed
    }
  }

  // Create PaymentIntent with Stripe API
  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": amount,
        "currency": currency,
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer sk_test_51QeI5mRq4X9sEHeUzYYFE98dXpFJSpqw8m9UHSLOGyHzsqcZQ1bFe8fh16E5lNrUa8Do8KpyVHvCtESXCyPHcf2r00ENqAvMPn", // Secret key
            "Content-Type": "application/x-www-form-urlencoded"
          },
        ),
      );
      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      print("Error in _createPaymentIntent: $e");
    }
    return null;
  }
}
