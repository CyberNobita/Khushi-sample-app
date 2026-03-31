class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class ApiException extends AppException {
  const ApiException(super.message);
}
