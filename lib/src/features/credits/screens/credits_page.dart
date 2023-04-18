import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A page that shows credits and attribution to the people, data and software
/// used to create this program.
class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final divider = LayoutBuilder(
      builder: (context, constraints) {
        return Divider(
          indent: constraints.maxWidth * 0.1,
          endIndent: constraints.maxWidth * 0.1,
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credits'),
      ),
      body: Align(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          children: [
            Text(
              'EiT Group 3',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              'TTK4852 - NTNU, Spring 2022',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            divider,
            Text(
              'Team members:',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            Text(
              'Gaute Hagen',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              'Victor Pierre Hamran',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              'Trym Jørgensen',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              'Thomas Bakken Moe',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              'Sofie Trovik',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            divider,
            Text(
              'Data sources:',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Base map tiles and city polygons, ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                    text: '© ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                    text: 'OpenStreetMap',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = Uri.parse(
                          'https://www.openstreetmap.org/copyright',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                  ),
                  TextSpan(
                    text: ' contributors',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Text(
              'Contains modified Copernicus Sentinel data [2022]',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '2022’s Happiest Cities in America, ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                    text: 'WalletHub.com',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final url = Uri.parse(
                          'https://web.archive.org/web/20220302040616/https://wallethub.com/edu/happiest-places-to-live/32619',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                  ),
                ],
              ),
            ),
            divider,
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  child: Text(
                    'Software licenses',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => LicensePage(
                        applicationName: 'SaTreeLight',
                        applicationIcon: Image(
                          image: Image.asset(
                            'assets/graphics/satreelight_logo.png',
                            cacheHeight: 420,
                          ).image,
                        ),
                        applicationVersion: '2.0',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
