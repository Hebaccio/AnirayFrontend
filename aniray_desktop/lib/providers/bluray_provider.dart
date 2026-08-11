import 'package:aniray_desktop/models/bluray/bluray_ire.dart';
import 'package:aniray_desktop/models/bluray/bluray_iru.dart';
import 'package:aniray_desktop/models/bluray/bluray_me.dart';
import 'package:aniray_desktop/models/bluray/bluray_mu.dart';
import 'package:aniray_desktop/models/bluray/bluray_soe.dart';
import 'package:aniray_desktop/models/bluray/bluray_sou.dart';
import 'package:aniray_desktop/models/bluray/bluray_ure.dart';
import 'package:aniray_desktop/models/bluray/bluray_uru.dart';
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
  BluRayProvider({required ApiClient apiClient})
    : super(
        endpoint: 'BluRay',
        apiClient: apiClient,

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
