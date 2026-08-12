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
  bool _forceReloadPending = false;
  int _generation = 0;
  Future<void>? _activeLoad;

  WalletModel? get wallet => _wallet;
  AppException? get error => _error;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _wallet != null;

  Future<void> load({bool force = false}) {
    if (_isLoading) {
      if (force) {
        _forceReloadPending = true;
      }
      return _activeLoad ?? Future<void>.value();
    }

    if (hasLoaded && !force) {
      return Future<void>.value();
    }

    final Future<void> load = _runLoadLoop();
    _activeLoad = load;
    return load;
  }

  Future<void> _runLoadLoop() async {
    final int generation = _generation;
    _isLoading = true;
    _forceReloadPending = false;
    _error = null;
    notifyListeners();

    try {
      do {
        _forceReloadPending = false;
        try {
          final WalletModel wallet = await _walletRepository.getCurrentWallet();
          if (generation != _generation) {
            return;
          }
          _wallet = wallet;
          _error = null;
        } on AppException catch (exception) {
          if (generation != _generation) {
            return;
          }
          _error = exception;
        } catch (_) {
          if (generation != _generation) {
            return;
          }
          _error = const AppException(
            message: 'Something unexpected happened. Please try again.',
            type: AppExceptionType.unknown,
          );
        }
      } while (_forceReloadPending && generation == _generation);
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        _activeLoad = null;
        notifyListeners();
      }
    }
  }

  void clear() {
    _generation++;
    _wallet = null;
    _error = null;
    _isLoading = false;
    _forceReloadPending = false;
    _activeLoad = null;
    notifyListeners();
  }
}
