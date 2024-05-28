class DurationFormatter {
  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes - hours * 60);
    final seconds = (duration.inSeconds - hours * 3600 - minutes * 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}