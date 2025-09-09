class LocationTemperature {
  final String regionName;
  final double temperature;

  LocationTemperature({
    required this.regionName,
    required this.temperature,
  });

  factory LocationTemperature.fromJson(Map<String, dynamic> json) {
    return LocationTemperature(
      regionName: json['regionName'],
      temperature: (json['temperature'] as num).toDouble(),
    );
  }
}
