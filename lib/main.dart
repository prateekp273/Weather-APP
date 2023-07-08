import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api_keys.dart';

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Remove the debug banner
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String _apiKey = apiKey; // Use the API key from api_keys.dart
  String _currentLocation = 'New York'; // Default location
  Map<String, dynamic>? _weatherData;
  TextEditingController _locationController = TextEditingController();

  Future<void> _fetchWeatherData() async {
    final Uri uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$_currentLocation&appid=$_apiKey&units=metric');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      setState(() {
        _weatherData = jsonDecode(response.body);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _changeLocation() {
    setState(() {
      _currentLocation = _locationController.text;
      _fetchWeatherData();
      _locationController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: _weatherData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            _weatherData!['name'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            '${_weatherData!['main']['temp']}°C',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 20),
          Text(
            _weatherData!['weather'][0]['main'],
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Enter location',
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _changeLocation,
                child: const Text('Change Location'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}