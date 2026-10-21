import '../../domain/entities/subscription.dart';
import '../../domain/repository/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _remoteDataSource;

  SubscriptionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Subscription> getMy() async {
    final model = await _remoteDataSource.getMy();
    return model.toEntity();
  }
}