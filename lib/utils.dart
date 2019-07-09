import 'package:intl/intl.dart';

class Utils {
  static var dateTimeFormat = DateFormat.Hm();
  static var dateFullFormat = DateFormat('MMMM d');

  static String formatDateTimeFormat(int dt, int timeShiftSec) {
    var utc = (DateTime.fromMillisecondsSinceEpoch(dt * 1000).toUtc());
    return timeShiftSec > 0
        ? dateTimeFormat.format((utc.add(Duration(seconds: timeShiftSec))))
        : dateTimeFormat
            .format((utc.subtract(Duration(seconds: -timeShiftSec))));
  }

  static String formatDateFullFormat(DateTime dt) {
    return dateFullFormat.format(dt);
  }

  static String getTempUnit(String value) {
    return value == 'metric' ? '°C' : '°F';
  }

  static String getWeatherIconUrl(String icon) {
    return 'http://openweathermap.org/img/wn/$icon@2x.png';
  }

  static String getDefaultWeatherIcon() {
    return 'placeholder.jpg';
  }
}
