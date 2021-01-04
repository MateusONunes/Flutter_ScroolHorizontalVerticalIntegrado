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
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey _SingleChildScrollViewVertical = GlobalKey();
  ScrollController _SingleChildScrollViewVerticalscrollController = ScrollController();

  List<ItemBox> listItemBox = new List<ItemBox>();
  String BoxSel = '';
  int indexBox = 0; // Esta variável controla "Qual a Box está selecionada"

  Offset utilGetPositionLocalY(GlobalKey _globalKey, Offset offset) {
    //Retorna a Coordenada Y de um Wideget
    final RenderBox cardBox = _globalKey.currentContext.findRenderObject();
    final positionrenderscrollProdutos = cardBox.globalToLocal(offset);

    return positionrenderscrollProdutos;
  }

  @override
  void initState() {
    addList();
    super.initState();

    _SingleChildScrollViewVerticalscrollController.addListener(() async {
      //*** Rotina de sincronização dos SingleChildScrollView Vertical e Horizontal
      //*** Esta rotina é disparada toda vez que o SingleChildScrollViewVertical é movimentado.
      // O PRINCIPAL OBJETIVO desta rotina é definir um valor para a variável global indexBox, ou seja
      // Definir qual a box está selecionada, e para isto ela vai identificar qual a Box
      // está visualmente NO COMEÇO (NA PARTE SUPERIOR) DO _SingleChildScrollViewVertical
      BoxSel = '';

      final RenderBox renderscrollVertical = _SingleChildScrollViewVertical.currentContext.findRenderObject();
      final positionrenderscrollVertical = renderscrollVertical.localToGlobal(Offset.zero);

      //Gerando valores position de cada box...
      for (var i = 0; i < listItemBox.length; ++i) {
        ItemBox item = listItemBox[i];
        final positionCard = utilGetPositionLocalY(item.Card_SingleChildScrollViewVertical, positionrenderscrollVertical);
        BoxSel = BoxSel + item.nome + ': ' + positionCard.dy.truncate().toString() + ' - ';
      }

      //Gerando o index atual(index da Box que está na parte superior do
      // SingleChildScrollViewVertical, ou seja a box que "está selecionada"....
      int index = 0;

      for (var i = 0; i < listItemBox.length; ++i) {
        //Este loop é o principal desta rotina. Basicamente ele vai parar no primeiro card que está no
        // comecinho(Visualmente falando) do size_SingleChildScrollViewVertical definindo assim o valor que será atribuído
        // para a variável _indexCategoriaSelecionada

        final RenderBox cardBox = listItemBox[i].Card_SingleChildScrollViewVertical.currentContext.findRenderObject();
        final positionCard = cardBox.globalToLocal(positionrenderscrollVertical);
        final size = cardBox.size;

        // O Primeiro card que eu encontrar que possuir o .dy Maior que zero é o "Card mais próximo da parte superiora do _SingleChildScrollViewVertical
        if (positionCard.dy <= 0) break;

        index++;
      }

      if (index > 0) index--;

      await setState(() {
        indexBox = index;
      });

      //Sincronizando o SingleChildScrollViewHorizontal de acordo com o indexBox (De acordo com a "Box Selecionada"
      Scrollable.ensureVisible(listItemBox[indexBox].Card_SingleChildScrollViewHorizontal.currentContext,
          duration: Duration(milliseconds: 200), alignment: 0.5);
    });
  }

  addList() {
    //*** Rotina para Alimentar o list com as caixas que serão exibidas
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
    return Scaffold(
      primary: true,
      appBar: new AppBar(
        title: Column(
          children: [
            Text('SingleChildScrollView Vertical/Horizontal integrado', style: TextStyle(fontSize: 16)),
            Text('Git: @MateusONunes', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: SingleChildScrollView(
                //** SingleChildScrollView Que fica na horizontal na paret superior do App.
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < listItemBox.length; ++i)
                      GestureDetector(
                          onTap: () async {
                            await Scrollable.ensureVisible(listItemBox[i].Card_SingleChildScrollViewVertical.currentContext,
                                duration: Duration(milliseconds: 500), alignment: 0.01);

                            _SingleChildScrollViewVerticalscrollController.notifyListeners();
                          },
                          child: SizedBox(
                              key: listItemBox[i].Card_SingleChildScrollViewHorizontal,
                              height: 40,
                              width: 100,
                              child: new Card(
                                  color: (i == indexBox) ? Colors.cyan : Colors.white, child: Center(child: Text(listItemBox[i].nome)))))
                  ],
                )),
          ),
          Text(BoxSel),
          Container(
            child: Expanded(
              child: SingleChildScrollView(
                  key: _SingleChildScrollViewVertical,
                  controller: _SingleChildScrollViewVerticalscrollController,
                  child: Column(
                    children: [
                      for (var _itemBox in listItemBox)
                        SizedBox(
                            key: _itemBox.Card_SingleChildScrollViewVertical,
                            height: _itemBox._height,
                            child: new Card(child: Center(child: Text(_itemBox.nome)))),

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
}

class ItemBox {
  String nome;
  double _height = 0;
  double bottomPadding = 0;

  GlobalKey Card_SingleChildScrollViewHorizontal = GlobalKey();
  GlobalKey Card_SingleChildScrollViewVertical = GlobalKey();
}
