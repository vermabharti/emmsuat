import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'url.dart';
import 'basicAuth.dart';
import 'idSearchAllDetails.dart';

class HomeComplaint extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<HomeComplaint> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController searchid = TextEditingController();
  String _id, qrCodeResult, _uatmsg;
  bool apiCall = false;
  ScaffoldState scaffold;

  // Get Eqiupment Detials

  Future<dynamic> _getEquipmentDetails() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _id = (prefs.getString('username') ?? "");

      final formData = jsonEncode({
        "primaryKeys": ["${searchid.text}"],
        "hospitalCode": "998",
        "seatId": '$_id'
      });

      Response response = await ioClient.post(EQUIPMENT_DETAILS,
          headers: headers, body: formData);

      Map<String, dynamic> equipmentlist = json.decode(response.body);
      if (equipmentlist["dataValue"] == null) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Color(0xffffffff),
                title: Text("No Details Available",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xff000000))),
                actions: <Widget>[
                  new FlatButton(
                      child: new Text("Close"),
                      onPressed: () => {Navigator.of(context).pop()}),
                ],
              );
            });
      } else {
        prefs.setString("prevoiusId", equipmentlist["dataValue"][0][17]);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViaIdSearch(
                  equipList: equipmentlist["dataValue"],
                  equipHeading: equipmentlist["dataHeading"],
                  institute: equipmentlist["dataValue"][0][1],
                  department: equipmentlist["dataValue"][0][2],
                  equipmentname: equipmentlist["dataValue"][0][3],
                  equipmentmodel: equipmentlist["dataValue"][0][4],
                  preId: equipmentlist["dataValue"][0][5],
                  // institute: equipmentlist["dataValue"][0][13],
                  // department: equipmentlist["dataValue"][0][14],
                  // equipmentname: equipmentlist["dataValue"][0][15],
                  // equipmentmodel: equipmentlist["dataValue"][0][16],
                  // preId: equipmentlist["dataValue"][0][17],
                  barcodeId: barcode)),
        );
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

// Scan Method
  String barcode = "";
  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      print('barcode===========> $barcode');
      // return Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => ViaBarcodeSearch(
      //             barcodeId: barcode,
      //           )),
      // );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _id = (prefs.getString('username') ?? "");

      final formData = jsonEncode({
        "primaryKeys": ["$barcode"],
        "hospitalCode": "998",
        "seatId": '$_id'
      });

      Response response = await ioClient.post(EQUIPMENT_DETAILS,
          headers: headers, body: formData);

      Map<String, dynamic> equipmentlist = json.decode(response.body);
      if (equipmentlist["dataValue"] == null) {
        return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Color(0xffffffff),
                title: Text("No Details Available",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xff000000))),
                actions: <Widget>[
                  new FlatButton(
                      child: new Text("Close"),
                      onPressed: () => {Navigator.of(context).pop()}),
                ],
              );
            });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViaIdSearch(
                  equipList: equipmentlist["dataValue"],
                  equipHeading: equipmentlist["dataHeading"],
                  institute: equipmentlist["dataValue"][0][1],
                  department: equipmentlist["dataValue"][0][2],
                  equipmentname: equipmentlist["dataValue"][0][3],
                  equipmentmodel: equipmentlist["dataValue"][0][4],
                  preId: equipmentlist["dataValue"][0][5],
                  barcodeId: barcode)),
        );
      }
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // print('@@##    $_uatmsg');
    // '$_uatmsg' == ''
    //     ? Text('')
    //     : WidgetsBinding.instance.addPostFrameCallback((_) => showSnackBar());
  }

  // void showSnackBar() {
  //   var snackBar = SnackBar(
  //     content: Text('You are using UAT App'),
  //     duration: Duration(seconds: 30),
  //     action: SnackBarAction(
  //       label: 'cancel',
  //       onPressed: () {},
  //     ),
  //   );
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  @override
  Widget build(BuildContext context) {
    // Main Screen
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: SingleChildScrollView(
              child: Column(children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: Color(0xff65dad1),
            child: Center(
                child: Text(
              'Complaint Raise',
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Color(0xff2d0e3e),
                  fontFamily: 'Open Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ))),
        Card(
            margin: EdgeInsets.all(10),
            child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black, width: 2.0),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.grey[300],
                      blurRadius: 3.0,
                      offset: new Offset(0.0, 3.0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Search Equipment',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Color(0xff2d0e3e),
                          fontFamily: 'Open Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                    Form(
                      key: _formKey,
                      child: Container(
                        margin: EdgeInsets.all(20),
                        child: new Row(
                          children: <Widget>[
                            new Flexible(
                              child: new TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Id is Mandatory';
                                  } else
                                    return null;
                                },
                                controller: searchid,
                                decoration: const InputDecoration(
                                    helperText: "Enter Unique ID"),
                                // style: Theme.of(context).textTheme.body1,
                              ),
                            ),
                            new Container(
                              width: 70,
                              height: 30,
                              margin: EdgeInsets.only(left: 10),
                              child: RaisedButton(
                                  padding: const EdgeInsets.all(8.0),
                                  textColor: Colors.white,
                                  color: Color(0xff34a853),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      _formKey.currentState.save();
                                      setState(() {
                                        apiCall = true;
                                      });
                                      _getEquipmentDetails();
                                    }
                                  },
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("GO"),
                                      Icon(Icons.arrow_forward_ios, size: 11)
                                    ],
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    FlatButton(onPressed: null, child: Text('OR')),
                    RaisedButton(
                        onPressed: scan,
                        padding: const EdgeInsets.all(8.0),
                        textColor: Colors.white,
                        color: Color(0xff34a853),
                        child: Container(
                            width: 150,
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.scanner, size: 16),
                                Text(" Scan QR Code"),
                              ],
                            ))))
                  ],
                ))),
      ]))),
    );
  }
}
