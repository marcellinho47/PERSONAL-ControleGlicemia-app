import 'dart:convert';
import 'dart:io';

import 'package:minha_glicemia/entity/marcacaoEntity.dart';
import 'package:path_provider/path_provider.dart';

class MarcacaoRepository {
  Future<String> localPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> localFile() async {
    final path = await localPath();
    return File("$path/dataMarcacoes.json");
  }

  void createFile() {
    localFile().then((file) => {
          if (!file.existsSync()) {file.create()}
        });
  }

  Future<File> saveData(List<Marcacao> listMarcacoes) async {
    String data = json.encode(listMarcacoes.map((e) => e.toJson()).toList());
    File file = await localFile();

    return file.writeAsString(data);
  }

  Future<String> getData() async {
    try {
      File file = await localFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
