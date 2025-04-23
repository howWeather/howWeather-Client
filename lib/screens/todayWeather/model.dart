class Weather {
  final String description;
  final String icon;
  final double temperature;

  Weather({
    required this.description,
    required this.icon,
    required this.temperature,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      temperature: (json['main']['temp'] as num).toDouble(),
    );
  }
}
