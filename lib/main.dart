import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:minha_glicemia/entity/marcacaoEntity.dart';
import 'package:minha_glicemia/repository/marcacaoRepository.dart';

/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */
/* MAIN */
/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */
void main() {
  runApp(MaterialApp(
      theme: ThemeData(primaryColor: Colors.black),
      title: "Welcome",
      home: MyApp(
        marcacaoRepository: MarcacaoRepository(),
      )));
}

class MyApp extends StatefulWidget {
  final MarcacaoRepository marcacaoRepository;

  MyApp({Key key, this.marcacaoRepository}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();

    widget.marcacaoRepository.createFile();
    widget.marcacaoRepository.localPath().then((value) => {print(value)});
  }

  List<Widget> _options = <Widget>[
    Historico(marcacaoRepository: MarcacaoRepository()),
    Marcar(marcacaoRepository: MarcacaoRepository()),
    Medias(marcacaoRepository: MarcacaoRepository())
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(148, 210, 189, 1.0),
        body: _options.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Color.fromRGBO(148, 210, 189, 1.0),
          unselectedItemColor: Colors.black38,
          fixedColor: Colors.black,
          currentIndex: _selectedIndex,
          onTap: _onItemTap,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_outlined), label: "Histórico"),
            BottomNavigationBarItem(
                icon: Icon(Icons.library_add_check_outlined), label: "Marcar"),
            BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined), label: "Médias")
          ],
        ));
  }
}

/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */
/* TOAST */
/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */
void _showErrorToast(BuildContext context, String msgError) {
  dynamic scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            color: Colors.black,
          ),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          Text(
            msgError,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 14.0),
          )
        ],
      ),
      duration: Duration(seconds: 5),
      backgroundColor: Colors.yellow,
      behavior: SnackBarBehavior.floating,
      width: 240.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25))),
    ),
  );
}

void _showSucessToast(BuildContext context) {
  dynamic scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline_outlined,
            color: Colors.black,
          ),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          Text(
            'Salvo!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 14.0),
          ),
        ],
      ),
      duration: Duration(seconds: 3),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      width: 120.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25))),
    ),
  );
}

/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */
/* MARCAR */
/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */
class Marcar extends StatefulWidget {
  final MarcacaoRepository marcacaoRepository;

  const Marcar({Key key, this.marcacaoRepository}) : super(key: key);

  @override
  _MarcarState createState() => _MarcarState();
}

class _MarcarState extends State<Marcar> {
  /* ---------------------------------------- */
  /* GLOBAL */
  /* ---------------------------------------- */
  // Variables
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Marcacao> listMarcacoes;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  void loadInitialData() {
    widget.marcacaoRepository.getData().then((value) {
      setState(() {
        if (value.isEmpty) {
          listMarcacoes = [];
        } else {
          List<dynamic> decode = json.decode(value);
          listMarcacoes = decode.map((e) => Marcacao.fromJson(e)).toList();
          dropdownInitialValue();
        }
      });
    });
  }

  /* ---------------------------------------- */
  /* TEXT - GLICEMIA */
  /* ---------------------------------------- */
  TextEditingController glicemiaController = TextEditingController();

  /* ---------------------------------------- */
  /* DROPDOWN - Refeição */
  /* ---------------------------------------- */
  List<String> dropdownValues = ['Café da Manhã', 'Almoço', 'Jantar'];
  String dropdownValue;

  void dropdownInitialValue() {
    List<int> auxRefeicao = [];
    listMarcacoes.forEach((marc) {
      if (DateFormat("dd-MM-yyyy").format(marc.dataMedicao) ==
          DateFormat("dd-MM-yyyy").format(DateTime.now())) {
        auxRefeicao.add(marc.refeicao);
        dropdownValues.remove(Refeicao.getRefeicaoById(marc.refeicao));
      }
    });

    if (!auxRefeicao.contains(1)) {
      dropdownValue = "Café da Manhã";
    } else if (!auxRefeicao.contains(2)) {
      dropdownValue = "Almoço";
    } else if (!auxRefeicao.contains(3)) {
      dropdownValue = "Jantar";
    } else {
      dropdownValue = null;
    }
  }

  /* ---------------------------------------- */
  /* BOTAO - Salvar */
  /* ---------------------------------------- */
  void _save() {
    Marcacao marc = Marcacao();
    marc.refeicao = Refeicao.getIDByRefeicao(dropdownValue);
    marc.glicemia = int.parse(glicemiaController.value.text);
    marc.dataMedicao = DateTime.now();

    if (listMarcacoes.isEmpty) {
      marc.id = 1;
    } else {
      int auxMaxID = 0;
      listMarcacoes.forEach((element) {
        if (element.id > auxMaxID) {
          auxMaxID = element.id;
        }
      });
      marc.id = auxMaxID + 1;
    }

    listMarcacoes.add(marc);
    widget.marcacaoRepository.saveData(listMarcacoes);

    _resetFields();
  }

