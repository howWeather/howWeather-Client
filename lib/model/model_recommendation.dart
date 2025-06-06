class FeelingData {
  final int time;
  final double temperature;
  final int feeling;

  FeelingData({
    required this.time,
    required this.temperature,
    required this.feeling,
  });

  factory FeelingData.fromJson(Map<String, dynamic> json) {
    return FeelingData(
      time: json['time'],
      temperature: json['temperature'],
      feeling: json['feeling'],
    );
  }
}

class ModelRecommendation {
  final List<int> uppersTypeList;
  final List<int> outersTypeList;
  final List<FeelingData> feelingList;

  ModelRecommendation({
    required this.uppersTypeList,
    required this.outersTypeList,
    required this.feelingList,
  });

  factory ModelRecommendation.fromJson(Map<String, dynamic> json) {
    return ModelRecommendation(
      uppersTypeList: List<int>.from(json['uppersTypeList']),
      outersTypeList: List<int>.from(json['outersTypeList']),
      feelingList: (json['feelingList'] as List)
          .map((e) => FeelingData.fromJson(e))
          .toList(),
    );
  }
}
