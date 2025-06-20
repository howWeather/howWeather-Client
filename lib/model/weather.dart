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

  factory Weather.fromJson(Map<String, dynamic> json, String koreanName) {
    return Weather(
      name: koreanName,
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temperature: (json['main']['temp'] as num).toDouble(),
    );
  }
}

class HourlyWeather {
  final DateTime dateTime;
  final double temperature;
  final double humidity;
  final String icon;
  final String description;

  HourlyWeather({
    required this.dateTime,
    required this.temperature,
    required this.humidity,
    required this.icon,
    required this.description,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    final dtText = json['dt_txt'] as String;
    final utcDateTime = DateTime.parse(dtText);
    final kstDateTime = utcDateTime.add(Duration(hours: 9));

    return HourlyWeather(
      dateTime: kstDateTime,
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      icon: (json['weather'][0]['icon']),
      description: json['weather'][0]['description'],
    );
  }
}

class DailyWeather {
  final DateTime dateTime;
  final int humidity;
  final String icon;
  final double maxTemp;
  final double minTemp;

  DailyWeather({
    required this.dateTime,
    required this.humidity,
    required this.icon,
    required this.maxTemp,
    required this.minTemp,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    final temps = (json['temps'] as Map<String, dynamic>);
    final humidities = (json['humidities'] as List).cast<int>();
    final icons = (json['weather_icons'] as List).cast<String>();

    return DailyWeather(
      dateTime: DateTime.parse(json['date']),
      humidity: humidities.reduce((a, b) => a + b) ~/ humidities.length,
      icon: icons.isNotEmpty ? icons[0] : 'default_icon', // 첫 시간대 아이콘 사용
      maxTemp: temps['max'].toDouble(),
      minTemp: temps['min'].toDouble(),
    );
  }
}
