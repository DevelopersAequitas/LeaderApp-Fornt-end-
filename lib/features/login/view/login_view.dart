import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_state.dart';
import '../model/role_model.dart';
import '../presenter/login_presenter.dart';

/// The View component of the Sign-In portal feature.
/// Renders the sign-in form, validation states, and the role auto-fill utility.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> implements LoginViewContract {
  late final LoginBloc _bloc;
  late final LoginPresenter _presenter;
  late final TextEditingController _inputController;

  bool _isFormValid = false;
  bool _isLoading = false;

  /// The list of pre-configured roles for auto-fill functionality.
  final List<RoleModel> _roles = [
    const RoleModel(
      title: 'Circle Chair',
      description: 'Own Circle · Read-only circle access · Submit reports',
      email: 'arjun@peersglobal.in',
      icon: Icons.chair_alt,
      iconBgColor: Color(0xFFF4ECE6),
      iconColor: Color(0xFF8B5E3C),
    ),
    const RoleModel(
      title: 'Circle Founder',
      description: 'Own Circle(s) · Full circle mgmt · Permanent role',
      email: 'sanjana@peersglobal.in',
      icon: Icons.spa_outlined,
      iconBgColor: Color(0xFFE8F5E9),
      iconColor: Color(0xFF4CAF50),
    ),
    const RoleModel(
      title: 'Circle Director',
      description: 'Own Circle(s) · Full circle mgmt · Can be reassigned',
      email: 'rohit@peersglobal.in',
      icon: Icons.track_changes_outlined,
      iconBgColor: Color(0xFFFCE4EC),
      iconColor: Color(0xFFE91E63),
    ),
    const RoleModel(
      title: 'Industry Director',
      description: 'Assigned Industries · All 18 industries · Circle oversight',
      email: 'kavitha@peersglobal.in',
      icon: Icons.factory_outlined,
      iconBgColor: Color(0xFFE0F2F1),
      iconColor: Color(0xFF009688),
    ),
    const RoleModel(
      title: 'District Exec Director',
      description:
          'One District · District-wide head · All circles in district',
      email: 'vikram@peersglobal.in',
      icon: Icons.map_outlined,
      iconBgColor: Color(0xFFFFF3E0),
      iconColor: Color(0xFFFF9800),
    ),
    const RoleModel(
      title: 'Country Director',
      description:
          'Entire Country · National head · All districts & industries',
      email: 'meera@peersglobal.in',
      icon: Icons.public_outlined,
      iconBgColor: Color(0xFFE3F2FD),
      iconColor: Color(0xFF2196F3),
    ),
    const RoleModel(
      title: 'Super Admin',
      description: 'Global · Full platform · Settings · Commissions · All',
      email: 'admin@peersglobal.in',
      icon: Icons.flash_on_outlined,
      iconBgColor: Color(0xFFFFFDE7),
      iconColor: Color(0xFFFBC02D),
    ),
  ];

  /// Getter to dynamically fetch all preconfigured and custom roles.
  List<RoleModel> get _allRoles {
    final customRoles = SessionManager().dynamicRoleLabels.map((label) {
      final email = '${label.replaceAll(' ', '').toLowerCase()}@peersglobal.in';
      return RoleModel(
        title: label,
        description: 'Custom Dynamic Role · Configured by Super Admin',
        email: email,
        icon: Icons.tune_rounded,
        iconBgColor: AppColors.successBg,
        iconColor: AppColors.success,
      );
    });

    return [
      ..._roles,
      ...customRoles,
    ];
  }

  @override
  void initState() {
    super.initState();
    _bloc = LoginBloc();
    _presenter = LoginPresenter(view: this, bloc: _bloc);
    _inputController = TextEditingController();

    // Listen to changes to report to presenter and rebuild UI to show selected state
    _inputController.addListener(() {
      _presenter.onEmailOrPhoneChanged(_inputController.text);
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Properly clean up controllers to prevent memory leaks (Rule 23)
    _inputController.dispose();
    _bloc.close();
    super.dispose();
  }

  // --- LoginViewContract Implementations ---

  @override
  void onLoginLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void onLoginSuccess() {
    setState(() {
      _isLoading = false;
    });
    // Visual confirmation for user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP sent successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    // Proceed to OTP verification screen
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.otp,
      arguments: _inputController.text,
    );
  }

  @override
  void onLoginError(String error) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sign in failed: $error'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  void onValidationChanged(bool isValid) {
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void onAutoFillRequest(String credentials) {
    _inputController.text = credentials;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: credentials.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>.value(
      value: _bloc,
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upper branding/portal title section
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.only(top: 48, bottom: 52),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/whitelogo.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Leadership Portal',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // White sheet login form card
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top slide navigation pill indicators
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Sign in headers
                          const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter your leadership credentials to access portal',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Email/Phone Form Field Input
                          const Text(
                            'EMAIL ADDRESS OR PHONE NUMBER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _inputController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.text,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: Colors.grey.shade400,
                                size: 22,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              hintText: 'Enter email or phone...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 15,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtext instruction guide
                          Text(
                            'Please sign in with your leadership contact information. Phone numbers must include country code (e.g. starting with "+").',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Action trigger Send OTP Button
                          PrimaryButton(
                            label: 'Send OTP',
                            onPressed: (_isFormValid && !_isLoading)
                                ? () => _presenter.submit()
                                : null,
                            isLoading: _isLoading,
                            trailingIcon: Icons.arrow_forward_rounded,
                          ),
                          const SizedBox(height: 36),
                          // Auto-Fill Role Utility Panel
                          CustomPaint(
                            painter: DashedBorderPainter(
                              color: AppColors.dashedBorder,
                              borderRadius: 16,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.ads_click_rounded,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'TAP A ROLE TO AUTO-FILL & SIGN IN',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textSecondary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Loop through all auto-fill roles
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _allRoles.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final role = _allRoles[index];
                                      return _buildRoleCard(role);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a premium auto-fill role selection tile.
  Widget _buildRoleCard(RoleModel role) {
    final isSelected = _inputController.text.trim() == role.email.trim();
    return InkWell(
      onTap: () => _presenter.onRoleSelected(role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rounded background icon badge
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: role.iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(role.icon, color: role.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Text credentials & info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        role.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      if (isSelected)
                        const StatusPill(
                          label: 'Selected',
                          backgroundColor: AppColors.primary,
                          textColor: Colors.white,
                          fontSize: 10,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role.email,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw clean dashed borders around containers.
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
    this.borderRadius = 16.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);

    final dashedPath = Path();
    double distance = 0.0;
    for (final measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashedPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
