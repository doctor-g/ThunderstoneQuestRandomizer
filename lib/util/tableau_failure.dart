class TableauFailureException implements Exception {
  String cause;
  TableauFailureException(this.cause);
}
