import 'package:asd/reco.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // GoogleFonts 패키지 임포트
import 'package:http/http.dart' as http; // http 패키지 임포트
import 'dart:convert'; // JSON 파싱을 위해 추가

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INNOVATORS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'INNOVATORS'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _keywordController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  int _selectedIndex = 0;

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendTextToApi(String keyword, String text) async {
    final url =
        Uri.parse('https://findchannelss-osetnt6elq-uc.a.run.app'); // API
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'credentials': 'include',
        'mode': 'cors',
      },
      body: '{"keyword": "$keyword", "productionInformation": "$text"}',
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final data = json.decode(responseData['data']);
      final reason = data['reason'];
      final subscriberCount = data['subscriberCount'];
      final title = data['title'];

      _showLoadingScreen(keyword, reason, subscriberCount, title);
    } else {
      _showWarningDialog('API 요청에 실패했습니다.');
    }
  }

  void _showLoadingScreen(
      String keyword, String reason, int subscriberCount, String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 4), () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecoPage(
                keyword: keyword,
                reason: reason,
                subscriberCount: subscriberCount,
                title: title,
              ),
            ),
          );
        });
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 245, 250, 251), // 배경 흰색으로 설정
        title: Text(
          'INNOVATORS', // 영문 제목
          style: GoogleFonts.oleoScript(
            fontSize: 44, // 글씨 크기 조절
            fontWeight: FontWeight.bold, // 글씨 두껍게
            color: Colors.black, // 글씨 색상은 검은색
          ),
        ),
        centerTitle: true, // 제목 가운데 정렬
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _keywordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '키워드 입력',
                    floatingLabelBehavior:
                        FloatingLabelBehavior.always, // labelText를 위로 이동
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _textController,
                  maxLines: 15, // 텍스트 입력 칸 높이 조절
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '텍스트 입력',
                    floatingLabelBehavior:
                        FloatingLabelBehavior.always, // labelText를 위로 이동
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_keywordController.text.isEmpty) {
                    _showWarningDialog('키워드를 입력해주세요.');
                  } else if (_textController.text.isEmpty) {
                    _showWarningDialog('텍스트를 입력해주세요.');
                  } else {
                    _sendTextToApi(
                        _keywordController.text, _textController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 20), // 버튼 크기 조절
                ),
                child: const Text('매칭하기',
                    style: TextStyle(fontSize: 20)), // 글씨 크기 조절
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
