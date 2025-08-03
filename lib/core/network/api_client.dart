class ApiClient {
  final dynamic dio; // Would be Dio instance in real implementation

  ApiClient(this.dio);

  // This would contain actual API methods in a real implementation
  Future<dynamic> get(String path) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    return {};
  }

  Future<dynamic> post(String path, dynamic data) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    return {};
  }

  Future<dynamic> put(String path, dynamic data) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 600));
    return {};
  }

  Future<dynamic> delete(String path) async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 400));
    return {};
  }
}