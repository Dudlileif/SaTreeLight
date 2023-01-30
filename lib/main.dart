import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/app/satreelight.dart';
import 'package:satreelight/widgets/loading_indicator.dart';

Future<void> main() async {
  runApp(const LoadingIndicator());

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: SaTreeLight(),
    ),
  );
}
