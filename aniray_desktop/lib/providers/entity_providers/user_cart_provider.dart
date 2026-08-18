import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:aniray_desktop/models/user_cart/usercart_models.dart';
import 'package:http/http.dart' as http;
import 'package:aniray_desktop/providers/api_client.dart';
import 'package:aniray_desktop/providers/generic_crud_provider.dart';

class UserCartProvider
    extends
        GenericCrudProvider<
          UserCartMU,
          UserCartME,
          BaseSO,
          BaseSO,
          UserCartIRU,
          UserCartIRE,
          UserCartURU,
          UserCartURE
        > {
  UserCartProvider()
    : super(
        endpoint: 'UserCart',
        apiClient: ApiClient(http.Client()),

        // Models
        modelUserFromJson: UserCartMU.fromJson,
        modelEmployeeFromJson: UserCartME.fromJson,

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
