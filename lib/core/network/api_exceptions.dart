class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Unable to connect to S3T server. Please check your network or backend server.'})
      : super(statusCode: null);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Your session has expired. Please log in again.'})
      : super(statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException({super.message = 'The requested resource was not found.'})
      : super(statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({super.message = 'A server error occurred. Please try again later.'})
      : super(statusCode: 500);
}
