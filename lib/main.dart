import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:tickets/admob_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AdMobService.initalize();
  runApp(MyApp());
}

/*final BannerAd myBanner = BannerAd(
  adUnitId: 'ca-app-pub-3991352577184641/4046757610',
  size: AdSize.banner,
  request: AdRequest(),
  listener: BannerAdListener(),
);

final BannerAd myBanner2 = BannerAd(
  adUnitId: 'ca-app-pub-3991352577184641/4046757610',
  size: AdSize.banner,
  request: AdRequest(),
  listener: BannerAdListener(),
);*/

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

String currentSport = "";
List<BetsForm> betsList = [];
List<MultiBetsForm> multiBetsList = [];

/*String betsDate(String datetime) {
  List newDateTime = datetime.split("T");
  String newDateTime2 = newDateTime[0];
  List newTime2 = newDateTime2.split("-");
  return newTime2[2] + ". " + newTime2[1] + ". " + newTime2[0];
}

String betsTime(String dateTime) {
  List time = dateTime.split("T");
  String newTime = time[1];
  List newTime2 = newTime.split(":");
  return newTime2[0] + ":" + newTime2[1];
}*/

String betsDate(String datetime) {
  return datetime.split("T")[0].split("-")[2] +
      ". " +
      datetime.split("T")[0].split("-")[1] +
      ". " +
      datetime.split("T")[0].split("-")[0];
}

String betsTime(String datetime) {
  return datetime.split("T")[1].split(":")[0] +
      ":" +
      datetime.split("T")[1].split(":")[1];
}

Future fetchBets() async {
  //https://swonapp.eu/api/match/bets
  final response =
      await http.get(Uri.parse('https://swonapp.eu/api/match/bets'));
  Map<String, dynamic> map = convert.jsonDecode(response.body);
  List<dynamic> data = map["singleBets"];

  if (betsList.length > 0) betsList.clear();
  if (multiBetsList.length > 0) multiBetsList.clear();

  for (int i = 0; i < data.length; i++) {
    var bets = new BetsForm(
        data[i]["sport"],
        betsDate(data[i]["date"]),
        betsTime(data[i]["date"]),
        data[i]["name"],
        data[i]["winner"],
        data[i]["odd"]);
    betsList.add(bets);
  }

  data = map["multiBets"];

  for (int i = 0; i < map["multiBets"].length; i++) {
    List<BetsForm> tempBetsList = [];
    for (int j = 0; j < data[i]["bets"].length; j++) {
      tempBetsList.add(BetsForm(
          data[i]["bets"][j]["sport"],
          betsDate(data[i]["bets"][j]["date"]),
          betsTime(data[i]["bets"][j]["date"]),
          data[i]["bets"][j]["name"],
          data[i]["bets"][j]["winner"],
          data[i]["bets"][j]["odd"]));
    }
    var obj = MultiBetsForm(tempBetsList, data[i]["totalOdd"]);
    multiBetsList.add(obj);
  }
}

class BetsForm {
  String sport;
  String date;
  String time;
  String name;
  String winner;
  var odd;

  BetsForm(String sport, String date, String time, String name, String winner,
      var odd) {
    this.sport = sport;
    this.date = date;
    this.time = time;
    this.name = name;
    this.winner = winner;
    this.odd = odd;
  }
}

class MultiBetsForm {
  List<BetsForm> bets;
  var totalOdd;

  MultiBetsForm(List<BetsForm> bets, var totalOdd) {
    this.bets = bets;
    this.totalOdd = totalOdd;
  }
}

class Bets extends StatefulWidget {
  @override
  _BetsState createState() => _BetsState();
}

class _BetsState extends State<Bets> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 28, 30, 33),
      appBar: AppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Container(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_rounded, size: 18),
                    SizedBox(width: 7),
                    Text("BT", style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: GestureDetector(
                onTap: () {
                  fetchBets();
                  setState(() {});
                  Fluttertoast.showToast(
                      msg: "Data byla aktualizována!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.SNACKBAR,
                      backgroundColor: Colors.grey[700],
                      textColor: Colors.white,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0);
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.refresh_outlined)),
          )
        ],
      ),
      bottomNavigationBar: Container(
          height: 50,
          child: AdWidget(
              key: UniqueKey(), ad: AdMobService.createBannerAd()..load())),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(height: 15),
                for (int i = 0; i < betsList.length; i++)
                  if (currentSport != "Multibets")
                    if (betsList[i].sport == currentSport)
                      Center(
                        child: Column(children: [
                          BetsContainer(
                              betsList[i].name,
                              betsList[i].date,
                              betsList[i].odd,
                              betsList[i].winner,
                              betsList[i].time),
                          SizedBox(height: 7),
                        ]),
                      ),
                if (currentSport == "Multibets")
                  for (int j = 0; j < multiBetsList.length; j++)
                    for (int i = 0; i < multiBetsList[j].bets.length; i++)
                      Center(
                          child: Column(
                        children: [
                          MultiBetsContainer(
                              multiBetsList[j].bets[i].name,
                              multiBetsList[j].bets[i].date,
                              multiBetsList[j].bets[i].odd,
                              multiBetsList[j].bets[i].winner,
                              multiBetsList[j].bets[i].time,
                              multiBetsList[j].bets[i].sport),
                          SizedBox(height: 7),
                          if (multiBetsList[j].bets.length == i + 1)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Column(
                                children: [
                                  Row(children: [
                                    Spacer(),
                                    Row(
                                      children: [
                                        Text('Total odds: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white)),
                                        Text(
                                            multiBetsList[j]
                                                .totalOdd
                                                .toString(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[800])),
                                      ],
                                    ),
                                  ]),
                                  SizedBox(height: 13),
                                ],
                              ),
                            ),
                        ],
                      )),
              ],
            ),
          ],
        ),
      )),
    );
  }
}

