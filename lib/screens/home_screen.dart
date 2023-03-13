import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/extensions/colors+.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'dart:ui' as ui;
import 'package:intl/date_symbol_data_local.dart';
import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/screens/setting_screen.dart';
import 'package:nyam_nyam_flutter/services/api_service.dart';
import 'package:nyam_nyam_flutter/widgets/menu_widget.dart';
import 'package:nyam_nyam_flutter/widgets/restaurantPicker_widget.dart';
import 'package:nyam_nyam_flutter/widgets/sevenDatePicker_widget.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static CampusType entryPoint = CampusType.seoul;
  static List<bool> isSelectedRestaurant = [
    true,
    false,
    false,
    false,
    false,
  ];
  static PageController pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.9,
  );
  static AutoScrollController autoScrollController = AutoScrollController();
  static List<String> seoulRestaurantName = [
    '참슬기',
    '생활관A',
    '생활관B',
    '학생식당',
    '교직원'
  ];
  static List<String> ansungRestaurantName = [
    '카우이츠',
    '카우버거',
    '라면',
  ];

  static List<bool> isSelectedDate = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  static late SharedPreferences preferences;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var sevenDays = [];
  var sevenDaysOfWeek = [];
  Map<String, String> sevenDates = {};
  List<bool> isSelectedDate = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  var currentPageIndex = 0;

  late Future<List<MealsForWeek>> meals;

  Future initPreferences() async {
    HomeScreen.preferences = await SharedPreferences.getInstance();
    final favoriteCampus = HomeScreen.preferences.getString('favoriteCampus');
    final sortedSeoulRestaurants =
        HomeScreen.preferences.getStringList('sortedSeoulRestaurants');
    final sortedAnsungRestaurants =
        HomeScreen.preferences.getStringList('sortedAnsungRestaurants');
    setState(() {
      if (favoriteCampus != null) {
        if (favoriteCampus == "서울") {
          HomeScreen.entryPoint = CampusType.seoul;
        } else {
          HomeScreen.entryPoint = CampusType.ansung;
        }
      } else {
        HomeScreen.preferences.setString('favoriteCampus', '');
      }

      if (sortedSeoulRestaurants != null) {
        HomeScreen.seoulRestaurantName = sortedSeoulRestaurants;
      } else {
        HomeScreen.preferences.setStringList('sortedSeoulRestaurants', [
          '참슬기',
          '생활관A',
          '생활관B',
          '학생식당',
          '교직원',
        ]);
      }

      if (sortedAnsungRestaurants != null) {
        HomeScreen.ansungRestaurantName = sortedAnsungRestaurants;
      } else {
        HomeScreen.preferences.setStringList('sortedAnsungRestaurants', [
          '카우이츠',
          '카우버거',
          '라면',
        ]);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initPreferences();
    get7daysFromToday();
    meals = ApiService().getMeals();
  }

  Map<String, String> get7daysFromToday() {
    var today = DateTime.now().add(const Duration(hours: 19));
    for (int i = 0; i < 7; i++) {
      initializeDateFormatting();
      DateTime date = today.subtract(Duration(days: -i));
      sevenDays.add(int.parse(DateFormat('dd').format(date)).toString());
      sevenDaysOfWeek.add(DateFormat.E('ko_KR').format(date));
      sevenDates[sevenDaysOfWeek[i]] = sevenDays[i];
    }
    return sevenDates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: NyamColors.gradientBG,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 30,
                left: 10,
                right: 10,
                bottom: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: TextButton.icon(
                      onPressed: (() {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoActionSheet(
                            title: const Text("캠퍼스를 선택해주세요."),
                            actions: <Widget>[
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  setState(() {
                                    HomeScreen.entryPoint = CampusType.seoul;
                                    Navigator.pop(context, 'Cancel');
                                    HomeScreen.isSelectedRestaurant = [
                                      true,
                                      false,
                                      false,
                                      false,
                                      false,
                                    ];
                                  });
                                },
                                child: const Text(
                                  "서울캠퍼스",
                                ),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  setState(() {
                                    HomeScreen.entryPoint = CampusType.ansung;
                                    Navigator.pop(context, 'Cancel');
                                    HomeScreen.isSelectedRestaurant = [
                                      true,
                                      false,
                                      false,
                                    ];
                                  });
                                },
                                child: const Text(
                                  "안성캠퍼스",
                                ),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(context, 'Cancel');
                              },
                              child: const Text("취소"),
                            ),
                          ),
                        );
                      }),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: NyamColors.customGrey,
                        size: 35,
                      ),
                      label: Text(
                        HomeScreen.entryPoint == CampusType.seoul
                            ? "서울캠퍼스"
                            : "안성캠퍼스",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = const Offset(1, 0);
                            var end = Offset.zero;
                            var curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end).chain(
                              CurveTween(
                                curve: curve,
                              ),
                            );
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SettingScreen(),
                        ),
                      );
                      setState(() {});
                    },
                    icon: const Icon(Icons.settings),
                    color: NyamColors.customGrey,
                    iconSize: 25,
                  )
                ],
              ),
            ),
            Container(
              height: 10,
              color: NyamColors.customSkyBlue,
            ),
            SevenDatePicker(
              sevenDays: sevenDays,
              sevenDaysOfWeek: sevenDaysOfWeek,
            ),
            Container(
              height: 10,
              color: NyamColors.customSkyBlue,
            ),
            RestaurantPicker(
              seoulRestaurantName: HomeScreen.seoulRestaurantName,
              ansungRestaurantName: HomeScreen.ansungRestaurantName,
            ),
            Expanded(
              child: PageView.builder(
                controller: HomeScreen.pageController,
                onPageChanged: (value) {
                  setState(() {
                    if (HomeScreen.entryPoint == CampusType.seoul) {
                      HomeScreen.isSelectedRestaurant = [
                        false,
                        false,
                        false,
                        false,
                        false,
                      ];
                    } else {
                      HomeScreen.isSelectedRestaurant = [
                        false,
                        false,
                        false,
                      ];
                    }

                    HomeScreen.isSelectedRestaurant[value] = true;
                    HomeScreen.autoScrollController.animateTo(
                      value * 30,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  });
                },
                itemCount: HomeScreen.entryPoint == CampusType.seoul
                    ? HomeScreen.seoulRestaurantName.length
                    : HomeScreen.ansungRestaurantName.length,
                itemBuilder: (context, index) {
                  return MealsOfRestaurant(
                    isBurgerOrRamen: false,
                    index: index,
                    mealsForDay: [
                      MealModel(
                        date: DateTime.now(),
                        openTime: [DateTime.now(), DateTime.now()],
                        restaurantType: RestaurantType.chamsulgi,
                        mealTime: MealTime.breakfast,
                        mealType: MealType.korean,
                        openType: OpenType.everyday,
                        menu: ["참깨", "비빔면", "냉면"],
                        price: "4,800 원",
                      ),
                      MealModel(
                        date: DateTime.now(),
                        openTime: [DateTime.now(), DateTime.now()],
                        restaurantType: RestaurantType.chamsulgi,
                        mealTime: MealTime.breakfast,
                        mealType: MealType.korean,
                        openType: OpenType.everyday,
                        menu: ["참깨", "비빔면", "냉면"],
                        price: "4,800 원",
                      ),
                      MealModel(
                        date: DateTime.now(),
                        openTime: [DateTime.now(), DateTime.now()],
                        restaurantType: RestaurantType.chamsulgi,
                        mealTime: MealTime.lunch,
                        mealType: MealType.korean,
                        openType: OpenType.everyday,
                        menu: ["참깨", "비빔면", "냉면"],
                        price: "4,800 원",
                      ),
                      MealModel(
                        date: DateTime.now(),
                        openTime: [DateTime.now(), DateTime.now()],
                        restaurantType: RestaurantType.chamsulgi,
                        mealTime: MealTime.dinner,
                        mealType: MealType.korean,
                        openType: OpenType.everyday,
                        menu: ["참깨", "비빔면", "냉면"],
                        price: "4,800 원",
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealsOfRestaurant extends StatefulWidget {
  MealsOfRestaurant({
    super.key,
    required this.mealsForDay,
    required this.index,
    required this.isBurgerOrRamen,
  });

  int index;
  MealsForDay mealsForDay;
  List<String> seoulRestaurantDetailNames = [
    "경영경제관 310관 B4층",
    "블루미르관 308관",
    "블루미르관 309관",
    "법학관 303관 B1층",
    "법학관 303관 B1층",
  ];

  String ansungRestaurantDetailName = "707관";

  bool isBurgerOrRamen;

  @override
  State<MealsOfRestaurant> createState() => _MealsOfRestaurantState();
}

class _MealsOfRestaurantState extends State<MealsOfRestaurant> {
  @override
  void initState() {
    super.initState();
    setMealsByTime();
  }

  MealsForDay breakfast = [];
  MealsForDay lunch = [];
  MealsForDay dinner = [];

  void setMealsByTime() {
    breakfast = widget.mealsForDay.where((element) {
      return element.mealTime == MealTime.breakfast;
    }).toList();
    lunch = widget.mealsForDay.where((element) {
      return element.mealTime == MealTime.lunch;
    }).toList();
    dinner = widget.mealsForDay.where((element) {
      return element.mealTime == MealTime.dinner;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 210,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 10,
            left: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  HomeScreen.entryPoint == CampusType.seoul
                      ? widget.seoulRestaurantDetailNames[widget.index]
                      : widget.ansungRestaurantDetailName,
                  style: const TextStyle(
                    color: NyamColors.grey50,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.isBurgerOrRamen ? 1 : 3,
                  itemBuilder: (context, index) {
                    var meals = [breakfast, lunch, dinner];
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 7,
                        bottom: 7,
                      ),
                      child: Menu(
                        mealsForDay: meals[index],
                        isBurgerOrRamen: widget.isBurgerOrRamen,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
