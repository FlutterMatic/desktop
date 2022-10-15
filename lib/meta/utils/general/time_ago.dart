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
    return '$days day${days > 1 ? 's' : ''} ago';
  } else if (hours > 0) {
    return '$hours hour${hours > 1 ? 's' : ''} ago';
  } else if (minutes > 0) {
    return '$minutes minute${minutes > 1 ? 's' : ''} ago';
  } else if (seconds > 0) {
    return '$seconds second${seconds > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}