class BetsContainer extends StatelessWidget {
  String name;
  String date;
  var odd;
  String winner;
  String time;

  BetsContainer(String name, String date, var odd, String winner, String time) {
    this.name = name;
    this.date = date;
    this.odd = odd;
    this.winner = winner;
    this.time = time;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(date,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 7),
                      Text(time, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Spacer(),
                  Center(
                    child: Container(
                        child: Center(
                            child: Text("$odd",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green)),
                  )
                ],
              ),
            ),
            height: 65,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: Color.fromARGB(255, 48, 51, 55))),
        Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    SizedBox(height: 7),
                    Text(winner, style: TextStyle(color: Colors.white)),
                  ]),
            ),
            height: 65,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: Color.fromARGB(255, 73, 78, 87))),
      ],
    ));
  }
}

class MultiBetsContainer extends StatelessWidget {
  String name;
  String date;
  var odd;
  String winner;
  String time;
  String sport;
  double imageHeight = 50.0;

  MultiBetsContainer(String name, String date, var odd, String winner,
      String time, String sport) {
    this.name = name;
    this.date = date;
    this.odd = odd;
    this.winner = winner;
    this.time = time;
    this.sport = sport;
  }

  @override
  Widget build(BuildContext context) {
    if (sport == "Ice-Hockey") {
      imageHeight = 30.0;
    } else if (sport == "Basketball") {
      imageHeight = 40.0;
    } else if (sport == "Football") {
      // CHANGE HEIGHT OF THESE IMAGES
      imageHeight = 40.0;
    } else if (sport == "Tennis") {
      imageHeight = 43.0;
    }
    return Container(
        child: Column(
      children: [
        Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(date,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 7),
                      Text(time, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Spacer(),
                  Center(
                    child: Container(
                        child: Center(
                            child: Text("$odd",
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.green)),
                  )
                ],
              ),
            ),
            height: 65,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: Color.fromARGB(255, 48, 51, 55))),
        Container(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(name,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 7),
                        Text(winner, style: TextStyle(color: Colors.white)),
                      ]),
                  Spacer(),
                  Image(
                      image: AssetImage("lib/media/$sport.png"),
                      height: imageHeight)
                ],
              ),
            ),
            height: 65,
            width: MediaQuery.of(context).size.width * 0.95,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: Color.fromARGB(255, 73, 78, 87))),
      ],
    ));
  }
}

class SportsContainer extends StatelessWidget {
  String picture;
  String name;
  String sport;
  double picHeight;

  SportsContainer(String picture, String name, String sport, double picHeight) {
    this.picture = picture;
    this.name = name;
    this.sport = sport;
    this.picHeight = picHeight;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        currentSport = sport;
        if (currentSport == "Multibets") AdMobService.showInterstitialAd();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Bets()),
        );
      },
      child: Container(
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 55, 59, 67),
              borderRadius: BorderRadius.all(
                Radius.circular(7),
              )),
          height: 140,
          width: MediaQuery.of(context).size.width * 0.95,
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(
                    image: AssetImage('lib/media/$picture'), height: picHeight),
                Text(name,
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ))
              ],
            ),
          )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    fetchBets();
  }

  /*@override
  void dispose() {
    super.dispose();
    myBanner.dispose();
  }*/

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 28, 30, 33),
      appBar: AppBar(
        leading: Center(child: Text("BT", style: TextStyle(fontSize: 18))),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: GestureDetector(
                onTap: () {
                  fetchBets();
                  setState(() {});
                  Fluttertoast.showToast(
                      msg: "Data byla aktualizována!",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.SNACKBAR,
                      backgroundColor: Colors.grey[700],
                      textColor: Colors.white,
                      timeInSecForIosWeb: 1,
                      fontSize: 16.0);
                },
                child: Icon(Icons.refresh_outlined)),
          )
        ],
      ),
      bottomNavigationBar: Container(
          height: 50,
          child: AdWidget(
              key: UniqueKey(), ad: AdMobService.createBannerAd()..load())),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 15),
                SportsContainer("Football.png", "FOOTBALL", "Football", 60),
                SizedBox(height: 10),
                SportsContainer("Tennis.png", "TENNIS", "Tennis", 65),
                SizedBox(height: 10),
                SportsContainer(
                    "Ice-Hockey.png", "ICE HOCKEY", "Ice-Hockey", 50),
                SizedBox(height: 10),
                SportsContainer(
                    "Basketball.png", "BASKETBALL", "Basketball", 60),
                SizedBox(height: 10),
                SportsContainer(
                    "goldenTicket.png", "GOLDEN TICKET", "Multibets", 53),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
