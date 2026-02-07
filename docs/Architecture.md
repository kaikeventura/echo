# Architecture

Echo follows a simplified **Clean Architecture** pattern to ensure separation of concerns and maintainability:

*   **Presentation Layer**: Widgets, Screens, and Riverpod Providers (Controllers).
*   **Domain/Model Layer**: Data entities (`RequestModel`, `CollectionModel`, `SessionModel`).
*   **Data/Service Layer**: Repositories and Services (`IsarService`, `HttpService`).

## Tech Stack

*   **Framework**: [Flutter](https://flutter.dev) (3.x)
*   **Language**: Dart
*   **State Management**: [Riverpod](https://riverpod.dev) (v2) with Code Generation
*   **Database**: [Isar](https://isar.dev) (NoSQL, ACID)
*   **HTTP Client**: [Dio](https://pub.dev/packages/dio)
*   **Window Management**: [window_manager](https://pub.dev/packages/window_manager)
