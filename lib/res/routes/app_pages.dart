import 'package:get/get.dart';
import '../../view/home_screen.dart';
import '../../view/splash_screen.dart';
import '../../view_model/home_controller.dart';
import '../../view_model/splash_controller.dart';
import '../constants/app_constants.dart';
import 'app_routes.dart';

/// Application routing table mapping each [AppRoutes] entry to its Screen and lazy Controller.
class AppPages {
  AppPages._();

  static const String initialRoute = AppRoutes.splash;

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<SplashScreen>(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder<SplashController>(() {
        Get.lazyPut<SplashController>(() => SplashController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: AppConstants.routeTransitionDuration,
    ),
    GetPage<HomeScreen>(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder<HomeController>(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
      transition: Transition.fadeIn,
      transitionDuration: AppConstants.routeTransitionDuration,
    ),
  ];
}