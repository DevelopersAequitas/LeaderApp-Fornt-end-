import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_color.dart';

/// Common App Bar styled after Peers Global Unity (`AppCommonBar`):
/// - Normal back button (`Icons.chevron_left_rounded`)
/// - Screen name (with optional subtitle if needed)
/// - Optional search button (`showSearch: true`) that toggles an inline search input in the app bar
/// - Optional brand logo mode (`showLogo: true`) with `PeersGlobal` + role subtitle for the Home tab
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final bool showLogo;
  final bool showSearch;
  final bool? isSearching;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final VoidCallback? onSearchTap;
  final VoidCallback? onSearchClose;
  final VoidCallback? onSearchClosed;
  final String? searchHint;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final VoidCallback? onBackTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.showLogo = false,
    this.showSearch = false,
    this.isSearching,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.onSearchTap,
    this.onSearchClose,
    this.onSearchClosed,
    this.searchHint,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.onBackTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _internalSearching = false;
  late final TextEditingController _internalController = TextEditingController();

  bool get _effectiveSearching => widget.isSearching ?? _internalSearching;
  TextEditingController get _effectiveController =>
      widget.searchController ?? _internalController;

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  void _handleSearchOpen() {
    if (widget.onSearchTap != null) {
      widget.onSearchTap!();
    } else {
      setState(() => _internalSearching = true);
    }
  }

  void _handleSearchClose() {
    if (widget.onSearchClose != null) {
      widget.onSearchClose!();
    } else {
      _effectiveController.clear();
      widget.onSearchChanged?.call('');
      widget.onSearchClosed?.call();
      setState(() => _internalSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppColor.darkBackground : AppColor.lightSurface);
    final iconColor =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final primaryTextColor =
        isDark ? AppColor.darkTextPrimary : AppColor.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    final borderColor = isDark ? AppColor.darkBorder : AppColor.lightBorder;

    if (_effectiveSearching) {
      return AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: kToolbarHeight,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 22, color: iconColor),
          onPressed: _handleSearchClose,
          padding: EdgeInsets.zero,
        ),
        titleSpacing: 0,
        title: TextField(
          controller: _effectiveController,
          autofocus: true,
          onChanged: (val) {
            setState(() {});
            widget.onSearchChanged?.call(val);
          },
          onSubmitted: widget.onSearchSubmitted,
          textInputAction: TextInputAction.search,
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 14.5,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText:
                widget.searchHint ?? 'Search ${widget.title.toLowerCase()}...',
            hintStyle: TextStyle(
              color: secondaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
          ),
        ),
        actions: [
          if (_effectiveController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close_rounded, size: 20, color: iconColor),
              onPressed: () {
                _effectiveController.clear();
                setState(() {});
                widget.onSearchChanged?.call('');
              },
            ),
          const SizedBox(width: 8),
        ],
      );
    }

    return AppBar(
      backgroundColor: bgColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: kToolbarHeight,
      automaticallyImplyLeading: false,
      leading: null,
      titleSpacing: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: borderColor),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            if (widget.showBackButton) ...[
              if (widget.leading != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: widget.leading!,
                )
              else
                GestureDetector(
                  onTap: widget.onBackTap ?? () => Navigator.of(context).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 26,
                      color: iconColor,
                    ),
                  ),
                ),
            ],
            Expanded(
              child: widget.showLogo
                  ? _PeersBrandLogoTitle(
                      subtitle: widget.subtitle,
                      secondaryTextColor: secondaryTextColor,
                    )
                  : Text(
                      widget.title,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            if (widget.showSearch)
              InkWell(
                onTap: _handleSearchOpen,
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  width: 40,
                  height: kToolbarHeight,
                  child: Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: iconColor,
                  ),
                ),
              ),
            ...?widget.actions,
          ],
        ),
      ),
    );
  }
}

class _PeersBrandLogoTitle extends StatelessWidget {
  final String? subtitle;
  final Color secondaryTextColor;

  const _PeersBrandLogoTitle({
    this.subtitle,
    required this.secondaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icons/AppIcon.png',
          width: 30,
          height: 30,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'LibreFranklin',
                    fontSize: 17.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    height: 1.15,
                  ),
                  children: [
                    TextSpan(
                      text: 'Peers',
                      style: TextStyle(color: AppColor.primaryPink),
                    ),
                    TextSpan(
                      text: 'Global',
                      style: TextStyle(color: AppColor.primaryBlue),
                    ),
                  ],
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