  bool _isFormValid() {
    bool isExistRefeicao = false;
    listMarcacoes.forEach((marc) {
      if (DateFormat("dd-MM-yyyy").format(marc.dataMedicao) ==
              DateFormat("dd-MM-yyyy").format(DateTime.now()) &&
          Refeicao.getRefeicaoById(marc.refeicao) == dropdownValue) {
        isExistRefeicao = true;
      }
    });

    return !isExistRefeicao;
  }

  void _resetFields() {
    glicemiaController.value = TextEditingValue.empty;
    dropdownValue = null;
    loadInitialData();
    setState(() {
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Form(
          key: _formKey,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0)),
              ),
              value: dropdownValue,
              elevation: 0,
              isExpanded: true,
              iconSize: 30.0,
              icon: Icon(
                Icons.arrow_drop_down_circle_outlined,
                color: Colors.black,
              ),
              items:
                  dropdownValues.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Center(
                    child: Text(value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 1),
                          fontSize: 24.0,
                        )),
                  ),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              hint: Center(
                child: Text(
                  "Refeição",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.2),
                    fontSize: 24.0,
                  ),
                ),
              ),
              validator: (value) {
                if (dropdownValues.isNotEmpty &&
                    (value == null || value.isEmpty)) {
                  return "Escolha a refeição";
                }
                return null;
              },
              style: TextStyle(
                fontSize: 24.0,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
              dropdownColor: Color.fromRGBO(255, 255, 255, 1),
            ),
            Padding(padding: EdgeInsets.only(top: 30.0)),
            TextFormField(
              decoration: InputDecoration(
                hintText: "5-600",
                hintStyle: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.2), fontSize: 24.0),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(0, 0, 0, 0.2), width: 1),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              validator: (value) {
                if (dropdownValues.isEmpty) {
                  return null;
                } else if (value == null || value.isEmpty) {
                  return 'Informe o valor da glicemia!';
                } else if (int.parse(value) <= 4 || int.parse(value) > 600) {
                  return 'Valor inválido!';
                }
                return null;
              },
              enabled: dropdownValues.isNotEmpty,
              autocorrect: false,
              enableSuggestions: false,
              showCursor: false,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofocus: false,
              style:
                  TextStyle(color: Color.fromRGBO(0, 0, 0, 1), fontSize: 24.0),
              controller: glicemiaController,
            ),
            Padding(padding: EdgeInsets.only(top: 30.0)),
            OutlinedButton(
                child: Text(
                  "Salvar",
                  style: TextStyle(fontSize: 24.0, color: Colors.black),
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    if (!_isFormValid()) {
                      _showErrorToast(
                          context, "Refeição já informada para hoje!");
                    } else if (dropdownValues.isEmpty) {
                      _showErrorToast(
                          context, "Todas as marcações já foram informadas!");
                    } else {
                      _save();
                      _showSucessToast(context);
                    }
                  }
                },
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.fromLTRB(40, 15, 40, 15)),
                    side: MaterialStateProperty.all<BorderSide>(
                        BorderSide(color: Colors.black)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ))))
          ]),
        ));
  }
}

/* -------------------------------------------------------------------------------- */
/* HISTORICO */
/* -------------------------------------------------------------------------------- */
class Historico extends StatefulWidget {
  final MarcacaoRepository marcacaoRepository;

