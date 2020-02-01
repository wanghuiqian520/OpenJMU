import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_library/extended_text_library.dart';

import 'package:openjmu/constants/constants.dart';

class AnnouncementDialog extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementDialog({
    Key key,
    this.announcement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text(
          '${announcement['title']}',
          style: TextStyle(
            fontSize: suSetSp(22.0),
            color: Colors.black,
          ),
        ),
        content: Wrap(
          children: <Widget>[
            ExtendedText(
              '${announcement['content']}',
              style: TextStyle(fontSize: suSetSp(18.0), color: Colors.black),
              specialTextSpanBuilder: RegExpSpecialTextSpanBuilder(),
              onSpecialTextTap: (dynamic data) {
                final text = data['content'];
                navigatorState.pushNamed(
                  Routes.OPENJMU_INAPPBROWSER,
                  arguments: {'url': text, 'title': '网页链接'},
                );
              },
              textAlign: TextAlign.left,
            )
          ],
        ),
        actions: <Widget>[
          CupertinoButton(
            child: Text(
              '确认',
              style: TextStyle(fontSize: suSetSp(19.0)),
            ),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      );
    } else {
      return AlertDialog(
        backgroundColor: currentThemeColor,
        title: Text(
          '${announcement['title']}',
          style: TextStyle(fontSize: suSetSp(22.0), color: Colors.white),
        ),
        content: Wrap(
          children: <Widget>[
            ExtendedText(
              '${announcement['content']}',
              style: TextStyle(fontSize: suSetSp(18.0), color: Colors.white),
              specialTextSpanBuilder: RegExpSpecialTextSpanBuilder(),
              onSpecialTextTap: (dynamic data) {
                final text = data['content'];
                navigatorState.pushNamed(
                  Routes.OPENJMU_INAPPBROWSER,
                  arguments: {'url': text, 'title': '网页链接'},
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              '确认',
              style: TextStyle(color: Colors.white, fontSize: suSetSp(18.0)),
            ),
            onPressed: Navigator.of(context).pop,
          )
        ],
      );
    }
  }
}

class LinkText extends SpecialText {
  static String startKey = 'https://';
  static const String endKey = ' ';

  LinkText(TextStyle textStyle, SpecialTextGestureTapCallback onTap)
      : super(startKey, endKey, textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    return TextSpan(
      text: toString(),
      style: textStyle?.copyWith(
        decoration: TextDecoration.underline,
      ),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          final data = {'content': toString()};
          if (onTap != null) onTap(data);
        },
    );
  }
}

class RegExpSpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  @override
  SpecialText createSpecialText(
    String flag, {
    TextStyle textStyle,
    SpecialTextGestureTapCallback onTap,
    int index,
  }) {
    if (isStart(flag, LinkText.startKey)) {
      return LinkText(textStyle, onTap);
    }
    return null;
  }
}
