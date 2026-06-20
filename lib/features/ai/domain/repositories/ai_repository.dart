abstract class AIRepository {
  Future<String> chat(String message);
  Stream<String> chatStream(String message);
  Future<void> clearHistory();
}
