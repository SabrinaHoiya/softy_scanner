/// Supported locales for the scanner UI.
enum ScannerLocale { en, fr, ar }

/// All translatable strings for a given locale.
class ScannerStrings {
  final String scanLabel;
  final String cancelLabel;
  final String continueLabel;
  final String galleryLabel;
  final String uniqueLabel;
  final String multipleLabel;
  final String addLabel;
  final String rotationLabel;
  final String cropLabel;
  final String deleteLabel;
  final String effectuerLabel;
  final String continueAddPagesLabel;
  final String titleLabel;
  final String confirmLabel;
  final String defaultTitlePrefix;
  final String reorderPagesLabel;
  final String selectAllLabel;
  final String reorderInstructionLabel;
  final String modifyLabel;
  final String removeLabel;
  final String saveAndSendLabel;
  final String addPagesLabel;

  const ScannerStrings({
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

  static const en = ScannerStrings(
    scanLabel: 'Scan',
    cancelLabel: 'Cancel',
    continueLabel: 'Continue',
    galleryLabel: 'Gallery',
    uniqueLabel: 'Single',
    multipleLabel: 'Multiple',
    addLabel: 'Add',
    rotationLabel: 'Rotate',
    cropLabel: 'Crop',
    deleteLabel: 'Delete',
    effectuerLabel: 'Done',
    continueAddPagesLabel: 'Continue adding pages',
    titleLabel: 'Title',
    confirmLabel: 'Confirm',
    defaultTitlePrefix: 'Scan',
    reorderPagesLabel: 'Reorder pages',
    selectAllLabel: 'Select all',
    reorderInstructionLabel: 'Hold and drag to reorder',
    modifyLabel: 'Edit',
    removeLabel: 'Delete',
    saveAndSendLabel: 'Save and send',
    addPagesLabel: 'Add',
  );

  static const fr = ScannerStrings(
    scanLabel: 'Scan',
    cancelLabel: 'Annuler',
    continueLabel: 'Continuer',
    galleryLabel: 'Galerie',
    uniqueLabel: 'Unique',
    multipleLabel: 'Multiple',
    addLabel: 'Ajouter',
    rotationLabel: 'Rotation',
    cropLabel: 'Recadrer',
    deleteLabel: 'Supprimer',
    effectuerLabel: 'Effectuer',
    continueAddPagesLabel: 'Continuer \u00e0 ajouter des pages',
    titleLabel: 'Titre',
    confirmLabel: 'Confirmer',
    defaultTitlePrefix: 'Scan',
    reorderPagesLabel: 'R\u00e9organiser pages',
    selectAllLabel: 'Tout s\u00e9lect.',
    reorderInstructionLabel:
        'Maintenez et faites glisser pour r\u00e9organiser',
    modifyLabel: 'Modifier',
    removeLabel: 'Supprimer',
    saveAndSendLabel: 'Enregistrer et envoyer',
    addPagesLabel: 'Ajouter',
  );

  static const ar = ScannerStrings(
    scanLabel: '\u0645\u0633\u062d',
    cancelLabel: '\u0625\u0644\u063a\u0627\u0621',
    continueLabel: '\u0645\u062a\u0627\u0628\u0639\u0629',
    galleryLabel: '\u0627\u0644\u0645\u0639\u0631\u0636',
    uniqueLabel: '\u0641\u0631\u062f\u064a',
    multipleLabel: '\u0645\u062a\u0639\u062f\u062f',
    addLabel: '\u0625\u0636\u0627\u0641\u0629',
    rotationLabel: '\u062a\u062f\u0648\u064a\u0631',
    cropLabel: '\u0642\u0635',
    deleteLabel: '\u062d\u0630\u0641',
    effectuerLabel: '\u062a\u0623\u0643\u064a\u062f',
    continueAddPagesLabel:
        '\u0645\u062a\u0627\u0628\u0639\u0629 \u0625\u0636\u0627\u0641\u0629 \u0627\u0644\u0635\u0641\u062d\u0627\u062a',
    titleLabel: '\u0627\u0644\u0639\u0646\u0648\u0627\u0646',
    confirmLabel: '\u062a\u0623\u0643\u064a\u062f',
    defaultTitlePrefix: '\u0645\u0633\u062d',
    reorderPagesLabel:
        '\u0625\u0639\u0627\u062f\u0629 \u062a\u0631\u062a\u064a\u0628',
    selectAllLabel:
        '\u062a\u062d\u062f\u064a\u062f \u0627\u0644\u0643\u0644',
    reorderInstructionLabel:
        '\u0627\u0636\u063a\u0637 \u0645\u0637\u0648\u0644\u0627\u064b \u0648\u0627\u0633\u062d\u0628 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u062a\u0631\u062a\u064a\u0628',
    modifyLabel: '\u062a\u0639\u062f\u064a\u0644',
    removeLabel: '\u062d\u0630\u0641',
    saveAndSendLabel:
        '\u062d\u0641\u0638 \u0648\u0625\u0631\u0633\u0627\u0644',
    addPagesLabel: '\u0625\u0636\u0627\u0641\u0629',
  );

  static ScannerStrings forLocale(ScannerLocale locale) {
    switch (locale) {
      case ScannerLocale.en:
        return en;
      case ScannerLocale.fr:
        return fr;
      case ScannerLocale.ar:
        return ar;
    }
  }
}
