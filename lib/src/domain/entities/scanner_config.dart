import 'package:flutter/material.dart';

import 'scan_mode.dart';
import 'scanner_locale.dart';

/// Configuration options for the scanner screen.
///
/// Pass [locale] to automatically translate all labels:
/// ```dart
/// ScannerConfig(locale: ScannerLocale.fr)
/// ```
/// Individual labels can still be overridden:
/// ```dart
/// ScannerConfig(locale: ScannerLocale.ar, scanLabel: 'Custom')
/// ```
class ScannerConfig {
  /// The initial scan mode (unique or multiple). Defaults to [ScanMode.unique].
  final ScanMode initialMode;

  /// Whether the user can toggle between unique and multiple modes.
  final bool allowModeSwitch;

  /// The preferred camera resolution.
  final CameraResolution resolution;

  /// Primary accent color used for the "Scan" label and active elements.
  final Color accentColor;

  /// Background color of the top and bottom bars.
  final Color barColor;

  /// The locale used for all labels.
  final ScannerLocale locale;

  // ── Scanner screen labels ──────────────────────────────────────────────

  final String scanLabel;
  final String cancelLabel;
  final String continueLabel;
  final String galleryLabel;
  final String uniqueLabel;
  final String multipleLabel;

  // ── Review screen labels ───────────────────────────────────────────────

  final String addLabel;
  final String rotationLabel;
  final String cropLabel;
  final String deleteLabel;
  final String effectuerLabel;
  final String continueAddPagesLabel;
  final String titleLabel;
  final String confirmLabel;
  final String defaultTitlePrefix;

  // ── PDF preview screen labels ──────────────────────────────────────────

  final String reorderPagesLabel;
  final String selectAllLabel;
  final String reorderInstructionLabel;
  final String modifyLabel;
  final String removeLabel;
  final String saveAndSendLabel;
  final String addPagesLabel;

  /// Creates a scanner configuration.
  ///
  /// All label defaults are resolved from [locale] (defaults to [ScannerLocale.fr]).
  /// Any explicitly passed label overrides the locale default.
  factory ScannerConfig({
    ScanMode initialMode = ScanMode.multiple,
    bool allowModeSwitch = true,
    CameraResolution resolution = CameraResolution.high,
    Color accentColor = const Color(0xFF31A7DF),
    Color barColor = const Color(0xFF1A1A2E),
    ScannerLocale locale = ScannerLocale.fr,
    String? scanLabel,
    String? cancelLabel,
    String? continueLabel,
    String? galleryLabel,
    String? uniqueLabel,
    String? multipleLabel,
    String? addLabel,
    String? rotationLabel,
    String? cropLabel,
    String? deleteLabel,
    String? effectuerLabel,
    String? continueAddPagesLabel,
    String? titleLabel,
    String? confirmLabel,
    String? defaultTitlePrefix,
    String? reorderPagesLabel,
    String? selectAllLabel,
    String? reorderInstructionLabel,
    String? modifyLabel,
    String? removeLabel,
    String? saveAndSendLabel,
    String? addPagesLabel,
  }) {
    final s = ScannerStrings.forLocale(locale);
    return ScannerConfig._(
      initialMode: initialMode,
      allowModeSwitch: allowModeSwitch,
      resolution: resolution,
      accentColor: accentColor,
      barColor: barColor,
      locale: locale,
      scanLabel: scanLabel ?? s.scanLabel,
      cancelLabel: cancelLabel ?? s.cancelLabel,
      continueLabel: continueLabel ?? s.continueLabel,
      galleryLabel: galleryLabel ?? s.galleryLabel,
      uniqueLabel: uniqueLabel ?? s.uniqueLabel,
      multipleLabel: multipleLabel ?? s.multipleLabel,
      addLabel: addLabel ?? s.addLabel,
      rotationLabel: rotationLabel ?? s.rotationLabel,
      cropLabel: cropLabel ?? s.cropLabel,
      deleteLabel: deleteLabel ?? s.deleteLabel,
      effectuerLabel: effectuerLabel ?? s.effectuerLabel,
      continueAddPagesLabel:
          continueAddPagesLabel ?? s.continueAddPagesLabel,
      titleLabel: titleLabel ?? s.titleLabel,
      confirmLabel: confirmLabel ?? s.confirmLabel,
      defaultTitlePrefix: defaultTitlePrefix ?? s.defaultTitlePrefix,
      reorderPagesLabel: reorderPagesLabel ?? s.reorderPagesLabel,
      selectAllLabel: selectAllLabel ?? s.selectAllLabel,
      reorderInstructionLabel:
          reorderInstructionLabel ?? s.reorderInstructionLabel,
      modifyLabel: modifyLabel ?? s.modifyLabel,
      removeLabel: removeLabel ?? s.removeLabel,
      saveAndSendLabel: saveAndSendLabel ?? s.saveAndSendLabel,
      addPagesLabel: addPagesLabel ?? s.addPagesLabel,
    );
  }

  const ScannerConfig._({
    required this.initialMode,
    required this.allowModeSwitch,
    required this.resolution,
    required this.accentColor,
    required this.barColor,
    required this.locale,
    required this.scanLabel,
    required this.cancelLabel,
    required this.continueLabel,
    required this.galleryLabel,
    required this.uniqueLabel,
    required this.multipleLabel,
    required this.addLabel,
    required this.rotationLabel,
    required this.cropLabel,
    required this.deleteLabel,
    required this.effectuerLabel,
    required this.continueAddPagesLabel,
    required this.titleLabel,
    required this.confirmLabel,
    required this.defaultTitlePrefix,
    required this.reorderPagesLabel,
    required this.selectAllLabel,
    required this.reorderInstructionLabel,
    required this.modifyLabel,
    required this.removeLabel,
    required this.saveAndSendLabel,
    required this.addPagesLabel,
  });
}

/// Camera resolution preset.
enum CameraResolution { low, medium, high, veryHigh, max }
