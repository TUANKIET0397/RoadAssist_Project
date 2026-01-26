import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_storage_service.dart';

final firebaseStorageProvider = Provider<FirebaseStorageService>(
      (ref) => FirebaseStorageService(),
);
