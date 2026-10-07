import 'package:flutter_test/flutter_test.dart';
import 'package:gaan_shuni/core/constants/app_constants.dart';
import 'package:gaan_shuni/core/utils/duration_formatter.dart';

void main() {
  group('DurationFormatter', () {
    test('formats short duration correctly', () {
      expect(DurationFormatter.format(0), '00:00');
      expect(DurationFormatter.format(65000), '01:05');
      expect(DurationFormatter.format(125000), '02:05');
    });

    test('formats long duration with hours', () {
      expect(DurationFormatter.format(3665000), '1:01:05');
    });

    test('formats file size correctly', () {
      expect(DurationFormatter.formatFileSize(1024), '1.0 KB');
      expect(DurationFormatter.formatFileSize(1048576 * 5), '5.0 MB');
    });
  });

  group('AppConstants', () {
    test('has correct app identity', () {
      expect(AppConstants.appName, 'Gaan Shuni');
    });
  });
}
