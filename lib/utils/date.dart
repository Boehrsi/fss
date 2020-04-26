import 'package:intl/intl.dart';

DateFormat _dateFormat = DateFormat('yyyy.MM.dd - HH:mm');

extension DateFormatting on int {
  String formattedDate() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(this);
    return _dateFormat.format(dateTime);
  }
}
