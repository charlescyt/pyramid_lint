class LogoutController {
  Future<void> logout() {
    final authRepo = AuthRepository();
    final storageRepo = StorageRepository();

    return Future.wait([
      authRepo.logout(),
      storageRepo.clearTokens(),
    ]);
  }
}

class AuthRepository {
  Future<void> logout() {
    return Future.value();
  }
}

class StorageRepository {
  Future<void> clearTokens() {
    return Future.value();
  }
}
