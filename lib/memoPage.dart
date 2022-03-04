import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'memo.dart';
import 'memoAdd.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({Key? key}) : super(key: key);

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  FirebaseDatabase? _database;
  DatabaseReference? reference;
  final String _databaseURL =
      'https://fir-example-bc7f8-default-rtdb.firebaseio.com/';

  // 메모 목록을 나타낼 리스트
  List<Memo> memos = List.empty(growable: true);

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase(databaseURL: _databaseURL);
    reference =
        _database!.reference().child('memo'); // 데이터베이스 안에 memo 컬렉션을 만드는 코드

    reference!.onChildAdded.listen((event) {
      print(event.snapshot.value.toString());
      setState(() {
        memos.add(Memo.fromSnapshot(event.snapshot));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메모 앱'),
      ),
      body: Container(
        child: Center(
          child: memos.isEmpty
              ? const CircularProgressIndicator()
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (context, index) {
                    return Card(
                      child: GridTile(
                        child: Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: SizedBox(
                            child: GestureDetector(
                              onTap: () {
                                // todo : 메모 상세 보기로 이동 구현
                              },
                              onLongPress: () {
                                // todo: 롱터치시 메모 삭제 구현
                              },
                              child: Text(memos[index].content),
                            ),
                          ),
                        ),
                        header: Text(memos[index].title),
                        footer: Text(memos[index].createTime.substring(0, 10)),
                      ),
                    );
                  },
                  itemCount: memos.length,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MemoAddPage(reference!)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
