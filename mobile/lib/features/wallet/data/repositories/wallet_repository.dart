import '../datasources/wallet_remote_data_source.dart';
import '../models/wallet_model.dart';

final class WalletRepository {
  const WalletRepository({required WalletRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final WalletRemoteDataSource _remoteDataSource;

  Future<WalletModel> getCurrentWallet() {
    return _remoteDataSource.getCurrentWallet();
  }
}
