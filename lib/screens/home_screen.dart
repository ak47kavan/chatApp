import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kri_dhan/models/chat_user.dart';
import 'package:kri_dhan/screens/profile_screen.dart';
import 'package:kri_dhan/widgets/chat_user_card.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api/apis.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching=!_isSearching;
            });
            return Future.value(false);
          }else {
                return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ?  TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Name, Email, ...',
                        hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w400)),
                    autofocus: true,
                    onChanged: (val){
                      _searchList.clear();
        
                      for (var i in _list){
                            if ((i.name?.toLowerCase().contains(val.toLowerCase()) ?? false) || 
        (i.email?.toLowerCase().contains(val.toLowerCase()) ?? false)) {
          // Your logic here
        _searchList.add(i);
        }
          setState(() {
        _searchList;
          });
                      }
                    },
                  )
                : Text(
                    "AK Chat",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600
                    ),
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid : Icons.search),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)),
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FloatingActionButton(
              onPressed: () async {
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
              },
              backgroundColor: const Color.fromARGB(255, 40, 219, 226),
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
        
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
        
                  if (_list.isNotEmpty) {
                    return ListView.builder(
                      itemCount: _isSearching ? _searchList.length:  _list.length,
                      padding: EdgeInsets.only(top: mq.height * .01),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ChatUserCard(user: _isSearching ? _searchList[index] : _list[index]);
                      },
                    );
                  } else {
                    return const Center(child: Text("No Connections Found! 🥺", style: TextStyle(fontSize: 20)));
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
