import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';

import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';
import '../../../../ClientsSide/ClientBottomNavigation/clientProfilesection/clientHelpsupportsection/clienthelpsupportcontroller.dart';

/// ======================================================================
/// MAIN SCREEN
/// ======================================================================

class Workerhelpandsupportscreen extends StatefulWidget {
  const Workerhelpandsupportscreen({super.key});

  @override
  State<Workerhelpandsupportscreen> createState() =>
      _WorkerhelpandsupportscreenState();
}

class _WorkerhelpandsupportscreenState
    extends State<Workerhelpandsupportscreen> {
  final Clienthelpsupportcontroller controller =
  Get.put(Clienthelpsupportcontroller());

  List<String> get mainTabs => [
    'help_support_tab_faqs'.tr,
    'help_support_tab_submit_ticket'.tr,
    'help_support_tab_live_chat'.tr,
  ];

  List<IconData> get mainTabIcons => const [
    Icons.menu_book_rounded,
    Icons.confirmation_num_outlined,
    Icons.forum_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSize.width * 0.03,
                AppSize.height * 0.015,
                AppSize.width * 0.03,
                AppSize.height * 0.015,
              ),
              child: Column(
                children: [
                  const _HelpSupportAppBar(),
                  SizedBox(height: AppSize.height * 0.02),
                  Obx(
                        () => _PillTabBar(
                      tabs: mainTabs,
                      selectedIndex: controller.mainTabIndex.value,
                      onTap: controller.changeMainTab,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                switch (controller.mainTabIndex.value) {
                  case 1:
                    return _SubmitTicketTabView(controller: controller);
                  case 2:
                    return _LiveChatTabView(controller: controller);
                  default:
                    return _FaqsTabView(controller: controller);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// ======================================================================
/// APP BAR
/// ======================================================================

class _HelpSupportAppBar extends StatelessWidget {
  const _HelpSupportAppBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomHeader(
      title: 'help_support_title'.tr,
      showBackButton: true,
      onBack: () => Get.back(),
      rightWidget: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.width * 0.03,
          vertical: AppSize.height * 0.01,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xff10B981).withOpacity(0.18),
              const Color(0xff10B981).withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xff10B981).withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingDot(color: const Color(0xff10B981)),
            SizedBox(width: AppSize.width * 0.015),
            Text(
              'help_support_live_badge'.tr,
              style: TextStyle(
                color: const Color(0xff10B981),
                fontWeight: FontWeight.bold,
                fontSize: AppSize.width * 0.026,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small animated "live" dot for the badge
class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_controller),
      child: Container(
        width: AppSize.width * 0.02,
        height: AppSize.width * 0.02,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

/// ======================================================================
/// PILL TAB BAR (with icons + smooth selected state)
/// ======================================================================

class _PillTabBar extends StatelessWidget {
  final List<String> tabs;
  final List<IconData>? icons;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool scrollable;

  const _PillTabBar({
    required this.tabs,
    this.icons,
    required this.selectedIndex,
    required this.onTap,
    this.scrollable = false,
  });

  Widget _pill(int index, ThemeData theme) {
    final selected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: scrollable
            ? EdgeInsets.only(right: AppSize.width * 0.02)
            : EdgeInsets.zero,
        padding: EdgeInsets.symmetric(
          vertical: AppSize.height * 0.012,
          horizontal: AppSize.width * 0.025,
        ),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: selected
              ? null
              : (scrollable ? theme.cardColor : Colors.transparent),
          borderRadius: BorderRadius.circular(30),
          boxShadow: selected
              ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.28),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
              : [],
        ),
        alignment: Alignment.center,
        child:
            Text(
              tabs[index],
              style: TextStyle(
                color: selected ? Colors.white : theme.canvasColor.withOpacity(0.6),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: AppSize.width * 0.0223,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (scrollable) {
      return SizedBox(
        height: AppSize.height * 0.045,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          itemBuilder: (context, index) => _pill(index, theme),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(AppSize.width * 0.012),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Row(
        children: List.generate(
          tabs.length,
              (index) => Expanded(child: _pill(index, theme)),
        ),
      ),
    );
  }
}

/// ======================================================================
/// FAQS TAB VIEW
/// ======================================================================

class _FaqsTabView extends StatelessWidget {
  final Clienthelpsupportcontroller controller;
  const _FaqsTabView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.width * 0.05,
        vertical: AppSize.height * 0.02,
      ),
      children: [
        const _DirectAssistanceSection(),
        SizedBox(height: AppSize.height * 0.028),

        /// SECTION TITLE
        Row(
          children: [
            Container(
              width: AppSize.width * 0.01,
              height: AppSize.width * 0.045,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(width: AppSize.width * 0.02),
            Text(
              'help_support_kb_section_title'.tr,
              style: TextStyle(
                fontFamily: "pb",
                fontSize: AppSize.width * 0.032,
                fontWeight: FontWeight.bold,
                color: theme.canvasColor.withOpacity(0.7),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSize.height * 0.016),
        _HelpSearchField(
          onChanged: (value) => controller.searchQuery.value = value,
        ),
        SizedBox(height: AppSize.height * 0.018),

        /// CATEGORY TABS
        Obx(
              () => _PillTabBar(
            tabs: faqCategories,
            selectedIndex: controller.categoryIndex.value,
            onTap: controller.changeCategory,
            scrollable: true,
          ),
        ),

        SizedBox(height: AppSize.height * 0.02),

        /// FAQ LIST
        Obx(() {
          final faqs = controller.filteredFaqs;
          if (faqs.isEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: AppSize.height * 0.06),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: AppSize.width * 0.12,
                        color: theme.canvasColor.withOpacity(0.2)),
                    SizedBox(height: AppSize.height * 0.012),
                    Text(
                      'help_support_no_results'.tr,
                      style: TextStyle(
                        fontFamily: "pr",
                        color: theme.canvasColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: List.generate(faqs.length, (index) {
              return _FaqTile(
                faq: faqs[index],
                expanded: controller.expandedFaqIndex.value == index,
                onTap: () => controller.toggleFaq(index),
              );
            }),
          );
        }),
      ],
    );
  }
}

/// ======================================================================
/// DIRECT ASSISTANCE SECTION — gradient hero style
/// ======================================================================

class _DirectAssistanceSection extends StatelessWidget {
  const _DirectAssistanceSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.width * 0.045),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.width * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: AppSize.width * 0.05),
              ),
              SizedBox(width: AppSize.width * 0.03),
              Expanded(
                child: Text(
                  'help_support_direct_assistance_title'.tr,
                  style: TextStyle(
                    fontFamily: "pb",
                    fontSize: AppSize.width * 0.033,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.height * 0.02),
          Row(
            children: [
              Expanded(
                child: _item(Icons.call_rounded, 'help_support_call_label'.tr,
                    '+1 (555) 0199'),
              ),
              Container(
                height: AppSize.height * 0.05,
                width: 1,
                color: Colors.white.withOpacity(0.25),
                margin: EdgeInsets.symmetric(horizontal: AppSize.width * 0.03),
              ),
              Expanded(
                child: _item(Icons.email_outlined,
                    'help_support_email_label'.tr, 'support@example.com'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSize.width * 0.02),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: AppSize.width * 0.042),
        ),
        SizedBox(width: AppSize.width * 0.022),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: "pr",
                  fontSize: AppSize.width * 0.024,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
              SizedBox(height: AppSize.height * 0.003),
              Text(
                value,
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: AppSize.width * 0.029,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ======================================================================
/// HELP SEARCH FIELD
/// ======================================================================

class _HelpSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _HelpSearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
            fontFamily: "pr",
            fontSize: AppSize.width * 0.035,
            color: theme.canvasColor),
        decoration: InputDecoration(
          hintText: 'help_support_search_hint'.tr,
          hintStyle: TextStyle(
              fontFamily: "pr",
              fontSize: AppSize.width * 0.032,
              color: theme.canvasColor.withOpacity(0.4)),
          prefixIcon: Icon(Icons.search_rounded,
              size: AppSize.width * 0.055, color: theme.primaryColor.withOpacity(0.7)),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: EdgeInsets.symmetric(vertical: AppSize.height * 0.016),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: theme.primaryColor, width: 1.6),
          ),
        ),
      ),
    );
  }
}

/// ======================================================================
/// FAQ TILE — smooth expand + rotating icon
/// ======================================================================

class _FaqTile extends StatelessWidget {
  final FaqModel faq;
  final bool expanded;
  final VoidCallback onTap;

  const _FaqTile({
    required this.faq,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(bottom: AppSize.height * 0.015),
      padding: EdgeInsets.all(AppSize.width * 0.04),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: expanded
              ? theme.primaryColor.withOpacity(0.4)
              : theme.dividerColor.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(expanded ? 0.05 : 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSize.width * 0.018),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.help_outline_rounded,
                      size: AppSize.width * 0.04, color: theme.primaryColor),
                ),
                SizedBox(width: AppSize.width * 0.03),
                Expanded(
                  child: Text(
                    faq.question,
                    style: TextStyle(
                      fontFamily: "pb",
                      fontSize: AppSize.width * 0.034,
                      fontWeight: FontWeight.w600,
                      color: theme.canvasColor,
                    ),
                  ),
                ),
                SizedBox(width: AppSize.width * 0.02),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: AppSize.width * 0.06,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: EdgeInsets.only(
                top: AppSize.height * 0.014,
                left: AppSize.width * 0.115,
              ),
              child: Text(
                faq.answer,
                style: TextStyle(
                  fontFamily: "pr",
                  fontSize: AppSize.width * 0.031,
                  color: theme.canvasColor.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState:
            expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOut,
          ),
        ],
      ),
    );
  }
}

/// ======================================================================
/// SUBMIT TICKET TAB VIEW
/// ======================================================================

class _SubmitTicketTabView extends StatelessWidget {
  final Clienthelpsupportcontroller controller;
  const _SubmitTicketTabView({required this.controller});

  InputDecoration _decoration(BuildContext context, String hint, IconData icon) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontFamily: "pr",
          color: theme.canvasColor.withOpacity(0.4),
          fontSize: AppSize.width * 0.032),
      prefixIcon: Icon(icon,
          size: AppSize.width * 0.05, color: theme.primaryColor.withOpacity(0.65)),
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: EdgeInsets.symmetric(
          horizontal: AppSize.width * 0.04, vertical: AppSize.height * 0.016),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.primaryColor, width: 1.6),
      ),
    );
  }

  Widget _label(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: AppSize.width * 0.034, color: theme.primaryColor),
        SizedBox(width: AppSize.width * 0.016),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontFamily: "pb",
            fontSize: AppSize.width * 0.028,
            fontWeight: FontWeight.bold,
            color: theme.canvasColor.withOpacity(0.6),
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
          horizontal: AppSize.width * 0.05, vertical: AppSize.height * 0.02),
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSize.width * 0.045),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSize.width * 0.015),
                    decoration: BoxDecoration(
                      color: const Color(0xff8B5CF6).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.confirmation_num_rounded,
                        color: const Color(0xff8B5CF6), size: AppSize.width * 0.045),
                  ),
                  SizedBox(width: AppSize.width * 0.03),
                  Expanded(
                    child: Text(
                      'help_support_tab_submit_ticket'.tr,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: AppSize.width * 0.03,
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.height * 0.02),
              Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
              SizedBox(height: AppSize.height * 0.02),

              _label(context, 'help_support_category_label'.tr, Icons.category_outlined),
              SizedBox(height: AppSize.height * 0.01),
              Obx(
                    () => DropdownButtonFormField<String>(
                  value: controller.selectedTicketCategory.value,
                  dropdownColor: theme.cardColor,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor),
                  style: TextStyle(fontFamily: "pr", color: theme.canvasColor),
                  decoration: _decoration(
                      context, 'help_support_select_category_hint'.tr, Icons.list_alt_outlined),
                  items: controller.ticketCategories
                      .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat,
                        style: TextStyle(
                            fontFamily: "pr",
                            fontSize: AppSize.width * 0.033,
                            color: theme.canvasColor)),
                  ))
                      .toList(),
                  onChanged: (value) => controller.selectedTicketCategory.value =
                      value ?? controller.selectedTicketCategory.value,
                ),
              ),
              SizedBox(height: AppSize.height * 0.02),

              _label(context, 'help_support_subject_label'.tr, Icons.short_text_rounded),
              SizedBox(height: AppSize.height * 0.01),
              TextField(
                controller: controller.subjectController,
                style: TextStyle(fontFamily: "pr", color: theme.canvasColor),
                decoration:
                _decoration(context, 'help_support_subject_hint'.tr, Icons.edit_outlined),
              ),
              SizedBox(height: AppSize.height * 0.02),

              _label(context, 'help_support_message_label'.tr, Icons.message_outlined),
              SizedBox(height: AppSize.height * 0.01),
              TextField(
                controller: controller.messageController,
                maxLines: 5,
                style: TextStyle(fontFamily: "pr", color: theme.canvasColor),
                decoration: _decoration(
                    context, 'help_support_message_hint'.tr, Icons.notes_rounded)
                    .copyWith(prefixIcon: null),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.height * 0.03),
        SizedBox(
          width: double.infinity,
          height: AppSize.height * 0.065,
          child: ElevatedButton(
            onPressed: controller.submitTicket,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ).copyWith(
              shadowColor: MaterialStateProperty.all(theme.primaryColor.withOpacity(0.4)),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    SizedBox(width: AppSize.width * 0.02),
                    Text(
                      'help_support_submit_ticket_button'.tr,
                      style: TextStyle(
                          fontFamily: "pb",
                          fontSize: AppSize.width * 0.036,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ======================================================================
/// LIVE CHAT TAB VIEW
/// ======================================================================

class _LiveChatTabView extends StatefulWidget {
  final Clienthelpsupportcontroller controller;
  const _LiveChatTabView({required this.controller});

  @override
  State<_LiveChatTabView> createState() => _LiveChatTabViewState();
}

class _LiveChatTabViewState extends State<_LiveChatTabView> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.controller;

    return Column(
      children: [
        /// CHAT HEADER
        Container(
          margin: EdgeInsets.fromLTRB(
              AppSize.width * 0.05, 0, AppSize.width * 0.05, AppSize.height * 0.015),
          padding: EdgeInsets.symmetric(
              horizontal: AppSize.width * 0.04, vertical: AppSize.height * 0.014),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSize.width * 0.028),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.support_agent_rounded,
                        color: Colors.white, size: AppSize.width * 0.05),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: AppSize.width * 0.032,
                      height: AppSize.width * 0.032,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.cardColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: AppSize.width * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('help_support_ai_name'.tr,
                      style: TextStyle(
                          fontFamily: "pb",
                          fontWeight: FontWeight.bold,
                          fontSize: AppSize.width * 0.036,
                          color: theme.canvasColor)),
                  SizedBox(height: 2),
                  Text('help_support_online_operator'.tr,
                      style: TextStyle(
                          fontFamily: "pr",
                          fontSize: AppSize.width * 0.026,
                          color: theme.canvasColor.withOpacity(0.5))),
                ],
              ),
            ],
          ),
        ),

        /// MESSAGES LIST
        Expanded(
          child: Obx(() {
            _scrollToBottom();
            return ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.05),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) =>
                  _bubble(controller.messages[index], theme),
            );
          }),
        ),

        /// INPUT FIELD
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSize.width * 0.04,
            AppSize.height * 0.012,
            AppSize.width * 0.04,
            AppSize.height * 0.016,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.12))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                  ),
                  child: TextField(
                    controller: controller.chatController,
                    style: TextStyle(fontFamily: "pr", color: theme.canvasColor),
                    onSubmitted: (_) => controller.sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'help_support_chat_input_hint'.tr,
                      hintStyle: TextStyle(
                          fontFamily: "pr", color: theme.canvasColor.withOpacity(0.4)),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSize.width * 0.045,
                          vertical: AppSize.height * 0.015),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSize.width * 0.025),
              GestureDetector(
                onTap: controller.sendMessage,
                child: Container(
                  padding: EdgeInsets.all(AppSize.width * 0.032),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: AppSize.width * 0.05),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bubble(ChatMessageModel message, ThemeData theme) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSize.height * 0.008),
        padding: EdgeInsets.symmetric(
            horizontal: AppSize.width * 0.04, vertical: AppSize.height * 0.014),
        constraints: BoxConstraints(maxWidth: AppSize.width * 0.75),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isUser ? null : theme.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: isUser ? null : Border.all(color: theme.dividerColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: (isUser ? theme.primaryColor : Colors.black).withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontFamily: "pr",
            color: isUser ? Colors.white : theme.canvasColor,
            fontSize: AppSize.width * 0.033,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}