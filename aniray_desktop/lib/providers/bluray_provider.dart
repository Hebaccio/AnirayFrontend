import 'package:aniray_desktop/models/bluray/bluray_models.dart';
import 'package:http/http.dart' as http;
import 'package:aniray_desktop/providers/api_client.dart';
import 'package:aniray_desktop/providers/generic_crud_provider.dart';

class BluRayProvider
    extends
        GenericCrudProvider<
          BluRayMU,
          BluRayME,
          BluRaySOU,
          BluRaySOE,
          BluRayIRU,
          BluRayIRE,
          BluRayURU,
          BluRayURE
        > {
  BluRayProvider()
    : super(
        endpoint: 'BluRay',
        apiClient: ApiClient(http.Client()),

        // Models
        modelUserFromJson: BluRayMU.fromJson,
        modelEmployeeFromJson: BluRayME.fromJson,

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
