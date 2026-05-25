enum Flavor {
  dev,
  stage,
  prod;

  static Flavor fromString(String value) {
    switch (value.toLowerCase()) {
      case 'dev':
        return Flavor.dev;
      case 'stage':
      case 'staging':
        return Flavor.stage;
      case 'prod':
      case 'production':
        return Flavor.prod;
      default:
        return Flavor.dev;
    }
  }
}

class AppConfig {
  final Flavor flavor;
  final String apiBaseUrl;

  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
  });

  factory AppConfig.fromFlavor(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        return const AppConfig(
          flavor: Flavor.dev,
          apiBaseUrl: 'https://dev-api.example.com',
        );
      case Flavor.stage:
        return const AppConfig(
          flavor: Flavor.stage,
          apiBaseUrl: 'https://stage-api.example.com',
        );
      case Flavor.prod:
        return const AppConfig(
          flavor: Flavor.prod,
          apiBaseUrl: 'https://api.example.com',
        );
    }
  }
}
