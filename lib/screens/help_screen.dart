import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/support_chat_screen.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/auth_layout.dart';
import 'package:frip_cash/widgets/home/home_tutorials_section.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AuthScaffold(
      backLabel: t.back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthScreenHeader(
            title: t.needHelp,
            subtitle: t.helpSubtitle,
          ),
          const SizedBox(height: 28),
          const HomeTutorialsSection(compact: true),
          const SizedBox(height: 28),
          _HelpSectionTitle(t.faqTitle),
          const SizedBox(height: 12),
          _FaqTile(question: t.faqCreateAccountQ, answer: t.faqCreateAccountA),
          _FaqTile(question: t.faqOtpNotReceivedQ, answer: t.faqOtpNotReceivedA),
          _FaqTile(question: t.faqForgotPasswordQ, answer: t.faqForgotPasswordA),
          _FaqTile(question: t.faqAccountBlockedQ, answer: t.faqAccountBlockedA),
          _FaqTile(question: t.faqDeliveryTimesQ, answer: t.faqDeliveryTimesA),
          _FaqTile(question: t.faqCommissionQ, answer: t.faqCommissionA),
          _FaqTile(question: t.faqOrangeMoneyQ, answer: t.faqOrangeMoneyA),
          const SizedBox(height: 28),
          _HelpSectionTitle(t.contactUsTitle),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.mail_outline_rounded,
            title: t.emailContact,
            subtitle: 'support@fripcash.com',
            detail: t.responseWithin24h,
          ),
          const SizedBox(height: 10),
          _ContactCard(
            icon: Icons.phone_outlined,
            title: t.phoneContact,
            subtitle: '+224 6XX XXX XXX',
            detail: t.weekdayHours,
          ),
          const SizedBox(height: 10),
          _ContactCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: t.whatsappContact,
            subtitle: '+224 6XX XXX XXX',
            detail: t.fastAssistance,
          ),
          const SizedBox(height: 28),
          AuthPrimaryButton(
            label: t.contactSupport,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SupportChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HelpSectionTitle extends StatelessWidget {
  const _HelpSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _ExpandToggleIcon(expanded: _expanded),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.answer,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandToggleIcon extends StatelessWidget {
  const _ExpandToggleIcon({required this.expanded});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(
        expanded ? Icons.remove : Icons.add,
        size: 18,
        color: AppColors.primary,
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
