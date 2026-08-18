import 'package:aniray_desktop/models/order/order_models.dart';
import 'package:http/http.dart' as http;
import 'package:aniray_desktop/providers/api_client.dart';
import 'package:aniray_desktop/providers/generic_crud_provider.dart';

class OrderProvider
    extends
        GenericCrudProvider<
          OrderMU,
          OrderME,
          OrderSOU,
          OrderSOE,
          OrderIRU,
          OrderIRE,
          OrderURU,
          OrderURE
        > {
  OrderProvider()
    : super(
        endpoint: 'Order',
        apiClient: ApiClient(http.Client()),

        // Models
        modelUserFromJson: OrderMU.fromJson,
        modelEmployeeFromJson: OrderME.fromJson,

        // Searches
        searchUserToJson: (value) => value.toJson(),
        searchEmployeeToJson: (value) => value.toJson(),

        // Inserts
        insertUserToJson: (value) => value.toJson(),
        insertEmployeeToJson: (value) => value.toJson(),

        // Updates
        updateUserToJson: (value) => value.toJson(),
        updateEmployeeToJson: (value) => value.toJson(),
      );
}
