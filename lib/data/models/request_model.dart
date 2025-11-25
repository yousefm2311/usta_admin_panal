class RequestModel {
  final String service;
  final String customer;
  final String artisan;
  final String status;
  final DateTime date;
  final double price;

  const RequestModel({
    required this.service,
    required this.customer,
    required this.artisan,
    required this.status,
    required this.date,
    required this.price,
  });
}
