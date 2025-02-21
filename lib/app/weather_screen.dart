import 'package:flutter/material.dart';
import 'package:weather/service/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>> weatherHistory = [];
  Color backgroundColor = Colors.blueGrey[900]!; // Varsayılan arka plan rengi

  void fetchWeather() async {
    if (_cityController.text.isEmpty) return;

    final data = await _weatherService.getWeatherByCity(_cityController.text);
    setState(() {
      weatherHistory.insert(0, data!);
      backgroundColor = getBackgroundColor(data['weather'][0]['main']);
    });

    _cityController.clear();
  }

  Color getBackgroundColor(String weatherCondition) {
    switch (weatherCondition.toLowerCase()) {
      case 'clear':
        return Colors.orangeAccent; // Güneşli hava
      case 'clouds':
        return Colors.blueGrey; // Bulutlu hava
      case 'rain':
      case 'drizzle':
        return Colors.blue; // Yağmurlu hava
      case 'snow':
        return Colors.white70; // Karlı hava
      case 'thunderstorm':
        return Colors.deepPurple; // Fırtına
      default:
        return Colors.grey; // Varsayılan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _cityController,
            style: TextStyle(color: Colors.white),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: "Şehir Adı Giriniz...",
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              suffixIcon: IconButton(
                icon: Icon(Icons.search, color: Colors.white),
                onPressed: fetchWeather,
              ),
            ),
            onSubmitted: (value) => fetchWeather(),
          ),
        ),
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: weatherHistory.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(weatherHistory[index]['name']),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                setState(() {
                  weatherHistory.removeAt(index);
                });
              },
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.red, Colors.black]),
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white, size: 30),
              ),
              child: GestureDetector(
                onTap: () => showWeatherDetails(context, weatherHistory[index]),
                child: WeatherCard(weatherHistory[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  void showWeatherDetails(
      BuildContext context, Map<String, dynamic> weatherData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${weatherData['name']} - ${weatherData['main']['temp']}°C",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                "Hissedilen: ${weatherData['main']['feels_like']}°C",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              Text(
                "Nem: ${weatherData['main']['humidity']}%",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              Text(
                "Basınç: ${weatherData['main']['pressure']} hPa",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              Text(
                "Rüzgar Hızı: ${weatherData['wind']['speed']} m/s",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Kapat",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WeatherCard extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  WeatherCard(this.weatherData);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      color: Colors.white.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[900]!, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "${weatherData['name']}",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "${weatherData['main']['temp']}°C",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.water_drop, color: Colors.blue, size: 30),
                    SizedBox(height: 5),
                    Text(
                      "Nem: ${weatherData['main']['humidity']}%",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.air, color: Colors.green, size: 30),
                    SizedBox(height: 5),
                    Text(
                      "Rüzgar: ${weatherData['wind']['speed']} m/s",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
