import 'package:http/http.dart' as http;
import '../../requests_and_models/entity_r&m/movie/movie_models.dart';
import '../generic_provider/api_client.dart';
import '../generic_provider/generic_crud_provider.dart';

class MovieProvider
    extends
        GenericCrudProvider<
          MovieMU,
          MovieME,
          MovieSOU,
          MovieSOE,
          MovieIRU,
          MovieIRE,
          MovieURU,
          MovieURE
        > {
  MovieProvider()
    : super(
        endpoint: 'Movie',
        apiClient: ApiClient(http.Client()),

        // Models
        modelUserFromJson: MovieMU.fromJson,
        modelEmployeeFromJson: MovieME.fromJson,

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
