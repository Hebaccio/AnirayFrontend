class ApiResponse<T> {
  final int statusCode;
  final T body;

  const ApiResponse({required this.statusCode, required this.body});
}
