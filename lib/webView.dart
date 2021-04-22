import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Webview Page with Title/Url

class UrlWebView extends StatefulWidget {
  final String url;
  final String title;
  UrlWebView({Key key, @required this.url, @required this.title})
      : super(key: key);

  @override
  _MyPageState createState() => new _MyPageState();
}

class _MyPageState extends State<UrlWebView> {
  num position = 1;
  String webUrl = "", webTitle = "", url;
  SharedPreferences prefs;
  WebViewController controller;

  final key = UniqueKey();

  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  @override
  // Update the Url controller while build method is called....

  void didUpdateWidget(covariant UrlWebView oldWidget) {
    if (controller != null)
      setState(() {
        controller.loadUrl(widget.url);
      });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.clearCache();
    super.dispose();
  }

  getInitialData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      webTitle = prefs.getString("title");
      webUrl = prefs.getString("url");
    });
  }

  doneLoading(String A) {
    setState(() {
      position = 0;
    });
  }

  startLoading(String A) {
    setState(() {
      position = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Main Webview screen

    return new Scaffold(
        backgroundColor: Color(0xffffffff),
        body: IndexedStack(index: position, children: <Widget>[
          WebView(
            onWebViewCreated: (WebViewController webViewController) {
              setState(() {
                controller = webViewController;
              });
              print(webViewController.getTitle().toString() + "=-=-=-=-");
            },
            initialUrl: "${widget.url}",
            javascriptMode: JavascriptMode.unrestricted,
            key: key,
            onPageFinished: doneLoading,
            onPageStarted: startLoading,
          ),
          Container(
            color: Colors.white,
            child: Center(child: CircularProgressIndicator()),
          ),
        ]));
  }
}
