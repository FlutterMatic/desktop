class ProgressEvent {
  final int contentLength;
  final int downloadedLength;

  const ProgressEvent(this.contentLength, this.downloadedLength);
}
