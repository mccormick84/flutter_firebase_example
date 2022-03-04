import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';

class TabsPage extends StatefulWidget {
  TabsPage(this.observer);

  final FirebaseAnalyticsObserver observer;

  @override
  State<StatefulWidget> createState() => _TabsPage(observer);
}

class _TabsPage extends State<TabsPage>
    with SingleTickerProviderStateMixin, RouteAware {
  _TabsPage(this.observer);

  final FirebaseAnalyticsObserver observer;
  TabController? _controller;
  int selectedIndex = 0;

  final List<Tab> tabs = <Tab>[
    const Tab(
      text: '1번',
      icon: Icon(Icons.looks_one),
    ),
    const Tab(
      text: '2번',
      icon: Icon(Icons.looks_two),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      vsync: this,
      length: tabs.length,
      initialIndex: selectedIndex,
    );

    _controller!.addListener(() {
      setState(() {
        if (selectedIndex != _controller!.index) {
          selectedIndex = _controller!.index;
          _sendCurrentTab();
        }
      });
    });
  }

  // fireAnalyticsObserver 사용을 앱에 전달(구독)
  // didChangeDependencies(): initState() 함수 다음에 상태에 변화가 생겼을 때 호출
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    observer.subscribe(this, ModalRoute.of(context) as dynamic);
  }

  // 현재 화면 이름을 fb애널리틱스에 전달: 사용자가 화면 접근 빈도를 알 수 있음
  void _sendCurrentTab() {
    observer.analytics.setCurrentScreen(screenName: 'tab/$selectedIndex');
  }

  @override
  void dispose() {
    observer.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _controller,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: tabs.map((Tab tab) {
          return Center(
            child: Text(tab.text!),
          );
        }).toList(),
      ),
    );
  }
}
