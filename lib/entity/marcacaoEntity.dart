import "package:intl/intl.dart";

class Marcacao {
  //Variables -----------------------------------------------------
  int id;
  int refeicao;
  int glicemia;
  DateTime dataMedicao;
  DateTime dataHoraInclusao;

  //Constructor -----------------------------------------------------
  Marcacao(
      {this.refeicao, this.glicemia, this.dataMedicao, this.dataHoraInclusao}) {
    if (this.dataHoraInclusao == null) {
      this.dataHoraInclusao = DateTime.now();
    }
  }

  Marcacao.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        refeicao = json['refeicao'],
        glicemia = json['glicemia'],
        dataMedicao = DateTime.fromMillisecondsSinceEpoch(json['dataMedicao']),
        dataHoraInclusao =
            DateTime.fromMillisecondsSinceEpoch(json['dataHoraInclusao']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'refeicao': refeicao,
        'glicemia': glicemia,
        'dataMedicao': dataMedicao.millisecondsSinceEpoch,
        'dataHoraInclusao': dataHoraInclusao.millisecondsSinceEpoch
      };

  @override
  String toString() {
    return "\n\tID: $id\n\tRefeição: " +
        Refeicao.getRefeicaoById(refeicao) +
        "\n\tGlicemia: $glicemia\n\tData da Medição: " +
        DateFormat("dd-MM-yyyy").format(dataMedicao) +
        "\n\tDataHora de Inclusão " +
        DateFormat("dd-MM-yyyy hh:mm").format(dataMedicao);
  }
}

abstract class Refeicao {
  static const CAFE = "Café da Manhã";
  static const ALMOCO = "Almoço";
  static const JANTAR = "Jantar";

  static String getRefeicaoById(int id) {
    switch (id) {
      case 1:
        return "Café da Manhã";
        break;

      case 2:
        return "Almoço";
        break;

      case 3:
        return "Jantar";
        break;
    }
    return "";
  }

  static int getIDByRefeicao(String refeicao) {
    switch (refeicao) {
      case CAFE:
        return 1;
        break;

      case ALMOCO:
        return 2;
        break;

      case JANTAR:
        return 3;
        break;
    }
    return 0;
  }
}
