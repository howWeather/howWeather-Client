class Weather {
  final String name;
  final String description;
  final String icon;
  final double temperature;

  Weather({
    required this.name,
    required this.description,
    required this.icon,
    required this.temperature,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      name: json['name'] ?? "",
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temperature: (json['main']['temp'] as num).toDouble(),
    );
  }
}

class HourlyWeather {
  final DateTime dateTime;
  final double temperature;
  final double precipitation; // mm
  final String icon;
  final String description;

  HourlyWeather({
    required this.dateTime,
    required this.temperature,
    required this.precipitation,
    required this.icon,
    required this.description,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      dateTime: DateTime.parse(json['dt_txt']),
      temperature: (json['main']['temp'] as num).toDouble(),
      precipitation: (json['rain']?['3h'] ?? 0).toDouble(),
      icon: (json['weather'][0]['icon']),
      description: json['weather'][0]['description'],
    );
  }
}
