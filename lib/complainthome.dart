import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'url.dart';
import 'webView.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'homecomplaint.dart';
import 'basicAuth.dart';

class Dish {
  final String name;
  final String icon;
  Dish({this.name, this.icon});
}

class ComplaintHomePage extends StatefulWidget {
  final String arguments, userN;
  ComplaintHomePage({Key key, @required this.arguments, @required this.userN})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new StateHomePage();
}

class StateHomePage extends State<ComplaintHomePage> {
  String _id, rolename, defaulturl, seatId, agr, tit, menulength;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;
  bool _enabled = false;
  bool _complaint = false;
  SharedPreferences prefs;
  Future _getMenuItems;

//Get Menu Method
  Future _getMainMenu() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _id = (prefs.getString('username') ?? "");
      final formData = jsonEncode({
        "primaryKeys": ['$_id']
      });
      Response response =
          await ioClient.post(MENU_URL, headers: headers, body: formData);
      if (response.statusCode == 200) {
        Map<String, dynamic> list = json.decode(response.body);
        List<dynamic> userid = list["dataValue"];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("useridLength", userid.length.toString());
        print('object ${userid.length.toString()} $userid +++ ');
        return userid;
      } else {
        throw Exception('Failed to load Menu');
      }
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xffffffff),
              title: Text("Please Check your Internet Connection",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xff000000))),
            );
          });
    }
  }

  // Static Menu List

  List<Dish> _dishes = List<Dish>();
  void _populateDishes() {
    var list = <Dish>[
      Dish(
        name: 'Web Based Open Source Platform',
        icon: 'globe',
      ),
      Dish(name: 'Compliant to Health Standards', icon: 'hospital'),
      Dish(name: 'Payment Online/Offline', icon: 'rupee-sign'),
      Dish(name: 'Dashboard and Report', icon: 'chart-pie'),
      Dish(name: 'Alert Management', icon: 'bell'),
      Dish(name: 'Mobile Apps.', icon: 'mobile-alt'),
    ];
    setState(() {
      _dishes = list;
    });
  }

  // Icon Method

  IconData getIconForName(String iconName) {
    switch (iconName) {
      case 'globe':
        {
          return FontAwesomeIcons.globe;
        }
        break;
      case 'hospital':
        {
          return FontAwesomeIcons.hospital;
        }
        break;
      case 'rupee-sign':
        {
          return FontAwesomeIcons.rupeeSign;
        }
        break;
      case 'bell':
        {
          return FontAwesomeIcons.bell;
        }
        break;
      case 'chart-pie':
        {
          return FontAwesomeIcons.chartPie;
        }
        break;
      default:
        {
          return FontAwesomeIcons.mobileAlt;
        }
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loadData();
    });
    _populateDishes();
    _getMenuItems = _getMainMenu();
  }

  // Get Store values of User

  loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rolename = (prefs.getString('uname') ?? "");
      _id = (prefs.getString('username') ?? "");
      defaulturl = (prefs.getString('defaultUrl') ?? "");
      menulength = (prefs.getString('useridLength') ?? "");
    });
  }

  final key = UniqueKey();

  @override
  // Main Screen
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Welcome to Flutter',
        home: Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(color: Color(0xff2d0e3e)),
              backgroundColor: Color(0xffffffff),
              title: Row(
                children: [
                  Container(
                    height: 35.0,
                    width: 35.0,
                    margin: EdgeInsets.only(right: 5),
                    child: new Image(
                      image: AssetImage("assets/images/tnmsclogo.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                  RichText(
                    text: new TextSpan(
                      // Note: Styles for TextSpans must be explicitly defined.
                      // Child text spans will inherit styles from parent
                      style: new TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                      children: <TextSpan>[
                        new TextSpan(
                            text: 'EMMS ',
                            style: new TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Open Sans',
                                color: Color(0xffC6426E))),
                        new TextSpan(
                            text: '| TNMSCL',
                            style: new TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Open Sans',
                                color: Color(0xff2d0e3e))),
                      ],
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                // IconButton(
                //   icon: Icon(Icons.home),
                //   onPressed: () {
                //     Navigator.popAndPushNamed(context, '/home');
                //   },
                // ),
                // IconButton(
                //   icon: Icon(Icons.exit_to_app),
                //   onPressed: () async {
                //     SharedPreferences prefs =
                //         await SharedPreferences.getInstance();
                //     prefs.remove("username");
                //     prefs.remove("password");
                //     Navigator.pushReplacementNamed(context, "/login");
                //   },
                // ),
              ],
            ),

            // SideBar  Drawer
            
            drawer: Drawer(
                child: Column(children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 120,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Color(0xff2d0e3e)),
                  child: Text("Welcome, $rolename",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 18)),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: new FutureBuilder(
                      future: _getMenuItems,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return new Center(
                            child: new Column(
                              children: <Widget>[
                                new Padding(padding: new EdgeInsets.all(50.0)),
                                new Center(child: CircularProgressIndicator())
                              ],
                            ),
                          );
                        } else if (snapshot.data.length == 0) {
                          return Text("No Data found",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontFamily: 'Open Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 26));
                        } else {
                          List<dynamic> posts = snapshot.data;
                          List menuList = posts.map((f) {
                            return f[0];
                          }).toList();
                          return Container(
                              child: ListView(
                            children: <Widget>[
                              // ignore: unrelated_type_equality_checks
                              // '$rolename' == 'silverline' ||
                              //         '$rolename' == 'HQ TNMSCL' ||
                              //         '$rolename' == 'Manohar' ||
                              //         '$rolename' == 'Deepak' ||
                              //         '$rolename' == 'Abhishek Verma'
                              //     ? ListTile(
                              //         title: Column(
                              //         children: posts.map((value) {
                              //           return GestureDetector(
                              //               onTap: () {
                              //                 if (value[1] ==
                              //                     'Complaint Raise') {
                              //                   setState(() {
                              //                     _enabled = false;
                              //                     _complaint = true;
                              //                   });
                              //                   Navigator.popAndPushNamed(
                              //                       context, '/home');
                              //                 } else {
                              //                   setState(() {
                              //                     _enabled = true;
                              //                     agr = value[2];
                              //                     tit = value[1];
                              //                     });
                              //                   Navigator.popAndPushNamed(
                              //                       context, '/home');
                              //                 }
                              //               },
                              //               child: Container(
                              //                   alignment: Alignment.topLeft,
                              //                   padding: EdgeInsets.all(10),
                              //                   child: Text(
                              //                     value[1],
                              //                     textAlign: TextAlign.left,
                              //                     style: TextStyle(
                              //                       fontSize: 15,
                              //                       color: Color(0xff2c003e),
                              //                       fontFamily: 'Open Sans',
                              //                     ),
                              //                   )));
                              //         }).toList(),
                              //       ))
                              //     :
                              '$menulength' == '6'
                                  // '$rolename' == 'emmsadmin'
                                  //  || '$rolename' == 'Demonstration User'
                                  ? Column(children: [
                                      menuList.contains('Procurement') == true
                                          ? ExpansionTile(
                                              title: Text('Procurement',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Color(0xff2c003e),
                                                      fontFamily: 'Open Sans')),
                                              children: posts.map((value) {
                                                return value[0] == 'Procurement'
                                                    ? GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            _enabled = true;
                                                            agr = value[2];
                                                            tit = value[1];
                                                          });
                                                          Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/home');
                                                          // Navigator.of(context)
                                                          //     .popAndPushNamed(
                                                          //         '/webpage',
                                                          //         arguments: UrlWebView(
                                                          //           url: value[2],
                                                          //           title: value[1],
                                                          //         ));
                                                          //       '/webpage', {
                                                          // url: value[2],
                                                          // title: value[1]
                                                        },
                                                        child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                              value[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff2c003e),
                                                                fontFamily:
                                                                    'Open Sans',
                                                              ),
                                                            )))
                                                    : Container();
                                              }).toList(),
                                            )
                                          : Container(),
                                      menuList.contains('Inventory') == true
                                          ? ExpansionTile(
                                              title: Text('Inventory',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Color(0xff2c003e),
                                                      fontFamily: 'Open Sans')),
                                              children: posts.map((value) {
                                                return value[0] == 'Inventory'
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _enabled = true;
                                                            agr = value[2];
                                                            tit = value[1];
                                                          });
                                                          Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/home');
                                                        },
                                                        child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                              value[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff2c003e),
                                                                fontFamily:
                                                                    'Open Sans',
                                                              ),
                                                            )))
                                                    : Container();
                                              }).toList(),
                                            )
                                          : Container(),
                                      menuList.contains('Maintenance Mgmt') ==
                                              true
                                          ? ExpansionTile(
                                              title: Text('Mantenance Mgmt',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Color(0xff2c003e),
                                                      fontFamily: 'Open Sans')),
                                              children: posts.map((value) {
                                                return value[0] ==
                                                        'Maintenance Mgmt'
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _enabled = true;
                                                            agr = value[2];
                                                            tit = value[1];
                                                          });
                                                          Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/home');
                                                        },
                                                        child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                              value[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff2c003e),
                                                                fontFamily:
                                                                    'Open Sans',
                                                              ),
                                                            )))
                                                    : Container();
                                              }).toList(),
                                            )
                                          : Container(),
                                      menuList.contains('Complaint') == true
                                          ? ExpansionTile(
                                              title: Text('Complaint',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Color(0xff2c003e),
                                                      fontFamily: 'Open Sans')),
                                              children: posts.map((value) {
                                                return value[0] == 'Complaint'
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          if (value[1] ==
                                                              'Complaint Raise') {
                                                            setState(() {
                                                              _enabled = false;
                                                              _complaint = true;
                                                            });
                                                            Navigator
                                                                .popAndPushNamed(
                                                                    context,
                                                                    '/home');
                                                          } else {
                                                            setState(() {
                                                              _enabled = true;
                                                              agr = value[2];
                                                              tit = value[1];
                                                            });
                                                            Navigator
                                                                .popAndPushNamed(
                                                                    context,
                                                                    '/home');
                                                            // Navigator.push(
                                                            //     context,
                                                            //     MaterialPageRoute(
                                                            //         builder: (context) =>
                                                            //             UrlWebView(
                                                            //                 url: value[
                                                            //                     2],
                                                            //                 title: value[
                                                            //                     1])));
                                                          }
                                                        },
                                                        child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                              value[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff2c003e),
                                                                fontFamily:
                                                                    'Open Sans',
                                                              ),
                                                            )))
                                                    : Container();
                                              }).toList(),
                                            )
                                          : Container(),
                                      menuList.contains('Financial') == true
                                          ? ExpansionTile(
                                              title: Text('Financial',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Color(0xff2c003e),
                                                      fontFamily: 'Open Sans')),
                                              children: posts.map((value) {
                                                return value[0] == 'Financial'
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _enabled = true;
                                                            agr = value[2];
                                                            tit = value[1];
                                                          });
                                                          Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/home');
                                                        },
                                                        child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                              value[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff2c003e),
                                                                fontFamily:
                                                                    'Open Sans',
                                                              ),
                                                            )))
                                                    : Container();
                                              }).toList(),
                                            )
                                          : Container(),
                                      menuList.contains('Setup') == true
                                          ? ExpansionTile(
                                              title: Text('Setup',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Color(0xff2c003e),
                                                      fontFamily: 'Open Sans')),
                                              children: posts.map((value) {
                                                return value[0] == 'Setup'
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _enabled = true;
                                                            agr = value[2];
                                                            tit = value[1];
                                                          });
                                                          Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/home');
                                                        },
                                                        child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                              value[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff2c003e),
                                                                fontFamily:
                                                                    'Open Sans',
                                                              ),
                                                            )))
                                                    : Container();
                                              }).toList(),
                                            )
                                          : Container(),
                                      menuList.contains('Reports') == true
                                          ? ExpansionTile(
                                              title: Text('Reports',
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      color: Color(0xff2c003e),
                                                      fontFamily: 'Open Sans')),
                                              children: posts.map((value) {
                                                return value[0] == 'Reports'
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _enabled = true;
                                                            agr = value[2];
                                                            tit = value[1];
                                                          });
                                                          Navigator
                                                              .popAndPushNamed(
                                                                  context,
                                                                  '/home');
                                                        },
                                                        child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Text(
                                                              value[1],
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: Color(
                                                                    0xff2c003e),
                                                                fontFamily:
                                                                    'Open Sans',
                                                              ),
                                                            )))
                                                    : Container();
                                              }).toList(),
                                            )
                                          : Container()
                                    ])
                                  : ListTile(
                                      title: Column(
                                      children: posts.map((value) {
                                        return GestureDetector(
                                            onTap: () {
                                              if (value[1] ==
                                                  'Complaint Raise') {
                                                setState(() {
                                                  _enabled = false;
                                                  _complaint = true;
                                                });
                                                Navigator.popAndPushNamed(
                                                    context, '/home');
                                              } else {
                                                setState(() {
                                                  _enabled = true;
                                                  agr = value[2];
                                                  tit = value[1];
                                                });
                                                Navigator.popAndPushNamed(
                                                    context, '/home');
                                              }
                                            },
                                            child: Container(
                                                alignment: Alignment.topLeft,
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                  value[1],
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xff2c003e),
                                                    fontFamily: 'Open Sans',
                                                  ),
                                                )));
                                      }).toList(),
                                    ))
                            ],
                          ));
                        }
                      })),
              ListTile(
                leading: Icon(Icons.exit_to_app, color: Color(0xff2d0e3e)),
                title: Text('Logout',
                    style: TextStyle(
                        color: Color(0xff2d0e3e),
                        fontSize: 16,
                        fontFamily: 'Open Sans',
                        fontWeight: FontWeight.w600)),
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.remove("username");
                  prefs.remove("password");
                  Navigator.pushReplacementNamed(context, "/login");
                },
              )
            ])),
            body: '$defaulturl' ==
                    'https://tnmscemms.prd.dcservices.in/eUpkaran/EUpkaranComplaintACTION?hmode=CallMasterPage&masterkey=complaintRaise&isGlobal=1&seatId=$_id'
                ? _enabled
                    ? Container(
                        child: UrlWebView(url: agr, title: tit),
                      )
                    : _complaint
                        ? Container(child: HomeComplaint())
                        : Container(child: HomeComplaint())
                : Center(
                    child: Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height -
                            0.1 * MediaQuery.of(context).size.height,
                        child: ListView(children: <Widget>[
                          SizedBox(
                              height: 900,
                              child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                itemCount: _dishes.length,
                                itemBuilder: (context, index) {
                                  var item = _dishes[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 8.0,
                                    ),
                                    child: Card(
                                        color: Color(0xffeeeeee),
                                        elevation: 4.0,
                                        child: IntrinsicHeight(
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 10, bottom: 10),
                                                    child: Column(children: [
                                                      IconButton(
                                                          iconSize: 45,
                                                          icon: Icon(
                                                              getIconForName(
                                                                  item.icon),
                                                              color: Color(
                                                                  0xffC6426E)),
                                                          onPressed:
                                                              () async {}),
                                                      Container(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  20, 5, 10, 5),
                                                          child: Text(
                                                            item.name,
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0xff2c003e),
                                                                fontFamily:
                                                                    'Open Sans',
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          )),
                                                    ])),
                                              ),
                                            ]))),
                                  );
                                },
                              )),
                        ])),
                  )));
  }
}
 
