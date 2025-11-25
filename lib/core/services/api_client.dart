class ApiClient {
  const ApiClient();

  // Mock delay to mimic network latency for demo interactions.
  Future<void> simulateDelay([int milliseconds = 500]) async {
    await Future<void>.delayed(Duration(milliseconds: milliseconds));
  }
}
