import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/iconcircle.dart';
import '../../../../../Core/Widgets/Backbutton.dart';
import '../../../../../Core/Widgets/Background.dart';
import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';
import 'controller.dart';
import 'depositsheet.dart';
import 'withdrawsheet.dart';


class Workerwalletscreen extends StatefulWidget {
  Workerwalletscreen({super.key});

  @override
  State<Workerwalletscreen> createState() => _WorkerwalletscreenState();
}

class _WorkerwalletscreenState extends State<Workerwalletscreen> {
  final c = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBackground(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.05),
        child: Column(
          children: [
            SizedBox(height: AppSize.height * 0.02),

            /// HEADER
            Row(
              children: [
                const CustomBackButton(),
                SizedBox(width: AppSize.width * 0.03),
                Text(
                  'worker_wallet_title'.tr,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.canvasColor),
                ),
              ],
            ),

            SizedBox(height: AppSize.height * 0.03),

            /// BALANCE CARD
            _balanceCard(theme),

            SizedBox(height: AppSize.height * 0.03),

            /// TRANSACTIONS TITLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'worker_wallet_recent_transactions'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.canvasColor),
                ),
                Text('worker_wallet_see_all'.tr, style: TextStyle(color: theme.primaryColor)),
              ],
            ),

            SizedBox(height: AppSize.height * 0.02),

            /// LIST
            Expanded(
              child: ListView(
                children: [
                  _txCard("+", 'worker_wallet_tx_plumbing_title'.tr, "+\$120.00", 'worker_wallet_tx_time_today'.tr),
                  _txCard("-", 'worker_wallet_tx_bank_withdrawal_title'.tr, "-\$500.00", 'worker_wallet_tx_time_yesterday'.tr),
                  _txCard("+", 'worker_wallet_tx_hvac_title'.tr, "+\$350.00", 'worker_wallet_tx_time_mar5'.tr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.height * 0.018, vertical: AppSize.height * 0.014),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('worker_wallet_total_balance'.tr, style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              IconCircle(
                icon: Icons.wallet,
                height: AppSize.height * 0.05,
                iconSize: AppSize.height * 0.025,
                backgroundColor: Colors.white.withOpacity(0.2),
                iconColor: Colors.white,
                width: AppSize.height * 0.05,
              ),
            ],
          ),
          SizedBox(height: AppSize.height * 0.009),
          Obx(() => Text("\$${c.balance.value.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
          SizedBox(height: AppSize.height * 0.018),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.generalDialog(pageBuilder: (_, __, ___) => Center(child: DepositPopup())),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  child: Text('worker_wallet_deposit_button'.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.dialog(WithdrawPopup()),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white),
                  child: Text('worker_wallet_withdraw_button'.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _txCard extends StatelessWidget {
  final String type;
  final String title;
  final String amount;
  final String time;

  const _txCard(this.type, this.title, this.amount, this.time);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlus = type == "+";

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.height * 0.01),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isPlus ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
            child: Text(type, style: TextStyle(color: isPlus ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: theme.canvasColor)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(color: theme.canvasColor.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(color: isPlus ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}