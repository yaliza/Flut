import 'package:intl/intl.dart';

var dateTimeFormat = DateFormat.Hm();
var dateFullFormat = DateFormat('MMMM d');

String formatDateTimeFormat(int dt, int timeShiftSec) {
  var utc = (DateTime.fromMillisecondsSinceEpoch(dt * 1000).toUtc());
  return timeShiftSec > 0
      ? dateTimeFormat.format((utc.add(Duration(seconds: timeShiftSec))))
      : dateTimeFormat.format((utc.subtract(Duration(seconds: -timeShiftSec))));
}

String formatDateFullFormat(DateTime dt) {
  return dateFullFormat.format(dt);
}

String getTempUnit(String value) {
  return value == 'metric' ? '°C' : '°F';
}

String getWeatherIconUrl(String icon) {
  return 'http://openweathermap.org/img/wn/$icon@2x.png';
}

String getDefaultWeatherIcon() {
  return 'placeholder.jpg';
}
