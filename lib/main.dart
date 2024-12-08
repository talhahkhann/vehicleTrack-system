import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vehitrack/MainScreen/AI%20Integration/Views/ChatScreen.View.dart';
import 'package:vehitrack/MainScreen/UserNotificationScreen.dart';
import 'package:vehitrack/MainScreen/splashscreen.dart';
import 'package:vehitrack/NewsApi/ViewClass.dart';
import 'package:vehitrack/ProfileView.dart';
import 'package:vehitrack/cinc_Scanner/cnic_scanner.dart';
import 'LoginAdminPage.dart';
import 'MainScreen/Regvehicle.dart';
import 'package:badges/badges.dart' as badges;
import 'firebase_options.dart';
import 'MainScreen/Mlvision.dart';
import 'MainScreen/change_password_screen.dart';
import 'MainScreen/settings.dart';
import "MainScreen/accessed_vehicles.dart";

import 'package:vehitrack/MainScreen/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFormCompleted = prefs.getBool('isFormCompleted') ?? false;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp(isFormCompleted: isFormCompleted));
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LoginPage(),
//     );

//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/', // Define the initial route
//       routes: {
//         '/': (context) => LoginPage(), // Initial route
//         '/settings': (context) => SettingsScreen(), // Add Settings route
//         '/change_password': (context) => ChangePasswordScreen(), // Add Change Password route
//       },
//     );
//   }
// }

class MyApp extends StatefulWidget {
  final bool isFormCompleted;

  MyApp({required this.isFormCompleted});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false; // Theme state (light mode by default)

  // Function to toggle the theme (already present in your code)
  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light, // Light theme
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark, // Dark theme
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Toggle theme
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/accessed_vehicles': (context) => AccessedVehiclesScreen(),
        '/identity_scan': (context) => Cnic(),

