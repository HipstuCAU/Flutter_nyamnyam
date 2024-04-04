import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:nyam_nyam_flutter/models/customType.dart';
import 'package:nyam_nyam_flutter/models/meal.dart';
import 'package:nyam_nyam_flutter/models/mealsByCampus.dart';

class ApiService {
  final firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getJsonFromFirebase() async {
    var response = await firestore
        .collection('CAU_Haksik')
        .doc("CAU_Cafeteria_Menu")
        .get();
    var data = response.data();
    if (data != null) {
      return data;
    }
    return {};
  }

  Future<List<Map<String, List<MealModel>>>> getMeals(
      Map<String, dynamic> data) async {
    List<Map<String, List<MealModel>>> meals = [];

    if (data.isNotEmpty) {
      MealsByCampusModel mealsInstances = MealsByCampusModel.fromJson(data);
      meals = getMealsForWeek(mealsInstances);
    }

    return meals;
  }

  List<List<MealModel>> getMealsByCampus(
      MealsByCampusModel mealsByCampusModel) {
    List<MealModel> seoulMeals = [];
    List<MealModel> ansungMeals = [];
    List<List<MealModel>> meals = [];
    List<String> menu;
    String price;
    DateTime date;
    List<DateTime> openTime = [];
    MealTime mealTime;
    MealType mealType;
    OpenType openType;
    RestaurantType restaurantType;

    List<MealModel> getMealsForOneCampus(CampusType campusType) {
      Map<String, dynamic> meals = campusType == CampusType.seoul
          ? mealsByCampusModel.seoulMeals
          : mealsByCampusModel.ansungMeals;

      List<MealModel> mealsForOneCampus = [];

      meals.forEach((key, value) {
        date = DateTime.parse(key.replaceAll(".", ""));

        Map<String, dynamic> mealsByDay = value;
        mealsByDay.forEach((key, value) {
          switch (key) {
            case "0":
              mealTime = MealTime.breakfast;
              break;
            case "1":
              mealTime = MealTime.lunch;
              break;
            case "2":
              mealTime = MealTime.dinner;
              break;
            default:
              mealTime = MealTime.breakfast;
          }
          Map<String, dynamic> mealsByTime = value;
          mealsByTime.forEach((key, value) {
            switch (key) {
              case "참슬기식당(310관 B4층)":
                restaurantType = RestaurantType.chamsulgi;
                break;
              case "생활관식당(블루미르308관)":
                restaurantType = RestaurantType.domitoryA;
                break;
              case "생활관식당(블루미르309관)":
                restaurantType = RestaurantType.domitoryB;
                break;
              case "학생식당(303관B1층)":
                restaurantType = RestaurantType.student;
                break;
              case "교직원식당(303관B1층)":
                restaurantType = RestaurantType.staff;
                break;
              case "카우잇츠(cau eats)":
                restaurantType = RestaurantType.cauEats;
                break;
              case "(안성)카우버거":
                restaurantType = RestaurantType.cauBurger;
                break;
              case "(안성)라면":
                restaurantType = RestaurantType.ramen;
                break;
              default:
                restaurantType = RestaurantType.chamsulgi;
                break;
            }
            Map<String, dynamic> mealsByType = value;
            mealsByType.forEach((key, value) {
              var tmpMealType = key.split("(");
              if (tmpMealType.length > 1) {
                key = tmpMealType[1].replaceAll(')', '');
              }

              switch (key) {
                case "한식":
                  mealType = MealType.korean;
                  break;
                case "양식":
                  mealType = MealType.western;
                  break;
                case "특식":
                  mealType = MealType.special;
                  break;
                case "학생석식":
                  mealType = MealType.studentDinner;
                  break;
                case "석식":
                  mealType = MealType.ordinaryDinner;
                  break;
                default:
                  mealType = MealType.korean;
                  break;
              }
              price = value['price'];
              var menuFullString = value['menu'];
              if (menuFullString != null) {
                if (menuFullString != "") {
                  menu = menuFullString.split("|");
                  openType = menu == "주말운영없음"
                      ? OpenType.closeOnWeekends
                      : OpenType.everyday;

                  if (value['time'] != null) {
                    openTime = [];

                    var tmpOpenTimeList = value['time'].split('~');
                    if (tmpOpenTimeList.length == 1) {
                      openTime
                          .add(DateFormat("hh:mm").parse(tmpOpenTimeList[0]));
                    } else if (tmpOpenTimeList.length == 2) {
                      try {
                        openTime
                            .add(DateFormat("hh:mm").parse(tmpOpenTimeList[0]));
                      } catch (e) {
                        openTime.add(DateFormat("hh:mm").parse("00:00"));
                      }
                      try {
                        openTime
                            .add(DateFormat("hh:mm").parse(tmpOpenTimeList[1]));
                      } catch (e) {
                        openTime.add(DateFormat("hh:mm").parse("00:00"));
                      }
                    }
                  }

                  MealModel meal = MealModel(
                    date: date,
                    openTime: openTime,
                    restaurantType: restaurantType,
                    mealTime: mealTime,
                    mealType: mealType,
                    openType: openType,
                    menu: menu,
                    price: price,
                  );
                  mealsForOneCampus.add(meal);
                }
              }
            });
          });
        });
      });
      return mealsForOneCampus;
    }

    seoulMeals = getMealsForOneCampus(CampusType.seoul);
    ansungMeals = getMealsForOneCampus(CampusType.ansung);

    meals.add(seoulMeals);
    meals.add(ansungMeals);

    return meals;
  }

  List<MealsForWeek> getMealsForWeek(MealsByCampusModel mealsByCampusModel) {
    List<List<MealModel>> mealsByCampus = getMealsByCampus(mealsByCampusModel);

    List<MealsForWeek> mealsForWeek = [];
    MealsForWeek seoulMealsForWeek = {};
    MealsForWeek ansungMealsForWeek = {};
    List<MealModel> mealsForDay = [];

    MealsForWeek getMealsForWeekByCampus(CampusType campusType) {
      List<MealModel> mealsForOneCampus =
          campusType == CampusType.seoul ? mealsByCampus[0] : mealsByCampus[1];
      MealsForWeek mealsForOneCampusForWeek = {};
      for (var element in mealsForOneCampus) {
        if (mealsForOneCampusForWeek.containsKey(element.date)) {
          mealsForDay = mealsForOneCampusForWeek[element.date]!;
          mealsForDay.add(element);
          mealsForOneCampusForWeek[element.date.toString().substring(0, 10)] =
              mealsForDay;
        } else {
          mealsForDay.add(element);
          mealsForOneCampusForWeek[element.date.toString().substring(0, 10)] =
              mealsForDay;
        }
      }
      return mealsForOneCampusForWeek;
    }

    seoulMealsForWeek = getMealsForWeekByCampus(CampusType.seoul);
    ansungMealsForWeek = getMealsForWeekByCampus(CampusType.ansung);

    mealsForWeek.add(seoulMealsForWeek);
    mealsForWeek.add(ansungMealsForWeek);

    return mealsForWeek;
  }
}
