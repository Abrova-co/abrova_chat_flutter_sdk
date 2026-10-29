/// Name this SDK reports to the Abrova backend.
const String abrovaChatSdkName = 'flutter';

/// Version of the abrova_chat package.
///
/// Must match `version` in pubspec.yaml (enforced by a unit test).
const String abrovaChatSdkVersion = '0.2.0';

/// Header that tells the API which SDK and version made a request.
const String abrovaChatSdkHeader = 'X-Abrova-SDK';

/// Its value: `flutter/<version>`.
const String abrovaChatSdkHeaderValue = '$abrovaChatSdkName/$abrovaChatSdkVersion';
