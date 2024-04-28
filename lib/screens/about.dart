import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _packageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    final name = AppLocalizations.of(context)!.appTitle;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleMedium;
    final bodyTextStyle = textTheme.bodyLarge;
    final linkStyle = bodyTextStyle!.copyWith(color: Colors.blue);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.about_title),
      ),
      body: Center(
        child: _packageInfo == null
            ? CircularProgressIndicator()
            : ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('$name', style: titleStyle),
                        Text(
                            '${AppLocalizations.of(context)!.about_version} ${_packageInfo!.version}',
                            style: bodyTextStyle),
                        Text('©2020–${DateTime.now().year} Paul Gestwicki',
                            style: bodyTextStyle),
                        _space(),
                        Text(
                            '${AppLocalizations.of(context)!.about_repository}:',
                            style: bodyTextStyle),
                        _makeLink(
                            'https://github.com/doctor-g/ThunderstoneQuestRandomizer',
                            linkStyle),
                        _space(),
                        Text(AppLocalizations.of(context)!.about_license,
                            style: bodyTextStyle),
                        _makeLink(
                            'https://www.gnu.org/licenses/gpl-3.0.en.html',
                            linkStyle),
                        _space(),
                        Text(AppLocalizations.of(context)!.about_ownership,
                            style: bodyTextStyle),
                        _makeLink('https://www.alderac.com/thunderstone-quest/',
                            linkStyle),
                        _space(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _space() => Padding(padding: EdgeInsets.all(8));

  Widget _makeLink(String url, var style) => InkWell(
        child: Text(url, style: style),
        onTap: () async {
          var uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        },
      );
}
