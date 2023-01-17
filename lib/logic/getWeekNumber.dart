int getWeekNumber(DateTime Date) {
  int weeksBetween(DateTime from, DateTime to) {
    from = DateTime.utc(from.year, from.month, from.day);
    to = DateTime.utc(to.year, to.month, to.day);
    return (to.difference(from).inDays / 7).ceil();
  }

  var date = Date;
  var firstJan = DateTime(Date.year, 1, 1);
  return weeksBetween(firstJan, date);
}
