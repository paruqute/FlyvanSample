class Station {
  String? name;

  Station({this.name});

  Station.fromJson(Map<String, dynamic> json) {
    name = json['StationName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['StationName'] = name;
    return data;
  }

  static List<Station> convertToList(List<dynamic> list) {
    List<Station> station = [];
    for (var element in list) {
      station.add(Station.fromJson(element));
    }
    return station;
  }

}
