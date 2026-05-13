import 'package:flutter_test/flutter_test.dart';
import 'package:softy_scanner/softy_scanner.dart';

void main() {
  group('ScanResult', () {
    test('cancelled result has no pages and isCancelled is true', () {
      const result = ScanResult.cancelled();
      expect(result.isCancelled, isTrue);
      expect(result.hasPages, isFalse);
      expect(result.pageCount, 0);
    });

    test('result with empty pages list is not cancelled by default', () {
      const result = ScanResult(scannedPages: []);
      expect(result.isCancelled, isFalse);
      expect(result.hasPages, isFalse);
    });

    test('supports value equality', () {
      const a = ScanResult(scannedPages: []);
      const b = ScanResult(scannedPages: []);
      expect(a, equals(b));
    });
  });

  group('ScannerConfig', () {
    test('default config has expected values', () {
      final config = ScannerConfig();
      expect(config.initialMode, ScanMode.multiple);
      expect(config.allowModeSwitch, isTrue);
      expect(config.resolution, CameraResolution.high);
      expect(config.locale, ScannerLocale.fr);
      expect(config.scanLabel, 'Scan');
      expect(config.cancelLabel, 'Annuler');
      expect(config.continueLabel, 'Continuer');
      expect(config.galleryLabel, 'Galerie');
    });

    test('custom config overrides defaults', () {
      final config = ScannerConfig(
        initialMode: ScanMode.multiple,
        allowModeSwitch: false,
        scanLabel: 'Numériser',
        cancelLabel: 'Annuler',
        continueLabel: 'Continuer',
      );
      expect(config.initialMode, ScanMode.multiple);
      expect(config.allowModeSwitch, isFalse);
      expect(config.scanLabel, 'Numériser');
      expect(config.cancelLabel, 'Annuler');
      expect(config.continueLabel, 'Continuer');
    });
  });

  group('ScanMode', () {
    test('has two values', () {
      expect(ScanMode.values.length, 2);
      expect(ScanMode.values, contains(ScanMode.unique));
      expect(ScanMode.values, contains(ScanMode.multiple));
    });
  });
}