  const Historico({Key key, this.marcacaoRepository}) : super(key: key);

  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State<Historico> {
  List<Marcacao> listMarcacoes;
  List<Map<String, dynamic>> listMarcacoesGrid;

  @override
  void initState() {
    super.initState();
    listMarcacoesGrid = [];

    // Trazendo lista do banco
    widget.marcacaoRepository.getData().then((value) {
      setState(() {
        List<dynamic> decode = json.decode(value);
        listMarcacoes = decode.map((e) => Marcacao.fromJson(e)).toList();
        loadInitialData();
      });
    });
  }

  void loadInitialData() {
    List<Map<String, dynamic>> listMarcacoesGridTemp = [];

    // Buscando menorData
    DateTime menorData = DateTime.now();
    DateTime maiorData = DateTime.now();

    listMarcacoes.forEach((element) {
      if (element.dataMedicao.isBefore(menorData)) {
        menorData = element.dataMedicao;
      }
    });

    // Criando lista de datas antes de hoje
    while (!(DateFormat('dd/MM/yyyy').format(maiorData) ==
        DateFormat('dd/MM/yyyy').format(menorData))) {
      Map<String, dynamic> map = Map();
      map.putIfAbsent("data", () => menorData);
      map.putIfAbsent("cafe", () => "");
      map.putIfAbsent("almoco", () => "");
      map.putIfAbsent("jantar", () => "");

      listMarcacoes.forEach((element) {
        if ((DateFormat('dd/MM/yyyy').format(element.dataMedicao) ==
            DateFormat('dd/MM/yyyy').format(menorData))) {
          switch (element.refeicao) {
            case 1:
              map["cafe"] = element.glicemia.toString();
              break;
            case 2:
              map["almoco"] = element.glicemia.toString();
              break;
            case 3:
              map["jantar"] = element.glicemia.toString();
              break;
          }
        }
      });

      listMarcacoesGridTemp.add(map);
      menorData = menorData.add(Duration(days: 1));
    }

    // Adicionando o dia atual
    Map<String, dynamic> map = Map();
    map["data"] = DateTime.now();
    listMarcacoes.forEach((element) {
      if ((DateFormat('dd/MM/yyyy').format(element.dataMedicao) ==
          DateFormat('dd/MM/yyyy').format(DateTime.now()))) {
        switch (element.refeicao) {
          case 1:
            map["cafe"] = element.glicemia.toString();
            break;
          case 2:
            map["almoco"] = element.glicemia.toString();
            break;
          case 3:
            map["jantar"] = element.glicemia.toString();
            break;
        }
      }
    });
    listMarcacoesGridTemp.add(map);

    listMarcacoesGridTemp.sort((b, a) {
      return a['data'].compareTo(b['data']);
    });

    // Adicionando cabecalho na lista
    _addTitleListGrid();

    // Convertendo listaTemp em Grid
    listMarcacoesGridTemp.forEach((element) {
      // Adicionando data
      Map<String, dynamic> map = Map();
      map['value'] = DateFormat("dd/MM").format(element['data']);
      map['fontWeight'] = FontWeight.bold;
      map['colorBackground'] = Color.fromRGBO(148, 210, 189, 1.0);
      map['colorFont'] = null;
      listMarcacoesGrid.add(map);

      // cafe
      map = Map();
      map['value'] = element['cafe'] ?? '';
      map['fontWeight'] = null;
      map['colorBackground'] = colorBackground(element['cafe']);
      map['colorFont'] = null;
      listMarcacoesGrid.add(map);

      // almoco
      map = Map();
      map['value'] = element['almoco'] ?? '';
      map['fontWeight'] = null;
      map['colorBackground'] = colorBackground(element['almoco']);
      map['colorFont'] = null;
      listMarcacoesGrid.add(map);

      // jantar
      map = Map();
      map['value'] = element['jantar'] ?? '';
      map['fontWeight'] = null;
      map['colorBackground'] = colorBackground(element['jantar']);
      map['colorFont'] = null;
      listMarcacoesGrid.add(map);
    });
  }

  void _addTitleListGrid() {
    Color corTitle = Color.fromRGBO(148, 210, 189, 1.0);

    // Adicionando cabecalho
    Map<String, dynamic> map = Map();
    map['value'] = '';
    map['fontWeight'] = FontWeight.bold;
    map['colorBackground'] = corTitle;
    map['colorFont'] = null;
    listMarcacoesGrid.add(map);

    map = Map();
    map['value'] = 'Café';
    map['fontWeight'] = FontWeight.bold;
    map['colorBackground'] = corTitle;
    map['colorFont'] = null;
    listMarcacoesGrid.add(map);

    map = Map();
    map['value'] = 'Almoço';
    map['fontWeight'] = FontWeight.bold;
    map['colorBackground'] = corTitle;
    map['colorFont'] = null;
    listMarcacoesGrid.add(map);

    map = Map();
    map['value'] = 'Jantar';
    map['fontWeight'] = FontWeight.bold;
    map['colorBackground'] = corTitle;
    map['colorFont'] = null;
    listMarcacoesGrid.add(map);
  }

  static Color colorBackground(String auxGlicemia) {
    if (auxGlicemia == null || auxGlicemia.isEmpty) {
      return null;
    }

    int glicemia = int.parse(auxGlicemia);

    // BRANCO - Bom
    if (glicemia >= 80 && glicemia <= 170) {
      return Color.fromRGBO(255, 255, 255, 1);
    }

    // VERMELHO - Alto - Hiperglicemia
    if (glicemia >= 170) {
      Color red1 = Color.fromRGBO(246, 42, 64, 1);
      Color red10 = Color.fromRGBO(247, 93, 115, 1);

      Color lerp = Color.lerp(red10, red1, glicemia / 600);
      return lerp;
    }

    // AZUL - Baixo - Hipoglicemia
    if (glicemia <= 40) {
      return Color.fromRGBO(0, 39, 90, 1.0);
    }

    // AZUL - Baixo - Hipoglicemia
    if (glicemia > 40 && glicemia < 80) {
      Color blue1 = Color.fromRGBO(0, 39, 90, 1.0);
      Color blue10 = Color.fromRGBO(255, 255, 255, 1.0);

      Color lerp = Color.lerp(blue10, blue1, 40.0 / glicemia.toDouble());
      return lerp;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        alignment: Alignment.topCenter,
        child: GridView.count(
          childAspectRatio: 16 / 8,
          physics: BouncingScrollPhysics(),
          crossAxisCount: 4,
          shrinkWrap: true,
          children: List.generate(listMarcacoesGrid.length, (index) {
            return Container(
                decoration: BoxDecoration(
                  color: listMarcacoesGrid[index]['colorBackground'] ??
                      Color.fromRGBO(106, 106, 106, 1.0),
                  border: Border.all(
                    width: 0.3,
                    color: Colors.black,
                  ),
                ),
                child: Center(
                  child: Text(
                    listMarcacoesGrid[index]['value'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.0,
                      color:
                          listMarcacoesGrid[index]['colorFont'] ?? Colors.black,
                      fontWeight: listMarcacoesGrid[index]['fontWeight'] ??
                          FontWeight.normal,
                    ),
                  ),
                ));
          }),
        ));
  }
}

/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */
/* MEDIAS */
/* ---------------------------------------------------------------------------------------------------------------------------------------------------------------- */
class Medias extends StatefulWidget {
  final MarcacaoRepository marcacaoRepository;

