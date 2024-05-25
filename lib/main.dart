import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suivi de Colis',
      home: TrackingPage(),
    );
  }
}

class TrackingPage extends StatefulWidget {
  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class PackageStatus {
  final String trackingNumber;
  final String status;

  PackageStatus({required this.trackingNumber, required this.status});
}

class _TrackingPageState extends State<TrackingPage> {
  final _trackingNumberController = TextEditingController();
  List<PackageStatus> _packageStatuses = [];
  String _apiKey = "apik_7Ytg2AYjYd0G5EL9v8UMdQzGaIWTle";

  final List<String> _imageUrls = [
    'assets/blog.jpg',
  ];

  Future<void> _trackPackages() async {
    final trackingNumbers = _trackingNumberController.text.split('\n');
    _packageStatuses.clear();

    for (final trackingNumber in trackingNumbers) {
      final url = Uri.parse('https://wehbook.site/8a9a125d-77ec-4880-88be-689afbbd2994$trackingNumber');
      final headers = {
        'aftership-api-key': _apiKey,
      };

      try {
        final response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _packageStatuses.add(PackageStatus(
            trackingNumber: trackingNumber,
            status: data['status'],
          ));
        } else {
          _packageStatuses.add(PackageStatus(
            trackingNumber: trackingNumber,
            status: 'Erreur lors de la récupération du statut du colis',
          ));
        }
      } catch (e) {
        _packageStatuses.add(PackageStatus(
          trackingNumber: trackingNumber,
          status: 'Erreur lors de la connexion à l\'API de suivi',
        ));
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/ecran.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 50.0),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                  ),
                  items: _imageUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 30.0),
                Text(
                  'Bienvenue sur l\'application de suivi de colis !',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.0),
                TextField(
                  controller: _trackingNumberController,
                  decoration: InputDecoration(
                    hintText: 'Numéros de suivi (un par ligne)',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 18.0),
                ElevatedButton(
                  onPressed: _trackPackages,
                  child: Text('Suivre les Colis'),
                ),
                SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: _packageStatuses.length,
                    itemBuilder: (context, index) {
                      final packageStatus = _packageStatuses[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '${packageStatus.trackingNumber}: ${packageStatus.status}',
                          style: TextStyle(fontSize: 19.0, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}