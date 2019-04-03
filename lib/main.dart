import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context)=> MaterialApp(
      title: 'Wowsy',
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Color(0xFF44318e),
          accentColor: Color(0xFFe98074),
          fontFamily: 'Quicksand',
          textTheme: TextTheme(
              headline: TextStyle(
                  fontSize: 55.0, fontWeight: FontWeight.bold, fontFamily: "Quicksand",
                  color: Color(0xFFe98074)),
              title: TextStyle(
                  fontSize: 20.0, fontWeight: FontWeight.bold, fontFamily: "Quicksand"))),
      home: Home()
  );
}
class Home extends StatefulWidget {
  final Future<MathFact> fact;
  Home({Key key, this.fact}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> with TickerProviderStateMixin {
  _HomeState({Key key, this.fact});
  Future<MathFact> fact;
  int defaultNumber = 0;
  TabController _tabController;

  static Widget myTab(String asset, String text) => Tab(
      icon: Image(image: AssetImage(asset), height: 35.0, width: 35.0), text: text
  );

  myPads(Widget child) => Padding(padding: const EdgeInsets.all(8.0), child: child);

  final List<Tab> myTabs = <Tab>[
    myTab("assets/albert.png", "Math"),
    myTab("assets/child.png", "Trivia"),
    myTab("assets/calender.png", "Date")
  ];
  Widget image(String asset)=> Image(image: AssetImage(asset),height: 35.0, width: 35.0);

  toggleTabs  (String text){
    setState(() {
    fact = fetchFact(defaultNumber.toString(), text);
    });
  }
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _tabController.addListener(() {
        if (_tabController.index == 1) {
          toggleTabs("trivia");
        } else if (_tabController.index == 2) {
          toggleTabs("date");
        } else if (_tabController.index == 0) {
          toggleTabs("math");
        }
    });
    defaultNumber = Random().nextInt(100);
    fact = fetchFact(defaultNumber.toString(), 'math');
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget math(String target) {
      return Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          myPads(
            Card(
              child: AnimatedContainer(
                duration: Duration(seconds: 5),
                child: FutureBuilder<MathFact>(future: fact, builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListTile(title: Text(snapshot.data.body));
                  } else if (snapshot.hasError) {return Text("Unable to connect to the internet");}
                    return Text("Loading...");
                  }
                )
              )
            )
          ),
          Card(child: target != "date" ? Container(width: MediaQuery.of(context).size.width,child: Column(
            children: <Widget>[
              myPads(NumberPicker.integer(itemExtent: 80.0, initialValue: defaultNumber, minValue: 0, maxValue: 1000000,
                  onChanged: (newValue) => setState(() {
                    defaultNumber = newValue;
                    toggleTabs(target);
                  })),
              ),
              myPads(Text("Scroll to change valuve")),
            ]))
              : FlatButton(onPressed: () {
                DatePicker.showDatePicker(context, locale: 'en',
                  onChanged: (date) {
                  setState(() {
                    fact = fetchFact(DateFormat('M/dd').format(date).toString(), target);
                  });
                });
                }, child: ListTile(
              title: Text("Choose Date"), subtitle: Text("Find facts vabout specific dates"), trailing: image("assets/calender.png"))),
          ),
        ],
      ));
    }
    return Scaffold(
      appBar: AppBar(bottom: TabBar(controller: _tabController, tabs: myTabs)),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          math("math"),
          math("trivia"),
          math("date"),
        ],
      ),
    );
  }
}

class MathFact {
  final String body;
  MathFact({this.body});
  factory MathFact.fromJson(json) {
    return MathFact(body: json.toString());
  }
}

Future<MathFact> fetchFact(String number, String target) async {
  final response = await http.get('http://numbersapi.com/$number/$target');
  if (response.statusCode == 200) {
    return MathFact.fromJson(response.body.toString());
  } else {
    throw Exception('Failed to load fact');
  }
}
