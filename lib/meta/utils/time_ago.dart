String getTimeAgo(DateTime date) {
  DateTime now = DateTime.now();
  Duration difference = now.difference(date);
  int days = difference.inDays;
  int hours = difference.inHours;
  int minutes = difference.inMinutes;
  int seconds = difference.inSeconds;
  if (days > 6) {
    return '${date.day}/${date.month}/${date.year}';
  } else if (days > 0) {
    return '$days days ago';
  } else if (hours > 0) {
    return '$hours hours ago';
  } else if (minutes > 0) {
    return '$minutes minutes ago';
  } else if (seconds > 0) {
    return '$seconds seconds ago';
  } else {
    return 'Just now';
  }
}
