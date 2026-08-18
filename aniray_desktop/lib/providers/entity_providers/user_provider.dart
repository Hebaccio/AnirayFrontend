import 'package:aniray_desktop/models/user/user_models.dart';
import 'package:http/http.dart' as http;
import 'package:aniray_desktop/providers/api_client.dart';
import 'package:aniray_desktop/providers/generic_crud_provider.dart';

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
