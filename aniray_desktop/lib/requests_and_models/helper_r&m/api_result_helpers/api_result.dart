class ApiResult<T> {
  final int? statusCode;
  final T? data;
  final String? message;

  const ApiResult({required this.statusCode, this.data, this.message});
}
