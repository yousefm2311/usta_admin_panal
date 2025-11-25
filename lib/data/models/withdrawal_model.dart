class WithdrawalModel {
  final String artisan;
  final double amount;
  final String iban;
  final String status;

  const WithdrawalModel({
    required this.artisan,
    required this.amount,
    required this.iban,
    required this.status,
  });
}
