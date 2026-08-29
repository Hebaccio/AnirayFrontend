import 'package:http/http.dart' as http;
import '../../requests_and_models/entity_r&m/user/user_models.dart';
import '../generic_provider/api_client.dart';
import '../generic_provider/generic_crud_provider.dart';

class UserProvider
    extends
        GenericCrudProvider<
          UserMU,
          UserME,
          UserSOU,
          UserSOE,
          UserIRU,
          UserIRE,
          UserURU,
          UserURE
        > {
  UserProvider()
    : super(
        endpoint: 'User',
        apiClient: ApiClient(http.Client()),

        // Models
        modelUserFromJson: UserMU.fromJson,
        modelEmployeeFromJson: UserME.fromJson,

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
