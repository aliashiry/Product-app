import 'package:flutter/material.dart';
import 'package:product_app/core/utils/di.dart';
import 'package:product_app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

