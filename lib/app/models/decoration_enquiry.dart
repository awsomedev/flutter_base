import 'package:madeira/app/models/decorations_response_model.dart';
import 'package:madeira/app/models/user_model.dart';

class DecorationEnquiry {
  final DecorationResponse enquiry;
  final User enquiryUser;
  final String note;

  DecorationEnquiry({
    required this.enquiry,
    required this.enquiryUser,
    required this.note,
  });
}
