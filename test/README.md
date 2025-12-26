# Tests Overview

This folder contains tests for the Club App. There are two categories of tests:

- Unit tests (pure Dart VM): Fast, no device required, use fakes/mocks.
- Real API tests (require device/emulator): Exercise Firebase plugins via platform channels.

## Files

- [test/api_test_mockup.dart](api_test_mockup.dart): Unit tests using `fake_cloud_firestore` and `firebase_auth_mocks` to verify `PostService` and `UserService` without Firebase initialization.
- [test/api_test_real.dart](api_test_real.dart): Attempts real Firebase calls. Note: running this as a unit test (`flutter test`) will fail because Firebase plugins need a device/emulator.
- [test/stress_test.dart](stress_test.dart): Unit-style stress scenarios for local logic.
- Integration counterpart (device-based): see [integration_test/api_integration_test.dart](../integration_test/api_integration_test.dart) for real Firebase integration tests that run on a device/emulator.

## Prerequisites

- Flutter SDK installed and on PATH.
- Firebase configured:
  - [lib/firebase_options.dart](../lib/firebase_options.dart) present.
  - [android/app/google-services.json](../android/app/google-services.json) present for Android.
- A network connection (for real API tests).
- An Android emulator or physical device for integration tests.

## Run Unit Tests (VM)

Use these when you want fast feedback without hitting Firebase.

```bash
# Run all tests in this folder
flutter test test

# Run individual files
flutter test test/api_test_mockup.dart
flutter test test/stress_test.dart
```

## Run Real Firebase Integration Tests (Recommended)

Real API tests must run on a device/emulator because Firebase plugins use platform channels.

```bash
# Install dependencies
flutter pub get

# List available devices
flutter devices

# Run the integration test on a specific device/emulator
# Replace <deviceId> with one from `flutter devices`
flutter test integration_test/api_integration_test.dart -d <deviceId>
```

The integration test initializes Firebase with `IntegrationTestWidgetsFlutterBinding` and cleans up created test data in `users`, `clubs`, and `posts`.

## About `test/api_test_real.dart`

- Running `flutter test test/api_test_real.dart` will typically fail with errors like:
  - `[core/no-app] No Firebase App '[DEFAULT]' has been created`
  - `PlatformException(channel-error, Unable to establish connection ...)`
- To test real Firebase, prefer the integration test at [integration_test/api_integration_test.dart](../integration_test/api_integration_test.dart).

## Optional: Use Firestore Emulator

If you want to avoid touching production data, we can wire tests to the emulator:

- Start the emulator (`firebase emulators:start`) and set host/port.
- In test setup, call `FirebaseFirestore.instance.useFirestoreEmulator(host, port)`.
- If you want, ask and I’ll add a flag to switch between prod and emulator.

## Data Cleanup

- Integration tests automatically delete documents they create in `users`, `clubs`, and `posts`.
- If a test aborts early, you may see leftover test documents. You can safely delete them.

## Troubleshooting

- **No Firebase App / channel-error**: Run tests on a device/emulator and use the integration test.
- **Auth/storage/Firestore not found**: Verify Firebase config files and initialization.
- **Network timeouts**: Ensure stable internet or use the emulator.

## Notes

- Performance measurements in stress/integration tests are indicative and depend on network and device.
- If you need more comprehensive API/edge-case coverage, we can expand the integration tests (unicode, large payloads, query performance, etc.).
