import 'package:chat_app/colors.dart';
import 'package:chat_app/common/utils/utils.dart';
import 'package:chat_app/common/widgets/custom_button.dart';
import 'package:chat_app/features/auth/controller/auth_controller.dart';
import 'package:chat_app/features/auth/repository/auth_repository.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final phoneController = TextEditingController();
  Country? country;

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  void pickCountry() {
    showCountryPicker(
      context: context,
      onSelect: (Country _country) {
        setState(() {
          country = _country;
        });
      },
      countryListTheme: const CountryListThemeData(
        backgroundColor: backgroundColor,
        bottomSheetHeight: 500,
      ),
    );
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, '+${country!.phoneCode}$phoneNumber');
    }
    else {
      showSnackBar(context: context, content: "Fill all fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter your phone number"),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Chat app will need to verify your phone number"),
            const SizedBox(height: 10),
            TextButton(
              onPressed: pickCountry,
              child: const Text("Pick Country"),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                if (country != null) Text('+${country!.phoneCode}'),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: size.width * 0.7,
                  child: TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(hintText: 'Phone Number'),
                  ),
                ),
              ],
            ),
            // SizedBox(height: size.height*0.6,),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: 90,
                child: CustomButton(text: 'Next', onPressed: sendPhoneNumber),
              ),
            )
          ],
        ),
      ),
    );
  }
}
