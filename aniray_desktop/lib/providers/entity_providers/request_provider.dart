import 'package:aniray_desktop/requests_and_models/entity_r&m/request/request_models.dart';
import 'package:http/http.dart' as http;
import 'package:aniray_desktop/providers/generic_provider/api_client.dart';
import 'package:aniray_desktop/providers/generic_provider/generic_crud_provider.dart';

class RequestProvider
    extends
        GenericCrudProvider<
          RequestMU,
          RequestME,
          RequestSOU,
          RequestSOE,
          RequestIRU,
          RequestIRE,
          RequestURU,
          RequestURE
        > {
  RequestProvider()
    : super(
        endpoint: 'Request',
        apiClient: ApiClient(http.Client()),

        // Models
        modelUserFromJson: RequestMU.fromJson,
        modelEmployeeFromJson: RequestME.fromJson,

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