  const Medias({Key key, this.marcacaoRepository}) : super(key: key);

  @override
  _MediasState createState() => _MediasState();
}

class _MediasState extends State<Medias> {
  /* ---------------------------------------- */
  /* GLOBAL */
  /* ---------------------------------------- */
  // Variables
  List<Marcacao> listMarcacoes;
  int mediaCafe = 0;
  int mediaAlmoco = 0;
  int mediaJantar = 0;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  void loadInitialData() {
    widget.marcacaoRepository.getData().then((value) {
      setState(() {
        List<dynamic> decode = json.decode(value);
        listMarcacoes = decode.map((e) => Marcacao.fromJson(e)).toList();
        calcMedias(listMarcacoes);
      });
    });
  }

  void calcMedias(List<Marcacao> listMarcacoes) {
    double sumCafe = 0.0, sumAlmoco = 0.0, sumJantar = 0.0;
    int countCafe = 0, countAlmoco = 0, countJantar = 0;

    listMarcacoes.forEach((element) {
      switch (element.refeicao) {
        case 1:
          sumCafe += element.glicemia;
          countCafe++;
          break;
        case 2:
          sumAlmoco += element.glicemia;
          countAlmoco++;
          break;
        case 3:
          sumJantar += element.glicemia;
          countJantar++;
          break;
      }
    });

    if (countCafe > 0) {
      mediaCafe = sumCafe ~/ countCafe;
    }
    if (countAlmoco > 0) {
      mediaAlmoco = sumAlmoco ~/ countAlmoco;
    }
    if (countJantar > 0) {
      mediaJantar = sumJantar ~/ countJantar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Café",
              style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Container(
                width: 80,
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: _HistoricoState.colorBackground(mediaCafe.toString()),
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(
                    width: 0.3,
                    color: Colors.black,
                  ),
                ),
                child: Center(
                  child: Text(
                    mediaCafe.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                )),
            Padding(padding: EdgeInsets.all(20.0)),
            Text(
              "Almoço",
              style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            Container(
                width: 80,
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color:
                      _HistoricoState.colorBackground(mediaAlmoco.toString()),
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(
                    width: 0.3,
                    color: Colors.black,
                  ),
                ),
                child: Center(
                  child: Text(
                    mediaAlmoco.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                )),
            Padding(padding: EdgeInsets.all(20.0)),
            Text("Jantar",
                style: TextStyle(
                    fontSize: 24.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(5.0)),
            Container(
                width: 80,
                padding: EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color:
                      _HistoricoState.colorBackground(mediaJantar.toString()),
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(
                    width: 0.3,
                    color: Colors.black,
                  ),
                ),
                child: Center(
                  child: Text(
                    mediaJantar.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
