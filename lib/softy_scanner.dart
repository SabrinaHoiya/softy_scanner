/// A Flutter package for document scanning with camera support,
/// single/multiple page modes, and gallery import.
library;

// Domain — Entities
export 'src/domain/entities/scan_mode.dart';
export 'src/domain/entities/scan_result.dart';
export 'src/domain/entities/scanner_config.dart';
export 'src/domain/entities/scanner_locale.dart';

// Domain — Repository interfaces (for custom implementations)
export 'src/domain/repositories/camera_repository.dart';
export 'src/domain/repositories/gallery_repository.dart';
export 'src/domain/repositories/image_edit_repository.dart';
export 'src/domain/repositories/pdf_repository.dart';

// Domain — Use cases
export 'src/domain/usecases/capture_photo_usecase.dart';
export 'src/domain/usecases/crop_image_usecase.dart';
export 'src/domain/usecases/dispose_camera_usecase.dart';
export 'src/domain/usecases/generate_pdf_usecase.dart';
export 'src/domain/usecases/initialize_camera_usecase.dart';
export 'src/domain/usecases/pick_from_gallery_usecase.dart';
export 'src/domain/usecases/rotate_image_usecase.dart';
export 'src/domain/usecases/save_pdf_usecase.dart';
export 'src/domain/usecases/toggle_flash_usecase.dart';

// Data — Implementations (for DI overrides)
export 'src/data/datasources/camera_data_source.dart';
export 'src/data/datasources/gallery_data_source.dart';
export 'src/data/datasources/image_edit_data_source.dart';
export 'src/data/datasources/pdf_data_source.dart';
export 'src/data/repositories/camera_repository_impl.dart';
export 'src/data/repositories/gallery_repository_impl.dart';
export 'src/data/repositories/image_edit_repository_impl.dart';
export 'src/data/repositories/pdf_repository_impl.dart';

// Presentation — Scanner BLoC
export 'src/presentation/bloc/scanner_bloc.dart';
export 'src/presentation/bloc/scanner_event.dart';
export 'src/presentation/bloc/scanner_state.dart';

// Presentation — Review BLoC
export 'src/presentation/bloc/review_bloc.dart';
export 'src/presentation/bloc/review_event.dart';
export 'src/presentation/bloc/review_state.dart';

// Presentation — PDF Preview BLoC
export 'src/presentation/bloc/pdf_preview_bloc.dart';
export 'src/presentation/bloc/pdf_preview_event.dart';
export 'src/presentation/bloc/pdf_preview_state.dart';

// Presentation — Screens
export 'src/presentation/screens/scanner_screen.dart';
export 'src/presentation/screens/review_screen.dart';
export 'src/presentation/screens/crop_screen.dart';
export 'src/presentation/screens/pdf_preview_screen.dart';
