import 'package:aniray_desktop/models/user_favorites/userfavorites_models.dart';
import 'package:http/http.dart' as http;
import 'package:aniray_desktop/providers/api_client.dart';
import 'package:aniray_desktop/providers/generic_crud_provider.dart';

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
        endpoint: 'UserFavorite',
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
}
