import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/app/satreelight.dart';
import 'package:satreelight/widgets/loading_indicator.dart';

Future<void> main() async {
  runApp(
    const ProviderScope(
      child: LoadingIndicator(),
    ),
  );
  await FastCachedImageConfig.init();

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      child: SaTreeLight(),
    ),
  );
}
