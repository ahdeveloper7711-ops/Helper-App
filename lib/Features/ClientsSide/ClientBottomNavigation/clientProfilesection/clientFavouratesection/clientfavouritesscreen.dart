import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Core/Widgets/Backbutton.dart';
import '../../../../../Core/Widgets/Background.dart';
import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';
import '../../clienthomesection/clientjobcard.dart';
import '../../clienthomesection/clientjobcontroller.dart';

class Clientfavouritesscreen extends StatefulWidget {
  const Clientfavouritesscreen({super.key});

  @override
  State<Clientfavouritesscreen> createState() => _ClientfavouritesscreenState();
}

class _ClientfavouritesscreenState extends State<Clientfavouritesscreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientJobsController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.05)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSize.heightPercent(0.02)),
                Row(
                  children: [
                    CustomBackButton(),
                    SizedBox(width: AppSize.width * 0.03),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: "pb",
                              fontSize: AppSize.textPercent(0.065),
                              fontWeight: FontWeight.bold,
                              color: theme.canvasColor,
                            ),
                            children: [
                              TextSpan(text: 'favourites_title_my'.tr),
                              TextSpan(
                                text: 'favourites_title_highlight'.tr,
                                style: TextStyle(color: theme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppSize.heightPercent(0.006)),
                        Obx(
                              () => Text(
                            'favourites_saved_jobs_count'.trParams({'count': '${controller.favouriteJobs.length}'}),
                            style: TextStyle(
                              fontFamily: "pr",
                              fontSize: AppSize.textPercent(0.035),
                              color: theme.canvasColor.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSize.heightPercent(0.03)),

                Expanded(
                  child: Obx(() {
                    final favourites = controller.favouriteJobs;

                    if (favourites.isEmpty) {
                      return _EmptyFavouritesState(theme: theme);
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: favourites.length,
                      itemBuilder: (context, index) {
                        return ClientJobCard(job: favourites[index]);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// EMPTY STATE
/// ------------------------------------------------------------
class _EmptyFavouritesState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyFavouritesState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.widthPercent(0.06)),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border_rounded,
              size: AppSize.textPercent(0.1),
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: AppSize.heightPercent(0.02)),
          Text(
            'favourites_empty_title'.tr,
            style: TextStyle(
              fontFamily: "pb",
              fontSize: AppSize.textPercent(0.042),
              fontWeight: FontWeight.bold,
              color: theme.canvasColor,
            ),
          ),
          SizedBox(height: AppSize.heightPercent(0.008)),
          Text(
            'favourites_empty_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "pr",
              fontSize: AppSize.textPercent(0.034),
              color: theme.canvasColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}