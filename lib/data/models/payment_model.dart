class PaymentModel {
  final String customer;
  final double amount;
  final String method;
  final DateTime date;

  const PaymentModel({
    required this.customer,
    required this.amount,
    required this.method,
    required this.date,
  });
}
