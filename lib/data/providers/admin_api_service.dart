import '../models/customer_model.dart';
import '../models/request_model.dart';
import '../models/review_model.dart';
import 'mock_data.dart';

class AdminApiService {
  const AdminApiService();

  List<CustomerModel> fetchCustomers() => MockData.customers;

  List<RequestModel> fetchRequests() => MockData.requests;

  List<ReviewModel> fetchReviews() => MockData.reviews;
}
