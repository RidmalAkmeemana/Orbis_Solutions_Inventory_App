import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

class HomeBody extends StatelessWidget {
  final String firstName;
  final String lastName;
  final bool isLoading;
  final double totalSales;
  final double totalExpenses;
  final double totalOutstanding;
  final List<dynamic> topCustomers;
  final List<dynamic> allUsers;
  final Function() onRefresh;

  const HomeBody({
    required this.firstName,
    required this.lastName,
    required this.isLoading,
    required this.totalSales,
    required this.totalExpenses,
    required this.totalOutstanding,
    required this.topCustomers,
    required this.allUsers,
    required this.onRefresh,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "en_US");

    Widget dashboardCard(String title, double value) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 25, offset: Offset(0, 12))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(formatter.format(value), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          ],
        ),
      );
    }

    Widget buildUserSlider() {
      if (allUsers.isEmpty) return SizedBox();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("User List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text("View More", style: TextStyle(color: Color(0xFFbe3235), fontSize: 14)),
              ),
            ],
          ),
          SizedBox(height: 15),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: allUsers.length,
              padding: EdgeInsets.only(left: 10),
              itemBuilder: (context, index) {
                final user = allUsers[index];
                return Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: user["img"] != null && user["img"].toString().isNotEmpty
                            ? NetworkImage(user["img"])
                            : null,
                        backgroundColor: Colors.grey.shade300,
                        child: (user["img"] == null || user["img"].toString().isEmpty)
                            ? Icon(Icons.person, size: 32, color: Colors.white)
                            : null,
                      ),
                      SizedBox(height: 6),
                      SizedBox(
                        width: 80,
                        child: Text(user["firstname"] ?? "",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    Widget buildTopCustomers() {
      if (topCustomers.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Top 10 Customers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {},
                  child: Text("View More", style: TextStyle(color: Color(0xFFbe3235), fontSize: 14)),
                ),
              ],
            ),
            SizedBox(height: 15),
            Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("No Customer Data Found", style: TextStyle(color: Colors.grey)),
                )),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Top 10 Customers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: Text("View More", style: TextStyle(color: Color(0xFFbe3235), fontSize: 14)),
              ),
            ],
          ),
          SizedBox(height: 10),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: topCustomers.length > 10 ? 10 : topCustomers.length,
            itemBuilder: (context, i) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 6),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(topCustomers[i]["customer_name"] ?? "-",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 3),
                          Text(topCustomers[i]["contact_no"] ?? "-",
                              style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: Color(0xFFbe3235),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text("#${i + 1}",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }

    // Show loading indicator first
    if (isLoading) {
      return Center(
        child: SizedBox(
          height: 80,
          width: 80,
          child: LoadingIndicator(
            indicatorType: Indicator.ballClipRotateMultiple,
            colors: [Color(0xFFbe3235)],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: Color(0xFFbe3235),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome $firstName $lastName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: PageView(
                controller: PageController(viewportFraction: 1.05),
                children: [
                  dashboardCard("Total Sales", totalSales),
                  dashboardCard("Total Expenses", totalExpenses),
                  dashboardCard("Total Outstanding", totalOutstanding),
                ],
              ),
            ),
            buildUserSlider(),
            buildTopCustomers(),
          ],
        ),
      ),
    );
  }
}
