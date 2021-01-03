import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey SingleChildScrollViewVertical = GlobalKey();
  GlobalKey _ContainerVertical = GlobalKey();

  List<ItemBox> listItemBox = new List<ItemBox>();
  ScrollController _scrollController = ScrollController();
  String BoxSel = '';
  double sizeApp = 0;
  int indexBox = 0;

  double utilGetHeigth(GlobalKey _globalKey) {
    final RenderBox cardBox = _globalKey.currentContext.findRenderObject();
    final size = cardBox.size;

    return size.height;
  }

  Offset utilGetPositionLocalY(GlobalKey _globalKey, Offset offset) {
    final RenderBox cardBox = _globalKey.currentContext.findRenderObject();
    final positionrenderscrollProdutos = cardBox.globalToLocal(offset);

    return positionrenderscrollProdutos;
  }

  @override
  void initState() {
    // TODO: implement initState

    addList();
    super.initState();

    _scrollController.addListener(() async {
      // Rotina de sincronização dos SingleChildScrollView Vertical e Horizontal
      // Esta rotina é disparada toda vez que o SingleChildScrollViewVertical é movimentado.

      BoxSel = '';

      final RenderBox renderscrollProdutos = SingleChildScrollViewVertical.currentContext.findRenderObject();
      final positionrenderscrollProdutos = renderscrollProdutos.localToGlobal(Offset.zero);

      //temp - gerando valores posision de cada box...
      for (var i = 0; i < listItemBox.length; ++i) {
        ItemBox item = listItemBox[i];
        final positionCard = utilGetPositionLocalY(item.globalKeyVertical, positionrenderscrollProdutos);
        BoxSel = BoxSel + item.nome + ': ' + positionCard.dy.truncate().toString() + ' - ';
      }

      //Gerando o index atual....
      int index = 0;

      for (var i = 0; i < listItemBox.length - 1; ++i) {
        final RenderBox cardBox = listItemBox[i].globalKeyVertical.currentContext.findRenderObject();
        final positionCard = cardBox.globalToLocal(positionrenderscrollProdutos);
        final size = cardBox.size;

        if (positionCard.dy - (size.height / 2) <= 0) break;

        index++;
      }

      await setState(() {
        indexBox = index;
      });
      Scrollable.ensureVisible(listItemBox[indexBox].globalKeyHorizontal.currentContext, duration: Duration(milliseconds: 200));
    });
  }

  addList() {
    listItemBox = new List<ItemBox>();

    add(String _nome, double _height) {
      ItemBox itemBox = ItemBox();

      itemBox.nome = _nome;
      itemBox._height = _height;

      listItemBox.add(itemBox);
    }

    add('Box 1', 160);
    add('Box 2', 260);
    add('Box 3', 30);
    add('Box 4', 100);
    add('Box 5', 260);
    add('Box 6', 200);
    add('Box 7', 160);
    add('Box 8', 160);
    add('Box 9', 100);
    add('Box 10', 190);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScrollView();
  }

  ScrollView() {
    return new Scaffold(
      primary: true,
      appBar: new AppBar(
        title: GestureDetector(onTap: addList(), child: Text('Home')),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < listItemBox.length; ++i)
                      GestureDetector(
                          onTap: () async {
                            await Scrollable.ensureVisible(listItemBox[i].globalKeyVertical.currentContext,
                                duration: Duration(milliseconds: 500));
                            _scrollController.notifyListeners();
                          },
                          child: box(listItemBox[i].nome, 40,
                              globalKey: listItemBox[i].globalKeyHorizontal, width: 100, cor: (i == indexBox) ? Colors.cyan : Colors.white))
                  ],
                )),
          ),
          Text(BoxSel),
          Container(
            key: _ContainerVertical,
            // width: double.infinity,
            // height: 200,
            child: Expanded(
              child: SingleChildScrollView(
                  key: SingleChildScrollViewVertical,
                  // scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  child: Column(
                    children: [
                      for (var i = 0; i < listItemBox.length; ++i)
                        box(listItemBox[i].nome, listItemBox[i]._height, globalKey: listItemBox[i].globalKeyVertical),
                      Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 1.5),
                      )
                      // Padding(padding: EdgeInsets.only(top: MediaQuery.of(context).size.height),)
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }

  box(String title, double _height, {GlobalKey globalKey, double width = double.infinity, Color cor = Colors.white}) {
    return SizedBox(key: globalKey, height: _height, width: width, child: new Card(color: cor, child: Center(child: Text(title))));
  }
}

class ItemBox {
  String nome;
  double _height = 0;
  double bottomPadding = 0;

  GlobalKey globalKeyHorizontal = GlobalKey();
  GlobalKey globalKeyVertical = GlobalKey();
}
