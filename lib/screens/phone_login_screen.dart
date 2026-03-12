import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme.dart';
import 'otp_verification_screen.dart';
import 'dashboard_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  bool _isLoading = false;
  String? _selectedMode;

  late AnimationController _animController;
  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;

  late AnimationController _fieldAnimController;
  late Animation<double> _fieldFade;
  late Animation<Offset> _fieldSlide;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _animController, curve: const Interval(0, 0.6)));

    _fieldAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fieldFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _fieldAnimController, curve: Curves.easeIn));
    _fieldSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _fieldAnimController, curve: Curves.easeOut));

    Future.delayed(
        const Duration(milliseconds: 100), () => _animController.forward());
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    _animController.dispose();
    _fieldAnimController.dispose();
    super.dispose();
  }

  void _selectMode(String mode) {
    if (_selectedMode == mode) return;
    setState(() {
      _selectedMode = mode;
      _inputController.clear();
    });
    _fieldAnimController.reset();
    _fieldAnimController.forward();
    Future.delayed(
        const Duration(milliseconds: 300), () => _inputFocus.requestFocus());
  }

  void _submit() async {
    final text = _inputController.text.trim();

    if (_selectedMode == 'phone') {
      if (text.isEmpty) {
        _showError('Please enter a phone number');
        return;
      }
      if (!RegExp(r'^(?:\+91|0)?(?!([0-9])\1{9})[789]\d{9}$').hasMatch(text)) {
        _showError('Please enter a valid mobile number');
        return;
      }
    }

    if (_selectedMode == 'email') {
      if (text.isEmpty) {
        _showError('Please enter an email address');
        return;
      }
      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(text)) {
        _showError('Please enter a valid email address');
        return;
      }
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: text,
            loginMode: _selectedMode!,
          ),
        ),
      );
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins()),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(                                   
      onTap: () => FocusScope.of(context).unfocus(),        
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome Back!\nSign In to Continue',
                        style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.25)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: SlideTransition(
                  position: _cardSlide,
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('How would you like to sign in?',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.greyText,
                                  height: 1.5)),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _ToggleButton(
                                  label: 'Login with Phone',
                                  icon: Icons.phone_outlined,
                                  isSelected: _selectedMode == 'phone',
                                  onTap: () => _selectMode('phone'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _ToggleButton(
                                  label: 'Login with Email',
                                  icon: Icons.email_outlined,
                                  isSelected: _selectedMode == 'email',
                                  onTap: () => _selectMode('email'),
                                ),
                              ),
                            ],
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: _selectedMode == null
                                ? const SizedBox(height: 0)
                                : SlideTransition(
                                    position: _fieldSlide,
                                    child: FadeTransition(
                                      opacity: _fieldFade,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 28),
                                          Text(
                                            _selectedMode == 'phone'
                                                ? 'Enter your phone number'
                                                : 'Enter your email address',
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.darkText),
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: AppColors.inputBorder,
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.04),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 16),
                                                Icon(
                                                  _selectedMode == 'phone'
                                                      ? Icons.phone_outlined
                                                      : Icons.email_outlined,
                                                  color: AppColors.primary,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 10),
                                                Container(
                                                    width: 1,
                                                    height: 24,
                                                    color:
                                                        AppColors.inputBorder),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: TextField(
                                                    key: ValueKey(_selectedMode),
                                                    controller: _inputController,
                                                    focusNode: _inputFocus,
                                                    keyboardType:
                                                        _selectedMode == 'phone'
                                                            ? TextInputType
                                                                .number
                                                            : TextInputType
                                                                .emailAddress,
                                                    inputFormatters:
                                                        _selectedMode == 'phone'
                                                            ? [
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly,
                                                                LengthLimitingTextInputFormatter(
                                                                    10),
                                                              ]
                                                            : [],
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            AppColors.darkText),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText:
                                                          _selectedMode ==
                                                                  'phone'
                                                              ? '(99) 999 99 99'
                                                              : 'example@email.com',
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                              color: AppColors
                                                                  .greyText
                                                                  .withOpacity(
                                                                      0.5),
                                                              fontSize: 15),
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                                  vertical: 18),
                                                    ),
                                                    onChanged: (_) =>
                                                        setState(() {}),
                                                  ),
                                                ),
                                                if (_inputController
                                                    .text.isNotEmpty)
                                                  GestureDetector(
                                                    onTap: () {
                                                      _inputController.clear();
                                                      setState(() {});
                                                    },
                                                    child: const Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 12),
                                                      child: Icon(
                                                          Icons.cancel_rounded,
                                                          color:
                                                              AppColors.greyText,
                                                          size: 20),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed:
                                                  _isLoading ? null : _submit,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.accent,
                                                foregroundColor:
                                                    AppColors.darkText,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 18),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14)),
                                                elevation: 4,
                                                shadowColor: AppColors.accent
                                                    .withOpacity(0.35),
                                              ),
                                             child: _isLoading
    ? const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkText),
        ),
      )
                                                  : Text(
                                                      _selectedMode == 'phone'
                                                          ? 'Send Verification Code'
                                                          : 'Continue with Email',
                                                      style: GoogleFonts.poppins(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: AppColors.inputBorder)),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                child: Text(
                                  'Or continue with',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color:
                                        AppColors.greyText.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                      height: 1,
                                      color: AppColors.inputBorder)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _SocialButton(
                                bgColor: const Color(0xFF1877F2),
                                faIcon: FontAwesomeIcons.facebookF,
                                label: 'Facebook',
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(
                                      loginMode: 'social',
                                      loginValue: 'facebook',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              _SocialButton(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF58529),
                                    Color(0xFFDD2A7B),
                                    Color(0xFF8134AF),
                                    Color(0xFF515BD4),
                                  ],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                                faIcon: FontAwesomeIcons.instagram,
                                label: 'Instagram',
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(
                                      loginMode: 'social',
                                      loginValue: 'instagram',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              _SocialButton(
                                bgColor: const Color(0xFFEA4335),
                                faIcon: FontAwesomeIcons.google,
                                label: 'Gmail',
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(
                                      loginMode: 'social',
                                      loginValue: 'gmail',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color:
                                        AppColors.greyText.withOpacity(0.7)),
                                children: const [
                                  TextSpan(
                                      text: 'By continuing, you agree to our '),
                                  TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                  TextSpan(text: ' & '),
                                  TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Toggle Button ─────────────────────────────────────────────────────
class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.25)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.greyText),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.greyText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Social Login Button ───────────────────────────────────────────────
class _SocialButton extends StatefulWidget {
  final Color? bgColor;
  final Gradient? gradient;
  final FaIconData faIcon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    this.bgColor,
    this.gradient,
    required this.faIcon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) async {
        await _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.gradient,
                color: widget.gradient == null ? widget.bgColor : null,
                boxShadow: [
                  BoxShadow(
                    color: (widget.bgColor ?? Colors.black).withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: FaIcon(
                  widget.faIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              widget.label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}