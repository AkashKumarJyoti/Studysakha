import 'package:flutter/material.dart';
import 'payment_gateway/coin_offer.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SideMenuScreen extends StatefulWidget {
  @override
  _SideMenuScreenState createState() => _SideMenuScreenState();
}

class _SideMenuScreenState extends State<SideMenuScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          // Background with linear gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFF76FFB8), // Slightly less light green
                  Color(0xFF6F99F7),// Lighter blue
                ],
                stops: [0.134, 0.866],
              ),
            ),
          ),
          // Content of the side menu
          SingleChildScrollView(
          child:Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50.0),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User's image
                    _currentUser != null
                        ? Container(
                      width: 71.95,
                      height: 71.95,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(_currentUser!.photoUrl ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : Container(), // Placeholder for when the image is loading or not available

                    const SizedBox(width: 10.0), // Adjust the spacing between image and name

                    // User's name and edit profile button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User's name
                        Text(
                          _currentUser?.displayName ?? 'Guest',
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 0.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 13.0), // Adjust the left padding as needed
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle edit profile button tap
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              minimumSize: const Size(79.91, 20.0), // Set the minimum size to control the height
                            ),
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 10.0,
                                fontWeight: FontWeight.w300,
                                color: Colors.black,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Your menu items go here
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: -2.0),// Remove default padding
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text(
                    'Home',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle home item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical:0.0),
                  leading: const Icon(Icons.list, color: Colors.white),
                  title: const Text(
                    'All Plans',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle All Plans item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                  leading: const Icon(Icons.monetization_on, color: Colors.white),
                  title: const Text(
                    'Buy Coins',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle Buy Coins item tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CoinOffers()),
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.account_balance, color: Colors.white),
                  title: const Text(
                    'My Plans',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle My Plans item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.class_, color: Colors.white),
                  title: const Text(
                    'My Classes',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle My Classes item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.assignment, color: Colors.white),
                  title: const Text(
                    'My Tests',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle My Tests item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.poll, color: Colors.white),
                  title: const Text(
                    'Results',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle Results item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.bar_chart, color: Colors.white),
                  title: const Text(
                    'Analysis Report',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle Analysis Report item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.library_books, color: Colors.white),
                  title: const Text(
                    'Library',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle Library item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.phone, color: Colors.white),
                  title: const Text(
                    'Call History',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle Call History item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.support, color: Colors.white),
                  title: const Text(
                    'Support',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle Support item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.assignment, color: Colors.white),
                  title: const Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle Terms and Conditions item tap
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(Icons.logout, color: Colors.white),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    // Handle Log Out item tap
                  },
                ),
              ],
            ),
          ),
          ),
        ],
      ),
       );

  }
}
