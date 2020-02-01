///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-31 22:29
///
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:openjmu/constants/constants.dart';

@FFRoute(name: "openjmu://changelog-page", routeName: "版本履历")
class ChangeLogPage extends StatefulWidget {
  @override
  _ChangeLogPageState createState() => _ChangeLogPageState();
}

class _ChangeLogPageState extends State<ChangeLogPage> {
  List changeLogs;
  bool error = false;

  @override
  void initState() {
    super.initState();
    loadChangelog();
  }

  Future<void> loadChangelog() async {
    try {
      final changelog = await rootBundle.loadString('assets/changelog.json');
      changeLogs = (jsonDecode(changelog) as List).cast<Map>();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Failed when loading changelog: $e');
      error = true;
      if (mounted) setState(() {});
    }
  }

  Widget get timelineIndicator => Container(
        margin: EdgeInsets.only(right: suSetWidth(40.0)),
        width: suSetWidth(6.0),
        color: currentThemeColor,
        child: Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Positioned(
              top: suSetHeight(38.0),
              left: -suSetWidth(7.0),
              child: Container(
                width: suSetWidth(20.0),
                height: suSetWidth(20.0),
                decoration: BoxDecoration(shape: BoxShape.circle, color: currentThemeColor),
              ),
            ),
          ],
        ),
      );

  Widget logWidget(ChangeLog log) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(bottom: suSetHeight(30.0), right: suSetWidth(30.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                versionInfo(log),
                buildNumberInfo(log),
                Spacer(),
                dateInfo(log),
              ],
            ),
            Divider(height: suSetHeight(8.0), thickness: suSetHeight(1.0)),
            sectionWidget(log.sections),
          ],
        ),
      ),
    );
  }

  Widget versionInfo(ChangeLog log) {
    return Text(
      '${log.version} ',
      style: Theme.of(context).textTheme.title.copyWith(fontSize: suSetSp(40.0)),
    );
  }

  Widget buildNumberInfo(ChangeLog log) {
    return Text(
      '(${log.buildNumber})',
      style: Theme.of(context).textTheme.body1.copyWith(fontSize: suSetSp(20.0)),
    );
  }

  Widget dateInfo(ChangeLog log) {
    return Text(
      '${log.date}',
      style: Theme.of(context).textTheme.caption.copyWith(fontSize: suSetSp(20.0)),
    );
  }

  Widget sectionWidget(Map<String, dynamic> sections) {
    return Text.rich(
      TextSpan(
        children: List<TextSpan>.generate(
          sections.keys.length,
          (i) => contentColumn(sections, i),
        ),
      ),
      style: Theme.of(context).textTheme.body1.copyWith(fontSize: suSetSp(20.0)),
    );
  }

  TextSpan contentColumn(Map<String, dynamic> sections, int index) {
    final name = sections.keys.elementAt(index);
    return TextSpan(
      children: List<TextSpan>.generate(
        sections[name].length + 1,
        (j) => j == 0
            ? TextSpan(
                text: '\n[$name]\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : TextSpan(text: '·  ${sections[name][j - 1]}\n'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: Screens.topSafeHeight,
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: changeLogs != null
                ? ListView.builder(
                    padding: EdgeInsets.only(
                      top: suSetHeight(kAppBarHeight),
                      left: suSetWidth(28.0),
                    ),
                    itemCount: changeLogs.length,
                    itemBuilder: (context, i) => IntrinsicHeight(
                      child: Row(
                        children: <Widget>[
                          timelineIndicator,
                          logWidget(ChangeLog.fromJson(changeLogs[i])),
                        ],
                      ),
                    ),
                  )
                : SpinKitWidget(),
          ),
          Positioned(
            top: Screens.topSafeHeight + 8.0,
            left: 0.0,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    blurRadius: suSetWidth(20.0),
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                    spreadRadius: 0.0,
                  ),
                ],
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: BackButton(),
            ),
          ),
        ],
      ),
    );
  }
}

class ChangeLog {
  String version;
  int buildNumber;
  String date;
  Map<String, dynamic> sections;

  ChangeLog({this.version, this.buildNumber, this.date, this.sections});

  ChangeLog.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    buildNumber = json['buildNumber'];
    date = json['date'];
    sections = json['sections'];
  }

  Map<String, dynamic> toJson() {
    return {'version': version, 'buildNumber': buildNumber, 'date': date, 'sections': sections};
  }

  @override
  String toString() {
    return 'ChangeLog ${JsonEncoder.withIndent('  ').convert(toJson())}';
  }
}
