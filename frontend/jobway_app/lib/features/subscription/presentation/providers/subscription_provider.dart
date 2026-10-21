import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/datasources/subscription_remote_data_source.dart';
import '../../data/repository/subscription_repository_impl.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repository/subscription_repository.dart';
import '../../domain/usecases/get_my_subscription_usecase.dart';

final subscriptionRemoteDataSourceProvider = Provider(
  (ref) => SubscriptionRemoteDataSource(ref.read(dioClientProvider).dio),
);

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepositoryImpl(ref.read(subscriptionRemoteDataSourceProvider)),
);

final getMySubscriptionUseCaseProvider = Provider(
  (ref) => GetMySubscriptionUseCase(ref.read(subscriptionRepositoryProvider)),
);

final subscriptionProvider = FutureProvider.autoDispose<Subscription>(
  (ref) => ref.read(getMySubscriptionUseCaseProvider)(),
);