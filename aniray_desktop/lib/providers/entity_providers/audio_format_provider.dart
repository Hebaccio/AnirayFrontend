import 'package:aniray_desktop/models/basic_entities/basic_entities.dart';
import 'package:http/http.dart' as http;
import 'package:aniray_desktop/providers/api_client.dart';
import 'package:aniray_desktop/providers/generic_crud_provider.dart';

class AudioFormatProvider
    extends
        GenericCrudProvider<
          BaseClassMU,
          BaseClassME,
          BaseClassSOU,
          BaseClassSOE,
          BaseClassIRU,
          BaseClassIRE,
          BaseClassURU,
          BaseClassURE
        > {
  AudioFormatProvider()
    : super(
        endpoint: 'AudioFormat',
        apiClient: ApiClient(http.Client()),

        // Models
        modelUserFromJson: BaseClassMU.fromJson,
        modelEmployeeFromJson: BaseClassME.fromJson,

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
