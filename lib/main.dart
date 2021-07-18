// @dart=2.9
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:dio/dio.dart';
import 'list.dart' as list;
import 'package:splashscreen/splashscreen.dart';
import 'package:draw_graph/draw_graph.dart';
import 'package:draw_graph/models/feature.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

var datalist;
var curr=-1;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //material app widget
    return MaterialApp(
      title: 'Crypto Price List',
      theme: new ThemeData(primaryColor: Colors.white),
      home: CryptoList(),
    );
  }
}

class CryptoList extends StatefulWidget {
  @override
  CryptoListState createState() => CryptoListState();
}

class CryptoListState extends State {
  Future getCryptoPrices() async {
    try{
      Dio _dio = Dio();
      _dio.options.headers['X-CMC_PRO_API_KEY']='9499f859-11de-4909-b693-31b42c7952bc';
      String _apiURL =
          "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest"; //url to get data

      Response response = await _dio.get(_apiURL); //waits for response
      datalist = response.data['data'] as List;
      return datalist;
    }
    on DioError catch(e) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NetworkProblem()),
      );
    }

  }

  @override
  void initState() {
    super.initState();
    getCryptoPrices();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home : Splash2(),
    );


  }


}
class Splash2 extends StatelessWidget {
  @override
    Widget build(BuildContext context) {
      return SplashScreen(
        loadingText: Text("Retrieving Data"),
        styleTextUnderTheLoader: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.cyan
        ),
        seconds: 5,
        imageBackground: AssetImage("idk/hello.png"),
        navigateAfterSeconds: SecondScreen(),
        backgroundColor: Colors.blueGrey,
        loaderColor: Colors.black54,
      );
    }
}
class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Color(0xffd3e2e8),
          appBar: AppBar(
            actions: [
              TextButton(
                child: Text("Switch Mode",
                style: TextStyle(
                  color:Colors.white,
                  fontWeight: FontWeight.w500
                )
                ),
               onPressed: (){
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => SecondScreenDark()),
                 );
               },
              )
            ],
            backgroundColor: Color(0xc40071da),
            title: Center(
                child: Text('Cryptonance',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 28,
                    fontFamily: "Poppins-Light",
                  ),
                )
            ),
          ),
          body:
              ListView(

              children: List.generate(datalist.length,
                      (index) =>
                      TextButton(
                        onPressed: (){
                          curr = index;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => details()),
                          );
                        },
                        child: Card(
                          elevation: 0.0,
                          //color: Colors.white,
                          child: ListTile(
                            leading: Image.asset(
                                'icons/${datalist[index]['id'].toString()}.png'),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(datalist[index]['name'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Poppins-Light",
                                  ),
                                ),
                                Text("USD \$${datalist[index]['quote']['USD']['price'].toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontFamily: "Poppins-Light",
                                    fontWeight: FontWeight.w600
                                  ),
                                )
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${datalist[index]['symbol'].toString()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Poppins-Light",
                                  ),
                                ),
                                Text("${datalist[index]['quote']['USD']['percent_change_7d'].toStringAsFixed(2)}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: datalist[index]['quote']['USD']['percent_change_7d']>=0?Color(0xff00b670): Colors.red,
                                    fontFamily: "Poppins-Light",
                                  ),
                                )
                              ],
                            )
                          ),
                        ),
                      ))

          )),
    );
  }
}
class details extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double price = datalist[curr]['quote']['USD']['price'];
    double ch_h=datalist[curr]['quote']['USD']['percent_change_1h'];
    double ch_24h=datalist[curr]['quote']['USD']['percent_change_24h'];
    double ch_7d=datalist[curr]['quote']['USD']['percent_change_7d'];
    double pr_7 = (100-ch_7d)*price/100;
    double pr_1= (100-ch_24h)*price/100;
    double pr_1h=(100-ch_h)*price/100;
    List<Data> chart_data =[
      Data(pr_7,1),
      Data(pr_1,7),
      Data(pr_1h,7.9),
      Data(price,8),
    ];
    return Scaffold(
          backgroundColor: Color(0xffd3e2e8),
          appBar: AppBar(
            backgroundColor: Color(0xc40071da),
            title: Center(child: Text(datalist[curr]['name'].toString(),
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                  fontFamily: "Poppins-Light",
                fontWeight: FontWeight.w500
              ),
            )),
          ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10.0),
            Image.asset('iconss/${datalist[curr]['id'].toString()}.png'),
            SizedBox(height:10.0),
            Text("${datalist[curr]['symbol'].toString()}",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontSize: 36,
                fontFamily: "Poppins-Light",
            ),
            ),
            SizedBox(height:10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("     Current Value",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins-Light",
                    )),
                Text("${datalist[curr]['quote']['USD']['price'].toStringAsFixed(2)}     ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins-Light",
                    ))
              ],
            ),
            SizedBox(height:10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("     Number of Market Pair",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                ),),
                Text("${datalist[curr]['num_market_pairs'].toStringAsFixed(2)}     ",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                ),)
              ],
            ),
            SizedBox(height:10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("     Total Supply",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                ),),
                Text("${datalist[curr]["total_supply"].toStringAsFixed(2)}     ",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                ),)
              ],
            ),
            SizedBox(height:10.0),
            Text("Percent Change in:-",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                fontFamily: "Poppins-Light",
              ),
            ),
            SizedBox(height:10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("1 Hour",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                ),),
                Text("${datalist[curr]['quote']['USD']['percent_change_1h'].toStringAsFixed(2)}%",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                  color: datalist[curr]['quote']['USD']['percent_change_1h']>=0?Color(0xff00b670): Colors.red,
                ),)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("24 Hour",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                )),
                Text("${datalist[curr]['quote']['USD']['percent_change_24h'].toStringAsFixed(2)}%",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                  color: datalist[curr]['quote']['USD']['percent_change_24h']>=0?Color(0xff00b670): Colors.red,
                ),)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("7 Days",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                )),
                Text("${datalist[curr]['quote']['USD']['percent_change_7d'].toStringAsFixed(2)}%",style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                  color: datalist[curr]['quote']['USD']['percent_change_7d']>=0?Color(0xff00b670): Colors.red,
                ))
              ],
            ),
            Text("___________________________"),
            Container(
              width:300,
              height:150,
              child: SfCartesianChart(
                borderColor: Colors.black,
                title: ChartTitle(
                  text: "Graph of Price Over the week",
                  alignment: ChartAlignment.center,
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                  )
                ),
                enableAxisAnimation: true,
                primaryXAxis: NumericAxis(
                  isVisible: false
                ),
                series: <ChartSeries>[
                LineSeries<Data,double>(dataSource: chart_data,
                  xValueMapper: (Data prim,_) => prim.day,
                  yValueMapper: (Data prim,_) => prim.val,
                )
              ],
              )
            ),

          ],
        )
      ),
    );
  }
}
class NetworkProblem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Colors.blueGrey,
          body: Container(
            height: MediaQuery. of(context). size. height,
            width: MediaQuery. of(context). size. width,
            decoration: BoxDecoration(
              image:DecorationImage(
                  image: AssetImage("idk/hp.png"),
                  fit: BoxFit.fill,
              )
            ),
          ),
      )
    );
  }
}
class Data{
  Data(this.val,this.day);
  final double val,day;
}
class SecondScreenDark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Color(0xfc181c27),
          appBar: AppBar(
            actions: [
              TextButton(
                child: Text("Switch Mode"),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecondScreen()),
                  );
                },
              )
            ],
            elevation: 0.0,
            backgroundColor: Color(0xfc181c27),
            title: Center(
                child: Text('Cryptonance',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xff0093ff),
                      fontSize: 28,
                      fontFamily: "Poppins-Light",
                  ),
                )
            ),
          ),
          body:
          ListView(
              children: List.generate(datalist.length,
                      (index) =>
                      TextButton(
                        onPressed: (){
                          curr = index;
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => detailsDark()),
                          );
                        },
                        child: Card(
                          elevation: 0.0,
                          color: Color(0xff434751),
                          child: ListTile(
                            leading: Image.asset(
                                'icons/${datalist[index]['id'].toString()}.png'),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(datalist[index]['name'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: "Poppins-Light",
                                  ),
                                ),
                                  Text("USD \$${datalist[index]['quote']['USD']['price'].toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color:Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "Poppins-Light"
                                    ),
                                  )
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${datalist[index]['symbol'].toString()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                    fontFamily: "Poppins-Light",
                                  ),
                                ),
                                Text("${datalist[index]['quote']['USD']['percent_change_7d'].toStringAsFixed(2)}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: datalist[index]['quote']['USD']['percent_change_7d']>=0?Color(0xff00b670): Colors.red,
                                    fontFamily: "Poppins-Light",
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ))

          )),
    );
  }
}
class detailsDark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double price = datalist[curr]['quote']['USD']['price'];
    double ch_h=datalist[curr]['quote']['USD']['percent_change_1h'];
    double ch_24h=datalist[curr]['quote']['USD']['percent_change_24h'];
    double ch_7d=datalist[curr]['quote']['USD']['percent_change_7d'];
    double pr_7 = (100-ch_7d)*price/100;
    double pr_1= (100-ch_24h)*price/100;
    double pr_1h=(100-ch_h)*price/100;
    List<Data> chart_data =[
      Data(pr_7,1),
      Data(pr_1,7),
      Data(pr_1h,7.9),
      Data(price,8),
    ];
    return Scaffold(
      backgroundColor: Color(0x3a000a23),
      appBar: AppBar(
        backgroundColor: Color(0x3a000a23),
        title: Center(child: Text(datalist[curr]['name'].toString(),
          style: TextStyle(
              fontSize: 28,
              color: Colors.white70,
              fontWeight: FontWeight.w700
          ),
        )),
      ),
      body: Center(

          child: Column(
            children: [
              SizedBox(height: 10.0),
              Image.asset('iconss/${datalist[curr]['id'].toString()}.png'),
              SizedBox(height:10.0),
              Text("${datalist[curr]['symbol'].toString()}",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontFamily: "Poppins-Light",
                ),
              ),
              SizedBox(height:10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("     Current Value",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins-Light",
                        color: Colors.white
                      )
                  ),
                  Text("${datalist[curr]['quote']['USD']['price'].toStringAsFixed(2)}     ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins-Light",
                        color: Colors.white
                      ))
                ],
              ),
              SizedBox(height:10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("     Number of Market Pair",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                    color: Colors.white
                  ),
                  ),
                  Text("${datalist[curr]['num_market_pairs'].toStringAsFixed(2)}     ",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                      color: Colors.white
                  ),)
                ],
              ),
              SizedBox(height:10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("     Total Supply",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                    color: Colors.white
                  ),
                  ),
                  Text("${datalist[curr]["total_supply"].toStringAsFixed(2)}     ",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                      color: Colors.white
                  ),)
                ],
              ),
              SizedBox(height:10.0),
              Text("Percent Change in:-",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins-Light",
                  color: Colors.white
                ),
              ),
              SizedBox(height:10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("1 Hour",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                    color: Colors.white
                  ),),
                  Text("${datalist[curr]['quote']['USD']['percent_change_1h'].toStringAsFixed(2)}%",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                    color: datalist[curr]['quote']['USD']['percent_change_1h']>=0?Color(0xff00b670): Colors.red,
                  ),)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("24 Hour",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                      color: Colors.white
                  )),
                  Text("${datalist[curr]['quote']['USD']['percent_change_24h'].toStringAsFixed(2)}%",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                    color: datalist[curr]['quote']['USD']['percent_change_24h']>=0?Color(0xff00b670): Colors.red,
                  ),)
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("7 Days",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                      color: Colors.white
                  )),
                  Text("${datalist[curr]['quote']['USD']['percent_change_7d'].toStringAsFixed(2)}%",style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins-Light",
                    color: datalist[curr]['quote']['USD']['percent_change_7d']>=0?Color(0xff00b670): Colors.red,
                  ))
                ],
              ),

              Text("___________________________",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
              ),
              Container(
                  width:300,
                  height:150,
                  child: SfCartesianChart(
                    borderColor: Colors.white,
                    title: ChartTitle(
                        text: "Graph of Price Over the week",
                        alignment: ChartAlignment.center,
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: "Poppins-Light",
                        )
                    ),
                    enableAxisAnimation: true,
                    primaryXAxis: NumericAxis(
                        isVisible: false
                    ),
                    series: <ChartSeries>[
                      LineSeries<Data,double>(dataSource: chart_data,
                        xValueMapper: (Data prim,_) => prim.day,
                        yValueMapper: (Data prim,_) => prim.val,
                      )
                    ],
                  )
              ),

            ],
          )
      ),
    );
  }
}
