import 'package:core/core.dart';
import 'main_common.dart';

void main() async {
  await mainCommon(
    Flavor.fromString(
      // ignore: do_not_use_environment
      const String.fromEnvironment('environment', defaultValue: 'dev'),
    ),
  );
}