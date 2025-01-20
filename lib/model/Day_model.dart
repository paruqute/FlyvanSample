class Day {
  late  String status;
  final String date;
  final bool? allocated;

  Day({required this.status, required this.date,this.allocated});

  // Factory method to create a Day object from JSON
  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      status: json['Status'] as String,
      date: json['Date'] as String,
      allocated: json['IsAllocated']?? false,
    );
  }

  // Convert a Day object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Status': status,
      'Date': date,
      'IsAllocated':allocated
    };
  }
}

class Days {
  final Day monday;
  final Day tuesday;
  final Day wednesday;
  final Day thursday;
  final Day friday;
  final Day saturday;
  final Day sunday;

  Days({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  // Factory method to create a Days object from JSON
  factory Days.fromJson(Map<String, dynamic> json) {
    return Days(
      monday: Day.fromJson(json['Monday']),
      tuesday: Day.fromJson(json['Tuesday']),
      wednesday: Day.fromJson(json['Wednesday']),
      thursday: Day.fromJson(json['Thursday']),
      friday: Day.fromJson(json['Friday']),
      saturday: Day.fromJson(json['Saturday']),
      sunday: Day.fromJson(json['Sunday']),
    );
  }

  // Convert a Days object to JSON
  Map<String, dynamic> toJson() {
    return {
      'Monday': monday.toJson(),
      'Tuesday': tuesday.toJson(),
      'Wednesday': wednesday.toJson(),
      'Thursday': thursday.toJson(),
      'Friday': friday.toJson(),
      'Saturday': saturday.toJson(),
      'Sunday': sunday.toJson(),
    };
  }
}
