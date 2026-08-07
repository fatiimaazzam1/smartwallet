import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/wallet_model.dart';
import '../../data/repositories/wallet_repository.dart';

final class WalletController extends ChangeNotifier {
  WalletController({required WalletRepository walletRepository})
    : _walletRepository = walletRepository;

  final WalletRepository _walletRepository;

  WalletModel? _wallet;
  AppException? _error;
  bool _isLoading = false;

  WalletModel? get wallet => _wallet;
  AppException? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _wallet != null;

  Future<void> load({bool force = false}) async {
    if (_isLoading || (hasLoaded && !force)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallet = await _walletRepository.getCurrentWallet();
    } on AppException catch (exception) {
      _error = exception;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _wallet = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
