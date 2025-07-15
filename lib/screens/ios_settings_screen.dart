import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cv_provider.dart';

class IOSSettingsScreen extends StatelessWidget {
  const IOSSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    
    return CupertinoPageScaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark 
            ? const Color(0xFF1C1C1E).withOpacity(0.8)
            : const Color(0xFFF2F2F7).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark 
                ? const Color(0xFF38383A)
                : const Color(0xFFD1D1D6),
            width: 0.5,
          ),
        ),
        middle: Text(
          'Settings',
          style: TextStyle(
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),
            
            // Profile Section
            _buildProfileSection(context, isDark),
            
            const SizedBox(height: 35),
            
            // Appearance Section
            _buildSection(
              context,
              isDark,
              'Appearance',
              [
                _buildSettingsTile(
                  context,
                  isDark,
                  'Dark Mode',
                  CupertinoIcons.moon,
                  trailing: CupertinoSwitch(
                    value: isDark,
                    onChanged: (value) => themeProvider.toggleTheme(),
                    activeColor: const Color(0xFF007AFF),
                  ),
                ),
                _buildSettingsTile(
                  context,
                  isDark,
                  'Language',
                  CupertinoIcons.globe,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        themeProvider.locale.languageCode.toUpperCase(),
                        style: TextStyle(
                          color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                        size: 16,
                      ),
                    ],
                  ),
                  onTap: () => _showLanguagePicker(context, themeProvider),
                ),
              ],
            ),
            
            const SizedBox(height: 35),
            
            // CV Data Section
            _buildSection(
              context,
              isDark,
              'CV Data',
              [
                Consumer<CVProvider>(
                  builder: (context, cvProvider, child) {
                    return _buildSettingsTile(
                      context,
                      isDark,
                      'Export CV Data',
                      CupertinoIcons.square_arrow_up,
                      onTap: () => _exportCVData(context, cvProvider),
                    );
                  },
                ),
                Consumer<CVProvider>(
                  builder: (context, cvProvider, child) {
                    return _buildSettingsTile(
                      context,
                      isDark,
                      'Clear All Data',
                      CupertinoIcons.trash,
                      isDestructive: true,
                      onTap: () => _showClearDataDialog(context, cvProvider),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 35),
            
            // About Section
            _buildSection(
              context,
              isDark,
              'About',
              [
                _buildSettingsTile(
                  context,
                  isDark,
                  'Version',
                  CupertinoIcons.info,
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildSettingsTile(
                  context,
                  isDark,
                  'Privacy Policy',
                  CupertinoIcons.doc_text,
                  onTap: () => _showPrivacyPolicy(context),
                ),
                _buildSettingsTile(
                  context,
                  isDark,
                  'Terms of Service',
                  CupertinoIcons.doc_text,
                  onTap: () => _showTermsOfService(context),
                ),
              ],
            ),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              color: Color(0xFF007AFF),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CV Generator User',
                  style: TextStyle(
                    color: isDark ? CupertinoColors.white : CupertinoColors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Professional CV Builder',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, bool isDark, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    bool isDark,
    String title,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark 
                  ? const Color(0xFF38383A)
                  : const Color(0xFFD1D1D6),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive 
                  ? const Color(0xFFFF3B30)
                  : const Color(0xFF007AFF),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive 
                      ? const Color(0xFFFF3B30)
                      : (isDark ? CupertinoColors.white : CupertinoColors.black),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, ThemeProvider themeProvider) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Language'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setLocale(const Locale('en'));
              Navigator.pop(context);
            },
            child: const Text('English'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              themeProvider.setLocale(const Locale('ar'));
              Navigator.pop(context);
            },
            child: const Text('العربية'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _exportCVData(BuildContext context, CVProvider cvProvider) {
    // Implementation for exporting CV data
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Export CV Data'),
        content: const Text('This feature will be available in a future update.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, CVProvider cvProvider) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete all your CV data. This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              cvProvider.resetCV();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Your privacy is important to us. We do not collect or store any personal data.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('By using this app, you agree to our terms of service.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
