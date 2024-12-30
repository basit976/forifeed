import 'package:flutter/material.dart';
import 'News_screen2.dart'; // Assuming NewsScreen2 exists
import 'firebase_service.dart'; // Import the FirebaseService class

class SelectionScreen extends StatefulWidget {
  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final List<Map<String, String>> channels = [
    {'name': 'The News International', 'logo': 'assets/images/news_international_logo.png'},
    {'name': 'Express Tribune', 'logo': 'assets/images/expresstribune.jpg'},
    {'name': 'Dawn', 'logo': 'assets/images/dawnnews.png'},
    {'name': 'Geo News', 'logo': 'assets/geonews.png'},
    {'name': 'ARY News', 'logo': 'assets/images/arynews.jpg'},
    {'name': 'Pakistan Today', 'logo': 'assets/images/pktodaynews.jpg'},
    {'name': 'Mashriq TV', 'logo': 'assets/images/mashriqnews.jpg'},
    {'name': 'Bol News', 'logo': 'assets/images/bolnews.png'},
    {'name': 'BBC', 'logo': 'assets/images/bbcnews.png'},
    {'name': 'The New York Times', 'logo': 'assets/images/nytimesnews.png'},
    {'name': 'CNN', 'logo': 'assets/images/cnnnews.png'},
    {'name': 'Sky News', 'logo': 'assets/images/skynews.jpg'},
    {'name': 'Fox News', 'logo': 'assets/images/foxnews.png'},
    {'name': 'Google News', 'logo': 'assets/images/googlenews.png'},
    {'name': 'Al Jazeera', 'logo': 'assets/images/aljazeera.png'},
    {'name': 'The Guardian', 'logo': 'assets/images/guardnews.jpg'},
    {'name': 'ASport', 'logo': 'assets/images/asport.jpg'},
    {'name': 'Hum News', 'logo': 'assets/images/humnews.jpg'},
    {'name': 'Ab Takk News', 'logo': 'assets/images/abtaknews.jpg'},
  ];

  List<String> followedChannels = [];

  @override
  void initState() {
    super.initState();
    _loadFollowedChannels();
  }

  /// Loads followed channels from Firebase
  Future<void> _loadFollowedChannels() async {
    List<String> channels = await _firebaseService.fetchFollowedChannels();
    setState(() {
      followedChannels = channels;
    });
  }

  /// Toggles the follow state of a channel
  void toggleFollow(String channelName) async {
    setState(() {
      if (followedChannels.contains(channelName)) {
        followedChannels.remove(channelName);
      } else {
        followedChannels.add(channelName);
      }
    });
    await _firebaseService.saveFollowedChannels(followedChannels);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'News Channels',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () async {
              await _firebaseService.saveFollowedChannels(followedChannels);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsScreen2()), // Replace with your NewsScreen2
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: channels.length,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          itemBuilder: (context, index) {
            final channel = channels[index];
            bool isFollowed = followedChannels.contains(channel['name']!);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                shadowColor: Colors.black.withOpacity(0.1),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.asset(
                      channel['logo']!,
                      fit: BoxFit.contain,
                    ),
                  ),
                  title: Text(
                    channel['name']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () => toggleFollow(channel['name']!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowed ? Colors.grey[300] : Colors.blueAccent,
                      foregroundColor: isFollowed ? Colors.black : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: Icon(
                      isFollowed ? Icons.check : Icons.add,
                      color: isFollowed ? Colors.green : Colors.white,
                    ),
                    label: Text(
                      isFollowed ? 'Following' : 'Follow',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