        '/settings': (context) => SettingsScreen(
            toggleTheme: toggleTheme), // Pass the toggle function
        '/change_password': (context) => ChangePasswordScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int unreadCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUnreadCount();
    tabController = new TabController(length: 5, vsync: this);
  }

  Future<void> _getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      unreadCount = prefs.getInt('unreadCount') ?? 0;
    });
  }

  Future<void> _launchWhatsApp() async {
    final String phoneNumber =
        "923094022968"; // Replace with the actual phone number
    final String message =
        "Hello, I would like to contact you."; // Custom message

    final Uri uri = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not launch WhatsApp")),
      );
    }
  }

  Future<String?> fetchProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final uid = user.uid;

    // Fetch the document from Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection('trust')
        .where('uid', isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return doc[
          'imageUrl']; // Assuming the field storing the image URL is 'imageUrl'
    }
    return null; // Return null if no document is found
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  // Function to capture image and save to gallery
  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // Read the image file as bytes
      final file = File(image.path);
      final bytes = await file.readAsBytes();

      // Save the image to gallery
      final asset = await PhotoManager.editor
          .saveImage(Uint8List.fromList(bytes), filename: 'image');
      print("Save asset: $asset");

      if (asset != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image saved to gallery")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save image")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.currentUser;
    return Scaffold(
        bottomNavigationBar: Material(
          color: Colors.brown.shade300,
          shadowColor: Colors.black.withOpacity(0.5),
          child: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            tabs: <Widget>[
              new Tab(
                icon: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatScreen()));
                },
                child: new Tab(
                  icon: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewsScreen()));
                    },
                    child: Icon(
                      Icons.newspaper,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              new Tab(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserNotificationPanel()),
                  ).then((_) =>
                      _getUnreadCount()); // Refresh unread count after returning
                },
                child: badges.Badge(
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.red,
                    padding: EdgeInsets.all(8),
                  ),
                  badgeContent: Text(
                    unreadCount > 0 ? unreadCount.toString() : '',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  showBadge: unreadCount >
                      0, // Show badge only if there are unread notifications
                  child: const Tab(
                    icon: Icon(
                      Icons.notification_important_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              new Tab(
                icon: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  },
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              )
            ],
          ),
        ),
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  _auth.signOut();
                },
                icon: Icon(Icons.logout_outlined))
          ],
          centerTitle: true,
          title: Text(
            'VEHI TRACK',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 63, 81, 181),
            ),
          ),
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 10),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2 - 40,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.7),
                        blurRadius: 20,
                        spreadRadius: 10,
                      )
                    ],
                    color: Colors.brown.shade300,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    )),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 130),
                          child: FutureBuilder<String?>(
                            future: fetchProfileImage(), // Fetch the image URL
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Icon(Icons.error);
                              }
                              final imageUrl = snapshot.data;
                              return Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Container(
                                  height: 105,
                                  width: 105,
                                  decoration: BoxDecoration(
                                      color: Colors.brown.shade300,
                                      borderRadius: BorderRadius.circular(52.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white,
                                          spreadRadius: 2,
                                        )
                                      ]),
                                  child: CircleAvatar(
                                    backgroundImage: imageUrl != null
                                        ? NetworkImage(
                                            imageUrl) // Use the image URL
                                        : AssetImage(
                                            'assets/default_profile.png'), // Fallback image
                                    radius: 50,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      currentUser!.email.toString(),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w300),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35),
                      child: Text(
                        'Control and Management Panel',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              // Navigate to the CreditCardScreen
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onTap: () {
                                  _takePicture();
                                },
                                child: Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.photo_camera,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 3,
                                    ),
                                    Text(
                                      'Camera',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              // Navigate to the CreditCardScreen
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _launchWhatsApp();
                                    },
                                    child: Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Phone',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            // onTap: () {
                            //   // Navigate to the CreditCardScreen
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) =>
                            //             GlassMorphicCard()),
                            //   );
                            // },
                            onTap: () {
                              Navigator.pushNamed(context, '/settings');
                            },

                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.settings,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'Settings',
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 40, right: 34, left: 34),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            height: 60,
                            width: 85,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade300,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 6,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                // Navigate to the DashboardScreen
                                Navigator.pushNamed(context, '/dashboard');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.dashboard,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'Dashboard',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Container(
                          //   height: 60,
                          //   width: 90,
                          //   decoration: BoxDecoration(
                          //       color: Colors.brown.shade300,
                          //       borderRadius: BorderRadius.circular(5),
                          //       boxShadow: [
                          //         BoxShadow(
                          //             color: Colors.black.withOpacity(0.3),
                          //             spreadRadius: 6,
                          //             blurRadius: 4)
                          //       ]),
                          //   child: InkWell(
                          //     onTap: () {
                          //       // Navigate to the CreditCardScreen
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => GlassMorphicCard()),
                          //       );
                          //     },
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Column(
                          //         children: <Widget>[
                          //           Icon(
                          //             Icons.dashboard,
                          //             color: Colors.white,
                          //           ),
                          //           Text(
                          //             'Dashboard',
                          //             style: TextStyle(color: Colors.white),
                          //           )
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Container(
                          //   height: 60,
                          //   width: 85,
                          //   decoration: BoxDecoration(
                          //       color: Colors.brown.shade300,
                          //       borderRadius: BorderRadius.circular(5),
                          //       boxShadow: [
                          //         BoxShadow(
                          //             color: Colors.black.withOpacity(0.3),
                          //             spreadRadius: 6,
                          //             blurRadius: 4)
                          //       ]),
                          //   child: InkWell(
                          //     onTap: () {
                          //       // Navigate to the CreditCardScreen
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) => DataCollect()),
                          //       );
                          //     },
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Column(
                          //         children: <Widget>[
                          //           Icon(Icons.account_balance,
                          //               color: Colors.white),
                          //           Text(
                          //             'Accessed',
                          //             style: TextStyle(color: Colors.white),
                          //           )
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Container(
                            height: 60,
                            width: 85,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade300,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 6,
                                  blurRadius: 4,
                                )
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                // Navigate to the AccessedVehiclesScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AccessedVehiclesScreen(), // Navigate to the screen showing the records
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.account_balance,
                                        color: Colors
                                            .white), // Icon for the Accessed container
                                    Text(
                                      'Accessed', // Text for the Accessed container
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Container(
                            height: 60,
                            width: 85,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade300,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 6,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                // Navigate to the CreditCardScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddDataScreen()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.credit_card,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'Alert',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            height: 60,
                            width: 85,
                            decoration: BoxDecoration(
                                color: Colors.brown.shade300,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 6,
                                      blurRadius: 4)
                                ]),
                            child: InkWell(
                              onTap: () {
                                // Navigate to the CreditCardScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RegistrationAndIdentificationPage()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.language,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'Regform',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Container(
                          //   height: 60,
                          //   width: 85,
                          //   decoration: BoxDecoration(
                          //       color: Colors.brown.shade300,
                          //       borderRadius: BorderRadius.circular(5),
                          //       boxShadow: [
                          //         BoxShadow(
                          //             color: Colors.black.withOpacity(0.3),
                          //             spreadRadius: 6,
                          //             blurRadius: 4)
                          //       ]),
                          //   child: InkWell(
                          //     onTap: () {
                          //       // Navigate to the CreditCardScreen
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (context) =>
                          //                 RegistrationAndIdentificationPage()),
                          //       );``````dart
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LoginPage(),
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/', // Define the initial route
//       routes: {
//         '/': (context) => LoginPage(), // Initial route
//         '/settings': (context) => SettingsScreen(), // Add Settings route
//         '/change_password': (context) => ChangePasswordScreen(), // Add Change Password route
//       },
//     );
//   }
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   bool isDarkMode = false; // Theme state (light mode by default)

//   // Function to toggle the theme (already present in your code)
//   void toggleTheme(bool value) {
//     setState(() {
//       isDarkMode = value;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         brightness: Brightness.light, // Light theme
//       ),
//       darkTheme: ThemeData(
//         primarySwatch: Colors.blue,
//         brightness: Brightness.dark, // Dark theme
//       ),
//       themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Toggle theme
//       initialRoute: '/',
//       routes: {
//         '/': (context) => AuthScreen(),
//         '/dashboard': (context) => DashboardScreen(),
//         '/accessed_vehicles': (context) => AccessedVehiclesScreen(),
//         '/identity_scan': (context) => OcrScreen(),
//         '/settings': (context) => SettingsScreen(
//             toggleTheme: toggleTheme), // Pass the toggle function
//         '/change_password': (context) => ChangePasswordScreen(),
//       },
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage>
//     with SingleTickerProviderStateMixin {
//   late TabController tabController;
//   int unreadCount = 0;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _getUnreadCount();
//     tabController = new TabController(length: 5, vsync: this);
//   }

//   Future<void> _getUnreadCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       unreadCount = prefs.getInt('unreadCount') ?? 0;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         bottomNavigationBar: Material(
//           color: Colors.brown.shade300,
//           shadowColor: Colors.black.withOpacity(0.5),
//           child: TabBar(
//             controller: tabController,
//             indicatorColor: Colors.white,
//             tabs: <Widget>[
//               new Tab(
//                 icon: Icon(
//                   Icons.home,
//                   color: Colors.white,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(context,
//                       MaterialPageRoute(builder: (context) => ChatScreen()));
//                 },
//                 child: new Tab(
//                   icon: Icon(
//                     Icons.chat_rounded,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               new Tab(
//                 icon: Icon(
//                   Icons.search,
//                   color: Colors.white,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const UserNotificationPanel()),
//                   ).then((_) =>
//                       _getUnreadCount()); // Refresh unread count after returning
//                 },
//                 child: badges.Badge(
//                   badgeStyle: const badges.BadgeStyle(
//                     badgeColor: Colors.red,
//                     padding: EdgeInsets.all(8),
//                   ),
//                   badgeContent: Text(
//                     unreadCount > 0 ? unreadCount.toString() : '',
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                   showBadge: unreadCount >
//                       0, // Show badge only if there are unread notifications
//                   child: const Tab(
//                     icon: Icon(
//                       Icons.notification_important_outlined,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//               new Tab(
//                 icon: Icon(
//                   Icons.person,
//                   color: Colors.white,
//                   size: 40,
//                 ),
//               )
//             ],
//           ),
//         ),
//         appBar: AppBar(
//           centerTitle: true,
//           title: Text(
//             'VEHI TRACK',
//             style: TextStyle(
//               fontSize: 27,
//               fontWeight: FontWeight.bold,
//               color: Color.fromARGB(255, 63, 81, 181),
//             ),
//           ),
//         ),
//         body: Container(
//           color: Colors.white,
//           child: Column(
//             children: <Widget>[
//               Container(
//                 padding: EdgeInsets.only(top: 10),
//                 width: MediaQuery.of(context).size.width,
//                 height: MediaQuery.of(context).size.height / 2 - 40,
//                 decoration: BoxDecoration(
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.7),
//                         blurRadius: 20,
//                         spreadRadius: 10,
//                       )
//                     ],
//                     color: Colors.brown.shade300,
//                     borderRadius: BorderRadius.only(
//                       bottomRight: Radius.circular(30),
//                       bottomLeft: Radius.circular(30),
//                     )),
//                 child: Column(
//                   children: <Widget>[
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         Padding(
//                           padding: const EdgeInsets.only(left: 130),
//                           child: Container(
//                             height: 105,
//                             width: 105,
//                             decoration: BoxDecoration(
//                                 color: Colors.brown.shade300,
//                                 borderRadius: BorderRadius.circular(52.5),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.yellow,
//                                     spreadRadius: 2,
//                                   )
//                                 ]),
//                             child: CircleAvatar(
//                               radius: 50,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text(
//                       '@Lahore Garisson Universty',
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.w300),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 35),
//                       child: Text(
//                         'Control and Management Panel',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(left: 20, right: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Container
//                 },
                          //     child: Padding(
                          //       padding: const EdgeInsets.all(8.0),
                          //       child: Column(
                          //         children: <Widget>[
                          //           Icon(
                          //             Icons.question_answer,
                          //             color: Colors.white,
                          //           ),
                          //           Text(
                          //             'Identity',
                          //             style: TextStyle(color: Colors.white),
                          //           )
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          Container(
                            height: 60,
                            width: 85,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade300,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 6,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () {
                                // Navigate to the IdentityScanScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Cnic(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Cnic()));
                                      },
                                      child: Icon(
                                        Icons.question_answer,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Scaning',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Container(
                            height: 60,
                            width: 85,
                            decoration: BoxDecoration(
                                color: Colors.brown.shade300,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 6,
                                      blurRadius: 4)
                                ]),
                            child: InkWell(
                              onTap: () {
                                // Navigate to the CreditCardScreen
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.visibility,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'Statics',
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountEmail: Text(
                  currentUser?.email ?? 'No email',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                accountName: Text(""),
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 175, 126, 108)),
                currentAccountPicture: FutureBuilder<String?>(
                    future: fetchProfileImage(), // Fetch the image URL
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Icon(Icons.error);
                      }
                      final imageUrl = snapshot.data;
                      (
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: imageUrl != null
                              ? NetworkImage(imageUrl) // Use the image URL
                              : AssetImage(
                                  'assets/default_profile.png'), // Fallback image
                          radius: 50,
                        )
                      );

                      return CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: imageUrl != null
                            ? NetworkImage(imageUrl) // Use the image URL
                            : AssetImage(
                                'assets/default_profile.png'), // Fallback image
                        radius: 50,
                      );
                    }),
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text(
                  'LGU Admin',
                  style: TextStyle(fontSize: 24.0),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => AdminLoginPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }
}
