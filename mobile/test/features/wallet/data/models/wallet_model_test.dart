import 'package:flutter_test/flutter_test.dart';
import 'package:smartwallet_mobile/features/wallet/data/models/wallet_model.dart';

void main() {
  test('parses the authenticated wallet response', () {
    final WalletModel wallet = WalletModel.fromJson(<String, dynamic>{
      'id': 11,
      'name': 'Personal Wallet',
      'currencyCode': 'usd',
      'balance': 0,
    });

    expect(wallet.id, 11);
    expect(wallet.name, 'Personal Wallet');
    expect(wallet.currencyCode, 'USD');
    expect(wallet.balance, 0);
  });

  test('rejects an invalid currency code', () {
    expect(
      () => WalletModel.fromJson(<String, dynamic>{
        'id': 11,
        'name': 'Personal Wallet',
        'currencyCode': 'US',
        'balance': 0,
      }),
      throwsFormatException,
    );
  });
}
