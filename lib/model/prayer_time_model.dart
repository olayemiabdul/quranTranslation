class PrayerDailyTimes {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String imsak;
  final String midnight;
  final String sunrise;
  final String sunset;

  PrayerDailyTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.midnight,
    required this.sunrise,
    required this.sunset,
  });

  factory PrayerDailyTimes.fromJson(Map<String, dynamic> json) {
    return PrayerDailyTimes(
      fajr: json['Fajr'],
      dhuhr: json['Dhuhr'],
      asr: json['Asr'],
      maghrib: json['Maghrib'],
      isha: json['Isha'],
      imsak: json['Imsak'],
      midnight: json['Midnight'],
      sunrise: json['Sunrise'],
      sunset: json['Sunset'],
    );
  }
}

class LocationInfo {
  final String city;
  final String country;

  LocationInfo({
    required this.city,
    required this.country,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      city: json['meta']['timezone'],
      country: json['meta']['timezone'], // Assuming meta contains location info; adjust as needed
    );
  }
}
