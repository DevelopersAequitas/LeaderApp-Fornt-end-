/// Model representing an OTP verification request.
class OtpModel {
  /// The contact identifier (email or phone) to which the OTP was sent.
  final String emailOrPhone;

  /// The 4-digit code inputted by the user.
  final String otpCode;

  const OtpModel({
    required this.emailOrPhone,
    required this.otpCode,
  });

  /// Factory constructor to create a blank model for a destination.
  factory OtpModel.empty(String emailOrPhone) {
    return OtpModel(emailOrPhone: emailOrPhone, otpCode: '');
  }
}
