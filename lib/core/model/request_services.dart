class RequestResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  const RequestResponse(this.success, {this.message, this.data});

  factory RequestResponse.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['status'] == 'success'; // Convert string to bool
    return RequestResponse(
      isSuccess,
      message: json['message'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data};
  }
}
