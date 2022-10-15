class NotificationObject {
  final int id;
  final String title;
  final String message;
  final Function()? onPressed;
  final DateTime? timestamp;

  const NotificationObject(
    this.id, {
    required this.title,
    required this.message,
    required this.onPressed,
    this.timestamp,
  });
}
