class GenericCreateResponse {
  final bool success;
  final String xid;

  GenericCreateResponse({this.success, this.xid});

  factory GenericCreateResponse.fromJson(Map<String, dynamic> json) {
    return GenericCreateResponse(
      success: json['success'],
      xid: json['xid'],
    );
  }
}
