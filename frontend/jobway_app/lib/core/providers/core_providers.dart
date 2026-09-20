import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider((ref) => TokenStorage());

final dioClientProvider = Provider((ref) => DioClient(ref.read(tokenStorageProvider)));