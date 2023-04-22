import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/app/satreelight.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: SaTreeLight(
        loading: true,
      ),
    ),
  );
  await FastCachedImageConfig.init();

  runApp(
    ProviderScope(
      child: SaTreeLight(),
    ),
  );
}
