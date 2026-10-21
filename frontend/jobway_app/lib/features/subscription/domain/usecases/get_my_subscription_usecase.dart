import '../entities/subscription.dart';
import '../repository/subscription_repository.dart';

class GetMySubscriptionUseCase {
  final SubscriptionRepository _repository;

  GetMySubscriptionUseCase(this._repository);

  Future<Subscription> call() => _repository.getMy();
}