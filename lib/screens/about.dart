import 'package:flutter/material.dart';
import 'package:flutter_tqr/util/web_version_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final name = AppLocalizations.of(context)!.appTitle;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.subtitle1;
    final bodyTextStyle = textTheme.bodyText1;
    final linkStyle = bodyTextStyle!.copyWith(color: Colors.blue);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.about_title),
      ),
      body: Center(
        child: ConstrainedBox(
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
                      '${AppLocalizations.of(context)!.about_version} ${WebVersionInfo.name}',
                      style: bodyTextStyle),
                  Text('©2020–2021 Paul Gestwicki', style: bodyTextStyle),
                  _space(),
                  Text('${AppLocalizations.of(context)!.about_repository}:',
                      style: bodyTextStyle),
                  _makeLink(
                      'https://github.com/doctor-g/ThunderstoneQuestRandomizer',
                      linkStyle),
                  _space(),
                  Text(AppLocalizations.of(context)!.about_license,
                      style: bodyTextStyle),
                  _makeLink('https://www.gnu.org/licenses/gpl-3.0.en.html',
                      linkStyle),
                  _space(),
                  Text(AppLocalizations.of(context)!.about_ownership,
                      style: bodyTextStyle),
                  _makeLink('https://www.alderac.com/thunderstone', linkStyle),
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
          if (await canLaunch(url)) {
            await launch(
              url,
              forceSafariVC: false,
            );
          }
        },
      );
}
