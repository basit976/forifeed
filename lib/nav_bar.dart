import 'package:flutter/material.dart';
import 'News_screen2.dart';
import 'categ_business.dart';
import 'categ_entertainment.dart';
import 'categ_pakistan.dart';
import 'categ_politics.dart';
import 'categ_sports.dart'; // Import your sports category screen

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Align(
        alignment: Alignment.centerLeft, // Align everything to the left
        child: Column(
          children: [
            // Custom Drawer Header with a Close Button
            Container(
              color: Colors.blue,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context), // Close the drawer
                  ),
                  Expanded(
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48), // Placeholder for symmetry
                ],
              ),
            ),
            // List Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.sports, color: Colors.blue),
                    title: Text('Sports'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategSports()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.movie, color: Colors.blue),
                    title: Text('Entertainment'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategEntertainment()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.movie, color: Colors.blue),
                    title: Text('Politics'),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategPolitics()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.movie, color: Colors.blue),
                    title: Text('Pakistan'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategPakistan()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.business, color: Colors.blue),
                    title: Text('Business'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategBusiness()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.fiber_new, color: Colors.blue),
                    title: Text('Latest'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewsScreen2()),
                      );
                    },
                  ),
                  // Add more items here as needed
                ],
              ),
            ),
            // Footer Section (moved below the ListTiles)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft, // Align footer to left
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
