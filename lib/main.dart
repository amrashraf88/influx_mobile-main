import 'package:adzmavall/app/app.dart';
import 'package:adzmavall/core/auth/auth_token_storage.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthTokenStorage.instance.init();
  DioClient.configure();
  runApp(const AdzMavallApp());
}
