import 'dart:async';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'url.dart';
import 'basicAuth.dart';

class ViaIdSearch extends StatefulWidget {
  // fetching the data from previous widget
  final List equipList;
  final List equipHeading;
  final String preId;
  final String institute;
  final String department;
  final String equipmentname;
  final String equipmentmodel;
  final String barcodeId;
  ViaIdSearch(
      {Key key,
      @required this.equipList,
      @required this.equipHeading,
      @required this.preId,
      @required this.institute,
      @required this.department,
      @required this.equipmentname,
      @required this.equipmentmodel,
      @required this.barcodeId})
      : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

TextStyle textstyle = TextStyle(
    fontSize: 16,
    color: Color(0xffC6426E),
    fontWeight: FontWeight.w600,
    fontFamily: 'Open Sans');

TextStyle datastyle = TextStyle(
    fontSize: 16,
    color: Color(0xff000000),
    fontWeight: FontWeight.w600,
    fontFamily: 'Open Sans');

TextStyle headingstyle = TextStyle(
    fontSize: 22,
    color: Color(0xff000000),
    fontWeight: FontWeight.w600,
    fontFamily: 'Open Sans');

class _MyPageState extends State<ViaIdSearch> {
  String _id,
      _equipid,
      _depid,
      _instid,
      _selectedValue,
      _problemId,
      selectedContactName,
      selectedSolName,
      _switchWorking,
      _contactId,
      _value;
  bool _switchValue = false;
  List<dynamic> listtt = ['1', 'other'];
  final TextEditingController otherProblemName = TextEditingController();
  final TextEditingController otherContactName = TextEditingController();
  final TextEditingController otherContactMobileNo = TextEditingController();
  final TextEditingController otherContactEmail = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // Current Date Method

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2010, 1),
        lastDate: DateTime(2100));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  // Current Time Method

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  // Active Complaint Method

  Future<dynamic> _getActiveComplaintDetails() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _id = (prefs.getString('username') ?? "");

      final formData = jsonEncode({
        "primaryKeys": ["${widget.preId}"],
        "hospitalCode": "998",
        "seatId": '$_id'
      });

      Response response = await ioClient.post(ACTIVE_COMPLAINT,
          headers: headers, body: formData);

      Map<String, dynamic> list = json.decode(response.body);
      List<dynamic> activelist = list["dataValue"];
      return activelist;
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

  // Problem Descrption Method

  Future<List<dynamic>> _getProblemDescriptionName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = (prefs.getString('username') ?? "");
    _equipid = (prefs.getString('equipmentName') ?? "");
    final formData = jsonEncode({
      "primaryKeys": ["${widget.equipmentname}"],
      "hospitalCode": "998",
      "seatId": '$_id'
    });
    Response response = await ioClient.post(PROBLEM_DESCRIPTION,
        headers: headers, body: formData);

    Map<String, dynamic> list = json.decode(response.body);
    List<dynamic> userid = list["dataValue"];
    if (userid == null) {
      return [listtt];
    } else {
      return userid + [listtt];
    }
  }

  // Problem Solution Method

  Future<List<dynamic>> _getContactName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = (prefs.getString('username') ?? "");
    _depid = (prefs.getString('department') ?? "");
    _instid = (prefs.getString('institution') ?? "");

    final formData = jsonEncode({
      "primaryKeys": ["${widget.institute}", "${widget.department}"],
      "hospitalCode": "998",
      "seatId": '$_id'
    });
    List<dynamic> listtt = ['1', 'other'];
    Response response =
        await ioClient.post(CONTACT_PERSON, headers: headers, body: formData);

    Map<String, dynamic> list = json.decode(response.body);
    List<dynamic> userid = list["dataValue"];
    if (userid == null) {
      return [listtt];
    } else {
      return userid + [listtt];
    }
    // ;
    // print('ghhghghgh $userid');
    // return userid;
  }

  // Problem Solution Method

  Future<List<dynamic>> _getProblemSolutionName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = (prefs.getString('username') ?? "");
    final formData = jsonEncode({
      "primaryKeys": ["${_problemId.toString()}"],
      "hospitalCode": "998",
      "seatId": '$_id'
    });
    Response response =
        await ioClient.post(PROBELM_SOLUTION, headers: headers, body: formData);

    Map<String, dynamic> list = json.decode(response.body);
    List<dynamic> userid = list["dataValue"];
    return userid;
  }

  // Saved Complaint Method

  Future _savedComplaint() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = (prefs.getString('username') ?? "");
    String workingDate, workingTime, _selectproblem, _mobile, _email;
    String month;
    switch (selectedDate.month) {
      case 1:
        month = "Jan";
        break;
      case 2:
        month = "Feb";
        break;
      case 3:
        month = "Mar";
        break;
      case 4:
        month = "Apr";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "Jun";
        break;
      case 7:
        month = "Jul";
        break;
      case 8:
        month = "Aug";
        break;
      case 9:
        month = "Sep";
        break;
      case 10:
        month = "Oct";
        break;
      case 11:
        month = "Nov";
        break;
      case 12:
        month = "Dec";
        break;
    }

    workingDate =
        '${selectedDate.day.toString().padLeft(2, '0')}-$month-${selectedDate.year.toString()}';
    workingTime =
        '${selectedTime.hour}:${selectedTime.minute}:${selectedTime.hour}';
    String otherProblem = otherProblemName.text;
    String otherContact = otherContactName.text;
    String othermobile = otherContactMobileNo.text;
    String otheremail = otherContactEmail.text;

    if (_switchValue == true) {
      _switchWorking = '1';
    } else if (_switchValue == false) {
      _switchWorking = '0';
      workingDate = '';
      workingTime = '';
    }

    if (_selectedValue == '$_selectedValue') {
      _selectproblem = '$_selectedValue';
    } else {
      _selectproblem = '1';
    }

    if (selectedContactName != '1') {
      _mobile = '${selectedContactName.split("^")[1]}';
      _email = '${selectedContactName.split("^")[2]}';
    } else if (selectedContactName == '1') {
      _mobile = otherContactMobileNo.text;
      _email = otherContactEmail.text;
    }
    final formData = jsonEncode({
      "modeFordata": "ADD",
      "hospitalCode": "998",
      "seatId": '$_id',
      "inputDataJson":
          "{\"uniqueEquipmentId\":\"${widget.equipList[0][9]}\",\"problemDescription\":\"$_selectproblem\",\"fieldForOherProblemDescription\":\"$otherProblem\",\"contactPerson\":\"$_contactId\",\"fieldForOherContactPerson\":\"$otherContact\",\"mobileNo\":\"$_mobile\",\"emailId\":\"$_email\",\"Remarks\":\"done\",\"uploadDocument\":\"\",\"workingCondition\":\"$_switchWorking\",\"notWorkingDate\":\"$workingDate\",\"Time\":\"$workingTime\",\"pkComplaintStatus\":\"0\",\"equipmentName\":\"${widget.equipmentname}\",\"equipmentModel\":\"${widget.equipmentmodel}\",\"reqTypeId\":\"1\",\"reqMode\":\"2\",\"reqId\":\"0\",\"institutionName\":\"${widget.institute}\",\"departmentName\":\"${widget.department}\",\"fileUploadFlag\":\"0\"}"
    });
    print('save complaint $formData');

    Response response =
        await ioClient.post(SAVING_COMPLAINT, headers: headers, body: formData);
    Map<String, dynamic> list = json.decode(response.body);
    String listsuccess = '$list';
    String newList = listsuccess.replaceAll(RegExp(r"[^\s\w]+"), "");
    if (response.statusCode == 200 &&
        '$list' != ' {"msg":"ERROR: Problem while saving records!"} ') {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xffffffff),
              title: Text(
                  "Complaint Raised successfully. Complaint No. - ${newList.split(' ')[8]}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xff000000))),
              actions: [
                new FlatButton(
                  child: new Text("OK"),
                  onPressed: () =>
                      Navigator.popAndPushNamed(context, '/homecomplaint'),
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => SearchSection())),
                ),
              ],
            );
          });
    } else {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xffffffff),
              title: Text("Error in saving complaints",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xff000000))),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
    }
  }

  selectedData(value) {
    setState(() {
      _selectedValue = value;
      _problemId = _selectedValue;
    });
  }

  selectedComtactData(value) {
    setState(() {
      selectedContactName = value;
      _contactId = selectedContactName;
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _textfiled() {
    return new Container(
        margin: EdgeInsets.all(4),
        // padding: EdgeInsets.all(1),
        child: TextFormField(
          validator: (value) {
            if (value.isEmpty) {
              return 'Enter Problem';
            }
            return null;
          },
          obscureText: false,
          controller: otherProblemName,
          // onTap: selectedData,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 25.0, 0.0),
              hintText: "Enter Problem Description *",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(4.0))),
        ));
  }

  // Default TextFields

  Widget _contactTextfield() {
    return new Column(
      children: [
        Container(
            margin: EdgeInsets.all(4),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Contact';
                }
                return null;
              },
              obscureText: false,
              controller: otherContactName,
              // onTap: selectedData,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 25.0, 0.0),
                  hintText: "Contact Name *",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0))),
            )),
        Container(
            margin: EdgeInsets.all(4),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Mobile No. (digits only)';
                }
                return null;
              },
              obscureText: false,
              controller: otherContactMobileNo,
              // onTap: selectedData,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 25.0, 0.0),
                  hintText: "Mobile no *",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0))),
            )),
        Container(
            margin: EdgeInsets.all(4),
            child: TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Enter Email';
                }
                return null;
              },
              obscureText: false,
              controller: otherContactEmail,
              // onTap: selectedData,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 25.0, 0.0),
                  hintText: "Email Id *",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0))),
            ))
      ],
    );
  }

  final _formKey = GlobalKey<FormState>();
  Future future, contact;

  @override
  void initState() {
    future = _getActiveComplaintDetails();
    _getProblemDescriptionName();
    contact = _getContactName();
    print("${widget.equipHeading}");
    print("${widget.equipList}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // main Page
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
              title: Text('Complaint Raise'),
              backgroundColor: Color(0xff2d0e3e)),
          body: Container(
            margin: EdgeInsets.all(10),
            child: ListView(children: <Widget>[
              // Equipment Details
              Container(
                  child: Column(children: [
                Container(
                    margin: EdgeInsets.all(10),
                    child: Text('Equipment Details', style: headingstyle)),
                Card(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[6]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][6]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[7]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][7]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[8]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][8]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[9]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][9]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[10]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][10]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[11]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][11]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[12]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][12]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[13]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][13]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[14]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][14]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[15]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][15]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(2),
                                child: RichText(
                                  text: TextSpan(
                                      text: '${widget.equipHeading[16]} : ',
                                      style: datastyle,
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' ${widget.equipList[0][16]}',
                                            style: textstyle),
                                      ]),
                                ),
                              ),
                              // Container(
                              //   margin: EdgeInsets.all(2),
                              //   child: RichText(
                              //     text: TextSpan(
                              //         text: '${widget.equipHeading[11]} : ',
                              //         style: datastyle,
                              //         children: <TextSpan>[
                              //           TextSpan(
                              //               text: '${widget.equipList[0][11]}',
                              //               style: textstyle),
                              //         ]),
                              //   ),
                              // ),
                            ]))),
              ])),
              '${widget.preId}' != '0'
                  ?
                  // Complaint Raise Form
                  Container(
                      child: Column(
                        children: [
                          Container(
                              child: FutureBuilder<dynamic>(
                            future: future, // async work
                            builder: (BuildContext context,
                                AsyncSnapshot<dynamic> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Text('Loading....');
                                default:
                                  if (snapshot.hasError)
                                    return Text('Error: ${snapshot.error}');
                                  else if (snapshot.data == null)
                                    return Container(
                                        child: Column(children: [
                                      Container(
                                          margin: EdgeInsets.all(10),
                                          child: Text(
                                            'Complaint Details',
                                            style: headingstyle,
                                          )),
                                      Card(
                                          child: Container(
                                              padding: EdgeInsets.all(10),
                                              child: Form(
                                                  key: _formKey,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Container(margin:EdgeInsets.all(4),
                                                        //                   child: Text('All fields are Mandatory', style: TextStyle(color:Colors.red))
                                                        //                 ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.all(2),
                                                          child: RichText(
                                                            text: TextSpan(
                                                                text:
                                                                    'Vender Name',
                                                                style:
                                                                    datastyle,
                                                                children: <
                                                                    TextSpan>[
                                                                  TextSpan(
                                                                      text: '*',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .red,
                                                                          fontSize:
                                                                              16.0)),
                                                                  TextSpan(
                                                                      text:
                                                                          ' ${widget.equipList[0][17]}',
                                                                      style:
                                                                          textstyle),
                                                                ]),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .fromLTRB(
                                                                  2, 15, 2, 1),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(2),
                                                                child: RichText(
                                                                  text: TextSpan(
                                                                      text:
                                                                          'Problem Description',
                                                                      style:
                                                                          datastyle,
                                                                      children: <
                                                                          TextSpan>[
                                                                        TextSpan(
                                                                            text:
                                                                                '*',
                                                                            style:
                                                                                TextStyle(color: Colors.red, fontSize: 16.0)),
                                                                      ]),
                                                                ),
                                                              ),
                                                              FutureBuilder<
                                                                      List<
                                                                          dynamic>>(
                                                                  future:
                                                                      _getProblemDescriptionName(),
                                                                  builder: (BuildContext
                                                                          context,
                                                                      AsyncSnapshot<
                                                                              List<dynamic>>
                                                                          snapshot) {
                                                                    if (!snapshot
                                                                            .hasData ||
                                                                        snapshot.data ==
                                                                            null) {
                                                                      return Container();
                                                                      // Center(child: CircularProgressIndicator())

                                                                    } else {
                                                                      return Container(
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        margin:
                                                                            EdgeInsets.all(4),
                                                                        padding:
                                                                            EdgeInsets.all(7.0),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(4.0),
                                                                            border: Border.all(color: Colors.grey)),
                                                                        child:
                                                                            DropdownButtonHideUnderline(
                                                                          child:
                                                                              new DropdownButton<dynamic>(
                                                                            hint:
                                                                                new Text("Select Problem"),
                                                                            value:
                                                                                _selectedValue,
                                                                            isDense:
                                                                                true,
                                                                            onChanged:
                                                                                selectedData,
                                                                            items:
                                                                                snapshot.data.map((map) {
                                                                              return new DropdownMenuItem<dynamic>(
                                                                                  value: map[0],
                                                                                  child: new Container(
                                                                                    width: 200,
                                                                                    child: Text(map[1], overflow: TextOverflow.fade, style: new TextStyle(color: Colors.black)),
                                                                                  ));
                                                                            }).toList(),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }
                                                                  }),
                                                              _selectedValue ==
                                                                      '1'
                                                                  ? _textfiled()
                                                                  : Container()
                                                            ],
                                                          ),
                                                        ),
                                                        _selectedValue ==
                                                                    null ||
                                                                _selectedValue ==
                                                                    '1'
                                                            ? new Container()
                                                            : Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        2,
                                                                        0,
                                                                        2,
                                                                        15),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      margin: EdgeInsets
                                                                          .all(
                                                                              2),
                                                                      child:
                                                                          RichText(
                                                                        text: TextSpan(
                                                                            text:
                                                                                'Problem Solution',
                                                                            style:
                                                                                datastyle,
                                                                            children: <TextSpan>[
                                                                              TextSpan(text: '*', style: TextStyle(color: Colors.red, fontSize: 16.0)),
                                                                            ]),
                                                                      ),
                                                                    ),
                                                                    FutureBuilder<
                                                                            List<
                                                                                dynamic>>(
                                                                        future:
                                                                            _getProblemSolutionName(),
                                                                        builder: (BuildContext
                                                                                context,
                                                                            AsyncSnapshot<List<dynamic>>
                                                                                snapshot) {
                                                                          if (!snapshot
                                                                              .hasData) {
                                                                            return Container();
                                                                          } else {
                                                                            return Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              margin: EdgeInsets.all(4),
                                                                              padding: EdgeInsets.all(7.0),
                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), border: Border.all(color: Colors.grey)),
                                                                              child: DropdownButtonHideUnderline(
                                                                                child: new DropdownButton<dynamic>(
                                                                                  hint: new Text("Select Problem Solution"),
                                                                                  value: selectedSolName,
                                                                                  isDense: true,
                                                                                  onChanged: (newValue) {
                                                                                    setState(() {
                                                                                      selectedSolName = newValue;
                                                                                    });
                                                                                  },
                                                                                  items: snapshot.data.map((map) {
                                                                                    return new DropdownMenuItem<dynamic>(
                                                                                        value: map[0],
                                                                                        child: new Container(
                                                                                          width: 200,
                                                                                          child: Text(map[0], overflow: TextOverflow.fade, style: new TextStyle(color: Colors.black)),
                                                                                        ));
                                                                                  }).toList(),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }
                                                                        })
                                                                  ],
                                                                ),
                                                              ),
                                                        Container(
                                                          margin: EdgeInsets
                                                              .fromLTRB(
                                                                  2, 5, 2, 4),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(2),
                                                                child: RichText(
                                                                  text: TextSpan(
                                                                      text:
                                                                          'Contact Person',
                                                                      style:
                                                                          datastyle,
                                                                      children: <
                                                                          TextSpan>[
                                                                        TextSpan(
                                                                            text:
                                                                                '*',
                                                                            style:
                                                                                TextStyle(color: Colors.red, fontSize: 16.0)),
                                                                      ]),
                                                                ),
                                                              ),
                                                              FutureBuilder<
                                                                      List<
                                                                          dynamic>>(
                                                                  future:
                                                                      contact,
                                                                  builder: (BuildContext
                                                                          context,
                                                                      AsyncSnapshot<
                                                                              List<dynamic>>
                                                                          snapshot) {
                                                                    if (!snapshot
                                                                            .hasData ||
                                                                        snapshot.data ==
                                                                            null) {
                                                                      return Container();
                                                                    } else {
                                                                      return Container(
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                            Container(
                                                                              width: MediaQuery.of(context).size.width,
                                                                              margin: EdgeInsets.all(4),
                                                                              padding: EdgeInsets.all(7.0),
                                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), border: Border.all(color: Colors.grey)),
                                                                              child: DropdownButtonHideUnderline(
                                                                                child: new DropdownButton<dynamic>(
                                                                                  hint: new Text("Select Contact Name"),
                                                                                  value: selectedContactName,
                                                                                  isDense: true,
                                                                                  onChanged: selectedComtactData,
                                                                                  items: snapshot.data.map((map) {
                                                                                    return new DropdownMenuItem<dynamic>(
                                                                                      value: map[0].toString(),
                                                                                      child: new Text(map[1], style: new TextStyle(color: Colors.black)),
                                                                                    );
                                                                                  }).toList(),

                                                                                  // onChanged: (value) {  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            _contactId == '1' || _contactId == null
                                                                                ? Container()
                                                                                : Container(
                                                                                    margin: EdgeInsets.all(2),
                                                                                    child: RichText(
                                                                                      text: TextSpan(text: 'Mobile No : ', style: datastyle, children: <TextSpan>[
                                                                                        TextSpan(text: '${_contactId.split("^")[1]}', style: textstyle),
                                                                                      ]),
                                                                                    ),
                                                                                  ),
                                                                            _contactId == '1' || _contactId == null
                                                                                ? Container()
                                                                                : Container(
                                                                                    margin: EdgeInsets.all(2),
                                                                                    child: RichText(
                                                                                      text: TextSpan(text: 'Email Id : ', style: datastyle, children: <TextSpan>[
                                                                                        TextSpan(text: '${_contactId.split("^")[2]}', style: textstyle),
                                                                                      ]),
                                                                                    ),
                                                                                  ),
                                                                          ]));
                                                                    }
                                                                  }),
                                                              selectedContactName ==
                                                                      '1'
                                                                  ? _contactTextfield()
                                                                  : Container()
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                            margin: EdgeInsets
                                                                .fromLTRB(
                                                                    2, 0, 2, 1),
                                                            child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: <
                                                                        Widget>[
                                                                      Flexible(
                                                                          child: Text(
                                                                              'Is item not in working condition - ',
                                                                              style: datastyle)),
                                                                      CupertinoSwitch(
                                                                        value:
                                                                            _switchValue,
                                                                        onChanged:
                                                                            (value) {
                                                                          setState(
                                                                              () {
                                                                            _switchValue =
                                                                                value;
                                                                          });
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  // ignore: unrelated_type_equality_checks
                                                                  _switchValue ==
                                                                          true
                                                                      ? Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                              Container(
                                                                                  // margin: EdgeInsets.all(2),
                                                                                  child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  RichText(
                                                                                    text: TextSpan(text: 'Not working date: ', style: datastyle, children: <TextSpan>[
                                                                                      TextSpan(text: '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString()}-${selectedDate.year.toString()}', style: textstyle),
                                                                                    ]),
                                                                                  ),
                                                                                  IconButton(icon: new Icon(Icons.calendar_today), onPressed: () => _selectDate(context))
                                                                                ],
                                                                              )),
                                                                              Container(
                                                                                  // margin: EdgeInsets.all(2),
                                                                                  child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  RichText(
                                                                                    text: TextSpan(text: 'Time: ', style: datastyle, children: <TextSpan>[
                                                                                      TextSpan(text: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}', style: textstyle),
                                                                                    ]),
                                                                                  ),
                                                                                  IconButton(icon: new Icon(Icons.alarm), onPressed: () => _selectTime(context))
                                                                                ],
                                                                              )),
                                                                            ])
                                                                      : Text("")
                                                                ])),
                                                        Center(
                                                            child: RaisedButton(
                                                                color: Color(
                                                                    0xff2d0e3e),
                                                                onPressed:
                                                                    () async {
                                                                  if (_formKey
                                                                      .currentState
                                                                      .validate()) {
                                                                    _formKey
                                                                        .currentState
                                                                        .save();
                                                                    showLoaderDialog(
                                                                        context);
                                                                    _savedComplaint();
                                                                  }
                                                                },
                                                                child: Text(
                                                                  'Raise Complaint',
                                                                  style: TextStyle(
                                                                      color: Color(
                                                                          0xffffffff)),
                                                                )))
                                                      ]))))
                                    ]));
                                  // Container();

                                  // Center(
                                  //     child: Text('No Data available'));
                                  else
                                    return Column(
                                        children:
                                            snapshot.data.map<Widget>((alist) {
                                      return Column(children: [
                                        Container(
                                            margin: EdgeInsets.all(10),
                                            child: Text(
                                                'Active Complaint Details',
                                                style: headingstyle)),
                                        Card(
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        margin:
                                                            EdgeInsets.all(2),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text:
                                                                  'Complaint ID: ',
                                                              style: datastyle,
                                                              children: <
                                                                  TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        '${alist[0]}',
                                                                    style:
                                                                        textstyle),
                                                              ]),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin:
                                                            EdgeInsets.all(2),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text:
                                                                  'Complaint Date and Time: ',
                                                              style: datastyle,
                                                              children: <
                                                                  TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        ' ${alist[1]}',
                                                                    style:
                                                                        textstyle),
                                                              ]),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin:
                                                            EdgeInsets.all(2),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text:
                                                                  'Complaint Description : ',
                                                              style: datastyle,
                                                              children: <
                                                                  TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        ' ${alist[2]}',
                                                                    style:
                                                                        textstyle),
                                                              ]),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin:
                                                            EdgeInsets.all(2),
                                                        child: RichText(
                                                          text: TextSpan(
                                                              text:
                                                                  'Complaint Status : ',
                                                              style: datastyle,
                                                              children: <
                                                                  TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        ' ${alist[3]}',
                                                                    style:
                                                                        textstyle),
                                                              ]),
                                                        ),
                                                      ),
                                                    ])))
                                      ]);
                                    }).toList());
                              }
                            },
                          )),
                        ],
                      ),
                    )
                  : Container(
                      child: Column(children: [
                      Container(
                          margin: EdgeInsets.all(10),
                          child: Text(
                            'Complaint Details',
                            style: headingstyle,
                          )),
                      Card(
                          child: Container(
                              padding: EdgeInsets.all(10),
                              child: Form(
                                  key: _formKey,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Container(margin:EdgeInsets.all(4),
                                        //                   child: Text('All fields are Mandatory', style: TextStyle(color:Colors.red))
                                        //                 ),
                                        Container(
                                          margin: EdgeInsets.all(2),
                                          child: RichText(
                                            text: TextSpan(
                                                text: 'Vender Name',
                                                style: datastyle,
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: '*',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 16.0)),
                                                  TextSpan(
                                                      text:
                                                          ' ${widget.equipList[0][17]}',
                                                      style: textstyle),
                                                ]),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(2, 15, 2, 1),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.all(2),
                                                child: RichText(
                                                  text: TextSpan(
                                                      text:
                                                          'Problem Description',
                                                      style: datastyle,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: '*',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize:
                                                                    16.0)),
                                                      ]),
                                                ),
                                              ),
                                              FutureBuilder<List<dynamic>>(
                                                  future:
                                                      _getProblemDescriptionName(),
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<
                                                                  List<dynamic>>
                                                              snapshot) {
                                                    if (!snapshot.hasData ||
                                                        snapshot.data == null) {
                                                      return Container();
                                                      // Center(child: CircularProgressIndicator())

                                                    } else {
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        margin:
                                                            EdgeInsets.all(4),
                                                        padding:
                                                            EdgeInsets.all(7.0),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4.0),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey)),
                                                        child:
                                                            DropdownButtonHideUnderline(
                                                          child:
                                                              new DropdownButton<
                                                                  dynamic>(
                                                            hint: new Text(
                                                                "Select Problem"),
                                                            value:
                                                                _selectedValue,
                                                            isDense: true,
                                                            onChanged:
                                                                selectedData,
                                                            items: snapshot.data
                                                                .map((map) {
                                                              return new DropdownMenuItem<
                                                                      dynamic>(
                                                                  value: map[0],
                                                                  child:
                                                                      new Container(
                                                                    width: 200,
                                                                    child: Text(
                                                                        map[1],
                                                                        overflow:
                                                                            TextOverflow
                                                                                .fade,
                                                                        style: new TextStyle(
                                                                            color:
                                                                                Colors.black)),
                                                                  ));
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }),
                                              _selectedValue == '1'
                                                  ? _textfiled()
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                        _selectedValue == null ||
                                                _selectedValue == '1'
                                            ? new Container()
                                            : Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    2, 0, 2, 15),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin: EdgeInsets.all(2),
                                                      child: RichText(
                                                        text: TextSpan(
                                                            text:
                                                                'Problem Solution',
                                                            style: datastyle,
                                                            children: <
                                                                TextSpan>[
                                                              TextSpan(
                                                                  text: '*',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          16.0)),
                                                            ]),
                                                      ),
                                                    ),
                                                    FutureBuilder<
                                                            List<dynamic>>(
                                                        future:
                                                            _getProblemSolutionName(),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    List<
                                                                        dynamic>>
                                                                snapshot) {
                                                          if (!snapshot
                                                              .hasData) {
                                                            return Container();
                                                          } else {
                                                            return Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              margin: EdgeInsets
                                                                  .all(4),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(7.0),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey)),
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child:
                                                                    new DropdownButton<
                                                                        dynamic>(
                                                                  hint: new Text(
                                                                      "Select Problem Solution"),
                                                                  value:
                                                                      selectedSolName,
                                                                  isDense: true,
                                                                  onChanged:
                                                                      (newValue) {
                                                                    setState(
                                                                        () {
                                                                      selectedSolName =
                                                                          newValue;
                                                                    });
                                                                  },
                                                                  items: snapshot
                                                                      .data
                                                                      .map(
                                                                          (map) {
                                                                    return new DropdownMenuItem<
                                                                            dynamic>(
                                                                        value: map[
                                                                            0],
                                                                        child:
                                                                            new Container(
                                                                          width:
                                                                              200,
                                                                          child: Text(
                                                                              map[0],
                                                                              overflow: TextOverflow.fade,
                                                                              style: new TextStyle(color: Colors.black)),
                                                                        ));
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        })
                                                  ],
                                                ),
                                              ),
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(2, 5, 2, 4),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.all(2),
                                                child: RichText(
                                                  text: TextSpan(
                                                      text: 'Contact Person',
                                                      style: datastyle,
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                            text: '*',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                                fontSize:
                                                                    16.0)),
                                                      ]),
                                                ),
                                              ),
                                              FutureBuilder<List<dynamic>>(
                                                  future: contact,
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<
                                                                  List<dynamic>>
                                                              snapshot) {
                                                    if (!snapshot.hasData ||
                                                        snapshot.data == null) {
                                                      return Container();
                                                    } else {
                                                      return Container(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                            Container(
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              margin: EdgeInsets
                                                                  .all(4),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(7.0),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey)),
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child:
                                                                    new DropdownButton<
                                                                        dynamic>(
                                                                  hint: new Text(
                                                                      "Select Contact Name"),
                                                                  value:
                                                                      selectedContactName,
                                                                  isDense: true,
                                                                  onChanged:
                                                                      selectedComtactData,
                                                                  items: snapshot
                                                                      .data
                                                                      .map(
                                                                          (map) {
                                                                    return new DropdownMenuItem<
                                                                        dynamic>(
                                                                      value: map[
                                                                              0]
                                                                          .toString(),
                                                                      child: new Text(
                                                                          map[
                                                                              1],
                                                                          style:
                                                                              new TextStyle(color: Colors.black)),
                                                                    );
                                                                  }).toList(),

                                                                  // onChanged: (value) {  },
                                                                ),
                                                              ),
                                                            ),
                                                            _contactId == '1' ||
                                                                    _contactId ==
                                                                        null
                                                                ? Container()
                                                                : Container(
                                                                    margin: EdgeInsets
                                                                        .all(2),
                                                                    child:
                                                                        RichText(
                                                                      text: TextSpan(
                                                                          text:
                                                                              'Mobile No : ',
                                                                          style:
                                                                              datastyle,
                                                                          children: <
                                                                              TextSpan>[
                                                                            TextSpan(
                                                                                text: '${_contactId.split("^")[1]}',
                                                                                style: textstyle),
                                                                          ]),
                                                                    ),
                                                                  ),
                                                            _contactId == '1' ||
                                                                    _contactId ==
                                                                        null
                                                                ? Container()
                                                                : Container(
                                                                    margin: EdgeInsets
                                                                        .all(2),
                                                                    child:
                                                                        RichText(
                                                                      text: TextSpan(
                                                                          text:
                                                                              'Email Id : ',
                                                                          style:
                                                                              datastyle,
                                                                          children: <
                                                                              TextSpan>[
                                                                            TextSpan(
                                                                                text: '${_contactId.split("^")[2]}',
                                                                                style: textstyle),
                                                                          ]),
                                                                    ),
                                                                  ),
                                                          ]));
                                                    }
                                                  }),
                                              selectedContactName == '1'
                                                  ? _contactTextfield()
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                        Container(
                                            margin:
                                                EdgeInsets.fromLTRB(2, 0, 2, 1),
                                            child: Column(children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Flexible(
                                                      child: Text(
                                                          'Is item not in working condition - ',
                                                          style: datastyle)),
                                                  CupertinoSwitch(
                                                    value: _switchValue,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _switchValue = value;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              // ignore: unrelated_type_equality_checks
                                              _switchValue == true
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                          Container(
                                                              // margin: EdgeInsets.all(2),
                                                              child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        'Not working date: ',
                                                                    style:
                                                                        datastyle,
                                                                    children: <
                                                                        TextSpan>[
                                                                      TextSpan(
                                                                          text:
                                                                              '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString()}-${selectedDate.year.toString()}',
                                                                          style:
                                                                              textstyle),
                                                                    ]),
                                                              ),
                                                              IconButton(
                                                                  icon: new Icon(
                                                                      Icons
                                                                          .calendar_today),
                                                                  onPressed: () =>
                                                                      _selectDate(
                                                                          context))
                                                            ],
                                                          )),
                                                          Container(
                                                              // margin: EdgeInsets.all(2),
                                                              child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        'Time: ',
                                                                    style:
                                                                        datastyle,
                                                                    children: <
                                                                        TextSpan>[
                                                                      TextSpan(
                                                                          text:
                                                                              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                                                          style:
                                                                              textstyle),
                                                                    ]),
                                                              ),
                                                              IconButton(
                                                                  icon: new Icon(
                                                                      Icons
                                                                          .alarm),
                                                                  onPressed: () =>
                                                                      _selectTime(
                                                                          context))
                                                            ],
                                                          )),
                                                        ])
                                                  : Text("")
                                            ])),
                                        Center(
                                            child: RaisedButton(
                                                color: Color(0xff2d0e3e),
                                                onPressed: () async {
                                                  if (_formKey.currentState
                                                      .validate()) {
                                                    _formKey.currentState
                                                        .save();
                                                    showLoaderDialog(context);
                                                    _savedComplaint();
                                                  }
                                                },
                                                child: Text(
                                                  'Raise Complaint',
                                                  style: TextStyle(
                                                      color: Color(0xffffffff)),
                                                )))
                                      ]))))
                    ]))
            ]),
          )),
    );
  }
}
