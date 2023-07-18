import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_icons/weather_icons.dart'; // Import the weather-icons-flutter package

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
      debugShowCheckedModeBanner: false,
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String _apiKey = apiKey;
  String _currentLocation = 'New York';
  Map<String, dynamic>? _weatherData;
  TextEditingController _locationController = TextEditingController();
  TemperatureUnit _currentUnit = TemperatureUnit.celsius;

  Future<void> _fetchWeatherData() async {
    final String encodedLocation = Uri.encodeComponent(_currentLocation);
    final Uri uri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$encodedLocation&appid=$_apiKey&units=metric');
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

  double _convertTemperature(double temperature) {
    if (_currentUnit == TemperatureUnit.fahrenheit) {
      return (temperature * 9 / 5) + 32.0;
    } else {
      return temperature;
    }
  }

  IconData _getWeatherIcon(String weatherCondition) {
    switch (weatherCondition) {
      case 'Clear':
        return WeatherIcons.day_sunny;
      case 'Clouds':
        return WeatherIcons.cloudy;
      case 'Rain':
        return WeatherIcons.rain;
      case 'Snow':
        return WeatherIcons.snow;
      default:
        return WeatherIcons.day_sunny; // Default icon
    }
  }

  String _getImageAsset(String weatherCondition) {
    switch (weatherCondition) {
      case 'Clear':
        return 'assets/images/clear.jpg';
      case 'Clouds':
        return 'assets/images/clouds.jpg';
      case 'Rain':
        return 'assets/images/rain.jpg';
      case 'Snow':
        return 'assets/images/snow.jpg';
      default:
        return 'assets/images/default.jpg'; // Fallback image
    }
  }

  void _changeLocation() {
    setState(() {
      _currentLocation = _locationController.text;
      _fetchWeatherData();
      _locationController.clear();
    });
  }

  Future<void> _refreshWeatherData() async {
    setState(() {
      _weatherData = null; // Clear the current weather data before fetching new data
    });
    await _fetchWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _weatherData == null;
    final String weatherCondition = isLoading ? 'Default' : _weatherData!['weather'][0]['main'];

    return Scaffold(
      body: Image.asset(
        _getImageAsset(weatherCondition),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        colorBlendMode: BlendMode.darken,
        color: Colors.black87,
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Text(
              _weatherData!['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              '${_convertTemperature(_weatherData!['main']['temp']).toStringAsFixed(1)}°',
              style: const TextStyle(fontSize: 48, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Icon(
              _getWeatherIcon(_weatherData!['weather'][0]['main']),
              color: Colors.white,
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(
              _weatherData!['weather'][0]['description'],
              style: const TextStyle(fontSize: 24, color: Colors.white),
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
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _changeLocation,
                  child: const Text('Change Location'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _refreshWeatherData,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
            DropdownButton<TemperatureUnit>(
              value: _currentUnit,
              onChanged: (unit) {
                setState(() {
                  _currentUnit = unit!;
                });
              },
              items: [
                DropdownMenuItem(
                  value: TemperatureUnit.celsius,
                  child: Text('Celsius'),
                ),
                DropdownMenuItem(
                  value: TemperatureUnit.fahrenheit,
                  child: Text('Fahrenheit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum TemperatureUnit {
  celsius,
  fahrenheit,
}
