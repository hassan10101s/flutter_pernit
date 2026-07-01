class PushDeviceRegistrationRequest {
  final String token;
  final String platform;
  final String environment;
  final String locale;
  final String timezone;

  const PushDeviceRegistrationRequest({
    required this.token,
    required this.platform,
    required this.environment,
    required this.locale,
    required this.timezone,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'platform': platform,
    'environment': environment,
    'locale': locale,
    'timezone': timezone,
  };
}

class PushDeviceRegistrationResponse {
  final String id;
  final String? tokenPreview;
  final String platform;
  final bool isActive;

  const PushDeviceRegistrationResponse({
    required this.id,
    this.tokenPreview,
    required this.platform,
    required this.isActive,
  });

  factory PushDeviceRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return PushDeviceRegistrationResponse(
      id: json['id'] as String? ?? '',
      tokenPreview: json['token_preview'] as String?,
      platform: json['platform'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
