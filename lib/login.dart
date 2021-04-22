import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'basicAuth.dart';
import 'url.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool _passwordVisible = true;
  bool checkValue = false;

  // Login API Method

  Future<dynamic> _loginuser() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      String user = username.text;
      String pass = password.text;
      final formData = jsonEncode({
        "primaryKeys": ["$user", "$pass"]
      });
      Response response =
          await ioClient.post(LOGIN_URL, headers: headers, body: formData);
      if (response.statusCode == 200) {
        Map<String, dynamic> list = json.decode(response.body);
        List<dynamic> userid = list["dataValue"];
        print('data $userid');
        if (list["dataValue"] != null && userid[0][0] != '0') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("username", userid[0][0]);
          prefs.setString("uname", userid[0][1]);
          prefs.setString("defaultUrl", userid[0][2]);
          prefs.setString("uatmessage", userid[0][3]);
          // if (userid[0][2] ==
          //     "https://uattamilnadu.dcservices.in/eUpkaran/EUpkaranComplaintACTION?hmode=CallMasterPage&masterkey=complaintRaise&isGlobal=1&seatId=20000001") {
          //   return Navigator.pushReplacementNamed(context, "/homecomplaint");
          // } else {
          return Navigator.pushReplacementNamed(context, "/homecomplaint");
          // }
        } else {
          return showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Color(0xffffffff),
                  title: Text("Please Enter Valid Username and Password",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xff000000))),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
      } else {
        throw Exception('Failed to load data');
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

  @override
  void initState() {
    super.initState();
    getCredential();
  }


// Get Store Value of particular User

  getCredential() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      checkValue = prefs.getBool("check");
      if (checkValue != null) {
        if (checkValue) {
          username.text = prefs.getString("username");
          password.text = prefs.getString("password");
        } else {
          username.clear();
          password.clear();
          prefs.clear();
        }
      } else {
        checkValue = false;
      }
    });
  }

  // Launcher Method
  _launchURL() async {
    const url = 'https://www.cdac.in/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Empty TextFields

  Widget _entryField(String title,
      {TextEditingController controller,
      IconButton suffixIcon,
      bool obscureText}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                fontFamily: 'Open Sans'),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            obscureText: obscureText,
            controller: controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                fillColor: Color(0xfff3f3f4),
                filled: true,
                suffixIcon: suffixIcon),
          ),
        ],
      ),
    );
  }

  // Submission Button
  
  Widget _submitButton() {
    return GestureDetector(
        onTap: () async {
          _loginuser();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              color: Color(0xff2d0e3e)),
          child: Text(
            'Login',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontFamily: 'Open Sans'),
          ),
        ));
  }

  _signUp() {
    print('hello World');
  }

  // Registration  Widget

  Widget _bottomRegistrationtitle() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 35,
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Don't have an account ",
                  style: TextStyle(
                      fontFamily: 'Open Sans', color: Color(0xff283643))),
              GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, "/signup");
                  },
                  // onTap: _signUp,
                  // onTap: _launchURL,
                  child: Text("Sign up",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue))),
            ],
          ),
          color: Colors.transparent,
        ));
  }
// Get Title Widget

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: new TextSpan(
        // Note: Styles for TextSpans must be explicitly defined.
        // Child text spans will inherit styles from parent
        style: new TextStyle(
          fontSize: 14.0,
          color: Colors.black,
        ),
        children: <TextSpan>[
          new TextSpan(
              text: 'Welcome To \n',
              style: TextStyle(
                  color: Color(0xff2d0e3e),
                  fontSize: 25,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.bold)),
          new TextSpan(
              text: 'EMMS ',
              style: new TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Open Sans',
                  color: Color(0xffC6426E))),
          new TextSpan(
              text: '| TNMSCL',
              style: new TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Open Sans',
                  color: Color(0xff2d0e3e))),
        ],
      ),
    );
    // return Text('Welcome to \ne-Upkaran | TNMSCL',
    //     textAlign: TextAlign.center,
    //     style: TextStyle(
    //         color: Color(0xff2d0e3e),
    //         fontSize: 25,
    //         fontFamily: 'Open Sans',
    //         fontWeight: FontWeight.w600));
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField(
          "Username",
          controller: username,
          obscureText: false,
        ),
        _entryField(
          "Password",
          controller: password,
          obscureText: _passwordVisible,
          suffixIcon: IconButton(
            icon: Icon(
              _passwordVisible ? Icons.visibility : Icons.visibility_off,
              color: Color(0xff2e1b3e),
            ),
            onPressed: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  // Main Screen 
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          new Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          height: 130.0,
                          width: 130.0,
                          // margin: const EdgeInsets.only(bottom:60),
                          child: new Image(
                            image: AssetImage("assets/images/tnmsclogo.png"),
                            fit: BoxFit.contain,
                          ),
                          // child: new Image(image: AssetImage("assets/images/img8.png"),fit: BoxFit.contain,),
                        ),
                        SizedBox(height: height * .001),
                        _title(),
                        SizedBox(height: 50),
                        _emailPasswordWidget(),
                        SizedBox(height: 15),
                        _submitButton(),
                        SizedBox(height: 10),
                        // _bottomRegistrationtitle()
                        // _divider(),
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
      // bottom footer app
      bottomSheet: Container(
        width: MediaQuery.of(context).size.width,
        height: 35,
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Designed & Developed by ',
                  style: TextStyle(
                      fontFamily: 'Open Sans', color: Color(0xff283643))),
              GestureDetector(
                  onTap: _launchURL,
                  child: Text("C-DAC",
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xffC6426E)))),
            ],
          ),
          color: Colors.transparent,
        ),
      ),
    );
  }
}
