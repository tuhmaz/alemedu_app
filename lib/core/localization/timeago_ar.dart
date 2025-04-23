import 'package:timeago/timeago.dart' as timeago;

class TimeagoAr implements timeago.LookupMessages {
  @override String prefixAgo() => 'منذ';
  @override String prefixFromNow() => 'في';
  @override String suffixAgo() => '';
  @override String suffixFromNow() => 'من الآن';
  @override String lessThanOneMinute(int seconds) => 'لحظات';
  @override String aboutAMinute(int minutes) => 'دقيقة';
  @override String minutes(int minutes) => '$minutes دقائق';
  @override String aboutAnHour(int minutes) => 'ساعة';
  @override String hours(int hours) => '$hours ساعات';
  @override String aDay(int hours) => 'يوم';
  @override String days(int days) => '$days أيام';
  @override String aboutAMonth(int days) => 'شهر';
  @override String months(int months) => '$months أشهر';
  @override String aboutAYear(int year) => 'سنة';
  @override String years(int years) => '$years سنوات';
  @override String wordSeparator() => ' ';
}
