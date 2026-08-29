abstract class BaseProvider {
  final String endpoint;

  const BaseProvider(this.endpoint);

  String get baseUrl => const String.fromEnvironment(
    'baseUrl',
    defaultValue: 'https://10.0.2.2:7247/',
  );

  String get url {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;

    return '$normalizedBaseUrl/$normalizedEndpoint';
  }
}
