/// Model representing the `data` payload returned by `POST /api/v1/leader/auth/send-otp`.
class SendOtpResultModel {
  final bool isRegistered;
  final bool isLeader;
  final String channel;
  final int otpExpirySeconds;

  const SendOtpResultModel({
    required this.isRegistered,
    required this.isLeader,
    required this.channel,
    required this.otpExpirySeconds,
  });

  factory SendOtpResultModel.fromJson(
    Map<String, dynamic> json, {
    String fallbackChannel = 'email',
  }) {
    final map = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawChannel = map['channel']?.toString().trim().toLowerCase();
    final resolvedChannel = (rawChannel == 'whatsapp' || rawChannel == 'sms')
        ? 'whatsapp'
        : (rawChannel == 'email' ? 'email' : fallbackChannel);

    return SendOtpResultModel(
      isRegistered: map['is_registered'] == true,
      isLeader: map['is_leader'] == true,
      channel: resolvedChannel,
      otpExpirySeconds:
          int.tryParse(map['otp_expiry_seconds']?.toString() ?? '') ?? 300,
    );
  }

  Map<String, dynamic> toJson() => {
        'is_registered': isRegistered,
        'is_leader': isLeader,
        'channel': channel,
        'otp_expiry_seconds': otpExpirySeconds,
      };
}

