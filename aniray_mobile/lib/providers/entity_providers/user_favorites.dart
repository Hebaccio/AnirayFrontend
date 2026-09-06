import 'package:http/http.dart' as http;

import '../../requests_and_models/entity_r&m/user_favorites/userfavorites_models.dart';
import '../../requests_and_models/helper_r&m/api_result_helpers/api_result.dart';
import '../generic_provider/api_client.dart';
import '../generic_provider/generic_crud_provider.dart';

class UserFavoriteProvider
    extends
        GenericCrudProvider<
          UserFavoritesMU,
          UserFavoritesME,
          UserFavoritesSOU,
          UserFavoritesSOE,
          UserFavoritesIRU,
          UserFavoritesIRE,
          UserFavoritesURU,
          UserFavoritesURE
        > {
  UserFavoriteProvider()
    : super(
        endpoint: 'UserFavorites',
        apiClient: ApiClient(http.Client()),

        // Models
        modelUserFromJson: UserFavoritesMU.fromJson,
        modelEmployeeFromJson: UserFavoritesME.fromJson,

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

  // ---------------------------------------------------------------------------
  // CHECK IF MOVIE IS IN FAVORITES
  // ---------------------------------------------------------------------------

  Future<ApiResult<bool>> isMovieInFavorites(int id) {
    return executeCustomGet<bool>(
      path: '/IsMovieInFavorites/ForUsers?id=$id',
      fromJson: (json) => json as bool,
    );
  }

  Future<ApiResult<bool>> removeMovieFromFavorites(int id) {
    return executeCustomDelete<bool>(
      path: '/RemoveFromFavorites/ForUsers?id=$id',
      fromJson: (json) => json as bool,
    );
  }
}
