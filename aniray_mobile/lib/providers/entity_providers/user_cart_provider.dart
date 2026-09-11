import 'package:http/http.dart' as http;

import '../../requests_and_models/entity_r&m/user_cart/usercart_models.dart';
import '../../requests_and_models/helper_r&m/api_result_helpers/api_result.dart';
import '../../requests_and_models/helper_r&m/basic_entities/basic_entities.dart';
import '../generic_provider/api_client.dart';
import '../generic_provider/generic_crud_provider.dart';

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

  Future<ApiResult<UserCartIsBluRayInCart>> isBluRayInCartForUsers(int id) {
    return executeCustomGet<UserCartIsBluRayInCart>(
      path: '/IsBluRayInCart/ForUsers/$id',
      fromJson: (json) =>
          UserCartIsBluRayInCart.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<ApiResult<bool>> updateIndividualBluRayInCart(
    UserCartIndividualURU request,
  ) {
    return executeCustomPost<bool>(
      path: '/UpdateIndividualBluRayInCart/ForUsers',
      body: request.toJson(),
      fromJson: (json) => json as bool,
    );
  }
}
