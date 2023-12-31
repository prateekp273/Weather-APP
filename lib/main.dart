import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:weather_icons/weather_icons.dart';

import 'api_keys.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final String _apiKey = apiKey;
  String _currentLocation = 'New York'; // Default location is New York
  Map<String, dynamic>? _weatherData;
  final TextEditingController _locationController = TextEditingController();
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
      _currentLocation = _locationController.text.trim();
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _getImageAsset(weatherCondition),
            fit: BoxFit.cover,
          ),
          isLoading
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                items: const [
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

              const SizedBox(height: 20),
              Text(
                'Date & Time: ${DateFormat.yMd().add_jm().format(DateTime.now())}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WeatherDetailTile(
                    icon: WeatherIcons.humidity,
                    label: 'Humidity',
                    value: '${_weatherData!['main']['humidity']}%',
                  ),
                  WeatherDetailTile(
                    icon: WeatherIcons.wind,
                    label: 'Wind',
                    value: '${_weatherData!['wind']['speed']} m/s',
                  ),
                  WeatherDetailTile(
                    icon: WeatherIcons.barometer,
                    label: 'Pressure',
                    value: '${_weatherData!['main']['pressure']} hPa',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WeatherDetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetailTile({super.key,
    required this.icon,
    required this.label,
    required this.value,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}
enum TemperatureUnit {
  celsius,
  fahrenheit,
}