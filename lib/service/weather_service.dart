import 'dart:convert';
import 'package:http/http.dart' as http;
class WeatherService {
  String apiKey = "32ce0d0f8d8db1622a091c539c2b0c54";
  final String baseUrl = "https://api.openweathermap.org/data/2.5/weather";

  Future<Map<String, dynamic>?> getWeatherByCity(String city) async {
    final url = "$baseUrl?q=$city&appid=$apiKey&units=metric";
    try
    {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      else
      {
      print("API hatası: " + response.statusCode.toString());
      return null;
      }
    }
    catch (error) {
      print("API çağrı hatası: $error");
      return null;
    }
  }
}
